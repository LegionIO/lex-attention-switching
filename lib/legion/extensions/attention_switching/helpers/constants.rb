# frozen_string_literal: true

module Legion
  module Extensions
    module AttentionSwitching
      module Helpers
        module Constants
          # Limits
          MAX_TASK_SETS = 100
          MAX_SWITCH_EVENTS = 500

          # Switch dynamics
          DEFAULT_SWITCH_COST = 0.3
          RESIDUAL_DECAY_RATE = 0.1
          WARMUP_RATE = 0.15
          CONTEXT_RESTORATION_COST = 0.2
          PRACTICE_REDUCTION = 0.01

          # Thresholds
          HIGH_COST_THRESHOLD = 0.6
          LOW_COST_THRESHOLD = 0.2
          READY_THRESHOLD = 0.8

          # Task set types
          TASK_SET_TYPES = %i[
            analytical creative social procedural
            perceptual linguistic spatial emotional
          ].freeze

          # Switch cost labels
          COST_LABELS = {
            (0.8..)     => :prohibitive,
            (0.6...0.8) => :high,
            (0.4...0.6) => :moderate,
            (0.2...0.4) => :low,
            (..0.2)     => :negligible
          }.freeze

          # Readiness labels
          READINESS_LABELS = {
            (0.8..)     => :fully_ready,
            (0.6...0.8) => :mostly_ready,
            (0.4...0.6) => :warming_up,
            (0.2...0.4) => :loading,
            (..0.2)     => :unprepared
          }.freeze

          # Residual activation labels
          RESIDUAL_LABELS = {
            (0.8..)     => :overwhelming,
            (0.6...0.8) => :strong,
            (0.4...0.6) => :moderate,
            (0.2...0.4) => :fading,
            (..0.2)     => :negligible
          }.freeze
        end
      end
    end
  end
end
