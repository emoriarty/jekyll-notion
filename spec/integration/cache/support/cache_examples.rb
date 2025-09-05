RSpec.shared_examples "pages are cached in the specified folder" do |cache_dir|
  def compose_filepath(path, title, page_id)
    File.join(path, "pages",
              "#{Jekyll::Utils.slugify(title)}-#{page_id.delete("-")}.yml")
  end

  def expect_file_to_be(path, page)
    filepath = compose_filepath(path, page.data["title"], page.data["id"])

    expect(File.exist?(filepath)).to be true
  end

  it "creates cache files in the specified folder" do
    site.pages.each { expect_file_to_be(cache_dir, _1) }
    site.posts.each { expect_file_to_be(cache_dir, _1) }
  end
end
