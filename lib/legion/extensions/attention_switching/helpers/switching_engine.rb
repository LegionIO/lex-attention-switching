# frozen_string_literal: true

module Legion
  module Extensions
    module AttentionSwitching
      module Helpers
        class SwitchingEngine
          include Constants

          def initialize
            @task_sets      = {}
            @switch_events  = []
            @active_task_id = nil
          end

          def register_task(name:, task_type: :analytical, complexity: 0.5)
            prune_tasks_if_needed
            task = TaskSet.new(name: name, task_type: task_type, complexity: complexity)
            @task_sets[task.id] = task
            task
          end

          def activate_task(task_id:)
            task = @task_sets[task_id]
            return nil unless task

            task.activate!
            @active_task_id = task_id
            task
          end

          def switch_to(task_id:)
            target = @task_sets[task_id]
            return nil unless target

            current = @task_sets[@active_task_id]
            event = if current && @active_task_id != task_id
                      perform_switch(current, target)
                    else
                      activate_task(task_id: task_id)
                      nil
                    end

            @active_task_id = task_id
            { task: target.to_h, switch_event: event&.to_h }
          end

          def warmup_active
            task = @task_sets[@active_task_id]
            return nil unless task

            task.warmup!
          end

          def decay_all_residuals!
            @task_sets.each_value(&:decay_residual!)
            { tasks_decayed: @task_sets.size }
          end

          def active_task
            @task_sets[@active_task_id]
          end

          def tasks_with_residual
            @task_sets.values.select(&:has_residual?)
          end

          def recent_switches(limit: 10)
            @switch_events.last(limit)
          end

          def average_switch_cost
            return DEFAULT_SWITCH_COST if @switch_events.empty?

            costs = @switch_events.map(&:switch_cost)
            (costs.sum / costs.size).round(10)
          end

          def costly_switches
            @switch_events.select(&:costly?)
          end

          def cheap_switches
            @switch_events.select(&:cheap?)
          end

          def switch_cost_between(from_id:, to_id:)
            relevant = @switch_events.select { |e| e.from_task_id == from_id && e.to_task_id == to_id }
            return nil if relevant.empty?

            costs = relevant.map(&:switch_cost)
            (costs.sum / costs.size).round(10)
          end

          def most_costly_pair
            return nil if @switch_events.empty?

            @switch_events.max_by(&:switch_cost)
          end

          def switching_report
            {
              total_tasks:        @task_sets.size,
              total_switches:     @switch_events.size,
              active_task:        active_task&.to_h,
              average_switch_cost: average_switch_cost,
              costly_count:       costly_switches.size,
              cheap_count:        cheap_switches.size,
              residual_count:     tasks_with_residual.size,
              recent_switches:    recent_switches(limit: 5).map(&:to_h)
            }
          end

          def to_h
            {
              total_tasks:         @task_sets.size,
              total_switches:      @switch_events.size,
              active_task_id:      @active_task_id,
              average_switch_cost: average_switch_cost,
              residual_count:      tasks_with_residual.size
            }
          end

          private

          def perform_switch(current, target)
            current.deactivate!

            type_cost = current.task_type == target.task_type ? 0.0 : 0.15
            complexity_cost = ((current.complexity - target.complexity).abs * 0.3).round(10)
            residual = current.residual_activation
            context_cost = CONTEXT_RESTORATION_COST * target.complexity
            practice_bonus = [target.activation_count * PRACTICE_REDUCTION, 0.2].min

            total_cost = (DEFAULT_SWITCH_COST + type_cost + complexity_cost +
                          (residual * 0.2) + context_cost - practice_bonus).clamp(0.0, 1.0).round(10)

            warmup = ((1.0 - target.readiness) * target.complexity).round(10)

            target.activate!

            event = SwitchEvent.new(
              from_task_id:          current.id,
              to_task_id:            target.id,
              switch_cost:           total_cost,
              residual_interference: residual,
              warmup_needed:         warmup
            )
            prune_events_if_needed
            @switch_events << event
            event
          end

          def prune_tasks_if_needed
            return if @task_sets.size < MAX_TASK_SETS

            least_used = @task_sets.values.min_by(&:activation_count)
            @task_sets.delete(least_used.id) if least_used
          end

          def prune_events_if_needed
            @switch_events.shift while @switch_events.size >= MAX_SWITCH_EVENTS
          end
        end
      end
    end
  end
end
