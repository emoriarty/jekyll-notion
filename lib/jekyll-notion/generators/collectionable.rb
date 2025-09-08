# frozen_string_literal: true

module JekyllNotion
  module Generators
    module Collectionable
      def page_exists?(collection, notion_page)
        page_exists = collection.any? do |page|
          page.data["title"]&.downcase == notion_page.title.downcase
        end

        if page_exists
          Jekyll.logger.warn("Jekyll Notion:",
                             "Page `#{notion_page.title}` exists — skipping Notion import.")
        end

        page_exists
      end

      def log_page(page)
        Jekyll.logger.info("Jekyll Notion:", "Page => #{page.data["title"]}")
        Jekyll.logger.info("", "URL => #{page.url}")
        Jekyll.logger.debug("", "Props => #{page.data.keys.inspect}")
      end
    end
  end
end
