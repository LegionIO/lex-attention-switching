# lex-attention-switching

Attention task-switching cost modeling for LegionIO — residual activation, warmup time, context restoration, and practice effects.

## What It Does

Models the real cognitive cost of switching between tasks. When an agent switches from one task type to another, residual activation from the previous task persists and interferes with the new one. Readiness for the new task must build up through warmup. Repeated switching between the same pair reduces the cost through practice. Returning to a previously active task incurs an additional context restoration cost.

## Core Concept: Switch Cost

```ruby
switch_cost = base_cost - (practice_count * 0.01) + context_restoration_if_returning
# e.g., first switch: 0.30, tenth switch between same pair: 0.20
```

## Usage

```ruby
client = Legion::Extensions::AttentionSwitching::Client.new

# Register task types
analytical = client.register_task(name: :code_review, task_type: :analytical, complexity: 0.7)
social     = client.register_task(name: :team_meeting, task_type: :social, complexity: 0.4)

# Switch tasks
result = client.switch_to(task_id: social[:task][:id])
# => { cost: 0.3, cost_label: :moderate, residual: 0.3, readiness: 0.1 }

# Warm up for the new task
client.warmup
client.warmup  # readiness increases

# Check for lingering residual from the previous task
client.residual_tasks
# => { tasks: [{ name: :code_review, residual_activation: 0.2 }] }

# Decay residuals between ticks
client.decay_residuals

# Historical cost between specific tasks
client.switch_cost_between(from_id: analytical[:task][:id], to_id: social[:task][:id])
```

## Integration

Wire into lex-tick mode transitions to model cognitive warmup time when switching between dormant and full_active modes. Use `average_switch_cost` to inform task scheduling: avoid frequent task-type switches when processing budget is limited.

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
