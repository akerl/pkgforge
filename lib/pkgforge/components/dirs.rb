require 'tmpdir'
require 'tempfile'

module PkgForge
  ##
  # Add dir methods to Forge
  class Forge
    Contract String => String
    def dep(package)
      tmpdir(package.to_sym)
    end

    Contract None => String
    def releasedir
      tmpdir(:release)
    end

    Contract Symbol => String
    def tmpdir(id)
      @tmpdirs ||= {}
      @tmpdirs[id] ||= Dir.mktmpdir(id.to_s)
    end

    Contract Symbol => String
    def tmpfile(id)
      @tmpfiles ||= {}
      @tmpfiles[id] ||= Tempfile.create(id.to_s).path
    end
  end

  module DSL
    ##
    # Add dir methods to Forge DSL
    class Forge
      Contract String => String
      def dep(dep_name)
        @forge.dep(dep_name)
      end
    end
  end
end