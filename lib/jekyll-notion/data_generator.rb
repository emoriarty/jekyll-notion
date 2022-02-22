module JekyllNotion
  class DataGenerator
    def initialize(db:, site:)
      @db = db
      @site = site
    end

    def generate
      @site.data[@db.data] = @db.pages.map(&:props)
    end
  end
end
