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
        "id"         => "b0e688e199af4295ae80b67eb52f2e2f",
        "collection" => collection,
        "filter"     => filter,
        "sort"       => sort,
      },
    }
  end
  let(:site) { Jekyll::Site.new(config) }
  let(:notion_client) do
    double("Notion::Client", :database_query => { :results => NOTION_RESULTS })
  end

  before do
    allow(ENV).to receive(:[]).with("NOTION_TOKEN").and_return(notion_token)
    allow(ENV).to receive(:[]).with("JEKYLL_ENV").and_return('production')
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

  it "id is mapped into collection doc" do
    expect(site.posts.first.data).to include("id" => NOTION_RESULTS.first.id)
  end

  it "created_time is mapped into collection doc" do
    expect(site.posts.first.data).to include("created_time" => Time.parse(NOTION_RESULTS.first.created_time))
  end

  it "last_edited_time is mapped into collection doc" do
    expect(site.posts.first.data).to include("last_edited_time" => Time.parse(NOTION_RESULTS.first.last_edited_time))
  end

  it "cover is mapped into collection doc" do
    expect(site.posts.first.data).to include("cover" => NOTION_RESULTS.first.cover.dig("external",
                                                                                       "url"))
  end

  it "icon is mapped into collection doc" do
    expect(site.posts.first.data).to include("icon" => NOTION_RESULTS.first.icon.emoji)
  end

  it "archived is mapped into collection doc" do
    expect(site.posts.first.data).to include("archived" => NOTION_RESULTS.first.archived)
  end

  it "archived is mapped into collection doc" do
    expect(site.posts.first.data).to include("archived" => NOTION_RESULTS.first.archived)
  end

  it "multi_select type is mapped into collection doc" do
    expected_value = NOTION_RESULTS.first.properties.dig("Multi Select", "multi_select").map(&:name)
    expect(site.posts.first.data).to include("multi_select" => expected_value)
  end

  it "select type is mapped into collection doc" do
    expected_value = NOTION_RESULTS.first.properties.dig("Select", "select").name
    expect(site.posts.first.data).to include("select" => expected_value)
  end

  it "people type is mapped into collection doc" do
    expected_value = NOTION_RESULTS.first.properties.dig("Person",
                                                         "people").map(&:name)
    expect(site.posts.first.data).to include("person" => expected_value)
  end

  it "number type is mapped into collection doc" do
    expected_value = NOTION_RESULTS.first.properties.dig("Numbers", "number")
    expect(site.posts.first.data).to include("numbers" => expected_value)
  end

  it "phone_number type is mapped into collection doc" do
    expected_value = NOTION_RESULTS.first.properties.dig("Phone", "phone_number")
    expect(site.posts.first.data).to include("phone" => expected_value.to_i)
  end

  it "files type is mapped into collection doc" do
    expected_value = NOTION_RESULTS.first.properties.dig("File", "files").map do |f|
      f.file.url
    end
    expect(site.posts.first.data).to include("file" => expected_value)
  end

  it "email type is mapped into collection doc" do
    expected_value = NOTION_RESULTS.first.properties.dig("Email", "email")
    expect(site.posts.first.data).to include("email" => expected_value)
  end

  it "checkbox type is mapped into collection doc" do
    expected_value = NOTION_RESULTS.first.properties.dig("Checkbox", "checkbox")
    expect(site.posts.first.data).to include("checkbox" => expected_value)
  end

  it "title type is mapped into collection doc" do
    expected_value = NOTION_RESULTS.first.properties.Name.title[0].plain_text
    expect(site.posts.first.data).to include("title" => expected_value)
  end

  it "date type is mapped into collection doc" do
    expected_value = NOTION_RESULTS.first.properties.dig("Date", "date", "start")
    expect(site.posts.first.data).to include("date" => Time.parse(expected_value))
  end

  it "page is stored in destination directory" do
    expected_path = site.posts.first.destination(".")
    expect(File).to exist(expected_path)
  end

  context("when using data") do
    let(:data_name) { "films" }
    let(:notion_config) do
      {
        "database"       => {
          "id"         => "b0e688e199af4295ae80b67eb52f2e2f",
          "data" => data_name,
          "filter"     => filter,
          "sort"       => sort,
        },
      }
    end
    let(:notion_client) do
      double("Notion::Client", :database_query => { :results => NOTION_FILMS })
    end

    it "creates a films key in data object" do
      expect(site.data).to have_key(data_name)
    end

    it "contains the same size as the returned films" do
      expect(site.data["films"].size).to be == NOTION_FILMS.size
    end
  end
end
