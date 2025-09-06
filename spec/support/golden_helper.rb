# spec/support/golden_helper.rb
module GoldenHelper
  GOLDEN_DIR = File.expand_path("../fixtures/golden", __dir__)

  def expect_to_match_golden_file(actual_content_or_path, golden_name)
    actual_content =
      if actual_content_or_path.is_a?(String) && File.file?(actual_content_or_path)
        File.read(actual_content_or_path)
      else
        actual_content_or_path # already content
      end

    golden_path = File.join("spec/fixtures/golden", golden_name)

    if ENV["UPDATE_GOLDEN"]
      File.write(golden_path, actual_content)
      warn "🔄 Updated golden file: #{golden_path}"
    end

    expect(actual_content).to eq(File.read(golden_path))
  end

  # @param document => JekyllNotion::DocumentWithoutAFile
  def expect_to_match_document(document)
    golden_name = "#{document.basename_without_ext}#{document.output_ext}"

    expect_to_match_golden_file(document.output, golden_name)
  end

  # @param document => JekyllNotion::PageWithoutAFile
  def expect_to_match_page(page)
    golden_name = "#{page.basename}#{page.output_ext}"

    expect_to_match_golden_file(page.output, golden_name)
  end
end
