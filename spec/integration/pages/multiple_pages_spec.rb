# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Pages: multiple pages import" do
  let(:config) do
    Jekyll.configuration(
      "source"      => SOURCE_DIR,
      "destination" => DEST_DIR,
      "notion"      => {
        "pages" => [
          { "id" => "9dc17c9c-9d2e-469d-bbf0-f9648f3288d3" }, # Page 1
          { "id" => "0b8c4501209246c1b800529623746afc" }, # Page 2
        ],
      }
    )
  end

  let(:site) { Jekyll::Site.new(config) }

  before do
    allow(NotionToMd::Page).to receive(:call).and_call_original

    site.process
  end

  it_behaves_like "a page is rendered correctly", "Page 1"
  it_behaves_like "a page is rendered correctly", "Page 2"
end
