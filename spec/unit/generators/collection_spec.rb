# frozen_string_literal: true

require "spec_helper"

RSpec.describe JekyllNotion::Generators::Collection do
  let(:site) do
    instance_double(Jekyll::Site, :in_source_dir => "/source/path", :collections => collections)
  end
  let(:collections) { { "posts" => instance_double(Jekyll::Collection, :docs => []) } }
  let(:config) { { "id" => "test-id" } }
  let(:notion_pages) { [] }
  let(:generator) do
    described_class.new(:config => config, :site => site, :notion_pages => notion_pages)
  end

  describe "#collection_name" do
    context "when collection is specified in config" do
      let(:config) { { "collection" => "articles" } }

      it "returns the specified collection name" do
        expect(generator.send(:collection_name)).to eq("articles")
      end
    end

    context "when collection is not specified in config" do
      let(:config) { {} }

      it "defaults to posts" do
        expect(generator.send(:collection_name)).to eq("posts")
      end
    end
  end

  describe "#make_filename" do
    let(:page) { double("NotionToMd::Page", :title => "Test Page Title") }

    context "with posts collection" do
      let(:config) { {} } # defaults to posts

      it "includes date prefix for posts" do
        allow(generator).to receive(:date_for).with(page).and_return(Date.parse("2023-01-15"))

        filename = generator.send(:make_filename, page)
        expect(filename).to eq("2023-01-15-test-page-title.md")
      end

      it "slugifies the title correctly" do
        allow(page).to receive(:title).and_return("Page with Special: Characters & Symbols!")
        allow(generator).to receive(:date_for).with(page).and_return(Date.parse("2023-01-15"))

        filename = generator.send(:make_filename, page)
        expect(filename).to match(%r!^2023-01-15-.+\.md$!)
        expect(filename).not_to include(":")
        expect(filename).not_to include("&")
        expect(filename).not_to include("!")
      end
    end

    context "with custom collection" do
      let(:config) { { "collection" => "articles" } }

      it "excludes date prefix for custom collections" do
        filename = generator.send(:make_filename, page)
        expect(filename).to eq("test-page-title.md")
        expect(filename).not_to match(%r!^\d{4}-\d{2}-\d{2}!)
      end

      it "slugifies the title correctly" do
        allow(page).to receive(:title).and_return("Article with Àccénts and Spåcês")

        filename = generator.send(:make_filename, page)
        expect(filename).to match(%r!^.+\.md$!)
        expect(filename).not_to include(" ")
      end
    end
  end

  describe "#make_path" do
    let(:page) { double("NotionToMd::Page", :title => "Test Page") }

    context "with posts collection" do
      let(:config) { {} }

      it "creates correct path for posts" do
        allow(generator).to receive(:make_filename).with(page).and_return("2023-01-15-test-page.md")

        path = generator.send(:make_path, page)
        expect(path).to eq("_posts/2023-01-15-test-page.md")
      end
    end

    context "with custom collection" do
      let(:config) { { "collection" => "articles" } }

      it "creates correct path for custom collection" do
        allow(generator).to receive(:make_filename).with(page).and_return("test-page.md")

        path = generator.send(:make_path, page)
        expect(path).to eq("_articles/test-page.md")
      end
    end
  end

  describe "#date_for" do
    context "when page has date property" do
      let(:page) { double("NotionToMd::Page", :props => { "date" => "2023-05-20" }) }

      it "returns parsed date from date property" do
        date = generator.send(:date_for, page)
        expect(date).to eq(Date.parse("2023-05-20"))
      end
    end

    context "when page has no date property but has created_time" do
      let(:page) do
        double("NotionToMd::Page",
               :props        => {},
               :created_time => "2023-04-15T10:30:00.000Z")
      end

      it "falls back to created_time" do
        date = generator.send(:date_for, page)
        expect(date).to eq(Date.parse("2023-04-15"))
      end
    end

    context "when date property is nil" do
      let(:page) do
        double("NotionToMd::Page",
               :props        => { "date" => nil },
               :created_time => "2023-04-15T10:30:00.000Z")
      end

      it "falls back to created_time" do
        date = generator.send(:date_for, page)
        expect(date).to eq(Date.parse("2023-04-15"))
      end
    end

    context "when date property is invalid" do
      let(:page) do
        double("NotionToMd::Page",
               :props        => { "date" => "invalid-date" },
               :created_time => "2023-04-15T10:30:00.000Z")
      end

      it "raises ArgumentError for invalid date" do
        # Current implementation doesn't catch ArgumentError, only TypeError and NoMethodError
        expect { generator.send(:date_for, page) }.to raise_error(ArgumentError)
      end
    end
  end
end
