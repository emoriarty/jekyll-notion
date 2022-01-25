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
      @custom_props ||= page.properties.each_with_object({}) do |prop, memo|
        name = prop.first
        value = prop.last # Notion::Messages::Message
        type = value.type

        next memo unless CustomProperty.respond_to?(type.to_sym)

        memo[name.parameterize.underscore] = CustomProperty.send(type, value)
      end.reject { |_k, v| v.presence.nil? }
    end

    def default_props
      @default_props ||= {
        :id           => id,
        :title        => title,
        :date         => created_datetime,
        :cover        => cover,
        :icon         => icon,
        :updated_date => updated_datetime,
      }
    end

    class CustomProperty
      class << self
        def multi_select(prop)
          prop.multi_select.map(&:name).join(", ")
        end

        def select(prop)
          prop["select"].name
        end

        def people(prop)
          prop.people.map(&:name).join(", ")
        end

        def files(prop)
          prop.files.map { |f| f.file.url }.join(", ")
        end

        def phone_number(prop)
          prop.phone_number
        end

        def number(prop)
          prop.number
        end

        def email(prop)
          prop.email
        end

        def checkbox(prop)
          prop.checkbox.to_s
        end

        # date type properties not supported:
        # - end
        # - time_zone
        def date(prop)
          prop.date.start
        end
      end
    end
  end
end
