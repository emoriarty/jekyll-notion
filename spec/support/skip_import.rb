
RSpec.shared_examples "skips import" do |page_name|
  before do
    allow(Notion::Client).to receive(:new)
  end

  it "does not instantiate Notion::Client" do
    expect(Notion::Client).not_to have_received(:new)
  end
end
