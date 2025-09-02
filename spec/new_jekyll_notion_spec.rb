# frozen_string_literal: true

require "spec_helper"

RSpec.describe(JekyllNotion) do
  let(:source_dir) { SOURCE_DIR }
  let(:dest_dir)   { DEST_DIR }
  let(:collections)    { nil }
  let(:notion_config)  { nil }
  let(:site) { Jekyll::Site.new(config) }
  let(:config) do
    Jekyll.configuration(
      "full_rebuild" => true,
      "source"       => source_dir,
      "destination"  => dest_dir,
      "show_drafts"  => false,
      "url"          => "http://example.org",
      "name"         => "My site",
      "author"       => { "name" => "Professor Moriarty" },
      "collections"  => collections,
      "notion"       => notion_config
    )
  end

  describe "setup" do
    context "when deprecated options are still used" do
      include_examples "setup without configuration"
    end

    context "when deprecated options are still used" do
      include_examples "setup with deprecated options"
    end
  end
end
