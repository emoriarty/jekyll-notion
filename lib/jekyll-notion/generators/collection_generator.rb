# frozen_string_literal: true

module JekyllNotion
  class CollectionGenerator < AbstractGenerator
    attr_reader :fetch_mode, :config

    def initialize(notion_resource:, site:, plugin:, config:, fetch_mode:)
      super(:notion_resource => notion_resource, :site => site, :plugin => plugin)
      @config = config
      @fetch_mode = fetch_mode
    end

    def generate
      if @fetch_mode
        @notion_resource.fetch.each do |page|
          make_doc(page)
          log_new_page(page)
        end
      else
        @notion_resource.fetch.each do |page|
          next if file_exists?(make_path(page))

          collection.docs << make_doc(page)
          log_new_page(page)
        end
        # Caching current collection
        @plugin.collections[@notion_resource.collection_name] = collection
      end
    end

    def collection
      @site.collections[@notion_resource.collection_name]
    end

    private

    # Checks if a file already exists in the site source
    def file_exists?(file_path)
      if @fetch_mode
        File.exist?(file_path)
      else
        File.exist? @site.in_source_dir(file_path)
      end
    end

    def make_doc(page)
      if @fetch_mode
        FileCreator.new(make_path(page), make_md(page)).create!
      else
        new_post = DocumentWithoutAFile.new(
          make_path(page),
          { :site => @site, :collection => collection }
        )
        new_post.content = make_md(page)
        new_post.read
        new_post
      end
    end

    def make_path(page)
      "#{@config["source"]}/_#{@notion_resource.collection_name}/#{make_filename(page)}"
    end

    def make_filename(page)
      if @notion_resource.collection_name == "posts"
        "#{date_for(page)}-#{Jekyll::Utils.slugify(page.title, :mode => "latin")}.md"
      else
        "#{Jekyll::Utils.slugify(page.title, :mode => "latin")}.md"
      end
    end

    def make_md(page)
      NotionToMd::Converter.new(:page_id => page.id).convert(:frontmatter => true)
    end

    def log_new_page(page)
      Jekyll.logger.info("Jekyll Notion:", "Page => #{page.title}")

      return if @fetch_mode

      if @site.config.dig(
        "collections", @notion_resource.collection_name, "output"
      )
        Jekyll.logger.info("",
                           "URL => #{collection.docs.last.url}")
      end
      Jekyll.logger.debug("", "Props => #{collection.docs.last.data.keys.inspect}")
    end

    def date_for(page)
      # The "date" property overwrites the Jekyll::Document#data["date"] key
      # which is the date used by Jekyll to set the post date.
      DateTime.parse(page.props["date"]).to_date
    rescue TypeError, NoMethodError
      # Because the "date" property is not required,
      # it fallbacks to the created_time which is always present.
      page.created_time.to_date
    end
  end
end
