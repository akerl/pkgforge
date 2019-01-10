module PkgForge
  ##
  # Add cflag options to Forge
  class Forge
    attr_writer :cflags, :libs

    Contract None => ArrayOf[String]
    def cflags
      @cflags ||= []
    end

    Contract None => ArrayOf[String]
    def libs
      @libs ||= []
    end
  end

  module DSL
    ##
    # Add cflag options to Forge DSL
    class Forge
      Contract Maybe[ArrayOf[String]] => nil
      def cflags(value = nil)
        default = '-I%<dep>s/usr/include -L%<dep>s/usr/lib'
        value ||= @forge.deps.map { |x, _| format(default, dep: dep(x)).split }
        @forge.cflags += value.flatten
        nil
      end

      Contract Maybe[ArrayOf[String]] => nil
      def libs(value = nil)
        value ||= @forge.deps.keys
        value.map! { |x| '-l' + x.to_s }
        @forge.libs += value
        nil
      end

      # Shamelessly sourced from:
      # https://blog.mayflower.de/5800-Hardening-Compiler-Flags-for-NixOS.html
      ALL_HARDEN_OPTS = {
        controlflow: %w[-fcf-protection -mcet],
        format: %w[-Wformat -Wformat-security -Werror=format-security],
        fortify: %w[-D_FORTIFY_SOURCE=2],
        implicit: %w[-Werror=implicit-function-declaration],
        lazybinding: %w[-Wl,-z,now],
        optimize: %w[-O2],
        pic: %w[-fPIC -shared],
        pie: %w[-fpie -Wl,-pie],
        relro: %w[-Wl,-z,relro],
        stackclash: %w[-fstack-clash-protection],
        stackprotector: %w[-fstack-protector-strong],
        strictoverflow: %w[-fno-strict-overflow],
        underlinking: %w[-Wl,-z,defs],
        warnings: %w[-Wall]
      }.freeze

      Contract Maybe[Array[String]] => nil
      def harden(list = [])
        harden_opts = ALL_HARDEN_OPTS.reject { |k, _| list.include? k.to_s }
        @forge.cflags += harden_opts.values.flatten
        nil
      end
    end
  end
end
