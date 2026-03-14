# frozen_string_literal: true

RSpec.describe Legion::Extensions::AttentionSwitching::Helpers::TaskSet do
  subject(:task) { described_class.new(name: 'coding') }

  describe '#initialize' do
    it 'assigns a UUID id' do
      expect(task.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'sets name' do
      expect(task.name).to eq('coding')
    end

    it 'defaults to analytical type' do
      expect(task.task_type).to eq(:analytical)
    end

    it 'defaults complexity to 0.5' do
      expect(task.complexity).to eq(0.5)
    end

    it 'starts with zero readiness' do
      expect(task.readiness).to eq(0.0)
    end

    it 'starts with zero residual' do
      expect(task.residual_activation).to eq(0.0)
    end

    it 'clamps high complexity' do
      high = described_class.new(name: 'x', complexity: 5.0)
      expect(high.complexity).to eq(1.0)
    end
  end

  describe '#activate!' do
    it 'sets readiness to 1.0' do
      task.activate!
      expect(task.readiness).to eq(1.0)
    end

    it 'clears residual activation' do
      task.activate!
      expect(task.residual_activation).to eq(0.0)
    end

    it 'increments activation count' do
      task.activate!
      expect(task.activation_count).to eq(1)
    end
  end

  describe '#deactivate!' do
    it 'transfers readiness to residual' do
      task.activate!
      task.deactivate!
      expect(task.residual_activation).to eq(1.0)
      expect(task.readiness).to eq(0.0)
    end
  end

  describe '#warmup!' do
    it 'increases readiness' do
      task.warmup!
      expect(task.readiness).to be > 0.0
    end

    it 'clamps at 1.0' do
      10.times { task.warmup! }
      expect(task.readiness).to eq(1.0)
    end
  end

  describe '#decay_residual!' do
    it 'reduces residual activation' do
      task.activate!
      task.deactivate!
      original = task.residual_activation
      task.decay_residual!
      expect(task.residual_activation).to be < original
    end

    it 'does not go below zero' do
      task.decay_residual!
      expect(task.residual_activation).to eq(0.0)
    end
  end

  describe '#ready?' do
    it 'is false initially' do
      expect(task.ready?).to be false
    end

    it 'is true after activation' do
      task.activate!
      expect(task.ready?).to be true
    end
  end

  describe '#has_residual?' do
    it 'is false initially' do
      expect(task.has_residual?).to be false
    end

    it 'is true after deactivation' do
      task.activate!
      task.deactivate!
      expect(task.has_residual?).to be true
    end
  end

  describe '#readiness_label' do
    it 'returns unprepared initially' do
      expect(task.readiness_label).to eq(:unprepared)
    end

    it 'returns fully_ready when activated' do
      task.activate!
      expect(task.readiness_label).to eq(:fully_ready)
    end
  end

  describe '#to_h' do
    it 'includes all fields' do
      hash = task.to_h
      expect(hash).to include(
        :id, :name, :task_type, :complexity, :readiness,
        :readiness_label, :residual_activation, :residual_label,
        :ready, :has_residual, :activation_count, :created_at
      )
    end
  end
end
