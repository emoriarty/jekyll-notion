# frozen_string_literal: true

module JekyllNotion
  class NotionDatabase < AbstractNotionResource
    # Returns an empty array or a NotionToMd:Page array
    def fetch
      return [] unless id?

      @pages ||= @notion.database_query(query)[:results].map do |page|
        NotionToMd::Page.new(:page => page, :blocks => nil)
      end
    end

    def filter
      config["filter"]
    end

    def sort
      config["sort"]
    end

    def collection
      config["collection"] || "posts"
    end

    def data
      config["data"]
    end

    private

    def query
      { :id => id, :filter => filter, :sort => sort }.compact
    end
  end
end
