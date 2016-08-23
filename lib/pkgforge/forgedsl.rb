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

    Contract String => nil
    def name(value)
      @forge.name = value
      nil
    end

    Contract String => nil
    def org(value)
      @forge.org = value
      nil
    end

    Contract HashOf[Symbol => String] => nil
    def deps(value)
      @forge.deps = value
      nil
    end

    Contract HashOf[Symbol => String] => nil
    def flags(value)
      @forge.flags = value
      nil
    end

    Contract Func[None => String] => nil
    def version(&block)
      @forge.version_block = block
      nil
    end

    Contract String => nil
    def patch(file)
      @forge.patches ||= []
      @forge.patches << file
      nil
    end

    Contract Func[None => nil] => nil
    def build(&block)
      @forge.build_block = block
      nil
    end

    Contract Func[None => nil] => nil
    def test(&block)
      @forge.test_block = block
      nil
    end

    Contract String => nil
    def license(file)
      @forge.license = file
      nil
    end

    Contract String => String
    def dep(dep_name)
      @forge.dep(dep_name)
    end
  end
end
