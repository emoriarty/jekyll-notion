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
      "notion" => notion_config
    }, overrides))
  end
  let(:site) { Jekyll::Site.new(config) }
  let(:notion_token) { 'secret_0987654321' }
  let(:notion_config) do
    {
      "database" => {
        "id" => "b0e688e199af4295ae80b67eb52f2e2f",
        "collection" => "posts",
        "filter" => { "property" => "Done", "checkbox" => { "equals" => true } },
        "sort" => { "propery" => "Last ordered", "direction" => "ascending" },
        "frontmatter" => {
          "layout" => "post"
        }
      }
    }
  end

  before do
    allow(ENV).to receive(:[]).with('NOTION_TOKEN').and_return(notion_token)
    allow_any_instance_of(Notion::Client).to receive(:database_query).and_return({ results: [] })
  end

  describe 'with NOTION_TOKEN' do
    context 'when not present' do
      let(:notion_token) { nil }

      it 'does not query notion database' do
        expect_any_instance_of(Notion::Client).not_to receive(:database_query)
        site.process
      end
    end

    context 'when empty' do
      let(:notion_token) { '' }

      it 'does not query notion database' do
        expect_any_instance_of(Notion::Client).not_to receive(:database_query)
        site.process
      end
    end

    it 'queries notion database' do
      expect_any_instance_of(Notion::Client).to receive(:database_query)
      site.process
    end
  end

  describe 'with config' do
    context 'when not present' do
      let(:notion_config) { nil }

      it 'does not query notion database' do
        expect_any_instance_of(Notion::Client).not_to receive(:database_query)
        site.process
      end
    end

    context 'when empty' do
      let(:notion_config) { {} }

      it 'does not query notion database' do
        expect_any_instance_of(Notion::Client).not_to receive(:database_query)
        site.process
      end
    end

    context 'when database is not present' do
      let(:notion_config) { { 'database' => nil } }

      it 'does not query notion database' do
        expect_any_instance_of(Notion::Client).not_to receive(:database_query)
        site.process
      end
    end

    context 'when database id is not present' do
      let(:notion_config) { { 'database' => { id: nil, 'collection' => 'posts' } } }

      it 'does not query notion database' do
        expect_any_instance_of(Notion::Client).not_to receive(:database_query)
        site.process
      end
    end

    context 'when collection is not present' do
      let(:notion_config) { { 'database' => { 'id' => 'bh29h', 'collection' => nil } } }

      it 'does not query notion database' do
        expect_any_instance_of(Notion::Client).not_to receive(:database_query)
        site.process
      end
    end

    it 'queries notion database' do
      expect_any_instance_of(Notion::Client).to receive(:database_query)
      site.process
    end
  end
end
