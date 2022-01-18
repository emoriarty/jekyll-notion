# frozen_string_literal: true

module JekyllNotion
  class NotionDatabase
    def initialize(config:)
      @notion = Notion::Client.new
      @config = config
    end

    def pages
      return [] unless id?

      @pages ||= @notion.database_query(query)[:results].map do |page|
        NotionPage.new(:page => page, :layout => config["layout"])
      end
    end

    private

    def config
      @config["database"]
    end

    def filter
      @config.dig("database", "filter")
    end

    def sort
      @config.dig("database", "sort")
    end

    def id
      @config.dig("database", "id")
    end

    def id?
      if id.nil? || id.empty?
        Jekyll.logger.error("Jekyll Notion:",
                            "database id is not provided. Cannot read from Notion.")
        return false
      end
      true
    end

    def query
      { :id => id, :filter => filter, :sort => sort }
    end
  end
end
