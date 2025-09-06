# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Pages: duplicate page declarations" do
  let(:site) { Jekyll::Site.new(config) }
  let(:config) do
    Jekyll.configuration(
      "source"      => SOURCE_DIR,
      "destination" => DEST_DIR,
      "notion"      => {
        "pages" => [
          { "id" => "9dc17c9c-9d2e-469d-bbf0-f9648f3288d3" },
          { "id" => "9dc17c9c-9d2e-469d-bbf0-f9648f3288d3" },
        ],
      }
    )
  end

  before do
    allow(Jekyll.logger).to receive(:warn)

    site.process
  end

  it_behaves_like "a page is rendered correctly", "Page 1"
  it_behaves_like "a jekyll page", "Page 1"

  it "logs a warning about duplicate page IDs" do
    expect(Jekyll.logger).to have_received(:warn).with(
      a_string_matching(%r!Jekyll Notion:!i),
      a_string_matching(%r!Duplicate pages detected: 9dc17c9c-9d2e-469d-bbf0-f9648f3288d3!i)
    )
  end

  it "only one page is imported" do
    expect(site.pages.size).to be(1)
  end

  context "with data" do
    let(:config) do
      Jekyll.configuration(
        "source"      => SOURCE_DIR,
        "destination" => DEST_DIR,
        "notion"      => {
          "pages" => [
            { "id" => "9dc17c9c-9d2e-469d-bbf0-f9648f3288d3", "data" => "page_1" },
            { "id" => "9dc17c9c-9d2e-469d-bbf0-f9648f3288d3", "data" => "page_2" },
          ],
        }
      )
    end

    it_behaves_like "a jekyll data object", "page_2"

    it "does not import page_1" do
      expect(site.data["page_1"]).to be_nil
    end
  end
end
