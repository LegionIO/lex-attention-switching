# lex-attention-switching

**Level 3 Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`
- **Grandparent**: `/Users/miverso2/rubymine/legion/CLAUDE.md`

## Purpose

Models the cognitive cost of switching between tasks including residual activation, warmup time, context restoration, and practice effects. Based on task-switching research showing that switching tasks incurs a real performance cost — residual activation from the previous task persists and interferes with the new one.

## Gem Info

- **Gem name**: `lex-attention-switching`
- **Version**: `0.1.0`
- **Module**: `Legion::Extensions::AttentionSwitching`
- **Ruby**: `>= 3.4`
- **License**: MIT

## File Structure

```
lib/legion/extensions/attention_switching/
  attention_switching.rb          # Main extension module
  version.rb                      # VERSION = '0.1.0'
  client.rb                       # Client wrapper
  helpers/
    constants.rb                  # Switch costs, residual decay, warmup rate, task types, labels
    task_set.rb                   # TaskSet value object (readiness, residual, practice count)
    switch_event.rb               # SwitchEvent value object
    switching_engine.rb           # SwitchingEngine — manages tasks, switch history, cost modeling
  runners/
    attention_switching.rb        # Runner module with 10 public methods
spec/
  (spec files)
```

## Key Constants

```ruby
MAX_TASK_SETS        = 100
MAX_SWITCH_EVENTS    = 500
DEFAULT_SWITCH_COST  = 0.3
RESIDUAL_DECAY_RATE  = 0.1     # residual activation decays per tick
WARMUP_RATE          = 0.15    # readiness increases per warmup call
CONTEXT_RESTORATION_COST = 0.2  # penalty when returning to a previous task
PRACTICE_REDUCTION   = 0.01    # switch cost reduces with practice
HIGH_COST_THRESHOLD  = 0.6
LOW_COST_THRESHOLD   = 0.2
READY_THRESHOLD      = 0.8
TASK_SET_TYPES = %i[analytical creative social procedural perceptual linguistic spatial emotional]
COST_LABELS    = { (0.8..) => :prohibitive, ... (..0.2) => :negligible }
READINESS_LABELS = { (0.8..) => :fully_ready, ... (..0.2) => :unprepared }
RESIDUAL_LABELS  = { (0.8..) => :overwhelming, ... (..0.2) => :negligible }
```

## Runners

### `Runners::AttentionSwitching`

Methods accept optional `engine:` parameter (defaults to `@default_engine`), allowing test injection.

- `register_task(name:, task_type: :analytical, complexity: 0.5, engine: nil)` — register a task set with type and complexity
- `switch_to(task_id:, engine: nil)` — switch to a task; computes switch cost including residual and context restoration; records SwitchEvent
- `warmup(engine: nil)` — warm up the active task (increases readiness)
- `decay_residuals(engine: nil)` — decay residual activation for all tasks with residual
- `active_task(engine: nil)` — returns the currently active task
- `residual_tasks(engine: nil)` — tasks with non-negligible residual activation
- `recent_switches(limit: 10, engine: nil)` — recent switch events
- `average_switch_cost(engine: nil)` — average cost across all recorded switches
- `switch_cost_between(from_id:, to_id:, engine: nil)` — historical average cost for a specific pair
- `switching_report(engine: nil)` — comprehensive report
- `status(engine: nil)` — full state hash

## Helpers

### `Helpers::SwitchingEngine`
Core engine. `switch_to` computes cost as: `base_cost - (practice_count * PRACTICE_REDUCTION) + context_restoration_penalty`. Records SwitchEvent. Sets residual on the departed task. `decay_all_residuals!` reduces all tasks' residual by `RESIDUAL_DECAY_RATE`.

### `Helpers::TaskSet`
Value object: name, task_type, complexity, readiness (0–1), residual_activation (0–1), practice_count, is_active.

### `Helpers::SwitchEvent`
Value object: from_task, to_task, cost, timestamp.

## Integration Points

No actor defined — callers must invoke `decay_residuals` periodically. Integrates with lex-tick mode switching: when lex-cortex changes cognitive modes (dormant → full_active), the switching cost models how long it takes to reach full cognitive readiness. `warmup` models the ramp-up time for new task contexts. `switch_cost_between` informs scheduling decisions about task sequencing.

## Development Notes

- `engine:` parameter pattern allows passing a test double without monkey-patching
- Context restoration cost applies when switching to a task previously active in the same session (residual > 0)
- Practice reduces cost over repeated switches between the same pair — models procedural learning
- `RESIDUAL_DECAY_RATE = 0.1` means full decay requires ~10 calls to `decay_residuals`
