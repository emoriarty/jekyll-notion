# frozen_string_literal: true

module JekyllNotion
  class Generator < Jekyll::Generator
    attr_reader :current_page, :current_db

    def generate(site)
      @site = site

      return unless notion_token? && config?

      if fetch_on_watch? || docs.empty?
        read_notion_database
      else
        collection.docs = docs
      end
    end

    protected

    def read_notion_database
      databases.each do |db_config|
        @current_db = NotionDatabase.new(:config => db_config)
        @current_db.pages.each do |page|
          @current_page = page
          current_collection.docs << make_page
          Jekyll.logger.info("Jekyll Notion:",
                             "New notion page at #{current_collection.docs.last.path}")
        end
        @docs = current_collection.docs
      end
    end

    def databases
      config["databases"] || [config["database"]]
    end

    def docs
      @docs ||= []
    end

    def make_page
      new_post = DocumentWithoutAFile.new(
        "#{Dir.pwd}/_#{current_db.collection}/#{make_filename}",
        { :site => @site, :collection => current_collection }
      )
      new_post.content = "#{make_frontmatter}\n\n#{make_md}"
      new_post.read
      new_post
    end

    def make_md
      NotionToMd::Converter.new(:page_id => current_page.id).convert
    end

    def make_frontmatter
      data = Jekyll::Utils.deep_merge_hashes(current_db.frontmatter, page_frontmatter)
      frontmatter = data.to_a.map { |k, v| "#{k}: #{v}" }.join("\n")
      <<~CONTENT
        ---
        #{frontmatter}
        ---
      CONTENT
    end

    def page_frontmatter
      Jekyll::Utils.deep_merge_hashes(current_page.custom_props, current_page.default_props)
    end

    def make_filename
      if current_db.collection == "posts"
        "#{current_page.created_date}-#{Jekyll::Utils.slugify(current_page.title,
                                                              :mode => "latin")}.md"
      else
        "#{current_page.title.downcase.parameterize}.md"
      end
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
  end
end
