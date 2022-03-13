# frozen_string_literal: true

module JekyllNotion
  class PageGenerator < AbstractGenerator
    def generate
      notion_page = @notion_resource.fetch
      unless notion_page.nil?
        @site.pages << make_page(notion_page)
        log_page(notion_page)
      end
    end

    def make_page(notion_page)
      JekyllNotion::PageWithoutAFile.new(@site, @site.source, "", "#{notion_page.title}.md",
                                         make_md)
    end

    def log_page(notion_page)
      Jekyll.logger.info("Jekyll Notion:", "Page => #{notion_page.title}")
      Jekyll.logger.info("", "Path => #{@site.pages.last.path}")
      Jekyll.logger.debug("", "Props => #{notion_page.props.keys.inspect}")
    end

    def make_md
      NotionToMd::Converter.new(:page_id => @notion_resource.id).convert(:frontmatter => true)
    end
  end
end
