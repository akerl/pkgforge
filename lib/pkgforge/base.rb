require 'contracts'

module PkgForge
  ##
  # Starter Forge object
  class Forge
    include Contracts::Core
    include Contracts::Builtin

    Contract Maybe[HashOf[Symbol => Any]] => nil
    def initialize(params = {})
      @options = params
      nil
    end
  end

  ##
  # Base engine structure
  class Base
    include Contracts::Core
    include Contracts::Builtin

    Contract PkgForge::Forge => nil
    def initialize(forge)
      @forge = forge
      nil
    end
  end

  module DSL
    class Forge < PkgForge::Base
    end

    class Build < PkgForge::Base
    end

    class Test < PkgForge::Base
    end
  end
end
