# frozen_string_literal: true

RSpec.describe Legion::Extensions::AttentionSwitching::Helpers::SwitchEvent do
  subject(:event) do
    described_class.new(
      from_task_id:          'task-a',
      to_task_id:            'task-b',
      switch_cost:           0.4,
      residual_interference: 0.3,
      warmup_needed:         0.2
    )
  end

  describe '#initialize' do
    it 'assigns a UUID id' do
      expect(event.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'sets task ids' do
      expect(event.from_task_id).to eq('task-a')
      expect(event.to_task_id).to eq('task-b')
    end

    it 'sets switch cost' do
      expect(event.switch_cost).to eq(0.4)
    end

    it 'clamps cost values' do
      high = described_class.new(from_task_id: 'a', to_task_id: 'b',
                                 switch_cost: 5.0, residual_interference: 0.0, warmup_needed: 0.0)
      expect(high.switch_cost).to eq(1.0)
    end
  end

  describe '#costly?' do
    it 'is false for moderate cost' do
      expect(event.costly?).to be false
    end

    it 'is true for high cost' do
      high = described_class.new(from_task_id: 'a', to_task_id: 'b',
                                 switch_cost: 0.8, residual_interference: 0.0, warmup_needed: 0.0)
      expect(high.costly?).to be true
    end
  end

  describe '#cheap?' do
    it 'is false for moderate cost' do
      expect(event.cheap?).to be false
    end

    it 'is true for low cost' do
      low = described_class.new(from_task_id: 'a', to_task_id: 'b',
                                switch_cost: 0.1, residual_interference: 0.0, warmup_needed: 0.0)
      expect(low.cheap?).to be true
    end
  end

  describe '#cost_label' do
    it 'returns a symbol' do
      expect(event.cost_label).to be_a(Symbol)
    end
  end

  describe '#to_h' do
    it 'includes all fields' do
      hash = event.to_h
      expect(hash).to include(
        :id, :from_task_id, :to_task_id, :switch_cost, :cost_label,
        :costly, :cheap, :residual_interference, :warmup_needed, :created_at
      )
    end
  end
end
