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
        NotionPage.new(:page => page, :layout => layout)
      end
    end

    def config
      @config || {}
    end

    def filter
      config["filter"]
    end

    def sort
      config["sort"]
    end

    def id
      config["id"]
    end

    def frontmatter
      config["frontmatter"] || {}
    end

    def collection
      config["collection"] || "posts"
    end

    def layout
      config["layout"]
    end

    private

    def id?
      if id.nil? || id.empty?
        Jekyll.logger.warn("Jekyll Notion:",
                           "database id is not provided. Cannot read from Notion.")
        return false
      end
      true
    end

    def query
      { :id => id, :filter => filter, :sort => sort }.compact
    end
  end
end
