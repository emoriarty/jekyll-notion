RSpec.shared_examples "a jekyll data object" do |data_name|
  it "stores id into the data object" do
    expect(site.data[data_name]).to include("id" => "9dc17c9c-9d2e-469d-bbf0-f9648f3288d3")
  end

  it "stores created_time into the data object" do
    expect(site.data[data_name]).to include("created_time" => "2022-01-23T12:31:00.000Z")
  end

  it "stores last_edited_time into the data object" do
    expect(site.data[data_name]).to include("last_edited_time" => "2023-12-02T22:09:00.000Z")
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
    expect(site.data[data_name]).to include("select" => "select1")
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
    expect(site.data[data_name]).to include("file" => ["https://prod-files-secure.s3.us-west-2.amazonaws.com/4783548e-2442-4bf3-bb3d-ed4ddd2dcdf0/23e8b74e-86d1-4b3a-bd9a-dd0415a954e4/me.jpeg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45HZZMZUHI%2F20231203%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20231203T065050Z&X-Amz-Expires=3600&X-Amz-Signature=c0b4d6da2da758e947be9abec351edebc1fdb115805aec69b85835954b0a597a&X-Amz-SignedHeaders=host&x-id=GetObject"])
  end

  it "stores email into the data object" do
    expect(site.data[data_name]).to include("email" => "hola@test.com")
  end

  it "stores checkbox into the data object" do
    expect(site.data[data_name]).to include("checkbox" => "false")
  end

  it "stores title into the data object" do
    expect(site.data[data_name]).to include("title" => "Page 1")
  end

  it "stores date into the data object" do
    expect(site.data[data_name]).to include("date" => Time.parse("2021-12-30"))
  end

  it "contains the content property" do
    expect(site.data[data_name]).to have_key("content")
  end

  it "stores the page body into the content property" do
    expect(site.data[data_name]["content"]).to include("Lorem ipsum")
  end
end
