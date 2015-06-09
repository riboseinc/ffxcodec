# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ffxcodec/version'

Gem::Specification.new do |spec|
  spec.name          = "ffxcodec"
  spec.version       = FFXCodec::VERSION
  spec.authors       = ["J. Brandt Buckley"]
  spec.email         = ["brandt@runlevel1.com"]

  spec.summary       = %q{Encodes two integers into one with optional encryption}
  spec.description   = %q{Encodes two unsigned integers into a single, larger (32 or 64-bit) integer with optional AES-FFX encryption.}
# spec.homepage      = "TODO: Put your gem's website or public repo URL here."

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com' to prevent pushes to rubygems.org, or delete to allow pushes to any server."
  end

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest"
end
