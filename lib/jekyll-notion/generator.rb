# frozen_string_literal: true

module JekyllNotion
  class Generator < Jekyll::Generator
    attr_reader :current_page, :current_db

    def generate(site)
      @site = site

      return unless config? && notion_token?

      assert_configuration
      setup

      @notion_client = Notion::Client.new

      if cache_empty?
        read_notion_databases
        read_notion_pages
      else
        collections.each_pair { |key, val| @site.collections[key] = val }
        data.each_pair { |key, val| @site.data[key] = val }
        pages.each { |page| @site.pages << page }
      end
    end

    def config
      @config ||= @site.config["notion"] || {}
    end

    def config_databases
      config["databases"] || []
    end

    def config_pages
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
        Generators::Collection.call(:config => db_config, :site => @site, :plugin => self,
                                    :notion_pages => notion_database.pages)
      end
    end

    def read_notion_pages
      config_pages.each do |page_config|
        next if page_config["id"].nil?

        notion_page = NotionToMd::Page.call(:id => page_config["id"], :notion_client => @notion_client,
                                            :frontmatter => true)
        Generators::Page.call(:config => page_config, :site => @site, :plugin => self,
                              :notion_pages => [notion_page])
      end
    end

    def notion_token
      ENV.fetch("NOTION_TOKEN", nil)
    end

    def notion_token?
      if ENV["NOTION_TOKEN"].nil? || ENV["NOTION_TOKEN"].empty?
        Jekyll.logger.warn(
          "Jekyll Notion:",
          "Skipping import: NOTION_TOKEN is missing. Please set the NOTION_TOKEN environment variable to enable Notion integration."
        )

        return false
      end
      true
    end

    def config?
      return false unless @site.config.key?("notion")

      if config.empty? || (config_databases.empty? && config_pages.empty?)
        Jekyll.logger.warn("Jekyll Notion:",
                           "The `databases` or `pages` configuration are not declared. Skipping import.")
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

    def assert_configuration
      # Check for deprecated or removed options
      if config.key?("fetch_on_watch")
        Jekyll.logger.warn(
          "Jekyll Notion:",
          "The `fetch_on_watch` option was removed in v3. Please use the cache mechanism instead: https://github.com/emoriarty/jekyll-notion#cache"
        )
      end

      if config.key?("database")
        Jekyll.logger.warn("Jekyll Notion:",
                           "The `database` key is deprecated. Please use `databases` instead.")
      end

      if config["page"]
        Jekyll.logger.warn("Jekyll Notion:",
                           "The `page` key is deprecated. Please use `pages` instead.")
      end
    end
  end
end
