# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Setup: missing notion configuration" do
  let(:source_dir) { SOURCE_DIR }
  let(:dest_dir)   { DEST_DIR }
  let(:site)       { Jekyll::Site.new(config) }

  before do
    allow(Jekyll.logger).to receive(:warn)
    allow(Jekyll.logger).to receive(:error)
    allow(Notion::Client).to receive(:new)
  end

  subject(:build!) { site.process }

  context "when the notion property is not declared" do
    let(:config) do
      Jekyll.configuration(
        "source"      => source_dir,
        "destination" => dest_dir
      )
    end

    it "does not instantiate Notion::Client when not configured" do
      build!
      expect(Notion::Client).not_to have_received(:new)
    end

    it "does not log any error" do
      build!
      expect(Jekyll.logger).not_to have_received(:error)
    end

    it "does not log any warning" do
      build!
      expect(Jekyll.logger).not_to have_received(:warn)
    end
  end

  context "when the notion property is declared but nil" do
    let(:config) do
      Jekyll.configuration(
        "source"      => source_dir,
        "destination" => dest_dir,
        "notion"      => nil
      )
    end

    it "does not instantiate Notion::Client when not configured" do
      build!
      expect(Notion::Client).not_to have_received(:new)
    end

    it "logs a warning about skipping import" do
      build!
      expect(Jekyll.logger).to have_received(:warn).with(
        a_string_matching(%r!Jekyll Notion:!i),
        a_string_matching(%r!skipping import!i)
      )
    end
  end

  context "when notion > databases is nil" do
    let(:config) do
      Jekyll.configuration(
        "source"      => source_dir,
        "destination" => dest_dir,
        "notion"      => { "databases" => nil }
      )
    end

    it "logs a warning about skipping import" do
      build!
      expect(Jekyll.logger).to have_received(:warn).with(
        a_string_matching(%r!Jekyll Notion:!i),
        a_string_matching(%r!skipping import!i)
      )
    end

    it "does not set up a Notion client" do
      build!
      expect(Notion::Client).not_to have_received(:new)
    end
  end

  context "when notion > pages is nil" do
    let(:config) do
      Jekyll.configuration(
        "source"      => source_dir,
        "destination" => dest_dir,
        "notion"      => { "pages" => nil }
      )
    end

    it "logs a warning about skipping import" do
      build!
      expect(Jekyll.logger).to have_received(:warn).with(
        a_string_matching(%r!Jekyll Notion:!i),
        a_string_matching(%r!skipping import!i)
      )
    end

    it "does not set up a Notion client" do
      build!
      expect(Notion::Client).not_to have_received(:new)
    end
  end
end
