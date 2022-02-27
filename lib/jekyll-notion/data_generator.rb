# frozen_string_literal: true

module JekyllNotion
  class DataGenerator < AbstractGenerator
    def generate
      @site.data[@db.data] = data
      # Caching current data
      @plugin.data[@db.data] = data
      log_pages
    end

    private

    def data
      @data ||= @db.pages.map(&:props)
    end

    def log_pages
      @db.pages.each do |page|
        Jekyll.logger.info("Jekyll Notion:", "Page => #{page.title}")
        Jekyll.logger.debug("", "Props => #{page.props.keys.inspect}")
      end
    end
  end
end
