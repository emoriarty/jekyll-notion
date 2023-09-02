# frozen_string_literal: true
#

module JekyllNotion
  # Using VCR to record and playback Notion API responses for caching
  module Cacheable
    def database_query(*args)
      puts "==> VCR DB item fetching #{args} from Notion..."

      VCR.use_cassette("#{args[0][:database_id]}") { super(*args) }
    end

    def block_children(*args)
      puts "==> VCR BLOCK CHILDREN fetching #{args} from Notion..."

      VCR.use_cassette("#{args[0][:block_id]}") { super(*args) }
    end

    def page(*args)
      puts "==> VCR PAGE fetching #{args} from Notion..."

      VCR.use_cassette("#{args[0][:page_id]}") { super(*args) }
    end
  end
end
