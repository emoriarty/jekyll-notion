# frozen_string_literal: true

module JekyllNotion
  class Generator < Jekyll::Generator
    priority :lowest

    attr_reader :current_page

    def initialize(plugin)
      super(plugin)
    end

    def generate(site)
      @site = site
      @db = NotionDatabase.new(config: config)
      @db.pages do |page|
        @current_page = page
        site.posts.docs << make_page
        Jekyll.logger.info("New page from notion", site.posts.docs.last.path)
      end
    end

    def make_page
      new_post = DocumentWithoutAFile.new(
        "#{Dir.pwd}/_#{config.dig('database', 'collection')}/#{make_filename}",
        { site: @site, collection: collection }
      )
      p make_frontmatter
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
  layout: #{current_page.layout}
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
  end
end
