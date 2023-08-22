module JekyllNotion
  class FileCreator
    attr_reader :path, :content
    def initialize(path, content)
      @path = path
      @content = content
    end

    def create!
      ensure_directory_exists
      write_file
    end

    private

    def ensure_directory_exists
      dir = File.dirname @path
      FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
    end

    def write_file
      File.open(@path, "w") do |f|
        f.puts(@content)
      end

      Jekyll.logger.info "File #{@path} #{"OK".green}"
    end
  end
end
