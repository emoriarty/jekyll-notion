# frozen_string_literal: true

module JekyllNotion
  module Generators
    class Data < Generator
      # pages => Array of NotionToMd::Page
      def call
        data = if notion_pages.size > 1
                 notion_pages.map do |page|
                   page.send(:frontmatter_properties).merge({ "content" => convert(page) })
                 end
               else
                 notion_pages.first.send(:frontmatter_properties).merge({ "content" => convert(notion_pages.first) })
               end

        @site.data[config["data"]] = data

        log_data(data)
      end

      protected

      # Convert the notion page body using the site.converters.
      #
      # Returns String the converted content.
      def convert(page)
        converters.reduce(page.body) do |output, converter|
          converter.convert(output)
        rescue StandardError => e
          Jekyll.logger.error "Conversion error:",
                              "#{converter.class} encountered an error while " \
                              "converting notion page '#{page.title}':"
          Jekyll.logger.error("", e.to_s)
          raise e
        end
      end

      def converters
        @converters ||= @site.converters.select { |c| c.matches(".md") }.tap(&:sort!)
      end

      def log_data(data)
        if data.is_a?(Array)
          data.each { |page| _log_data(page, Array.to_s) }
        else
          _log_data(data, Hash.to_s)
        end
      end

      def _log_data(page, type)
        Jekyll.logger.info("Jekyll Notion:", "Page => #{page["title"]}")
        Jekyll.logger.info("", "#{type} => site.data.#{config["data"]}")
        Jekyll.logger.debug("", "Props => #{page.keys.inspect}")
      end
    end
  end
end
