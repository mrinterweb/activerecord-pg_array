# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'activerecord/pg_array/version'
require 'activerecord/pg_array'

Gem::Specification.new do |spec|
  spec.name          = "activerecord-pg_array"
  spec.version       = Activerecord::PgArray::VERSION
  spec.authors       = ["Sean McCleary"]
  spec.email         = ["seanmcc@gmail.com"]
  spec.description   = %q{A ruby gem that makes working with Postgres arrays in ActiveRecord easier}
  spec.summary       = %q{This gem defines methods in your models for ActiveRecord attributes that use Postgres's arrays}
  spec.homepage      = "https://github.com/mrinterweb/activerecord-pg_array"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pg"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"
end
