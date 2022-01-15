# frozen_string_literal: true

module JekyllNotion
  class Generator < Jekyll::Generator
    attr_reader :current_page

    def initialize(plugin)
      super(plugin)
    end

    def generate(site)
      @site = site

      return unless notion_token?
      return unless config?

      read_notion_database
    end

    def read_notion_database
      @db = NotionDatabase.new(config: config)
      @db.pages do |page|
        @current_page = page
        collection.docs << make_page
        Jekyll.logger.info('Jekyll Notion:', "New notion page at #{collection.docs.last.path}")
      end
    end

    def make_page
      new_post = DocumentWithoutAFile.new(
        "#{Dir.pwd}/_#{config.dig('database', 'collection')}/#{make_filename}",
        { site: @site, collection: collection }
      )
      new_post.content = "#{make_frontmatter}\n\n#{make_md}"
      new_post.read
      new_post
    end

    def make_md
      NotionToMd::Converter.new(page_id: current_page.id).convert
    end

    def make_frontmatter
      <<-CONTENT
#{config.dig('database', 'frontmatter').to_yaml}
id: #{current_page.id}
title: #{current_page.title}
date: #{current_page.created_datetime.to_s}
cover: #{current_page.cover}
---
      CONTENT
    end

    def make_filename
      "#{current_page.created_date.to_s}-#{current_page.title.downcase.parameterize}.md"
    end

    def collection
      @site.send(config.dig('database', 'collection').to_sym)
    end

    def config
      @config ||= @site.config["notion"] || {}
    end

    def notion_token?
      if ENV['NOTION_TOKEN'].nil? || ENV['NOTION_TOKEN'].empty?
        Jekyll.logger.error('Jekyll Notion:', 'NOTION_TOKEN not provided. Cannot read from Notion.')
        return false
      end
      true
    end

    def config?
      if config.empty?
        Jekyll.logger.error('Jekyll Notion:', 'No config provided.')
        return false
      end
      true
    end
  end
end
