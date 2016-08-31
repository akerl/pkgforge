module PkgForge
  ##
  # Add configure flag options to Forge
  class Forge
    attr_writer :configure_flags

    Contract None => HashOf[Symbol => Maybe[String]]
    def configure_flags
      @configure_flags ||= {}
    end
  end

  module DSL
    ##
    # Add configure flag options to Forge DSL
    class Forge
      Contract HashOf[Symbol => Maybe[String]] => nil
      def configure_flags(value)
        @forge.configure_flags = value
        nil
      end
    end

    ##
    # Add configure flag options to Build DSL
    class Build
      Contract None => ArrayOf[Strings]
      def configure_flag_strings
        @forge.configure_flags.map do |flag, value|
          "--#{flag}#{'=' if value}#{value}"
        end
      end
    end
  end
end
