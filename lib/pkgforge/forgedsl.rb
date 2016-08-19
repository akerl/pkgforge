##
# Declare DSL for Forge objects
module PkgForge
  ##
  # DSL for generating a Forge
  class ForgeDSL
    include Contracts::Core
    include Contracts::Builtin

    Contract Forge, Maybe[Hash] => nil
    def initialize(forge, params = {})
      @forge = forge
      @options = params
      nil
    end

    Contract String => String
    def name(value)
      @forge.name = value
    end

    Contract String => String
    def org(value)
      @forge.org = value
    end

    Contract HashOf[Symbol => String] => HashOf[Symbol => String]
    def deps(value)
      @forge.deps = value
    end

    Contract HashOf[Symbol => String] => HashOf[Symbol => String]
    def flags(value)
      @forge.flags = value
    end

    Contract Func[None => String] => Proc
    def version(&block)
      @forge.version_block = block
    end

    Contract String => nil
    def patch(file)
      @forge.patches ||= []
      @forge.patches << file
    end

    Contract Func[None => nil] => Proc
    def build(&block)
      @forge.build_block = block
    end

    Contract String => nil
    def license(file)
      @forge.license = file
    end
  end
end
