RSpec.shared_examples "a jekyll data object" do |data_name|
  it "stores id into the data object" do
    expect(site.data[data_name]).to include("id" => "9dc17c9c-9d2e-469d-bbf0-f9648f3288d3")
  end

  it "stores created_time into the data object" do
    expect(site.data[data_name]).to include("created_time" => "2022-01-23T12:31:00+00:00".dump)
  end

  it "stores last_edited_time into the data object" do
    expect(site.data[data_name]).to include("last_edited_time" => "2022-10-04T20:23:00+00:00".dump)
  end

  it "stores cover into the data object" do
    expect(site.data[data_name]).to include("cover" => "https://www.notion.so/images/page-cover/met_canaletto_1720.jpg")
  end

  it "stores icon into the data object" do
    expect(site.data[data_name]).to include("icon" => "💥")
  end

  it "stores archived into the data object" do
    expect(site.data[data_name]).to include("archived" => false)
  end

  it "stores multi_select into the data object" do
    expected_value = %w(mselect1 mselect2 mselect3)
    expect(site.data[data_name]).to include("multi_select" => expected_value)
  end

  it "stores select into the data object" do
    expect(site.data[data_name]).to include("select" => "select1".dump)
  end

  it "stores people into the data object" do
    expect(site.data[data_name]).to include("person" => ["Armando Broncas"])
  end

  it "stores number into the data object" do
    expect(site.data[data_name]).to include("numbers" => 12)
  end

  it "stores phone_number into the data object" do
    expect(site.data[data_name]).to include("phone" => "983788379")
  end

  it "stores files into the data object" do
    expect(site.data[data_name]).to include("file" => ["https://s3.us-west-2.amazonaws.com/secure.notion-static.com/23e8b74e-86d1-4b3a-bd9a-dd0415a954e4/me.jpeg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20230906%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20230906T093545Z&X-Amz-Expires=3600&X-Amz-Signature=f7d32fc1cd829865b5d1f2a5aaf11b42dd93585892c8b6091245d1fbb519fc0a&X-Amz-SignedHeaders=host&x-id=GetObject"])
  end

  it "stores email into the data object" do
    expect(site.data[data_name]).to include("email" => "hola@test.com")
  end

  it "stores checkbox into the data object" do
    expect(site.data[data_name]).to include("checkbox" => "false")
  end

  it "stores title into the data object" do
    expect(site.data[data_name]).to include("title" => "Page 1".dump)
  end

  it "stores date into the data object" do
    expect(site.data[data_name]).to include("date" => "2022-01-28")
  end

  it "contains the content property" do
    expect(site.data[data_name]).to have_key("content")
  end

  it "stores the page body into the content property" do
    expect(site.data[data_name]["content"]).to include("Lorem ipsum")
  end
end
