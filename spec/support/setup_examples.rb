RSpec.shared_examples "setup without configuration" do
  let(:notion_config) { nil }

  before do
    allow(Jekyll.logger).to receive(:warn)
    allow(Jekyll.logger).to receive(:error)
    allow(Notion::Client).to receive(:new)

    site.process
  end

  context "when the notion property is not declared" do
    let(:config) do
      Jekyll.configuration({
        "source"      => source_dir,
        "destination" => dest_dir,
      })
    end

    it "no setup is carried" do
      expect(Notion::Client).not_to have_received(:new)
    end

    it "no error is logged" do
      expect(Jekyll.logger).not_to have_received(:error)
    end

    it "no warning is logged" do
      expect(Jekyll.logger).not_to have_received(:warn)
    end
  end

  context "when notion > databases property is empty" do
    let(:config) do
      Jekyll.configuration({
        "source"      => source_dir,
        "destination" => dest_dir,
        "notion"      => { :databases => nil },
      })
    end

    it "logs a warning" do
      expect(Jekyll.logger).not_to have_received(:warn).with(anything,
                                                             a_string_matching("skipping import"))
    end

    it "no setup is carried" do
      expect(Notion::Client).not_to have_received(:new)
    end
  end

  context "when notion > pages property is empty" do
    let(:config) do
      Jekyll.configuration({
        "source"      => source_dir,
        "destination" => dest_dir,
        "notion"      => { :pages => nil },
      })
    end

    it "logs a warning" do
      expect(Jekyll.logger).not_to have_received(:warn).with(anything,
                                                             a_string_matching("skipping import"))
    end

    it "no setup is carried" do
      expect(Notion::Client).not_to have_received(:new)
    end
  end
end

RSpec.shared_examples "setup with deprecated options" do
  before do
    allow(Jekyll.logger).to receive(:warn)
    allow(NotionToMd::Database).to receive(:call)
    allow(NotionToMd::Page).to receive(:call)
    allow(JekyllNotion::Generators::Collection).to receive(:call)
    allow(JekyllNotion::Generators::Page).to receive(:call)

    site.process
  end

  context "with fetch_on_watch" do
    let(:config) do
      Jekyll.configuration({
        "source"      => source_dir,
        "destination" => dest_dir,
        "notion"      => { "fetch_on_watch" => false, "databases" => [:id => "XXXX"],
"pages" => ["id" => "XXXX"], },
      })
    end

    it "logs a warning message" do
      expect(Jekyll.logger).to have_received(:warn).with(anything,
                                                         a_string_matching("fetch_on_watch"))
    end
  end

  context "with database" do
    let(:config) do
      Jekyll.configuration({
        "source"      => source_dir,
        "destination" => dest_dir,
        "notion"      => { "database" => { :id => "XXXX" }, "pages" => ["id" => "XXXX"] },
      })
    end

    it "logs a warning message" do
      expect(Jekyll.logger).to have_received(:warn).with(anything,
                                                         a_string_matching("`database` key is deprecated"))
    end
  end

  context "with page" do
    let(:config) do
      Jekyll.configuration({
        "source"      => source_dir,
        "destination" => dest_dir,
        "notion"      => { "databases" => [:id => "XXXX"], "page" => { "id" => "XXXX" } },
      })
    end

    it "logs a warning message" do
      expect(Jekyll.logger).to have_received(:warn).with(anything,
                                                         a_string_matching("`page` key is deprecated"))
    end
  end
end
