# frozen_string_literal: true

module JekyllNotion
  module Generators
    class Page < Generator
      include Collectionable

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
        return if page_exists?(site.pages, notion_page)

        page = make_page(notion_page)

        site.pages << page

        log_page(page)
      end

      def make_page(notion_page)
        JekyllNotion::PageWithoutAFile.new(@site, @site.source, "", "#{notion_page.title}.md",
                                           notion_page.to_md)
      end
    end
  end
end
