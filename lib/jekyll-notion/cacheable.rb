# frozen_string_literal: true
#

module JekyllNotion
  module Cacheable
    def database_query(*args)
      VCR.use_cassette("#{args[0][:database_id]}") { super(*args) }
    end

    def block_children(*args)
      VCR.use_cassette("#{args[0][:block_id]}") { super(*args) }
    end

    def page(*args)
      VCR.use_cassette("#{args[0][:page_id]}") { super(*args) }
    end
  end
end
