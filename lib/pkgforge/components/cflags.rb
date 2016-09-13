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
      Contract Maybe[String] => nil
      def cflags(value = nil)
        default = '-I%{dep}/usr/include -L%{dep}/usr/lib'
        value ||= @forge.deps.map { |x, _| (default % { dep: dep(x) }).split }
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
        format: %w(-Wformat -Wformat-security -Werror=format-security),
        stackprotector: %w(-fstack-protector-strong --param ssp-buffer-size=4),
        fortify: %w(-O2 -D_FORTIFY_SOURCE=2),
        pic: '-fPIC',
        strictoverflow: '-fno-strict-overflow',
        relro: '-zrelro',
        bindnow: '-zbindnow'
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
