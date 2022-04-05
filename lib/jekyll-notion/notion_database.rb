# frozen_string_literal: true

module JekyllNotion
  class NotionDatabase < AbstractNotionResource
    # Returns an empty array or a NotionToMd:Page array
    def fetch
      return [] unless id?

      @fetch ||= @notion.database_query(query)[:results].map do |page|
        NotionToMd::Page.new(:page => page, :blocks => @notion.block_children(:block_id => page.id))
      end
    end

    def filter
      config["filter"]
    end

    def sorts
      if config["sort"]
        Jekyll.logger.warn("Jekyll Notion:", "sort property is deprecated, use sorts instead")
      end
      config["sorts"]
    end

    def collection_name
      config["collection"] || "posts"
    end

    def data_name
      config["data"]
    end

    private

    def query
      { :database_id => id, :filter => filter, :sorts => sorts }.compact
    end
  end
end
