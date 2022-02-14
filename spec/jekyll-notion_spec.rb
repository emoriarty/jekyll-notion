# frozen_string_literal: true

require "spec_helper"

describe(JekyllNotion) do
  let(:overrides) { {} }
  let(:source_dir) { SOURCE_DIR }
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
        "films"   => { "output" => false },
        "recipes" => { "output" => false },
      },
      "notion"       => notion_config,
    }, overrides))
  end
  let(:notion_token) { "secret_0987654321" }
  let(:collection) { nil }
  let(:filter) { nil }
  let(:sort) { nil }
  let(:fetch_on_watch) { nil }
  let(:notion_config) do
    {
      "fetch_on_watch" => fetch_on_watch,
      "database"       => {
        "id"          => "b0e688e199af4295ae80b67eb52f2e2f",
        "collection"  => collection,
        "filter"      => filter,
        "sort"        => sort,
      },
    }
  end
  let(:site) { Jekyll::Site.new(config) }
  let(:notion_client) do
    double("Notion::Client", :database_query => { :results => NOTION_RESULTS })
  end

  before do
    allow(ENV).to receive(:[]).with("NOTION_TOKEN").and_return(notion_token)
    allow(Notion::Client).to receive(:new).and_return(notion_client)
    allow(NotionToMd::Converter).to receive(:new) do |page_id:|
      double("NotionToMd::Converter", :convert => md_files[page_id])
    end
  end

  before(:each) do
    site.process
  end

  context "when NOTION_TOKEN not present" do
    let(:notion_token) { nil }

    it "does not query notion database" do
      expect(notion_client).not_to have_received(:database_query)
    end
  end

  context "when NOTION_TOKEN is empty" do
    let(:notion_token) { "" }

    it "does not query notion database" do
      expect(notion_client).not_to have_received(:database_query)
    end
  end

  context "when config is not present" do
    let(:notion_config) { nil }

    it "does not query notion database" do
      expect(notion_client).not_to have_received(:database_query)
    end
  end

  context "when config is empty" do
    let(:notion_config) { {} }

    it "does not query notion database" do
      expect(notion_client).not_to have_received(:database_query)
    end
  end

  context "when config.database is not present" do
    let(:notion_config) { { "database" => nil } }

    it "does not query notion database" do
      expect(notion_client).not_to have_received(:database_query)
    end
  end

  context "when config.database.id is not present" do
    let(:notion_config) { { "database" => { :id => nil } } }

    it "does not query notion database" do
      expect(notion_client).not_to have_received(:database_query)
    end
  end

  it "stores pages into posts collection" do
    expect(site.posts.size).to be == NOTION_RESULTS.size
  end

  it "post filename matches YYYY-MM-DD-title.md format" do
    expect(site.posts.first.path).to match(%r!_posts/\d{4}-\d{2}-\d{2}-.*.md$!)
  end

  context "when collection is not posts" do
    let(:collection) { "films" }

    it "stores page into designated collection" do
      expect(site.collections[collection].size).to be == NOTION_RESULTS.size
    end

    it "does not store page into posts collection" do
      expect(site.posts.size).to be == 0
    end

    it "filename does not contain date" do
      expect(site.collections[collection].first.path).not_to match(%r!_films/\d{4}-\d{2}-\d{2}-.*.md$!)
    end
  end

  context "when filter is provided" do
    let(:filter) { { :property => "blabla", :checkbox => { :equals => true } } }

    it do
      expect(notion_client).to have_received(:database_query)
        .with(hash_including(:filter => filter))
    end
  end

  context "when filter is not provided" do
    let(:filter) { nil }

    it do
      expect(notion_client).not_to have_received(:database_query)
        .with(hash_including(:filter => filter))
    end
  end

  context "when sort is provided" do
    let(:sort) { { :propery => "Last ordered", :direction => "ascending" } }

    it {
      expect(notion_client).to have_received(:database_query)
        .with(hash_including(:sort => sort))
    }
  end

  context "when sort is not provided" do
    let(:sort) { nil }

    it {
      expect(notion_client).not_to have_received(:database_query)
        .with(hash_including(:sort => sort))
    }
  end

  context "when site is processed a second time" do
    before(:each) do
      site.process
    end

    it "the posts collection is not empty" do
      expect(site.posts).not_to be_empty
    end

    it "the posts collection is the same length" do
      expect(site.posts.size).to be(NOTION_RESULTS.size)
    end

    it "does not query notion database" do
      expect(notion_client).to have_received(:database_query).once
    end
  end

  context "when fetch_on_watch is true" do
    let(:fetch_on_watch) { true }

    before(:each) do
      site.process
    end

    it "queries notion database as many times as the site rebuild" do
      expect(notion_client).to have_received(:database_query).twice
    end
  end

  context "when multiple databases" do
    let(:posts_id) { "b0e688e199af4295ae80b67eb52f2e2f" }
    let(:recipes_id) { "f0e688e199af4295ae80b67eb52f2e2r" }
    let(:posts_results) { NOTION_RESULTS_2 }
    let(:recipes_results) { NOTION_RESULTS }
    let(:notion_config) do
      {
        "databases" => [
          {
            "id" => posts_id,
          },
          {
            "id"         => recipes_id,
            "collection" => "recipes",
          },
        ],
      }
    end

    context "with posts database" do
      let(:notion_client) do
        double("Notion::Client", :database_query => { :results => NOTION_RESULTS_2 })
      end

      it "stores pages in posts collection" do
        expect(site.posts.size).to be == NOTION_RESULTS_2.size
      end
    end

    context "with recipes database" do
      let(:notion_client) do
        double("Notion::Client", :database_query => { :results => NOTION_RESULTS })
      end

      it "stores pages in recipes collection" do
        expect(site.collections["recipes"].size).to be == NOTION_RESULTS.size
      end
    end
  end

  context "when there is a post present in source dir" do
    let(:source_dir) { SOURCE_DIR_2 }

    it "adds one more document to posts collection" do
      expect(site.posts.size).to be == (NOTION_RESULTS.size + 1)
    end

    context "with a document matching the same filename" do
      let(:notion_client) do
        # NOTION_RESULTS_3 contains one page with the same date and title
        # as the post present in SOURCE_DIR_2
        double("Notion::Client", :database_query => { :results => NOTION_RESULTS_3 })
      end

      it "only local document is kept" do
        # notion pages are processed after Jekyll has generated local documents
        # so, the last element in the collection must be an instance of a Jekyll:Document
        expect(site.posts.last).to be_an_instance_of(Jekyll::Document)
      end
    end
  end
end
