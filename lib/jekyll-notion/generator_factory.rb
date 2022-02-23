module JekyllNotion
  class GeneratorFactory
    def self.for(db:, site:, plugin:)
       unless db.data.nil?
         DataGenerator.new(db: db, site: site, plugin: plugin)
       else
         CollectionGenerator.new(db: db, site: site, plugin: plugin)
       end
    end
  end
end
