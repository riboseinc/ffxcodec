# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ffxcodec/version'

Gem::Specification.new do |spec|
  spec.name          = 'ffxcodec'
  spec.version       = FFXCodec::VERSION
  spec.authors       = ['J. Brandt Buckley']
  spec.email         = ['brandt@runlevel1.com']
  spec.license       = 'BSD-2-Clause'

  spec.summary       = 'Encodes two integers into one with optional encryption'
  spec.description   = 'Encodes two unsigned integers into a single, larger (32 or 64-bit) integer with optional AES-FFX encryption.'
  spec.homepage      = 'https://github.com/brandt/ffxcodec'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest"
end
