RSpec.shared_examples "a jekyll collection" do |collection_name|
  context "with front matter properties mapped to data" do
    it "id is mapped into collection doc" do
      expect(site.collections[collection_name].first.data).to include("id" => "7a33528a-8a38-4148-bdb1-ca5a62a0ce3c")
    end

    it "created_time is mapped into collection doc" do
      expect(site.collections[collection_name].first.data).to include("created_time" => Time.parse("2022-09-17 15:03:00.000000000 +0000"))
    end

    it "last_edited_time is mapped into collection doc" do
      expect(site.collections[collection_name].first.data).to include("last_edited_time" => Time.parse("2022-10-04 20:05:00.000000000 +0000"))
    end

    it "cover is mapped into collection doc" do
      expect(site.collections[collection_name].first.data).to include("cover" => nil)
    end

    it "icon is mapped into collection doc" do
      expect(site.collections[collection_name].first.data).to include("icon" => nil)
    end

    it "archived is mapped into collection doc" do
      expect(site.collections[collection_name].first.data).to include("archived" => false)
    end
  end

  it "page is stored in destination directory" do
    expected_path = site.collections[collection_name].first.destination(".")
    expect(File).to exist(expected_path)
  end

  context "when site is processed a second time" do
    before(:each) do
      VCR.use_cassette("notion_database") { site.process }
    end

    it "the posts collection is not empty" do
      expect(site.collections[collection_name]).not_to be_empty
    end

    it "the posts collection is the same length" do
      expect(site.collections[collection_name].size).to be(8)
    end
  end
end
