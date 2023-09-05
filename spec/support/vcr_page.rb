RSpec.shared_examples "a jekyll page" do
  it "stores id into page data" do
    expect(site.pages.first.data).to include("id" => "9dc17c9c-9d2e-469d-bbf0-f9648f3288d3")
  end

  it "stores created_time into page data" do
    expect(site.pages.first.data).to include("created_time" => Time.parse("2022-01-23T12:31:00.000Z"))
  end

  it "stores last_edited_time into page data" do
    expect(site.pages.first.data).to include("last_edited_time" => Time.parse("2022-10-04T20:23:00.000Z"))
  end

  it "stores cover into page data" do
    expect(site.pages.first.data).to include("cover" => "https://www.notion.so/images/page-cover/met_canaletto_1720.jpg")
  end

  it "stores icon into page data" do
    expect(site.pages.first.data).to include("icon" => "💥")
  end

  it "stores archived into page data" do
    expect(site.pages.first.data).to include("archived" => false)
  end

  it "stores multi_select into page data" do
    expected_value = %w(mselect1 mselect2 mselect3)
    expect(site.pages.first.data).to include("multi_select" => expected_value)
  end

  it "stores select into page data" do
    expect(site.pages.first.data).to include("select" => "select1")
  end

  it "stores people into page data" do
    expect(site.pages.first.data).to include("person" => ["Julie Guiraud"])
  end

  it "stores number into page data" do
    expect(site.pages.first.data).to include("numbers" => 12)
  end

  it "stores phone_number into page data" do
    expect(site.pages.first.data).to include("phone" => 983_788_379)
  end

  it "stores files into page data" do
    expect(site.pages.first.data).to include("file" => ["https://s3.us-west-2.amazonaws.com/secure.notion-static.com/23e8b74e-86d1-4b3a-bd9a-dd0415a954e4/me.jpeg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20230904%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20230904T103127Z&X-Amz-Expires=3600&X-Amz-Signature=1215cb42dc11192ac75ce34f709b1e09f8a3cfec232e34e97958f866bc310453&X-Amz-SignedHeaders=host&x-id=GetObject"])
  end

  it "stores email into page data" do
    expect(site.pages.first.data).to include("email" => "hola@test.com")
  end

  it "stores checkbox into page data" do
    expect(site.pages.first.data).to include("checkbox" => false)
  end

  it "stores title into page data" do
    expect(site.pages.first.data).to include("title" => "Page 1")
  end

  it "stores date into page data" do
    expect(site.pages.first.data).to include("date" => DateTime.parse("2022-01-28"))
  end

  it "page is stored in destination directory" do
    expect(File).to exist(site.pages.first.destination("."))
  end
end
