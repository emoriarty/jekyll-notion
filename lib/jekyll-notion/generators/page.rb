# frozen_string_literal: true

module JekyllNotion
  module Generators
    class Page < Support::Generator
      def call
        if config["data_name"].nil?
          notion_pages.each { |notion_page| generate_page(notion_page) }
        else
          DataGenerator.call(config: config, site: site, plugin: plugin, notion_pages: notion_pages)
        end
      end

      private

      def generate_page(notion_page)
        # TODO: check if file exists to prevent overwriting an existing page
        # next if file_exists?(make_path(page))

        page = make_page(notion_page)

        @site.pages << page
        @plugin.pages << page

        log_page(notion_page)
      end

      def make_page(notion_page)
        JekyllNotion::PageWithoutAFile.new(@site, @site.source, "", "#{notion_page.title}.md",
                                           notion_page.to_md)
      end

      def log_page(notion_page)
        Jekyll.logger.info("Jekyll Notion:", "Page => #{notion_page.title}")
        Jekyll.logger.info("", "URL => #{@site.pages.last.url}")
        Jekyll.logger.debug("", "Props => #{notion_page.properties.keys.inspect}")
      end
    end
  end
end
