# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module AttentionSwitching
      module Helpers
        class TaskSet
          include Constants

          attr_reader :id, :name, :task_type, :complexity, :readiness,
                      :residual_activation, :activation_count, :created_at

          def initialize(name:, task_type: :analytical, complexity: 0.5)
            @id                  = SecureRandom.uuid
            @name                = name.to_s
            @task_type           = task_type.to_sym
            @complexity          = complexity.to_f.clamp(0.0, 1.0).round(10)
            @readiness           = 0.0
            @residual_activation = 0.0
            @activation_count    = 0
            @created_at          = Time.now.utc
          end

          def activate!
            @readiness = 1.0
            @residual_activation = 0.0
            @activation_count += 1
            self
          end

          def deactivate!
            @residual_activation = @readiness
            @readiness = 0.0
            self
          end

          def warmup!(amount: WARMUP_RATE)
            @readiness = (@readiness + amount).clamp(0.0, 1.0).round(10)
            self
          end

          def decay_residual!
            @residual_activation = (@residual_activation - RESIDUAL_DECAY_RATE).clamp(0.0, 1.0).round(10)
            self
          end

          def ready?
            @readiness >= READY_THRESHOLD
          end

          def has_residual?
            @residual_activation > 0.1
          end

          def readiness_label
            match = READINESS_LABELS.find { |range, _| range.cover?(@readiness) }
            match ? match.last : :unprepared
          end

          def residual_label
            match = RESIDUAL_LABELS.find { |range, _| range.cover?(@residual_activation) }
            match ? match.last : :negligible
          end

          def to_h
            {
              id:                  @id,
              name:                @name,
              task_type:           @task_type,
              complexity:          @complexity,
              readiness:           @readiness,
              readiness_label:     readiness_label,
              residual_activation: @residual_activation,
              residual_label:      residual_label,
              ready:               ready?,
              has_residual:        has_residual?,
              activation_count:    @activation_count,
              created_at:          @created_at
            }
          end
        end
      end
    end
  end
end
