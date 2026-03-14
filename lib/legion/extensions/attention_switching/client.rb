# frozen_string_literal: true

module Legion
  module Extensions
    module AttentionSwitching
      class Client
        include Runners::AttentionSwitching

        def initialize(engine: nil)
          @default_engine = engine || Helpers::SwitchingEngine.new
        end
      end
    end
  end
end
