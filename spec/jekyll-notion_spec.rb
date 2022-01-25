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
  let(:properties) { nil }
  let(:notion_config) do
    {
      "database" => {
        "id"          => "b0e688e199af4295ae80b67eb52f2e2f",
        "collection"  => collection,
        "filter"      => filter,
        "sort"        => sort,
        "frontmatter" => frontmatter,
        "properties"  => properties,
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
        expect(film.path).not_to match(%r!_films/\d{4}-\d{2}-\d{2}-.*.md$!)
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

  it "adds id to page data" do
    site.posts.each_with_index do |post, index|
      id = notion_client_query[index].id
      expect(post.data).to include("id" => id)
    end
  end

  it "adds title to page data" do
    site.posts.each_with_index do |post, index|
      title = notion_client_query[index].properties.Name.title[0].plain_text
      expect(post.data).to include("title" => title)
    end
  end

  it "adds cover to page data" do
    site.posts.each_with_index do |post, index|
      cover = notion_client_query[index].dig("cover", "external", "url")
      expect(post.data).to include("cover" => cover)
    end
  end

  it "adds icon to page data" do
    site.posts.each_with_index do |post, index|
      icon = notion_client_query[index].dig("icon", "emoji")
      expect(post.data).to include("icon" => icon)
    end
  end

  it "adds date to page data" do
    site.posts.each_with_index do |post, index|
      date = notion_client_query[index].created_time
      expect(post.data).to include("date" => Time.parse(date))
    end
  end

  context "when custom properties are present in config" do
    it "adds a multi_select type to page data" do
      site.posts.each_with_index do |post, index|
        multi_select = notion_client_query[index].properties.dig("Multi Select",
                                                                 "multi_select").map(&:name).join(", ")
        expect(post.data).to include("multi_select" => multi_select.presence)
      end
    end

    it "adds a select type to page data" do
      site.posts.each_with_index do |post, index|
        select = notion_client_query[index].properties.dig("Select", "select").name
        expect(post.data).to include("select" => select.presence)
      end
    end

    it "adds a people type to page data" do
      site.posts.each_with_index do |post, index|
        person = notion_client_query[index].properties.dig("Person",
                                                           "people").map(&:name).join(", ")
        if person.presence.nil?
          expect(post.data).not_to include("person")
        else
          expect(post.data).to include("person" => person.presence)
        end
      end
    end

    it "adds a files type to page data" do
      site.posts.each_with_index do |post, index|
        file = notion_client_query[index].properties.dig("File", "files").map do |f|
          f.file.url
        end.join(", ")
        if file.presence.nil?
          expect(post.data).not_to include("file")
        else
          expect(post.data).to include("file" => file.presence)
        end
      end
    end

    it "adds a number type to page data" do
      site.posts.each_with_index do |post, index|
        number = notion_client_query[index].properties.dig("Numbers", "number")
        if number.presence.nil?
          expect(post.data).not_to include("numbers")
        else
          expect(post.data).to include("numbers" => number)
        end
      end
    end

    it "adds a phone_number type to page data" do
      site.posts.each_with_index do |post, index|
        phone_number = notion_client_query[index].properties.dig("Phone", "phone_number")
        if phone_number.nil?
          expect(post.data).not_to include("phone")
        else
          expect(post.data).to include("phone" => phone_number)
        end
      end
    end

    it "adds an email type to page data" do
      site.posts.each_with_index do |post, index|
        email = notion_client_query[index].properties.dig("Email", "email")
        if email.nil?
          expect(post.data).not_to include("email")
        else
          expect(post.data).to include("email" => email)
        end
      end
    end

    it "adds a checkbox type to page data" do
      site.posts.each_with_index do |post, index|
        checkbox = notion_client_query[index].properties.dig("Checkbox", "checkbox")
        expect(post.data).to include("checkbox" => checkbox)
      end
    end

    it "adds a date type to page data" do
      site.posts.each_with_index do |post, index|
        date = notion_client_query[index].properties.dig("New Date", "date", "start")
        if date.presence.nil?
          expect(post.data).not_to include("new_date")
        else
          expect(post.data).to include("new_date" => Date.parse(date))
        end
      end
    end
  end

  context "when a custom and default property have the same name (date)" do
    it "cannot overwrite the default property" do
      site.posts.each_with_index do |post, index|
        date = notion_client_query[index].properties.dig("Date", "date", "start")
        expect(post.data["date"]).not_to eq(date)
      end
    end

    it "default property keeps intact" do
      site.posts.each_with_index do |post, index|
        created_time = notion_client_query[index].created_time
        expect(post.data["date"]).to eq(Jekyll::Utils.parse_date(created_time))
      end
    end
  end
end
