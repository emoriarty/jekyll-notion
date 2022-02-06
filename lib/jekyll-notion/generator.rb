# frozen_string_literal: true

module JekyllNotion
  class Generator < Jekyll::Generator
    attr_reader :current_page

    def generate(site)
      @site = site

      return unless notion_token? && config?

      if fetch_on_watch? || docs.empty?
        read_notion_database
      else
        collection.docs = docs
      end
    end

    def read_notion_database
      @db = NotionDatabase.new(:config => config)
      @db.pages.each do |page|
        @current_page = page
        collection.docs << make_page
        Jekyll.logger.info("Jekyll Notion:", "Page => #{page.title}")
        Jekyll.logger.info("", "Path => #{collection.docs.last.path}") if @site.config.dig("collections", collection_name, "output")
        Jekyll.logger.debug("", "Props => #{page_frontmatter.keys.inspect}")
      end
      @docs = collection.docs
    end

    def docs
      @docs ||= []
    end

    def make_page
      new_post = DocumentWithoutAFile.new(
        "#{Dir.pwd}/_#{collection_name}/#{make_filename}",
        { :site => @site, :collection => collection }
      )
      new_post.content = "#{make_frontmatter}\n\n#{make_md}"
      new_post.read
      new_post
    end

    def make_md
      NotionToMd::Converter.new(:page_id => current_page.id).convert
    end

    def make_frontmatter
      data = Jekyll::Utils.deep_merge_hashes(config_frontmatter, page_frontmatter)
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

    def config_frontmatter
      config.dig("database", "frontmatter") || {}
    end

    def make_filename
      if collection_name == "posts"
        "#{current_page.created_date}-#{Jekyll::Utils.slugify(current_page.title,
                                                              :mode => "latin")}.md"
      else
        "#{current_page.title.downcase.parameterize}.md"
      end
    end

    def collection_name
      config.dig("database", "collection") || "posts"
    end

    def collection
      @site.collections[collection_name]
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
