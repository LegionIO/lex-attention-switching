# frozen_string_literal: true

require_relative 'lib/legion/extensions/attention_switching/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-attention-switching'
  spec.version       = Legion::Extensions::AttentionSwitching::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'Attention task-switching cost modeling for LegionIO'
  spec.description   = 'Models the cognitive cost of switching between tasks including residual activation, ' \
                       'warmup time, context restoration, and practice effects.'
  spec.homepage      = 'https://github.com/LegionIO/lex-attention-switching'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri']      = spec.homepage
  spec.metadata['source_code_uri']   = 'https://github.com/LegionIO/lex-attention-switching'
  spec.metadata['documentation_uri'] = 'https://github.com/LegionIO/lex-attention-switching/blob/master/README.md'
  spec.metadata['changelog_uri']     = 'https://github.com/LegionIO/lex-attention-switching/blob/master/CHANGELOG.md'
  spec.metadata['bug_tracker_uri']   = 'https://github.com/LegionIO/lex-attention-switching/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.require_paths = ['lib']
end
