RSpec.shared_examples "a jekyll collection" do
  context "with front matter properties mapped to data" do
    it "id is mapped into collection doc" do
      expect(site.collections[collection_name].first.data).to include("id" => NOTION_RESULTS.first.id)
    end

    it "created_time is mapped into collection doc" do
      expect(site.collections[collection_name].first.data).to include("created_time" => Time.parse(NOTION_RESULTS.first.created_time))
    end

    it "last_edited_time is mapped into collection doc" do
      expect(site.collections[collection_name].first.data).to include("last_edited_time" => Time.parse(NOTION_RESULTS.first.last_edited_time))
    end

    it "cover is mapped into collection doc" do
      expect(site.collections[collection_name].first.data).to include("cover" => NOTION_RESULTS.first.cover.dig("external",
                                                                                                                "url"))
    end

    it "icon is mapped into collection doc" do
      expect(site.collections[collection_name].first.data).to include("icon" => NOTION_RESULTS.first.icon.emoji)
    end

    it "archived is mapped into collection doc" do
      expect(site.collections[collection_name].first.data).to include("archived" => NOTION_RESULTS.first.archived)
    end

    it "archived is mapped into collection doc" do
      expect(site.collections[collection_name].first.data).to include("archived" => NOTION_RESULTS.first.archived)
    end

    it "multi_select type is mapped into collection doc" do
      expected_value = NOTION_RESULTS.first.properties.dig("Multi Select",
                                                           "multi_select").map(&:name)
      expect(site.collections[collection_name].first.data).to include("multi_select" => expected_value)
    end

    it "select type is mapped into collection doc" do
      expected_value = NOTION_RESULTS.first.properties.dig("Select", "select").name
      expect(site.collections[collection_name].first.data).to include("select" => expected_value)
    end

    it "people type is mapped into collection doc" do
      expected_value = NOTION_RESULTS.first.properties.dig("Person",
                                                           "people").map(&:name)
      expect(site.collections[collection_name].first.data).to include("person" => expected_value)
    end

    it "number type is mapped into collection doc" do
      expected_value = NOTION_RESULTS.first.properties.dig("Numbers", "number")
      expect(site.collections[collection_name].first.data).to include("numbers" => expected_value)
    end

    it "phone_number type is mapped into collection doc" do
      expected_value = NOTION_RESULTS.first.properties.dig("Phone", "phone_number")
      expect(site.collections[collection_name].first.data).to include("phone" => expected_value.to_i)
    end

    it "files type is mapped into collection doc" do
      expected_value = NOTION_RESULTS.first.properties.dig("File", "files").map do |f|
        f.file.url
      end
      expect(site.collections[collection_name].first.data).to include("file" => expected_value)
    end

    it "email type is mapped into collection doc" do
      expected_value = NOTION_RESULTS.first.properties.dig("Email", "email")
      expect(site.collections[collection_name].first.data).to include("email" => expected_value)
    end

    it "checkbox type is mapped into collection doc" do
      expected_value = NOTION_RESULTS.first.properties.dig("Checkbox", "checkbox")
      expect(site.collections[collection_name].first.data).to include("checkbox" => expected_value)
    end

    it "title type is mapped into collection doc" do
      expected_value = NOTION_RESULTS.first.properties.Name.title[0].plain_text
      expect(site.collections[collection_name].first.data).to include("title" => expected_value)
    end

    it "date type is mapped into collection doc" do
      expected_value = NOTION_RESULTS.first.properties.dig("Date", "date", "start")
      expect(site.collections[collection_name].first.data).to include("date" => Time.parse(expected_value))
    end
  end

  it "page is stored in destination directory" do
    expected_path = site.collections[collection_name].first.destination(".")
    expect(File).to exist(expected_path)
  end

  context "when site is processed a second time" do
    before(:each) do
      site.process
    end

    it "the posts collection is not empty" do
      expect(site.collections[collection_name]).not_to be_empty
    end

    it "the posts collection is the same length" do
      expect(site.collections[collection_name].size).to be(NOTION_RESULTS.size)
    end

    it "does not query notion database" do
      expect(notion_client).to have_received(:database_query).once
    end
  end
end
