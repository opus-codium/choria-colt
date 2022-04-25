# frozen_string_literal: true

require_relative 'lib/choria/colt/version'

Gem::Specification.new do |spec|
  spec.name = 'choria-colt'
  spec.version = Choria::Colt::VERSION
  spec.authors = ['Romuald Conty']
  spec.email = ['romuald@opus-codium.fr']

  spec.summary = 'Bolt-like CLI to run Bolt tasks, through Choria'
  spec.description = 'Colt eases the Bolt tasks run through Choria'
  spec.homepage = 'https://github.com/opus-codium/choria-colt'
  spec.required_ruby_version = '>= 2.5.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/opus-codium/choria-colt'
  spec.metadata['changelog_uri'] = 'https://github.com/opus-codium/choria-colt/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport'
  spec.add_dependency 'choria-mcorpc-support'
  spec.add_dependency 'deep_merge'
  spec.add_dependency 'pastel'
  spec.add_dependency 'puppet'
  spec.add_dependency 'thor'
  spec.add_dependency 'tty-logger'

  # spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'github_changelog_generator'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rake'
  spec.add_development_dependency 'rubocop-rspec'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata['rubygems_mfa_required'] = 'true'
end
