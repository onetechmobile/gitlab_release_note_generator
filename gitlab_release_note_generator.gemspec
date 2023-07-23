lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "gitlab_release_note_generator/version"

Gem::Specification.new do |spec|
  spec.name          = "gitlab_release_note_generator"
  spec.version       = GitlabReleaseNoteGenerator::VERSION
  spec.authors       = ["Ayan"]
  spec.email         = ["ayan.kurmanbai@gmail.com"]

  spec.summary       = %q{A gem for generating gitlab release notes. Follow the instructions on github.}
  spec.homepage      = "https://github.com/kurmanbayan/gitlab_release_note_generator"
  spec.license       = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.2"
  spec.add_development_dependency "faraday", "~> 1.0"
  
end
