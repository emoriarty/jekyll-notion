# frozen_string_literal: true

module JekyllNotion
  class PageWithoutAFile < Jekyll::Page
    def initialize(site, base, dir, name, new_content)
      self.content = new_content
      super(site, base, dir, name)
    end

    def read_yaml(base, name, _opts = {})
      filename = @path || site.in_source_dir(base, name)
      Jekyll.logger.debug "Reading:", relative_path

      begin
        if content =~ Jekyll::Document::YAML_FRONT_MATTER_REGEXP
          self.content = Regexp.last_match.post_match
          self.data = SafeYAML.load(Regexp.last_match(1))
        end
      rescue Psych::SyntaxError => e
        Jekyll.logger.warn "YAML Exception reading page #{name}: #{e.message}"
        raise e if site.config["strict_front_matter"]
      end

      self.data ||= {}

      validate_data! filename
      validate_permalink! filename

      self.data
    end
  end
end
