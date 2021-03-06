require 'tmpdir'
require 'tempfile'

module PkgForge
  ##
  # Add dir methods to Forge
  class Forge
    Contract Or[String, Symbol] => String
    def dep(package)
      tmpdir(package.to_sym)
    end

    Contract None => String
    def releasedir
      tmpdir(:release)
    end

    Contract Symbol => String
    def tmpdir(id)
      state[:tmpdirs] ||= {}
      state[:tmpdirs][id] ||= Dir.mktmpdir(id.to_s)
    end

    Contract Symbol => String
    def tmpfile(id)
      state[:tmpfiles] ||= {}
      state[:tmpfiles][id] ||= Tempfile.create(id.to_s).path
    end
  end

  module DSL
    ##
    # Add dir methods to Forge DSL
    class Forge
      Contract Or[String, Symbol] => String
      def dep(dep_name)
        @forge.dep(dep_name)
      end
    end

    ##
    # Add dir methods to Build DSL
    class Build
      Contract None => String
      def releasedir
        @forge.tmpdir(:release)
      end

      Contract Or[String, Symbol] => String
      def dep(package)
        @forge.tmpdir(package.to_sym)
      end

      Contract Symbol => String
      def tmpdir(id)
        @forge.tmpdir(id)
      end
    end
  end
end
