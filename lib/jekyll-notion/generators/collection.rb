# frozen_string_literal: true

module JekyllNotion
  module Generators
    class Collection < Generator
      def call
        if config["data"].nil?
          notion_pages.each { |notion_page| generate_document(notion_page) }
        else
          Data.call(:config => config, :site => site,
                    :notion_pages => notion_pages)
        end
      end

      private

      def generate_document(notion_page)
        return if file_exists?(make_path(notion_page))

        document = make_doc(notion_page)

        site_collection.docs << document

        log_page(notion_page)
      end

      def site_collection
        @site.collections[collection_name]
      end

      # Checks if a file already exists in the site source
      def file_exists?(file_path)
        File.exist? @site.in_source_dir(file_path)
      end

      def make_doc(page)
        new_post = DocumentWithoutAFile.new(
          make_path(page),
          { :site => @site, :collection => site_collection }
        )
        new_post.content = page.to_md
        new_post.read
        new_post
      end

      def make_path(page)
        "_#{collection_name}/#{make_filename(page)}"
      end

      def collection_name
        config["collection"] || "posts"
      end

      def make_filename(page)
        if collection_name == "posts"
          "#{date_for(page)}-#{Jekyll::Utils.slugify(page.title, :mode => "latin")}.md"
        else
          "#{Jekyll::Utils.slugify(page.title, :mode => "latin")}.md"
        end
      end

      def log_page(page)
        Jekyll.logger.info("Jekyll Notion:", "Page => #{page.title}")
        if @site.config.dig(
          "collections", collection_name, "output"
        )
          Jekyll.logger.info("",
                             "URL => #{site_collection.docs.last.url}")
        end
        Jekyll.logger.debug("", "Props => #{site_collection.docs.last.data.keys.inspect}")
      end

      def date_for(page)
        # The "date" property overwrites the Jekyll::Document#data["date"] key
        # which is the date used by Jekyll to set the post date.
        Time.parse(page.props["date"]).to_date
      rescue TypeError, NoMethodError
        # Because the "date" property is not required,
        # it fallbacks to the created_time which is always present.
        Time.parse(page.created_time).to_date
      end
    end
  end
end
