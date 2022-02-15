# frozen_string_literal: true

require_relative "lib/jekyll-notion/version"

Gem::Specification.new do |spec|
  spec.name             = "jekyll-notion"
  spec.version          = JekyllNotion::VERSION
  spec.authors          = ["Enrique Arias"]
  spec.email            = ["emoriarty81@gmail.com"]
  spec.summary          = "A Jekyll plugin to generate pages from Notion"
  spec.homepage         = "https://github.com/emoriarty/jekyll-notion"
  spec.license          = "MIT"

  spec.files            = Dir["lib/**/*", "README.md"]
  spec.extra_rdoc_files = Dir["README.md", "LICENSE.txt"]
  # spec.test_files       = spec.files.grep(%r!^spec/!)
  spec.require_paths    = ["lib"]

  spec.required_ruby_version = ">= 2.5.0"

  spec.add_dependency "activesupport", "~> 6"
  spec.add_dependency "jekyll", ">= 3.7", "< 5.0"
  spec.add_dependency "notion-ruby-client", "~> 0"
  spec.add_dependency "notion_to_md", "~> 0"

  spec.add_development_dependency "bundler", "~> 2"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop-jekyll", "~> 0.12.0"
end
