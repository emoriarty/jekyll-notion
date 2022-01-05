# frozen_string_literal: true

module JekyllNotion
  class DocumentWithoutAFile < Jekyll::Document
    def read_content(new_content, **opts)
      if content =~ YAML_FRONT_MATTER_REGEXP
        self.content = $POSTMATCH
        data_file = SafeYAML.load(Regexp.last_match(1))
        merge_data!(data_file, :source => "YAML front matter") if data_file
      end
    end
  end
end
