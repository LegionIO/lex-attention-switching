# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module AttentionSwitching
      module Helpers
        class SwitchEvent
          include Constants

          attr_reader :id, :from_task_id, :to_task_id, :switch_cost,
                      :residual_interference, :warmup_needed, :created_at

          def initialize(from_task_id:, to_task_id:, switch_cost:, residual_interference:, warmup_needed:)
            @id                    = SecureRandom.uuid
            @from_task_id          = from_task_id
            @to_task_id            = to_task_id
            @switch_cost           = switch_cost.to_f.clamp(0.0, 1.0).round(10)
            @residual_interference = residual_interference.to_f.clamp(0.0, 1.0).round(10)
            @warmup_needed         = warmup_needed.to_f.clamp(0.0, 1.0).round(10)
            @created_at            = Time.now.utc
          end

          def costly?
            @switch_cost >= HIGH_COST_THRESHOLD
          end

          def cheap?
            @switch_cost <= LOW_COST_THRESHOLD
          end

          def cost_label
            match = COST_LABELS.find { |range, _| range.cover?(@switch_cost) }
            match ? match.last : :negligible
          end

          def to_h
            {
              id:                    @id,
              from_task_id:          @from_task_id,
              to_task_id:            @to_task_id,
              switch_cost:           @switch_cost,
              cost_label:            cost_label,
              costly:                costly?,
              cheap:                 cheap?,
              residual_interference: @residual_interference,
              warmup_needed:         @warmup_needed,
              created_at:            @created_at
            }
          end
        end
      end
    end
  end
end
