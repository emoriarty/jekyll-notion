# frozen_string_literal: true

require "spec_helper"

RSpec.describe JekyllNotion::CassetteManager do
  let(:cache_dir) { Dir.mktmpdir("cassette-manager-unit") }
  let(:manager) { described_class.new(cache_dir) }
  let(:page_id) { "test-123" }

  after { FileUtils.rm_rf(cache_dir) }

  describe "#cassette_name_for" do
    context "when index mapping exists and file exists" do
      before do
        index_path = File.join(cache_dir, ".pages_index.yml")
        FileUtils.mkdir_p(File.dirname(index_path))
        File.write(index_path, { "test123" => "pages/pretty-name-test123" }.to_yaml)

        pretty_file = File.join(cache_dir, "pages", "pretty-name-test123.yml")
        FileUtils.mkdir_p(File.dirname(pretty_file))
        File.write(pretty_file, "test")
      end

      it "returns the pretty name from index" do
        result = manager.cassette_name_for(page_id)
        expect(result).to eq("pages/pretty-name-test123")
      end
    end

    context "when existing file matches ID pattern" do
      before do
        existing_file = File.join(cache_dir, "pages", "old-title-test123.yml")
        FileUtils.mkdir_p(File.dirname(existing_file))
        File.write(existing_file, "test")
      end

      it "returns the existing filename" do
        result = manager.cassette_name_for(page_id)
        expect(result).to eq("pages/old-title-test123")
      end
    end

    context "when no existing files found" do
      it "returns plain ID fallback" do
        result = manager.cassette_name_for(page_id)
        expect(result).to eq("pages/test123")
      end
    end
  end

  describe "#update_after_call" do
    let(:result_with_title) do
      double("result", :title => "Test Page Title")
    end

    let(:result_without_title) do
      double("result", :title => "")
    end

    context "when result has a title" do
      it "updates index and renames cassette" do
        allow(manager).to receive(:rename_cassette_if_needed)
        allow(manager).to receive(:update_index_yaml)

        manager.update_after_call(page_id, result_with_title)

        expect(manager).to have_received(:rename_cassette_if_needed).with(
          :from => "pages/test123",
          :to   => "pages/test-page-title-test123"
        )
        expect(manager).to have_received(:update_index_yaml).with(
          :id     => "test123",
          :pretty => "pages/test-page-title-test123"
        )
      end
    end

    context "when result has no title" do
      it "does nothing" do
        allow(manager).to receive(:rename_cassette_if_needed)
        allow(manager).to receive(:update_index_yaml)

        manager.update_after_call(page_id, result_without_title)

        expect(manager).not_to have_received(:rename_cassette_if_needed)
        expect(manager).not_to have_received(:update_index_yaml)
      end
    end
  end

  describe "private methods" do
    describe "#find_existing_by_id" do
      context "when matching files exist" do
        before do
          existing_file = File.join(cache_dir, "pages", "some-title-test123.yml")
          FileUtils.mkdir_p(File.dirname(existing_file))
          File.write(existing_file, "test")
        end

        it "returns the basename without extension" do
          result = manager.send(:find_existing_by_id, "test123")
          expect(result).to eq("pages/some-title-test123")
        end
      end

      context "when no matching files exist" do
        it "returns nil" do
          result = manager.send(:find_existing_by_id, "nonexistent")
          expect(result).to be_nil
        end
      end
    end

    describe "#rename_cassette_if_needed" do
      context "when source and destination are the same" do
        it "does nothing" do
          expect(FileUtils).not_to receive(:mv)
          manager.send(:rename_cassette_if_needed, :from => "pages/same", :to => "pages/same")
        end
      end

      context "when source file exists and destination doesn't" do
        before do
          src_file = File.join(cache_dir, "pages", "old-name.yml")
          FileUtils.mkdir_p(File.dirname(src_file))
          File.write(src_file, "test content")
        end

        it "renames the file" do
          manager.send(:rename_cassette_if_needed, :from => "pages/old-name",
                                                   :to   => "pages/new-name")

          src_path = File.join(cache_dir, "pages", "old-name.yml")
          dst_path = File.join(cache_dir, "pages", "new-name.yml")

          expect(File.exist?(src_path)).to be false
          expect(File.exist?(dst_path)).to be true
          expect(File.read(dst_path)).to eq("test content")
        end
      end

      context "when source doesn't exist" do
        it "does nothing" do
          expect do
            manager.send(:rename_cassette_if_needed, :from => "pages/nonexistent",
                                                     :to   => "pages/new-name")
          end.not_to raise_error

          expect(File.exist?(File.join(cache_dir, "pages", "new-name.yml"))).to be false
        end
      end

      context "when destination already exists" do
        before do
          src_file = File.join(cache_dir, "pages", "old-name.yml")
          dst_file = File.join(cache_dir, "pages", "new-name.yml")
          FileUtils.mkdir_p(File.dirname(src_file))
          File.write(src_file, "source")
          File.write(dst_file, "destination")
        end

        it "does nothing to avoid overwriting" do
          manager.send(:rename_cassette_if_needed, :from => "pages/old-name",
                                                   :to   => "pages/new-name")

          src_path = File.join(cache_dir, "pages", "old-name.yml")
          dst_path = File.join(cache_dir, "pages", "new-name.yml")

          expect(File.read(src_path)).to eq("source")
          expect(File.read(dst_path)).to eq("destination")
        end
      end
    end

    describe "#load_index_yaml" do
      context "when index file exists and is valid" do
        before do
          index_path = File.join(cache_dir, ".pages_index.yml")
          FileUtils.mkdir_p(File.dirname(index_path))
          File.write(index_path, { "key" => "value" }.to_yaml)
        end

        it "returns the parsed YAML content" do
          result = manager.send(:load_index_yaml)
          expect(result).to eq({ "key" => "value" })
        end
      end

      context "when index file doesn't exist" do
        it "returns empty hash" do
          result = manager.send(:load_index_yaml)
          expect(result).to eq({})
        end
      end

      context "when index file has invalid YAML" do
        before do
          index_path = File.join(cache_dir, ".pages_index.yml")
          FileUtils.mkdir_p(File.dirname(index_path))
          File.write(index_path, "invalid: yaml: content:\n  - unclosed")
        end

        it "returns empty hash on syntax error" do
          result = manager.send(:load_index_yaml)
          expect(result).to eq({})
        end
      end
    end

    describe "#update_index_yaml" do
      it "creates new index file with mapping" do
        manager.send(:update_index_yaml, :id => "page123", :pretty => "pages/nice-title")

        index_path = File.join(cache_dir, ".pages_index.yml")
        expect(File.exist?(index_path)).to be true

        content = YAML.safe_load(File.read(index_path))
        expect(content["page123"]).to eq("pages/nice-title")
      end

      it "updates existing index file" do
        manager.send(:update_index_yaml, :id => "page1", :pretty => "pages/title1")
        manager.send(:update_index_yaml, :id => "new", :pretty => "pages/new-title")

        index_path = File.join(cache_dir, ".pages_index.yml")
        content = YAML.safe_load(File.read(index_path))

        expect(content["page1"]).to eq("pages/title1")
        expect(content["new"]).to eq("pages/new-title")
      end

      it "doesn't update if mapping is unchanged" do
        manager.send(:update_index_yaml, :id => "page1", :pretty => "pages/same")

        index_path = File.join(cache_dir, ".pages_index.yml")
        original_mtime = File.mtime(index_path)

        sleep 0.01
        manager.send(:update_index_yaml, :id => "page1", :pretty => "pages/same")

        expect(File.mtime(index_path)).to eq(original_mtime)
      end
    end

    describe "utility methods" do
      describe "#sanitize_title" do
        it "uses Jekyll's slugify for title sanitization" do
          result = manager.send(:sanitize_title, "My Title!")
          expect(result).to eq("my-title")
        end
      end

      describe "#sanitize_id" do
        it "removes dashes from IDs" do
          result = manager.send(:sanitize_id, "abc-123-def")
          expect(result).to eq("abc123def")
        end
      end
    end
  end
end
