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
  let(:collection) { nil }
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
  let(:notion_client) do
    double("Notion::Client", :database_query => { :results => notion_client_query })
  end

  before do
    allow(ENV).to receive(:[]).with("NOTION_TOKEN").and_return(notion_token)
    # allow_any_instance_of(Notion::Client).to receive(:database_query)
    #   .and_return({ :results => notion_client_query })
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
    expect(site.posts.size).to be == md_files.size
  end

  it "post filename matches YYYY-MM-DD-title.md format" do
    site.posts.each do |post|
      expect(post.path).to match(%r!_posts/\d{4}-\d{2}-\d{2}-.*.md$!)
    end
  end

  context "when collection is not posts" do
    let(:collection) { "films" }

    it "stores pages into designated collection" do
      expect(site.collections[collection].size).to be == md_files.size
    end

    it "filename does not contain date" do
      site.collections[collection].each do |film|
        expect(film.path).to match(%r!_films/.*.md$!)
      end
    end
  end

  context "when filter is provided" do
    let(:filter) { { :property => "blabla", :checkbox => { :equals => true } } }

    it do
      expect(notion_client).to have_received(:database_query)
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

  context "when frontmatter is provided" do
    let(:frontmatter) { { :layout => "post", :title => "a_title_from_config" } }

    it "is added into page data" do
      site.posts.each do |post|
        expect(post.data["layout"]).to eq("post")
      end
    end

    it "does not overwrite default fronmatter" do
      site.posts.each do |post|
        expect(post.data["title"]).not_to eq("a_title_from_config")
      end
    end
  end

  context "when multiple frontmatter properties" do
    let(:frontmatter) { { :option1 => "uno", :option2 => "dos", :option3 => "tres" } }

    it "is added into page data" do
      site.posts.each do |post|
        expect(post.data).to include(*frontmatter.keys.map(&:to_s))
      end
    end
  end

  context "when complex frontmatter properties" do
    let(:frontmatter) do
      { :url => "https://regardsprotestants.com/wp-content/uploads/2020/06/balblart-e1591697827166.jpg?size=276" }
    end

    it "is added into page data" do
      site.posts.each do |post|
        expect(post.data).to include(*frontmatter.keys.map(&:to_s))
      end
    end
  end
end
