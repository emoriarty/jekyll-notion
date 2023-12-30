module JekyllNotion
  class FetchCommand < Jekyll::Command

    def self.init_with_program(p)
      p.command(:fetch_notion) do |c|
        c.syntax "fetch_notion [options]"
        c.description 'Fetches Notion content and places it in collection\'s directory'

        c.action do |args, options|
          process(args, options)
        end
      end
    end

    def self.process(args = [], options = {})
      @config = configuration_from_options(options)

      return unless notion_token? && fetch_mode?

      # requires plugins (and _plugins/ directory) to be able to
      # define custom notion_to_md blocks via monkey-patching
      site = Jekyll::Site.new(@config)

      config_databases.each do |db_config|
        db = NotionDatabase.new(:config => db_config)
        CollectionGenerator.new(:notion_resource => db, :site => nil, :plugin => nil, :config => @config, :fetch_mode => true).generate
      end
    end

    def self.fetch_mode?
      return true if @config["notion"]["fetch_mode"] == true

      Jekyll.logger.warn("Jekyll Notion:", "fetch_mode should be true to use this command.")
      false
    end

    def self.notion_token?
      if ENV["NOTION_TOKEN"].nil? || ENV["NOTION_TOKEN"].empty?
        Jekyll.logger.warn("Jekyll Notion:", "NOTION_TOKEN not provided. Cannot read from Notion.")
        return false
      end
      true
    end

    def self.config_databases
      if @config["notion"]["database"]
        Jekyll.logger.warn("Jekyll Notion:",
                           "database property is deprecated, use databases instead.")
      end

      @config["notion"]["databases"] || []
    end

  end
end
