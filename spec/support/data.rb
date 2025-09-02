# frozen_string_literal: true

RSpec.shared_examples "a jekyll data object" do
  it "creates a the declared key in data object" do
    expect(site.data).to have_key(data_name)
  end

  it "contains the same size as the returned list" do
    expect(site.data[data_name].size).to be == size
  end

  context "when site is processed a second time" do
    before(:each) do
      site.process
    end

    it "the data object is not nil" do
      expect(site.data[data_name]).not_to be_nil
    end
  end
end
