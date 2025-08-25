# frozen_string_literal: true

require 'ostruct'

module JekyllNotion
  class AbstractNotionResource
    def initialize(config:)
      @notion = Notion::Client.new
      @config = config
    end

    def config
      @config || {}
    end

    def id
      config["id"]
    end

    def fetch
      raise "Do not use the AbstractNotionResource class. Implement the fetch method in a subclass."
    end

    def collection_name
      raise "Do not use the AbstractGenerator class. Implement the collection_name method in a subclass."
    end

    def data_name
      raise "Do not use the AbstractGenerator class. Implement the data_name method in a subclass."
    end

    protected

    def id?
      if id.nil? || id.empty?
        Jekyll.logger.warn("Jekyll Notion:",
                           "Database or page id is not provided. Cannot read from Notion.")
        return false
      end
      true
    end

    def build_blocks(block_id, page_size: 100)
      fetch_pages = lambda do |nested_id|
        all_results  = []
        start_cursor = nil

        loop do
          params = { block_id: nested_id, page_size: page_size }
          params[:start_cursor] = start_cursor if start_cursor

          resp = @notion.block_children(params)

          # Normalize the notion-ruby-client response (works whether it's a Hash or an object)
          results     = resp.respond_to?(:results)     ? resp.results     : (resp[:results]     || resp['results']     || [])
          has_more    = resp.respond_to?(:has_more)    ? resp.has_more    : (resp[:has_more]    || resp['has_more'])
          next_cursor = resp.respond_to?(:next_cursor) ? resp.next_cursor : (resp[:next_cursor] || resp['next_cursor'])

          all_results.concat(results)

          break unless has_more && next_cursor
          start_cursor = next_cursor
        end

        # Return an object that quacks like the original response (only `.results` is used downstream)
        OpenStruct.new(results: all_results)
      end

      NotionToMd::Blocks.build(:block_id => block_id, &fetch_pages)
    end
  end
end
