# frozen_string_literal: true

module JekyllNotion
  class GeneratorFactory
    def self.for(db:, site:, plugin:)
      if db.data.nil?
        CollectionGenerator.new(:db => db, :site => site, :plugin => plugin)
      else
        DataGenerator.new(:db => db, :site => site, :plugin => plugin)
      end
    end
  end
end
