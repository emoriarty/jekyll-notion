module JekyllNotion
  class AbstractGenerator
    def initialize(db:, site:, plugin:)
      @db = db
      @site = site
      @plugin = plugin
    end

    def generate
      raise "Do not use the AbstractGenerator class directly. Implement the generate method in a subclass."
    end
  end
end
