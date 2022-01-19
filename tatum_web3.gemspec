# frozen_string_literal: true

require_relative "lib/tatum_web3/version"

Gem::Specification.new do |spec|
  spec.name          = "tatum_web3"
  spec.version       = TatumWeb3::VERSION
  spec.authors       = ["captproton"]
  spec.email         = ["carl@wdwhub.net"]

  spec.summary       = "tatum_web3 allows you to interact with web3 through the tatum.io web api."
  spec.description   = "With tatum_web3, you can perform actions like create NFT's and wallets on several blockchains"
    spec.metadata["homepage_uri"]       = "https://github.com/captproton/tatum_web3"
  spec.metadata["source_code_uri"]    = "https://github.com/captproton/tatum_web3"
  spec.metadata["changelog_uri"]      = "https://github.com/captproton/tatum_web3/blob/main/CHANGELOG.md"

  spec.add_development_dependency "awesome_print", "~> 1.9", ">= 1.9.2"
  spec.add_development_dependency "pry", "~> 0.14.1"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rubocop", "~> 1.7"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_runtime_dependency "httparty", "~> 0.19.0"
  spec.add_runtime_dependency 'dry-struct', '~> 1.4'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
