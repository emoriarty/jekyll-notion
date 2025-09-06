# frozen_string_literal: true

require "spec_helper"

RSpec.describe JekyllNotion::Generator do
  let(:site) { instance_double(Jekyll::Site, :config => site_config) }
  let(:site_config) { { "notion" => notion_config } }
  let(:notion_config) { {} }
  let(:generator) { described_class.new }

  before do
    generator.instance_variable_set(:@site, site)
    allow(ENV).to receive(:fetch).with("NOTION_TOKEN", nil).and_return("test-token")
    allow(Jekyll.logger).to receive(:warn)
    allow(Jekyll.logger).to receive(:info)
  end

  describe "#config_databases" do
    context "when databases are configured" do
      let(:notion_config) { { "databases" => [{ "id" => "db1" }, { "id" => "db2" }] } }

      it "returns the databases array" do
        expect(generator.send(:config_databases)).to eq([{ "id" => "db1" }, { "id" => "db2" }])
      end
    end

    context "when databases are not configured" do
      let(:notion_config) { {} }

      it "returns empty array" do
        expect(generator.send(:config_databases)).to eq([])
      end
    end
  end

  describe "#config_pages" do
    context "when pages are configured" do
      let(:notion_config) { { "pages" => [{ "id" => "page1" }, { "id" => "page2" }] } }

      it "returns the pages array" do
        expect(generator.send(:config_pages)).to eq([{ "id" => "page1" }, { "id" => "page2" }])
      end
    end

    context "when pages are not configured" do
      let(:notion_config) { {} }

      it "returns empty array" do
        expect(generator.send(:config_pages)).to eq([])
      end
    end
  end

  describe "#notion_token?" do
    context "when NOTION_TOKEN is set" do
      before { allow(ENV).to receive(:[]).with("NOTION_TOKEN").and_return("valid-token") }

      it "returns true" do
        expect(generator.send(:notion_token?)).to be true
      end
    end

    context "when NOTION_TOKEN is nil" do
      before { allow(ENV).to receive(:[]).with("NOTION_TOKEN").and_return(nil) }

      it "returns false and logs warning" do
        expect(Jekyll.logger).to receive(:warn).with("Jekyll Notion:", %r!NOTION_TOKEN is missing!)
        expect(generator.send(:notion_token?)).to be false
      end
    end

    context "when NOTION_TOKEN is empty" do
      before { allow(ENV).to receive(:[]).with("NOTION_TOKEN").and_return("") }

      it "returns false and logs warning" do
        expect(Jekyll.logger).to receive(:warn).with("Jekyll Notion:", %r!NOTION_TOKEN is missing!)
        expect(generator.send(:notion_token?)).to be false
      end
    end
  end

  describe "#config?" do
    context "when site has notion config key" do
      context "with valid databases config" do
        let(:notion_config) { { "databases" => [{ "id" => "db1" }] } }

        it "returns true" do
          expect(generator.send(:config?)).to be true
        end
      end

      context "with valid pages config" do
        let(:notion_config) { { "pages" => [{ "id" => "page1" }] } }

        it "returns true" do
          expect(generator.send(:config?)).to be true
        end
      end

      context "with both databases and pages" do
        let(:notion_config) do
          {
            "databases" => [{ "id" => "db1" }],
            "pages"     => [{ "id" => "page1" }],
          }
        end

        it "returns true" do
          expect(generator.send(:config?)).to be true
        end
      end

      context "with empty config" do
        let(:notion_config) { {} }

        it "returns false and logs warning" do
          expect(Jekyll.logger).to receive(:warn).with("Jekyll Notion:",
                                                       %r!databases.*or.*pages.*not declared!)
          expect(generator.send(:config?)).to be false
        end
      end

      context "with empty databases and pages arrays" do
        let(:notion_config) { { "databases" => [], "pages" => [] } }

        it "returns false and logs warning" do
          expect(Jekyll.logger).to receive(:warn).with("Jekyll Notion:",
                                                       %r!databases.*or.*pages.*not declared!)
          expect(generator.send(:config?)).to be false
        end
      end
    end

    context "when site has no notion config key" do
      let(:site_config) { {} }

      it "returns false" do
        expect(generator.send(:config?)).to be false
      end
    end
  end

  describe "#cache?" do
    context "when cache is explicitly configured" do
      context "with cache: true" do
        let(:notion_config) { { "cache" => true } }

        it "returns true" do
          expect(generator.send(:cache?)).to be true
        end
      end

      context "with cache: false" do
        let(:notion_config) { { "cache" => false } }

        it "returns false" do
          expect(generator.send(:cache?)).to be false
        end
      end

      context "with cache: nil" do
        let(:notion_config) { { "cache" => nil } }

        it "returns true (nil is truthy for cache)" do
          expect(generator.send(:cache?)).to be true
        end
      end

      context "with cache: '0'" do
        let(:notion_config) { { "cache" => "0" } }

        it "returns false (0 is falsy for cache)" do
          expect(generator.send(:cache?)).to be false
        end
      end

      context "with cache: 'false'" do
        let(:notion_config) { { "cache" => "false" } }

        it "returns false" do
          expect(generator.send(:cache?)).to be false
        end
      end

      context "with cache: 'no'" do
        let(:notion_config) { { "cache" => "no" } }

        it "returns false" do
          expect(generator.send(:cache?)).to be false
        end
      end
    end

    context "when cache is not configured but ENV var is set" do
      let(:notion_config) { {} }

      context "with JEKYLL_NOTION_CACHE=1" do
        before { allow(ENV).to receive(:fetch).with("JEKYLL_NOTION_CACHE", nil).and_return("1") }

        it "returns true" do
          expect(generator.send(:cache?)).to be true
        end
      end

      context "with JEKYLL_NOTION_CACHE=0" do
        before { allow(ENV).to receive(:fetch).with("JEKYLL_NOTION_CACHE", nil).and_return("0") }

        it "returns false" do
          expect(generator.send(:cache?)).to be false
        end
      end

      context "with JEKYLL_NOTION_CACHE=false" do
        before do
          allow(ENV).to receive(:fetch).with("JEKYLL_NOTION_CACHE", nil).and_return("false")
        end

        it "returns false" do
          expect(generator.send(:cache?)).to be false
        end
      end

      context "with no ENV var" do
        before { allow(ENV).to receive(:fetch).with("JEKYLL_NOTION_CACHE", nil).and_return(nil) }

        it "returns true (default is true)" do
          expect(generator.send(:cache?)).to be true
        end
      end
    end
  end

  describe "#falsy?" do
    it "recognizes '0' as falsy" do
      expect(generator.send(:falsy?, "0")).to be true
    end

    it "recognizes 'false' as falsy" do
      expect(generator.send(:falsy?, "false")).to be true
    end

    it "recognizes 'no' as falsy" do
      expect(generator.send(:falsy?, "no")).to be true
    end

    it "recognizes 'FALSE' as falsy (case insensitive)" do
      expect(generator.send(:falsy?, "FALSE")).to be true
    end

    it "recognizes other values as truthy" do
      expect(generator.send(:falsy?, "1")).to be false
      expect(generator.send(:falsy?, "true")).to be false
      expect(generator.send(:falsy?, "yes")).to be false
      expect(generator.send(:falsy?, "anything")).to be false
    end

    it "handles non-string values" do
      expect(generator.send(:falsy?, 0)).to be true
      expect(generator.send(:falsy?, false)).to be true
    end
  end
end
