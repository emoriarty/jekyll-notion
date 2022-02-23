module JekyllNotion
  class DataGenerator < AbstractGenerator
    def generate
      @site.data[@db.data] = data
      # Caching current data
      @plugin.data[@db.data] = data
    end

    private

    def data
      @data ||= @db.pages.map(&:props)
    end
  end
end
