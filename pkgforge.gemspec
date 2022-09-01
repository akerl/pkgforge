require 'English'
$LOAD_PATH.unshift File.expand_path('lib', __dir__)
require 'pkgforge/version'

Gem::Specification.new do |s|
  s.name        = 'pkgforge'
  s.version     = PkgForge::VERSION

  s.required_ruby_version = '>= 3.0'

  s.summary     = 'DSL engine for building Arch packages'
  s.description = 'DSL engine for building Arch packages'
  s.authors     = ['Les Aker']
  s.email       = 'me@lesaker.org'
  s.homepage    = 'https://github.com/akerl/pkgforge'
  s.license     = 'MIT'

  s.files       = `git ls-files`.split
  s.executables = ['pkgforge']

  s.add_dependency 'contracts', '~> 0.17.0'
  s.add_dependency 'cymbal', '~> 2.0.0'
  s.add_dependency 'mercenary', '~> 0.4.0'

  s.add_development_dependency 'goodcop', '~> 0.9.5'
  s.metadata['rubygems_mfa_required'] = 'true'
end
