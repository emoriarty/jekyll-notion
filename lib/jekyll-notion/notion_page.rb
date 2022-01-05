module JekyllNotion
  class NotionPage
    attr_reader :page, :layout

    def initialize(page:, layout:)
      @page = page
      @layout = layout
    end

    def title
      page.dig(:properties, :Name, :title).inject('') do |acc, slug|
        acc + slug[:plain_text]
      end
    end

    def cover
      page.dig(:cover, :external, :url)
    end

    def icon
      page.dig(:icon, :emoji)
    end

    def id
      page[:id]
    end

    def created_date
      created_datetime.to_date
    end

    def created_datetime
      DateTime.parse(page["created_time"])
    end

    def updated_date
      updated_datetime.to_date
    end

    def updated_datetime
      DateTime.parse(page["last_edited_time"])
    end

    def url
      page[:url]
    end
  end
end