# frozen_string_literal: true

RSpec.shared_examples "a jekyll page" do |page_name|
  let(:page) do
    site.pages.find { _1.basename == page_name }
  end

  it "stores id into page data" do
    expect(page.data).to include("id" => "9dc17c9c-9d2e-469d-bbf0-f9648f3288d3")
  end

  it "stores created_time into page data" do
    expect(page.data).to include("created_time" => Time.parse("2022-01-23 12:31:00.000000000 +0000"))
  end

  it "stores last_edited_time into page data" do
    expect(page.data).to include("last_edited_time" => Time.parse("2025-08-29 12:35:00.000000000 +0000"))
  end

  it "stores cover into page data" do
    expect(page.data).to include("cover" => "https://www.notion.so/images/page-cover/met_canaletto_1720.jpg")
  end

  it "stores icon into page data" do
    expect(page.data).to include("icon" => "💥")
  end

  it "stores archived into page data" do
    expect(page.data).to include("archived" => false)
  end

  it "stores multi_select into page data" do
    expected_value = %w(mselect1 mselect2 mselect3)
    expect(page.data).to include("multi_select" => expected_value)
  end

  it "stores select into page data" do
    expect(page.data).to include("select" => "select1")
  end

  it "stores people into page data" do
    expect(page.data).to include("person" => ["Armando Broncas"])
  end

  it "stores number into page data" do
    expect(page.data).to include("numbers" => 12)
  end

  it "stores phone_number into page data" do
    expect(page.data).to include("phone" => 983_788_379)
  end

  it "stores files into page data" do
    expect(page.data).to include(
      "file" => array_including(
        start_with("https://prod-files-secure.s3.us-west-2.amazonaws.com/")
      )
    )
  end

  it "stores email into page data" do
    expect(page.data).to include("email" => "hola@test.com")
  end

  it "stores checkbox into page data" do
    expect(page.data).to include("checkbox" => false)
  end

  it "stores title into page data" do
    expect(page.data).to include("title" => "Page 1")
  end

  it "stores date into page data" do
    expect(page.data).to include("date" => Time.parse("2021-12-30"))
  end

  it "page is stored in destination directory" do
    expect(File).to exist(page.destination("."))
  end
end
