# frozen_string_literal: true

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

    def build_blocks(block_id)
      NotionToMd::Blocks.build(block_id: block_id) do |nested_id|
        @notion.block_children({ :block_id => nested_id })
      end
    end
  end
end
