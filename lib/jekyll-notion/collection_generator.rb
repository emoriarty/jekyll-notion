# frozen_string_literal: true

module JekyllNotion
  class CollectionGenerator < AbstractGenerator
    def generate
      @notion_resource.pages.each do |page|
        next if file_exists?(make_path(page))

        collection.docs << make_doc(page)
        log_new_page(page)
      end
      # Caching current collection
      @plugin.collections[@notion_resource.collection] = collection
    end

    def collection
      @site.collections[@notion_resource.collection]
    end

    private

    # Checks if a file already exists in the site source
    def file_exists?(file_path)
      File.exist? @site.in_source_dir(file_path)
    end

    def make_doc(page)
      new_post = DocumentWithoutAFile.new(
        make_path(page),
        { :site => @site, :collection => collection }
      )
      new_post.content = make_md(page)
      new_post.read
      new_post
    end

    def make_path(page)
      "_#{@notion_resource.collection}/#{make_filename(page)}"
    end

    def make_filename(page)
      if @notion_resource.collection == "posts"
        "#{page.created_time.to_date}-#{Jekyll::Utils.slugify(page.title,
                                                              :mode => "latin")}.md"
      else
        "#{page.title.downcase.parameterize}.md"
      end
    end

    def make_md(page)
      NotionToMd::Converter.new(:page_id => page.id).convert(:frontmatter => true)
    end

    def log_new_page(page)
      Jekyll.logger.info("Jekyll Notion:", "Page => #{page.title}")
      if @site.config.dig(
        "collections", @notion_resource.collection, "output"
      )
        Jekyll.logger.info("",
                           "Path => #{collection.docs.last.path}")
      end
      Jekyll.logger.debug("", "Props => #{collection.docs.last.data.keys.inspect}")
    end
  end
end
