# frozen_string_literal: true

require_relative 'attention_switching/version'
require_relative 'attention_switching/helpers/constants'
require_relative 'attention_switching/helpers/task_set'
require_relative 'attention_switching/helpers/switch_event'
require_relative 'attention_switching/helpers/switching_engine'
require_relative 'attention_switching/runners/attention_switching'
require_relative 'attention_switching/client'

module Legion
  module Extensions
    module AttentionSwitching
      extend Legion::Extensions::Core if defined?(Legion::Extensions::Core)
    end
  end
end
