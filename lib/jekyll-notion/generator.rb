# frozen_string_literal: true

module JekyllNotion
  class Generator < Jekyll::Generator
    attr_reader :current_page, :current_db

    def generate(site)
      @site = site

      return unless notion_token? && config?

      if fetch_on_watch? || collections.empty?
        read_notion_database
      else
        collections.each_pair { |key, val| @site.collections[key] = val }
      end
    end

    protected

    def read_notion_database
      databases.each do |db_config|
        @current_db = NotionDatabase.new(:config => db_config)
        @current_db.pages.each do |page|
          @current_page = page
          next if file_exists?(make_path)

          current_collection.docs << make_page
          log_new_page
        end
        # Store current collection
        collections[current_db.collection] = current_collection
      end
    end

    def databases
      config["databases"] || [config["database"]]
    end

    def collections
      @collections ||= {}
    end

    # Checks if a file already exists in the site source
    def file_exists?(file_path)
      File.exist? @site.in_source_dir(file_path)
    end

    def make_page
      new_post = DocumentWithoutAFile.new(
        make_path,
        { :site => @site, :collection => current_collection }
      )
      new_post.content = make_md
      new_post.read
      new_post
    end

    def make_path
      "_#{current_db.collection}/#{make_filename}"
    end

    def make_filename
      if current_db.collection == "posts"
        "#{current_page.created_time.to_date.to_s}-#{Jekyll::Utils.slugify(current_page.title,
                                                              :mode => "latin")}.md"
      else
        "#{current_page.title.downcase.parameterize}.md"
      end
    end

    def make_md
      NotionToMd::Converter.new(:page_id => current_page.id).convert(frontmatter: true)
    end

    def current_collection
      @site.collections[current_db.collection]
    end

    def config
      @config ||= @site.config["notion"] || {}
    end

    def fetch_on_watch?
      config["fetch_on_watch"].present?
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

    def log_new_page
      Jekyll.logger.info("Jekyll Notion:", "Page => #{current_page.title}")
      if @site.config.dig(
        "collections", current_db.collection, "output"
      )
        Jekyll.logger.info("",
                           "Path => #{current_collection.docs.last.path}")
      end
      Jekyll.logger.debug("", "Props => #{current_collection.docs.last.data.keys.inspect}")
    end
  end
end
