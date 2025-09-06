# frozen_string_literal: true

module JekyllNotion
  module Generators
    class Page < Support::Generator
      def call
        if config["data"].nil?
          notion_pages.each { |notion_page| generate_page(notion_page) }
        else
          Data.call(:config => config, :site => site,
                    :notion_pages => notion_pages)
        end
      end

      private

      def generate_page(notion_page)
        return if page_exists?(notion_page)

        page = make_page(notion_page)

        @site.pages << page

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

      def page_exists?(notion_page)
        page_exists = site.pages.any? do |page|
          page.data["title"].downcase == notion_page.title.downcase
        end

        if page_exists
          Jekyll.logger.warn("Jekyll Notion:",
                             "Page `#{notion_page.title}` exists — skipping Notion import.")
        end

        page_exists
      end
    end
  end
end
