# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Setup: missing NOTION_TOKEN" do
  let(:notion_token) { nil }
  let(:site) { Jekyll::Site.new(config) }
  let(:source_dir) { SOURCE_DIR }
  let(:dest_dir)   { DEST_DIR }
  let(:config) do
    Jekyll.configuration(
      "source"      => source_dir,
      "destination" => dest_dir,
      "notion"      => {
        "pages" => [{ "id" => "9dc17c9c-9d2e-469d-bbf0-f9648f3288d3" }] # Page 1
      }
    )
  end

  before do
    allow(Jekyll.logger).to receive(:warn)
    allow(ENV).to receive(:[]).with("NOTION_TOKEN").and_return(notion_token)

    VCR.use_cassette("notion_page") { site.process }
  end

  it_behaves_like "skips import"

  it "logs an error when NOTION_TOKEN is nil" do
    expect(Jekyll.logger).to have_received(:warn).with(
      a_string_matching(%r!Jekyll Notion!i),
      a_string_matching(%r!skipping import: NOTION_TOKEN is missing!i)
    )
  end

  context "when NOTION_TOKEN is empty" do
    let(:notion_token) { "" }

    it "logs an error when NOTION_TOKEN is empty" do
      expect(Jekyll.logger).to have_received(:warn).with(
        a_string_matching(%r!Jekyll Notion!i),
        a_string_matching(%r!skipping import: NOTION_TOKEN is missing!i)
      )
    end
  end
end
