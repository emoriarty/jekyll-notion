# frozen_string_literal: true

require "spec_helper"

RSpec.describe JekyllNotion::Generators::Data do
  let(:site) do
    instance_double(Jekyll::Site,
                    :data       => site_data,
                    :converters => converters)
  end
  let(:site_data) { {} }
  let(:converters) { [markdown_converter] }
  let(:markdown_converter) do
    instance_double("Jekyll::Converters::Markdown",
                    :matches => matches_md,
                    :convert => "converted content")
  end
  let(:matches_md) { true }
  let(:config) { { "data" => "test_data" } }
  let(:generator) do
    described_class.new(:config => config, :site => site, :notion_pages => notion_pages)
  end

  before do
    allow(Jekyll.logger).to receive(:info)
    allow(Jekyll.logger).to receive(:debug)
  end

  describe "#call" do
    context "with multiple pages" do
      let(:page1) do
        double("NotionToMd::Page",
               :frontmatter_properties => { "title" => "Page 1", "id" => "page1-id" },
               :body                   => "# Page 1\n\nContent 1")
      end
      let(:page2) do
        double("NotionToMd::Page",
               :frontmatter_properties => { "title" => "Page 2", "id" => "page2-id" },
               :body                   => "# Page 2\n\nContent 2")
      end
      let(:notion_pages) { [page1, page2] }

      it "stores pages as array in site data" do
        generator.call

        expect(site.data["test_data"]).to be_an(Array)
        expect(site.data["test_data"].size).to eq(2)
      end

      it "includes page properties and converted content" do
        generator.call

        first_entry = site.data["test_data"].first
        expect(first_entry["title"]).to eq("Page 1")
        expect(first_entry["id"]).to eq("page1-id")
        expect(first_entry["content"]).to eq("converted content")
      end

      it "logs each page import" do
        expect(Jekyll.logger).to receive(:info).with("Jekyll Notion:", "Page => Page 1")
        expect(Jekyll.logger).to receive(:info).with("Jekyll Notion:", "Page => Page 2")

        generator.call
      end
    end

    context "with single page" do
      let(:page) do
        double("NotionToMd::Page",
               :frontmatter_properties => { "title" => "Single Page", "id" => "single-id" },
               :body                   => "# Single Page\n\nSingle content")
      end
      let(:notion_pages) { [page] }

      it "stores page as object (not array) in site data" do
        generator.call

        expect(site.data["test_data"]).to be_a(Hash)
        expect(site.data["test_data"]).not_to be_an(Array)
      end

      it "includes page properties and converted content" do
        generator.call

        expect(site.data["test_data"]["title"]).to eq("Single Page")
        expect(site.data["test_data"]["id"]).to eq("single-id")
        expect(site.data["test_data"]["content"]).to eq("converted content")
      end

      it "logs single page import" do
        expect(Jekyll.logger).to receive(:info).with("Jekyll Notion:", "Page => Single Page")

        generator.call
      end
    end
  end

  describe "#convert" do
    let(:notion_pages) { [] }
    let(:page) do
      instance_double("NotionToMd::Page",
                      :body  => "# Test\n\nContent",
                      :title => "Test Page")
    end

    context "with successful conversion" do
      it "applies site converters to page body" do
        expect(markdown_converter).to receive(:convert).with("# Test\n\nContent").and_return("<h1>Test</h1>\n<p>Content</p>")

        result = generator.send(:convert, page)
        expect(result).to eq("<h1>Test</h1>\n<p>Content</p>")
      end

      it "applies converters in order" do
        # Mock the converters method to return a specific order
        ordered_converters = [markdown_converter]
        allow(generator).to receive(:converters).and_return(ordered_converters)

        expect(markdown_converter).to receive(:convert).with("# Test\n\nContent").and_return("final converted content")

        result = generator.send(:convert, page)
        expect(result).to eq("final converted content")
      end
    end

    context "with conversion error" do
      let(:conversion_error) { StandardError.new("Conversion failed") }

      before do
        allow(markdown_converter).to receive(:convert).and_raise(conversion_error)
        allow(Jekyll.logger).to receive(:error)
      end

      it "logs error with converter class and page title" do
        expect(Jekyll.logger).to receive(:error).with("Conversion error:",
                                                      %r!encountered an error while.*Test Page!)
        expect(Jekyll.logger).to receive(:error).with("", "Conversion failed")

        expect { generator.send(:convert, page) }.to raise_error(conversion_error)
      end

      it "re-raises the original error" do
        allow(Jekyll.logger).to receive(:error)

        expect { generator.send(:convert, page) }.to raise_error(StandardError, "Conversion failed")
      end
    end
  end

  describe "#converters" do
    let(:notion_pages) { [] }
    let(:all_converters) do
      [
        markdown_converter,
        instance_double("Jekyll::Converters::Sass", :matches => false),
        instance_double("Jekyll::Converters::CoffeeScript", :matches => false),
      ]
    end

    before do
      allow(site).to receive(:converters).and_return(all_converters)
    end

    it "selects only converters that match .md files" do
      allow(markdown_converter).to receive(:matches).with(".md").and_return(true)
      allow(all_converters[1]).to receive(:matches).with(".md").and_return(false)
      allow(all_converters[2]).to receive(:matches).with(".md").and_return(false)

      converters = generator.send(:converters)
      expect(converters).to eq([markdown_converter])
    end

    it "sorts the selected converters" do
      selected_converters = [markdown_converter]
      allow(site.converters).to receive(:select).and_return(selected_converters)
      expect(selected_converters).to receive(:sort!).and_return(selected_converters)

      generator.send(:converters)
    end
  end
end
