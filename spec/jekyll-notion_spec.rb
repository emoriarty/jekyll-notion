# frozen_string_literal: true

require "spec_helper"
require "support/check_config"
require "support/collection"
require "support/data"
require "support/page"

describe(JekyllNotion) do
  let(:source_dir) { SOURCE_DIR }
  let(:config) do
    Jekyll.configuration({
      "full_rebuild" => true,
      "source"       => source_dir,
      "destination"  => dest_dir,
      "show_drafts"  => false,
      "url"          => "http://example.org",
      "name"         => "My site",
      "author"       => {
        "name" => "Dr. Moriarty",
      },
      "collections"  => collections,
      "notion"       => notion_config,
    })
  end
  let(:notion_token) { "secret_0987654321" }
  let(:collections) { nil }
  let(:notion_config) { nil }
  let(:site) { Jekyll::Site.new(config) }

  before do
    allow(ENV).to receive(:[]).with("NOTION_TOKEN").and_return(notion_token)
    allow(ENV).to receive(:[]).with("JEKYLL_ENV").and_return("production")
    allow(Notion::Client).to receive(:new).and_return(notion_client)
    allow(NotionToMd::Converter).to receive(:new) do |page_id:|
      double("NotionToMd::Converter", :convert => md_files[page_id])
    end
  end

  before(:each) do
    site.process
  end

  context "with a notion database" do
    let(:notion_client) do
      double("Notion::Client", :database_query => { :results => NOTION_RESULTS },
                               :block_children => NOTION_PAGE_BLOCKS)
    end
    let(:notion_config) do
      {
        "database" => {
          "id" => "b0e688e199af4295ae80b67eb52f2e2f",
        },
      }
    end

    include_examples "check settings" do
      let(:query) { :database_query }
    end

    it_behaves_like "a jekyll collection" do
      let(:collection_name) { "posts" }
    end

    context "when data is declared" do
      let(:notion_config) do
        {
          "database" => {
            "id"   => "b0e688e199af4295ae80b67eb52f2e2f",
            "data" => data_name,
          },
        }
      end
      let(:notion_client) {
        double("Notion::Client", :database_query => { :results => NOTION_FILMS },
                                :block_children => NOTION_PAGE_BLOCKS)
      }

      it_behaves_like "a jekyll data object" do
        let(:data_name) { "films" }
        let(:size) { NOTION_FILMS.size }
      end

      context "with a collection in the same configuration object" do
        let(:collection_name) { "movies" }
        let(:data_name) { "films" }
        let(:notion_config) do
          {
            "database" => {
              "id"         => "b0e688e199af4295ae80b67eb52f2e2f",
              "data"       => data_name,
              "collection" => collection_name,
            },
          }
        end

        it "creates the data key" do
          expect(site.data).to have_key(data_name)
        end

        it "does not create the collection " do
          expect(site.collections).not_to have_key(collection_name)
        end
      end
    end

    context "when database is nil" do
      let(:notion_config) { { "database" => nil } }

      it "does not query notion database" do
        expect(notion_client).not_to have_received(:database_query)
      end
    end

    context "when no database id is present" do
      let(:notion_config) { { "database" => { :id => nil } } }

      it "does not query notion database" do
        expect(notion_client).not_to have_received(:database_query)
      end
    end

    it "stores pages into posts collection" do
      expect(site.posts.size).to be == NOTION_RESULTS.size
    end

    it "each item filename matches YYYY-MM-DD-title.md format" do
      site.posts.each do |post|
        expect(post.path).to match(%r!_posts/\d{4}-\d{2}-\d{2}-.*.md$!)
      end
    end

    context "when a collection films is defined" do
      let(:collection) { "films" }
      let(:collections) do
        {
          "films" => { "output" => true },
        }
      end
      let(:notion_config) do
        {
          "database" => {
            "id"         => "b0e688e199af4295ae80b67eb52f2e2f",
            "collection" => collection,
          },
        }
      end

      it_behaves_like "a jekyll collection" do
        let(:collection_name) { collection }
      end

      it "stores page into films collection" do
        expect(site.collections[collection].size).to be == NOTION_RESULTS.size
      end

      it "does not store page into posts collection" do
        expect(site.posts.size).to be == 0
      end

      it "each item filename does not contain date" do
        site.collections[collection].each do |film|
          expect(film.path).not_to match(%r!_films/\d{4}-\d{2}-\d{2}-.*.md$!)
        end
      end
    end

    context "when filter is provided" do
      let(:filter) { { :property => "blabla", :checkbox => { :equals => true } } }
      let(:notion_config) do
        {
          "database" => {
            "id"     => "b0e688e199af4295ae80b67eb52f2e2f",
            "filter" => filter,
          },
        }
      end

      it do
        expect(notion_client).to have_received(:database_query)
          .with(hash_including(:filter => filter))
      end
    end

    context "when filter is not provided" do
      it do
        expect(notion_client).not_to have_received(:database_query)
          .with(hash_including(:filter => nil))
      end
    end

    context "when sort is provided" do
      let(:sorts) { [{ :timestamp=> "created_time", :direction => "ascending" }] }
      let(:notion_config) do
        {
          "database" => {
            "id"   => "b0e688e199af4295ae80b67eb52f2e2f",
            "sorts" => sorts,
          },
        }
      end

      it do
        expect(notion_client).to have_received(:database_query)
          .with(hash_including(:sorts => sorts))
      end
    end

    context "when sort is not provided" do
      it do
        expect(notion_client).not_to have_received(:database_query)
          .with(hash_including(:sort => nil))
      end
    end

    context "with fetch_on_watch true" do
      let(:notion_config) do
        {
          "fetch_on_watch" => true,
          "database"       => {
            "id" => "b0e688e199af4295ae80b67eb52f2e2f",
          },
        }
      end

      before(:each) do
        site.process
      end

      it "queries notion database as many times as the site rebuild" do
        expect(notion_client).to have_received(:database_query).twice
      end
    end

    context "when multiple databases" do
      let(:posts_results) { NOTION_RESULTS_2 }
      let(:recipes_results) { NOTION_RESULTS }
      let(:collection) { "recipes" }
      let(:collections) do
        {
          "recipes" => { "output" => true },
        }
      end
      let(:notion_config) do
        {
          "databases" => [
            {
              "id" => "b0e688e199af4295ae80b67eb52f2e2f",
            },
            {
              "id"         => "f0e688e199af4295ae80b67eb52f2e2r",
              "collection" => "recipes",
            },
          ],
        }
      end

      context "with posts database" do
        let(:notion_client) do
          double("Notion::Client", :database_query => { :results => posts_results },
                                   :block_children => NOTION_PAGE_BLOCKS)
        end

        it "stores pages in posts collection" do
          expect(site.posts.size).to be == posts_results.size
        end
      end

      context "with recipes database" do
        let(:notion_client) do
          double("Notion::Client", :database_query => { :results => recipes_results },
                                   :block_children => NOTION_PAGE_BLOCKS)
        end

        it "stores pages in recipes collection" do
          expect(site.collections["recipes"].size).to be == recipes_results.size
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
          double("Notion::Client", :database_query => { :results => NOTION_RESULTS_3 },
                                   :block_children => NOTION_PAGE_BLOCKS)
        end

        it "only local document is kept" do
          # notion pages are processed after Jekyll has generated local documents
          # so, the last element in the collection must be an instance of a Jekyll:Document
          expect(site.posts.last).to be_an_instance_of(Jekyll::Document)
        end
      end
    end
  end

  context "with a notion page" do
    let(:notion_client) do
      double("Notion::Client", :database_query => { :results => nil }, :page => NOTION_PAGE,
:block_children => NOTION_PAGE_BLOCKS)
    end
    let(:notion_config) do
      {
        "page" => {
          "id" => "9dc17c9c-9d2e-469d-bbf0-f9648f3288d3",
        },
      }
    end
    
    include_examples "check settings" do
      let(:query) { :page }
    end

    it_behaves_like "a jekyll page"

    context "when site is processed a second time" do
      before(:each) do
        site.process
      end

      it "pages is not empty" do
        expect(site.pages).not_to be_empty
      end

      it "does not query notion database" do
        expect(notion_client).to have_received(:page).once
      end
    end

    context "when data is declared" do
      let(:notion_config) do
        {
          "page" => {
            "id"   => "9dc17c9c-9d2e-469d-bbf0-f9648f3288d3",
            "data" => "page",
          },
        }
      end

      it_behaves_like "a jekyll data object" do
        let(:data_name) { "page" }
        let(:size) { 19 } # properties + body content
      end

      it "does not create the page" do
        expect(site.pages).to be_empty
      end
    end

    context "with multiple pages" do
      let(:notion_config) do
        {
          "pages" => [{
            "id" => "9dc17c9c-9d2e-469d-bbf0-f9648f3288d3",
          }, {
            "id" => "9dc17c9c-9d2e-469d-bbf0-f9648f3288d3",
          }],
        }
      end

      it_behaves_like "a jekyll page"

      context "when site is processed a second time" do
        before(:each) do
          site.process
        end

        it "pages is not empty" do
          expect(site.pages).not_to be_empty
        end

        it "does not query notion database" do
          expect(notion_client).to have_received(:page).twice
        end
      end
    end
  end
end
