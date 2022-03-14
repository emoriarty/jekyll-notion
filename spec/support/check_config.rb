RSpec.shared_examples "check settings" do
  context "when NOTION_TOKEN not present" do
    let(:notion_token) { nil }

    it "does not do a request to notion" do
      expect(notion_client).not_to have_received(query)
    end
  end

  context "when NOTION_TOKEN is empty" do
    let(:notion_token) { "" }

    it "does not do a request to notion" do
      expect(notion_client).not_to have_received(query)
    end
  end

  context "when config is not present" do
    let(:notion_config) { nil }

    it "does not do a request to notion" do
      expect(notion_client).not_to have_received(query)
    end
  end

  context "when config is empty" do
    let(:notion_config) { {} }

    it "does not do a request to notion" do
      expect(notion_client).not_to have_received(query)
    end
  end
end
