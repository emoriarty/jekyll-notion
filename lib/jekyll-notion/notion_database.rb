# frozen_string_literal: true

module JekyllNotion
  class NotionDatabase
    def initialize(config:)
      @notion = Notion::Client.new
      @config = config
    end

    def pages
      @pages ||= @notion.database_query(query)[:results].map do |page|
        NotionPage.new(page: page, layout: config['layout'])
      end
      
      return @pages unless block_given?

      @pages.each { |page| yield page }
    end

    private

    def config
      @config['database']
    end

    def filter
      @config.dig('database', 'filter')
    end

    def sort
      @config.dig('database', 'sort')
    end

    def id
      @config.dig('database', 'id')
    end

    def query 
      { id: id, filter: filter, sort: sort }
    end
  end
end
