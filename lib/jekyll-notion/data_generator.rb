# frozen_string_literal: true

module JekyllNotion
  class DataGenerator < AbstractGenerator
    def generate
      unless data.nil?
        @site.data[@notion_resource.data] = data
        # Caching current data in Generator instance (plugin)
        @plugin.data[@notion_resource.data] = data
        log_pages
      end
    end

    private

    def data
      @data ||= if @notion_resource.is_a?(NotionDatabase)
        @notion_resource.fetch.map(&:props)
      else
        @notion_resource.fetch&.props
      end
    end

    def log_pages
      if @notion_resource.is_a?(NotionDatabase)
        @notion_resource.fetch.each do |page|
          Jekyll.logger.info("Jekyll Notion:", "Page => #{page.title}")
          Jekyll.logger.debug("", "Props => #{page.props.keys.inspect}")
        end
      else
        page = @notion_resource.fetch
        Jekyll.logger.info("Jekyll Notion:", "Page => #{page.title}")
        Jekyll.logger.debug("", "Props => #{page.props.keys.inspect}")
      end
    end
  end
end
