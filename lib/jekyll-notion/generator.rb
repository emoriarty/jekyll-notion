# frozen_string_literal: true

module JekyllNotion
  class Generator < Jekyll::Generator
    attr_reader :current_page, :current_db

    def generate(site)
      @site = site

      return unless notion_token? && config?

      if fetch_on_watch? || collections_and_data_empty?
        read_notion_databases
        read_notion_pages
      else
        collections.each_pair { |key, val| @site.collections[key] = val }
        data.each_pair { |key, val| @site.data[key] = val }
      end
    end

    def databases
      config["databases"] || [config["database"]]
    end

    def pages
      config["pages"] || []
    end

    def collections
      @collections ||= {}
    end

    def data
      @data ||= {}
    end

    protected

    def collections_and_data_empty?
      collections.empty? && data.empty?
    end

    def read_notion_databases
      databases.each do |db_config|
        db = NotionDatabase.new(:config => db_config)
        GeneratorFactory.for(:notion_resource => db, :site => @site, :plugin => self).generate
      end
    end

    def read_notion_pages
      pages.each do |page_config|
        page = NotionPage.new(:config => page_config)
        GeneratorFactory.for(:notion_resource => page, :site => @site, :plugin => self).generate
      end
    end

    def config
      @config ||= @site.config["notion"] || {}
    end

    def fetch_on_watch?
      config["fetch_on_watch"] == true
    end

    def notion_token?
      if ENV["NOTION_TOKEN"].nil? || ENV["NOTION_TOKEN"].empty?
        Jekyll.logger.warn("Jekyll Notion:", "NOTION_TOKEN not provided. Cannot read from Notion.")
        return false
      end
      true
    end

    def config?
      if config.empty?
        Jekyll.logger.warn("Jekyll Notion:", "No config provided.")
        return false
      end
      true
    end
  end
end
