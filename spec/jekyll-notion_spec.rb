# frozen_string_literal: true

require "spec_helper"

describe(JekyllNotion) do
  let(:overrides) { {} }
  let(:config) do
    Jekyll.configuration(Jekyll::Utils.deep_merge_hashes({
      "full_rebuild" => true,
      "source"       => source_dir,
      "destination"  => dest_dir,
      "show_drafts"  => false,
      "url"          => "http://example.org",
      "name"         => "My site",
      "author"       => {
        "name" => "Dr. Moriarty",
      },
      "collections"  => {
        "posts" => { "output" => true },
        "films" => { "output" => false },
      },
      "notion"       => notion_config,
    }, overrides))
  end
  let(:notion_token) { "secret_0987654321" }
  let(:collection) { "posts" }
  let(:filter) { nil }
  let(:sort) { nil }
  let(:frontmatter) { nil }
  let(:notion_config) do
    {
      "database" => {
        "id"          => "b0e688e199af4295ae80b67eb52f2e2f",
        "collection"  => collection,
        "filter"      => filter,
        "sort"        => sort,
        "frontmatter" => frontmatter,
      },
    }
  end
  let(:site) { Jekyll::Site.new(config) }

  before do
    allow(ENV).to receive(:[]).with("NOTION_TOKEN").and_return(notion_token)
    allow_any_instance_of(Notion::Client).to receive(:database_query)
      .and_return({ :results => notion_client_query })
    allow(NotionToMd::Converter).to receive(:new) do |page_id:|
      double("NotionToMd::Converter", :convert => md_files[page_id])
    end
  end

  describe "NOTION_TOKEN" do
    context "when not present" do
      let(:notion_token) { nil }

      it "does not query notion database" do
        expect_any_instance_of(Notion::Client).not_to receive(:database_query)
        site.process
      end
    end

    context "when empty" do
      let(:notion_token) { "" }

      it "does not query notion database" do
        expect_any_instance_of(Notion::Client).not_to receive(:database_query)
        site.process
      end
    end

    it "queries notion database" do
      expect_any_instance_of(Notion::Client).to receive(:database_query)
      site.process
    end
  end

  describe "config" do
    context "when not present" do
      let(:notion_config) { nil }

      it "does not query notion database" do
        expect_any_instance_of(Notion::Client).not_to receive(:database_query)
        site.process
      end
    end

    context "when empty" do
      let(:notion_config) { {} }

      it "does not query notion database" do
        expect_any_instance_of(Notion::Client).not_to receive(:database_query)
        site.process
      end
    end

    context "when database is not present" do
      let(:notion_config) { { "database" => nil } }

      it "does not query notion database" do
        expect_any_instance_of(Notion::Client).not_to receive(:database_query)
        site.process
      end
    end

    context "when database id is not present" do
      let(:notion_config) { { "database" => { :id => nil, "collection" => "posts" } } }

      it "does not query notion database" do
        expect_any_instance_of(Notion::Client).not_to receive(:database_query)
        site.process
      end
    end

    context "when collection is not present" do
      let(:notion_config) { { "database" => { "id" => "bh29h", "collection" => nil } } }

      it "does not query notion database" do
        expect_any_instance_of(Notion::Client).not_to receive(:database_query)
        site.process
      end
    end

    it "queries notion database" do
      expect_any_instance_of(Notion::Client).to receive(:database_query)
      site.process
    end
  end

  describe "generate" do
    before(:each) { site.process }

    it "stores into designated collection" do
      expect(site.collections[collection].size).to be == md_files.size
    end

    it "post filename is consistent" do
      site.posts.each do |post|
        expect(post.path).to match(%r!_posts/\d{4}-\d{2}-\d{2}-.*.md$!)
      end
    end

    context "when collection is not posts" do
      let(:collection) { "films" }

      it "filename does not contain date" do
        site.collections[collection].each do |film|
          expect(film.path).to match(%r!_films/.*.md$!)
        end
      end
    end
  end
end
