# frozen_string_literal: true

module JekyllNotion
  class NotionPage
    attr_reader :page, :layout

    def initialize(page:, layout:)
      @page = page
      @layout = layout
    end

    def title
      page.dig(:properties, :Name, :title).inject("") do |acc, slug|
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

    def custom_props
      @props ||= page.properties.inject({}) do |memo, prop|
        name = prop.first
        value = prop.last # Notion::Messages::Message
        type = value.type

        next memo unless CustomProperty.respond_to?(type.to_sym)

        memo[name.parameterize.underscore] = CustomProperty.send(type, value)
        memo
      end.compact
    end

    class CustomProperty
      class << self
        def multi_select(prop)
          prop.multi_select.map(&:name).join(', ')
        end

        def select(prop)
          prop["select"].name
        end

        def people(prop)
          prop.people.map(&:name).join(', ')
        end

        def files(prop)
          prop.files.map(&:file).join(', ')
        end
      end
    end
  end
end
