# frozen_string_literal: true

module JekyllNotion
  class DataGenerator < AbstractGenerator
    def generate
      unless data.nil?
        @site.data[@notion_resource.data_name] = data
        # Caching current data in Generator instance (plugin)
        @plugin.data[@notion_resource.data_name] = data
        log_pages
      end
    end

    private

    def data
      @data ||= if @notion_resource.is_a?(NotionDatabase)
                  pages = @notion_resource.fetch
                  pages.map { |page| page.props.merge({ "content" => convert(page) }) }
                else
                  page = @notion_resource.fetch
                  page&.props&.merge({ "content" => convert(page) })
                end
    end

    # Convert the notion page body using the site.converters.
    #
    # Returns String the converted content.
    def convert(page)
      converters.reduce(page.body) do |output, converter|
        converter.convert output
      rescue StandardError => e
        Jekyll.logger.error "Conversion error:",
                            "#{converter.class} encountered an error while "\
                            "converting notion page '#{page.title}':"
        Jekyll.logger.error("", e.to_s)
        raise e
      end
    end

    def converters
      @converters ||= @site.converters.select { |c| c.matches(".md") }.tap(&:sort!)
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
