module PkgForge
  ##
  # Add configure flag options to Forge
  class Forge
    attr_writer :configure_flags

    Contract None => ArrayOf[String]
    def configure_flags
      @configure_flags ||= []
    end
  end

  module DSL
    ##
    # Add configure flag options to Forge DSL
    class Forge
      Contract HashOf[Symbol => String] => nil
      def configure_flags(value)
        @forge.configure_flags = value
        nil
      end
    end
  end
end
