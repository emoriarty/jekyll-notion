# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Pages: preserve existing pages" do
  let(:site) { Jekyll::Site.new(config) }
  let(:config) do
    Jekyll.configuration(
      "source"      => SOURCE_DIR_2, # contains a local "Page 1"
      "destination" => DEST_DIR,
      "notion"      => {
        "pages" => [
          { "id" => "9dc17c9c-9d2e-469d-bbf0-f9648f3288d3" }, # Notion "Page 1"
        ],
      }
    )
  end

  before do
    allow(Jekyll.logger).to receive(:warn)
    site.process
  end

  it "logs a warning when a page with the same title exists" do
    expect(Jekyll.logger).to have_received(:warn).with(
      a_string_matching(%r!Jekyll Notion:!i),
      a_string_matching(%r!Page `Page 1` .*skipping .*Notion import!i)
    )
  end

  it "does not add a duplicate page" do
    matching = site.pages.select { |p| p.data["title"].downcase == "page 1" }
    expect(matching.size).to eq(1)
  end

  it "keeps the local file contents" do
    page = site.pages.find { |p| p.data["title"].downcase == "page 1" }
    expect(page.instance_variable_get(:@base)).to start_with(SOURCE_DIR_2) # ensures it’s the local file
  end

  context "When the titles are not in the same case" do
    let(:config) do
      Jekyll.configuration(
        "source"      => SOURCE_DIR_2, # contains a local "page 2"
        "destination" => DEST_DIR,
        "notion"      => {
          "pages" => [
            { "id" => "0b8c4501209246c1b800529623746afc" }, # Notion "Page 2"
          ],
        }
      )
    end

    it "still logs a warning treating titles case-insensitively" do
      expect(Jekyll.logger).to have_received(:warn).with(
        a_string_matching(%r!Jekyll Notion:!i),
        a_string_matching(%r!Page `Page 2` .*skipping .*Notion import!i)
      )
    end

    it "does not add a duplicate even if the cases differ" do
      matching = site.pages.select { |p| p.data["title"].downcase == "page 2" }
      expect(matching.size).to eq(1)
    end

    it "keeps the local file contents (case-insensitive match)" do
      page = site.pages.find { |p| p.data["title"].downcase == "page 2" }
      expect(page.instance_variable_get(:@base)).to start_with(SOURCE_DIR_2) # still the local file
    end
  end
end
