# frozen_string_literal: true

module Legion
  module Extensions
    module AttentionSwitching
      module Runners
        module AttentionSwitching
          include Legion::Extensions::Helpers::Lex if defined?(Legion::Extensions::Helpers::Lex)

          def register_task(name:, task_type: :analytical, complexity: 0.5, engine: nil, **)
            eng = engine || default_engine
            task = eng.register_task(name: name, task_type: task_type, complexity: complexity)
            { success: true, task: task.to_h }
          end

          def switch_to(task_id:, engine: nil, **)
            eng = engine || default_engine
            result = eng.switch_to(task_id: task_id)
            return { success: false, error: 'task not found' } unless result

            { success: true, **result }
          end

          def warmup(engine: nil, **)
            eng = engine || default_engine
            task = eng.warmup_active
            return { success: false, error: 'no active task' } unless task

            { success: true, task: task.to_h }
          end

          def decay_residuals(engine: nil, **)
            eng = engine || default_engine
            result = eng.decay_all_residuals!
            { success: true, **result }
          end

          def active_task(engine: nil, **)
            eng = engine || default_engine
            task = eng.active_task
            return { success: false, error: 'no active task' } unless task

            { success: true, task: task.to_h }
          end

          def residual_tasks(engine: nil, **)
            eng = engine || default_engine
            { success: true, tasks: eng.tasks_with_residual.map(&:to_h) }
          end

          def recent_switches(limit: 10, engine: nil, **)
            eng = engine || default_engine
            { success: true, switches: eng.recent_switches(limit: limit).map(&:to_h) }
          end

          def average_switch_cost(engine: nil, **)
            eng = engine || default_engine
            { success: true, average_cost: eng.average_switch_cost }
          end

          def switch_cost_between(from_id:, to_id:, engine: nil, **)
            eng = engine || default_engine
            cost = eng.switch_cost_between(from_id: from_id, to_id: to_id)
            return { success: false, error: 'no switches found for this pair' } unless cost

            { success: true, cost: cost }
          end

          def switching_report(engine: nil, **)
            eng = engine || default_engine
            { success: true, report: eng.switching_report }
          end

          def status(engine: nil, **)
            eng = engine || default_engine
            { success: true, **eng.to_h }
          end

          private

          def default_engine
            @default_engine ||= Helpers::SwitchingEngine.new
          end
        end
      end
    end
  end
end
