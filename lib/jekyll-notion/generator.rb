# frozen_string_literal: true

module JekyllNotion
  class Generator < Jekyll::Generator
    attr_reader :current_page

    def generate(site)
      @site = site

      return unless notion_token? && config?

      read_notion_database
    end

    def read_notion_database
      @db = NotionDatabase.new(:config => config)
      @db.pages.each do |page|
        @current_page = page
        collection.docs << make_page
        Jekyll.logger.info("Jekyll Notion:", "New notion page at #{collection.docs.last.path}")
      end
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
      <<~CONTENT
        ---
        id: #{current_page.id}
        title: #{current_page.title}
        date: #{current_page.created_datetime}
        cover: #{current_page.cover}
        #{frontmatter}
        ---
      CONTENT
    end

    def frontmatter
      config.dig("database", "frontmatter").to_a.map { |k, v| "#{k}: #{v}" }.join('\n')
    end

    def make_filename
      if collection_name == "posts"
        "#{current_page.created_date}-#{current_page.title.downcase.parameterize}.md"
      else
        "#{current_page.title.downcase.parameterize}.md"
      end
    end

    def collection_name
      config.dig("database", "collection") || "posts"
    end

    def collection
      @collection ||= @site.collections[collection_name]
    end

    def config
      @config ||= @site.config["notion"] || {}
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
