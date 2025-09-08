# frozen_string_literal: true

RSpec.shared_examples "a page is rendered correctly" do |page_name|
  it "imports and generates page" do
    page = site.pages.find { |p| p.basename == page_name }

    raise "`#{page_name}` not found" if page.nil?

    expect_to_match_page(page)
  end
end

RSpec.shared_examples "a page is not rendered" do |page_name|
  it "imports and generates page" do
    page = site.pages.find { |p| p.basename == page_name }

    expect(page).to be_nil
  end
end

RSpec.shared_examples "all pages are renderer correctly" do
  it "imports and generates pages" do
    raise "The `pages` collection is empty" if site.pages.empty?

    site.pages.each { |page| expect_to_match_page(page) }
  end
end

RSpec.shared_examples "a collection is renderded correctly" do |collection_name|
  it "imports database and generates documents" do
    raise "The `#{collection_name}` collection is empty" if site.collections[collection_name].empty?

    site.collections[collection_name].each do |document|
      expect_to_match_document(document)
    end
  end
end

RSpec.shared_examples "a collection is not renderded" do |collection_name|
  it "imports database and generates documents" do
    expect(site.send(collection_name.to_sym)).to be_empty
  end
end
