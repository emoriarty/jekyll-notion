# frozen_string_literal: true

module JekyllNotion
  class DataGenerator < AbstractGenerator
    def generate
      @site.data[@notion_resource.data] = data
      # Caching current data
      @plugin.data[@notion_resource.data] = data
    end

    private

    def data
      begin
        @data ||= @notion_resource.pages.map(&:props)
      rescue Notion::Api::Errors::NotionError
        # it's not a database, fetch a page
        @data ||= @notion_resource.page.map(&:props)
      end
    end

    def log_pages
      @notion_resource.pages.each do |page|
        Jekyll.logger.info("Jekyll Notion:", "Page => #{page.title}")
        Jekyll.logger.debug("", "Props => #{page.props.keys.inspect}")
      end
    end
  end
end
