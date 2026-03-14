# frozen_string_literal: true

RSpec.describe Legion::Extensions::AttentionSwitching::Helpers::SwitchingEngine do
  subject(:engine) { described_class.new }

  let(:coding) { engine.register_task(name: 'coding', task_type: :analytical, complexity: 0.7) }
  let(:writing) { engine.register_task(name: 'writing', task_type: :creative, complexity: 0.5) }
  let(:chatting) { engine.register_task(name: 'chatting', task_type: :social, complexity: 0.3) }

  describe '#register_task' do
    it 'creates a task set' do
      task = engine.register_task(name: 'test')
      expect(task).to be_a(Legion::Extensions::AttentionSwitching::Helpers::TaskSet)
    end
  end

  describe '#activate_task' do
    it 'activates the task' do
      engine.activate_task(task_id: coding.id)
      expect(coding.ready?).to be true
    end

    it 'returns nil for unknown task' do
      expect(engine.activate_task(task_id: 'bad')).to be_nil
    end
  end

  describe '#switch_to' do
    it 'switches between tasks' do
      engine.activate_task(task_id: coding.id)
      result = engine.switch_to(task_id: writing.id)
      expect(result[:task][:id]).to eq(writing.id)
      expect(result[:switch_event]).not_to be_nil
    end

    it 'records switch cost' do
      engine.activate_task(task_id: coding.id)
      result = engine.switch_to(task_id: writing.id)
      expect(result[:switch_event][:switch_cost]).to be > 0
    end

    it 'creates residual on previous task' do
      engine.activate_task(task_id: coding.id)
      engine.switch_to(task_id: writing.id)
      expect(coding.has_residual?).to be true
    end

    it 'returns nil for unknown task' do
      expect(engine.switch_to(task_id: 'bad')).to be_nil
    end

    it 'has no switch event for first activation' do
      result = engine.switch_to(task_id: coding.id)
      expect(result[:switch_event]).to be_nil
    end
  end

  describe '#warmup_active' do
    it 'increases active task readiness' do
      engine.activate_task(task_id: coding.id)
      engine.switch_to(task_id: writing.id)
      engine.switch_to(task_id: coding.id)
      # After switching back, warmup the task
      initial = coding.readiness
      engine.warmup_active
      expect(coding.readiness).to be >= initial
    end

    it 'returns nil with no active task' do
      expect(engine.warmup_active).to be_nil
    end
  end

  describe '#decay_all_residuals!' do
    it 'reduces residual on deactivated tasks' do
      engine.activate_task(task_id: coding.id)
      engine.switch_to(task_id: writing.id)
      original = coding.residual_activation
      engine.decay_all_residuals!
      expect(coding.residual_activation).to be < original
    end
  end

  describe '#active_task' do
    it 'returns nil initially' do
      expect(engine.active_task).to be_nil
    end

    it 'returns active task after activation' do
      engine.activate_task(task_id: coding.id)
      expect(engine.active_task.id).to eq(coding.id)
    end
  end

  describe '#tasks_with_residual' do
    it 'returns tasks with residual activation' do
      engine.activate_task(task_id: coding.id)
      engine.switch_to(task_id: writing.id)
      expect(engine.tasks_with_residual.map(&:id)).to include(coding.id)
    end
  end

  describe '#average_switch_cost' do
    it 'returns default with no switches' do
      default = Legion::Extensions::AttentionSwitching::Helpers::Constants::DEFAULT_SWITCH_COST
      expect(engine.average_switch_cost).to eq(default)
    end

    it 'computes average after switches' do
      engine.activate_task(task_id: coding.id)
      engine.switch_to(task_id: writing.id)
      engine.switch_to(task_id: chatting.id)
      expect(engine.average_switch_cost).to be > 0
    end
  end

  describe '#switch_cost_between' do
    it 'returns average cost for a specific pair' do
      engine.activate_task(task_id: coding.id)
      engine.switch_to(task_id: writing.id)
      cost = engine.switch_cost_between(from_id: coding.id, to_id: writing.id)
      expect(cost).to be > 0
    end

    it 'returns nil for unknown pair' do
      expect(engine.switch_cost_between(from_id: 'a', to_id: 'b')).to be_nil
    end
  end

  describe '#most_costly_pair' do
    it 'returns nil with no switches' do
      expect(engine.most_costly_pair).to be_nil
    end

    it 'returns the highest cost event' do
      engine.activate_task(task_id: coding.id)
      engine.switch_to(task_id: writing.id)
      expect(engine.most_costly_pair).to be_a(Legion::Extensions::AttentionSwitching::Helpers::SwitchEvent)
    end
  end

  describe '#switching_report' do
    it 'returns comprehensive report' do
      engine.activate_task(task_id: coding.id)
      engine.switch_to(task_id: writing.id)
      report = engine.switching_report
      expect(report).to include(
        :total_tasks, :total_switches, :active_task,
        :average_switch_cost, :costly_count, :cheap_count,
        :residual_count, :recent_switches
      )
    end
  end

  describe '#to_h' do
    it 'returns summary hash' do
      hash = engine.to_h
      expect(hash).to include(
        :total_tasks, :total_switches, :active_task_id,
        :average_switch_cost, :residual_count
      )
    end
  end
end
