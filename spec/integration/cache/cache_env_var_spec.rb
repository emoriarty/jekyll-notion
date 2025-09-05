# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Caching: JEKYLL_NOTION_CACHE" do
  let(:cache_dir) { Dir.mktmpdir("jekyll-cache-") }
  let(:site) { Jekyll::Site.new(config) }
  let(:config) do
    Jekyll.configuration(
      "source"      => SOURCE_DIR,
      "destination" => DEST_TMP_DIR,
      "notion"      => {
        "cache_dir" => cache_dir,
        "pages"     => [{ "id" => "9dc17c9c-9d2e-469d-bbf0-f9648f3288d3" }],
      }
    )
  end

  before { VCR.use_cassette("cache_env_var") { site.process } }

  %w(0 false FALSE no NO False).each do |falsy_value|
    it "disables caching with #{falsy_value}" do
      original_value = ENV["JEKYLL_NOTION_CACHE"]
      ENV["JEKYLL_NOTION_CACHE"] = falsy_value

      begin
        # Verify no cache files were created in default location
        expect(Dir.empty?(cache_dir)).to be(true)
      ensure
        if original_value.nil?
          ENV.delete("JEKYLL_NOTION_CACHE")
        else
          ENV["JEKYLL_NOTION_CACHE"] = original_value
        end
      end
    end
  end
end
