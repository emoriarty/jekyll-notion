# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Pages: single page import" do
  let(:config) do
    Jekyll.configuration(
      "source"      => SOURCE_DIR,
      "destination" => DEST_TMP_DIR,
      "notion"      => {
        "pages" => [{ "id" => "9dc17c9c-9d2e-469d-bbf0-f9648f3288d3" }], # Page 1
      }
    )
  end

  let(:site) { Jekyll::Site.new(config) }

  before do
    allow(NotionToMd::Page).to receive(:call).and_call_original

    VCR.use_cassette("notion_page") { site.process }
  end

  it_behaves_like "a page is rendered correctly", "Page 1"
  it_behaves_like "a jekyll page", "Page 1"

  context "when site is processed a second time" do
    before do
      VCR.use_cassette("notion_page") { site.process }
    end

    it "imports page once" do
      expect(NotionToMd::Page).to have_received(:call).once
    end
  end

  context "with cache disabled" do
    let(:config) do
      Jekyll.configuration(
        "source"      => SOURCE_DIR,
        "destination" => DEST_TMP_DIR,
        "notion"      => {
          "cache" => false,
          "pages" => [{ "id" => "9dc17c9c-9d2e-469d-bbf0-f9648f3288d3" }], # Page 1
        }
      )
    end

    context "when site is processed a second time" do
      before do
        VCR.use_cassette("notion_page") { site.process }
      end

      it "imports page twice" do
        expect(NotionToMd::Page).to have_received(:call).twice
      end
    end
  end

  context "with page imported as data" do
    let(:config) do
      Jekyll.configuration(
        "source"      => SOURCE_DIR,
        "destination" => DEST_TMP_DIR,
        "notion"      => {
          "pages" => [
            {
              "id"   => "9dc17c9c-9d2e-469d-bbf0-f9648f3288d3", # Page 1
              "data" => "dummy",
            },
          ],
        }
      )
    end

    it_behaves_like "a jekyll data object", "dummy"
  end
end
