module JekyllNotion
  class GeneratorFactory
    def initialize(db:, site:, parent:)
      @db = db
      @site = site
      @parent = parent
      @generator = unless db.data.nil?
                     DataGenerator.new(db: db, site: site)
                   else
                     CollectionGenerator.new(db: db, site: site)
                   end
    end

    def generate
      if @generator.is_a?(DataGenerator)
        @parent.data[@db.data] = DataGenerator.new(:db => @db, :site => @site).generate
        return
      end

      new_collection = CollectionGenerator.new(:db => @db, :site => @site).generate
      # Caching current collection
      @parent.collections[@db.collection] = new_collection
    end
  end
end
