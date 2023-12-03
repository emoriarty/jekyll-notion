RSpec.shared_examples "a jekyll collection" do |collection_name|
  it "page is stored in destination directory" do
    expected_path = site.collections[collection_name].first.destination(".")
    expect(File).to exist(expected_path)
  end

  it "stores every page title in the collection" do
    site.collections[collection_name].each do |page|
      expect(["Page 1", "Page 2", "Page 3", "lists", "tables", "Title: with “double quotes” and ‘single quotes’ and :colons:"]).to be_include(page.title)
    end
  end

  context "when site is processed a second time" do
    before(:each) do
      VCR.use_cassette("notion_database") { site.process }
    end

    it "keeps the collection with the same length" do
      expect(site.collections[collection_name].size).to be(6)
    end
  end
end
