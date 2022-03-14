RSpec.shared_examples "a jekyll page" do
  context "with front matter properties mapped to data" do
    it "id is mapped into page data" do
      expect(site.pages.first.data).to include("id" => NOTION_PAGE.id)
    end

    it "created_time is mapped into page data" do
      expect(site.pages.first.data).to include("created_time" => Time.parse(NOTION_PAGE.created_time))
    end

    it "last_edited_time is mapped into page data" do
      expect(site.pages.first.data).to include("last_edited_time" => Time.parse(NOTION_PAGE.last_edited_time))
    end

    it "cover is mapped into page data" do
      expect(site.pages.first.data).to include("cover" => NOTION_PAGE.cover.dig("external",
                                                                                                                "url"))
    end

    it "icon is mapped into page data" do
      expect(site.pages.first.data).to include("icon" => NOTION_PAGE.icon.emoji)
    end

    it "archived is mapped into page data" do
      expect(site.pages.first.data).to include("archived" => NOTION_PAGE.archived)
    end

    it "archived is mapped into page data" do
      expect(site.pages.first.data).to include("archived" => NOTION_PAGE.archived)
    end

    it "multi_select type is mapped into page data" do
      expected_value = NOTION_PAGE.properties.dig("Multi Select",
                                                           "multi_select").map(&:name)
      expect(site.pages.first.data).to include("multi_select" => expected_value)
    end

    it "select type is mapped into page data" do
      expected_value = NOTION_PAGE.properties.dig("Select", "select").name
      expect(site.pages.first.data).to include("select" => expected_value)
    end

    it "people type is mapped into page data" do
      expected_value = NOTION_PAGE.properties.dig("Person",
                                                           "people").map(&:name)
      expect(site.pages.first.data).to include("person" => expected_value)
    end

    it "number type is mapped into page data" do
      expected_value = NOTION_PAGE.properties.dig("Numbers", "number")
      expect(site.pages.first.data).to include("numbers" => expected_value)
    end

    it "phone_number type is mapped into page data" do
      expected_value = NOTION_PAGE.properties.dig("Phone", "phone_number")
      expect(site.pages.first.data).to include("phone" => expected_value.to_i)
    end

    it "files type is mapped into page data" do
      expected_value = NOTION_PAGE.properties.dig("File", "files").map do |f|
        f.file.url
      end
      expect(site.pages.first.data).to include("file" => expected_value)
    end

    it "email type is mapped into page data" do
      expected_value = NOTION_PAGE.properties.dig("Email", "email")
      expect(site.pages.first.data).to include("email" => expected_value)
    end

    it "checkbox type is mapped into page data" do
      expected_value = NOTION_PAGE.properties.dig("Checkbox", "checkbox")
      expect(site.pages.first.data).to include("checkbox" => expected_value)
    end

    it "title type is mapped into page data" do
      expected_value = NOTION_PAGE.properties.Name.title[0].plain_text
      expect(site.pages.first.data).to include("title" => expected_value)
    end

    it "date type is mapped into page data" do
      expected_value = NOTION_PAGE.properties.dig("Date", "date", "start")
      expect(site.pages.first.data).to include("date" => DateTime.parse(expected_value))
    end
  end

  it "page is stored in destination directory" do
    expected_path = site.pages.first.destination(".")
    expect(File).to exist(expected_path)
  end
end
