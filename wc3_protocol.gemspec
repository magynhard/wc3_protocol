# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wc3_protocol/version'

Gem::Specification.new do |spec|
  spec.name          = "wc3_protocol"
  spec.version       = Wc3Protocol::VERSION
  spec.authors       = ["Matthäus J. N. Beyrle"]
  spec.email         = ["wc3_protocol.gemspec@mail.magynhard.de"]

  spec.summary       = %q{The ruby gem to find and retrieve information of Warcraft3 games}
  spec.homepage      = "https://github.com/magynhard/wc3_protocol"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.3'

  spec.add_development_dependency 'bundler',  '>= 2.0'
  spec.add_development_dependency 'rake',     '>= 10.0'
  spec.add_development_dependency 'rspec',    '>= 3.0'
end
