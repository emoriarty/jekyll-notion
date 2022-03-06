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

    protected

    def id?
      if id.nil? || id.empty?
        Jekyll.logger.warn("Jekyll Notion:",
                           "Database or page id is not provided. Cannot read from Notion.")
        return false
      end
      true
    end
  end
end
