# frozen_string_literal: true

module JekyllNotion
  class Generator < Jekyll::Generator
    attr_reader :current_page, :current_db

    def generate(site)
      @site = site

      return unless notion_token? && config?

      setup

      @notion_client = Notion::Client.new

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
        next if db_config["id"].nil?

        notion_database = NotionToMd::Database.call(:id => db_config["id"],
                                                    :notion_client => @notion_client, :filter => db_config["filter"], :sorts => db_config["sorts"], :frontmatter => true)
        JekyllNotion::Generators::Collection.call(:config => db_config, :site => @site, :plugin => self,
                                                  :notion_pages => notion_database.pages)
      end
    end

    def read_notion_pages
      config_pages.each do |page_config|
        next if page_config["id"].nil?

        notion_page = NotionToMd::Page.call(:id => page_config["id"], :notion_client => @notion_client,
                                            :frontmatter => true)
        JekyllNotion::Generators::Page.call(:config => page_config, :site => @site, :plugin => self,
                                            :notion_pages => [notion_page])
      end
    end

    def config
      @config ||= @site.config["notion"] || {}
    end

    def fetch_on_watch?
      Jekyll.logger.warn("Jekyll Notion:",
                         "[Warning] The fetch_on_watch feature is deprecated in preference to the cache mechanism. It will be removed in the next major release.")

      config["fetch_on_watch"] == true
    end

    def notion_token?
      if ENV["NOTION_TOKEN"].nil? || ENV["NOTION_TOKEN"].empty?
        Jekyll.logger.warn("Jekyll Notion:",
                           "Cannot read from Notion becuase NOTION_TOKEN was not provided")
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
        NotionToMd::Page.prepend(JekyllNotion::Cacheable)
      end
    end

    def cache?
      return true if config["cache"].nil?

      config["cache"] == true.to_s
    end
  end
end
