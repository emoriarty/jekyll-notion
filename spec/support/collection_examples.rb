# frozen_string_literal: true

RSpec.shared_examples "a jekyll collection" do |collection_name|
  it "page is stored in destination directory" do
    expected_path = site.collections[collection_name].first.destination(".")
    expect(File).to exist(expected_path)
  end

  it "stores every page title in the collection" do
    site.collections[collection_name].each do |page|
      expect(["Page 1", "Page 2", "Page 3", "lists", "tables",
              "Title: with “double quotes” and ‘single quotes’ and :colons: but forget àccénts: àáâãäāăȧǎȁȃ", "A very long document",]).to be_include(page.title)
    end
  end
end

RSpec.shared_examples "a jekyll collection with existing posts" do |collection_name|
  it "page is stored in destination directory" do
    expected_path = site.collections[collection_name].first.destination(".")
    expect(File).to exist(expected_path)
  end

  it "stores every page title in the collection" do
    site.collections[collection_name].each do |page|
      expect(["Page 1", "Page 2", "Page 3", "lists", "tables",
              "Title: with “double quotes” and ‘single quotes’ and :colons: but forget àccénts: àáâãäāăȧǎȁȃ", "A very long document",
              "My Post",]).to be_include(page.title)
    end
  end
end

RSpec.shared_examples "passes filter to notion client" do
  it "passes filter configuration to Notion client" do
    expect_any_instance_of(Notion::Client).to receive(:database_query)
      .with(hash_including(:filter => filter)).and_call_original

    VCR.use_cassette("notion_database") { site.process }
  end
end

RSpec.shared_examples "passes sorts to notion client" do
  it "passes sorts configuration to Notion client" do
    expect_any_instance_of(Notion::Client).to receive(:database_query)
      .with(hash_including(:sorts => sorts)).and_call_original

    VCR.use_cassette("notion_database") { site.process }
  end
end

RSpec.shared_examples "passes filter and sorts to notion client" do
  it "passes both filter and sorts configuration to Notion client" do
    expect_any_instance_of(Notion::Client).to receive(:database_query)
      .with(hash_including(:filter => filter, :sorts => sorts)).and_call_original

    VCR.use_cassette("notion_database") { site.process }
  end
end

RSpec.shared_examples "filters posts correctly" do |expected_count|
  it "fetches the expected number of filtered pages" do
    VCR.use_cassette("notion_database") { site.process }

    expect(site.posts.size).to eq(expected_count)
  end
end

RSpec.shared_examples "sorts posts by created_time ascending" do
  it "sorts posts in ascending order by created_time" do
    VCR.use_cassette("notion_database") { site.process }

    # With ascending sort by created_time, posts should be ordered from oldest to newest
    created_times = site.posts.map { |post| post.data["created_time"] }

    expect(created_times).to eq(created_times.sort)
  end
end

RSpec.shared_examples "sorts posts by created_time descending" do
  it "sorts posts in descending order by created_time" do
    VCR.use_cassette("notion_database") { site.process }

    # With descending sort by created_time, posts should be ordered from newest to oldest
    created_times = site.posts.map { |post| post.data["created_time"] }

    expect(created_times).to eq(created_times.sort.reverse)
  end
end
