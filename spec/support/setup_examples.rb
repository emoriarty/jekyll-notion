RSpec.shared_examples "setup with deprecated options" do
  context "with fetch_on_watch" do
    let(:notion_config) do
      { "fetch_on_watch" => false }
    end

    before do
      allow(Jekyll.logger).to receive(:warn)

      site.process
    end

    it "logs a warning message" do
      expect(Jekyll.logger).to have_received(:warn).with(anything, a_string_matching("fetch_on_watch"))
    end
  end
end
