# frozen_string_literal: true

module JekyllNotion
  class Generator < Jekyll::Generator
    attr_reader :current_page, :current_db

    def generate(site)
      @site = site

      return unless notion_token? && config?

      setup

      if fetch_on_watch? || cache_empty?
        read_notion_databases
        read_notion_pages
      else
        collections.each_pair { |key, val| @site.collections[key] = val }
        data.each_pair { |key, val| @site.data[key] = val }
        pages.each { |page| @site.pages << page }
      end
    end

    def config_databases
      if config["database"]
        Jekyll.logger.warn("Jekyll Notion:",
                           "database property is deprecated, use databases instead.")
      end

      config["databases"] || []
    end

    def config_pages
      if config["page"]
        Jekyll.logger.warn("Jekyll Notion:",
                           "page property is deprecated, use pages instead.")
      end
      config["pages"] || []
    end

    def collections
      @collections ||= {}
    end

    def data
      @data ||= {}
    end

    def pages
      @pages ||= []
    end

    protected

    def cache_empty?
      collections.empty? && pages.empty? && data.empty?
    end

    def read_notion_databases
      config_databases.each do |db_config|
        db = NotionDatabase.new(:config => db_config)
        DatabaseFactory.for(:notion_resource => db, :site => @site, :plugin => self).generate
      end
    end

    def read_notion_pages
      config_pages.each do |page_config|
        page = NotionPage.new(:config => page_config)
        PageFactory.for(:notion_resource => page, :site => @site, :plugin => self).generate
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
        Jekyll.logger.warn("Jekyll Notion:", "Cannot read from Notion becuase NOTION_TOKEN was not provided")
        return false
      end
      true
    end

    def config?
      if config.empty?
        Jekyll.logger.warn("Jekyll Notion:", "No configuration provided")
        return false
      end
      true
    end

    def setup
      # Cache Notion API responses
      if ENV["JEKYLL_ENV"] != "test" && cache?
        JekyllNotion::Cacheable.setup(config["cache_dir"])
        Notion::Client.prepend JekyllNotion::Cacheable
      end
    end

    def cache?
      return true if config["cache"].nil?

      config["cache"] == true.to_s
    end
  end
end
