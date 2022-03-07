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
                  pages = @notion_resource.fetch
                  pages.map { |page| page.props.merge({ "content" => page.body }) }
                else
                  page = @notion_resource.fetch
                  page.props.merge({ "content" => page.body }) unless page.nil?
                end
    end

    def log_pages
      if data.is_a?(Array)
        data.each do |page|
          Jekyll.logger.info("Jekyll Notion:", "Page => #{page["title"]}")
          Jekyll.logger.debug("", "Props => #{page.keys.inspect}")
        end
      else
        Jekyll.logger.info("Jekyll Notion:", "Page => #{data["title"]}")
        Jekyll.logger.debug("", "Props => #{data.keys.inspect}")
      end
    end
  end
end
