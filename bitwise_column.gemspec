# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bitwise_column/version'

Gem::Specification.new do |spec|
  spec.name          = "bitwise_column"
  spec.version       = BitwiseColumn::VERSION
  spec.authors       = ["Sibevin Wang"]
  spec.email         = ["sibevin@gmail.com"]
  spec.summary       = %q{Using bitwise to store multiple values in a single column.}
  spec.homepage      = "https://github.com/sibevin/bitwise_column"
  spec.license       = "MIT"
  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
end
