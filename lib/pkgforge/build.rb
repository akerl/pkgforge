require 'fileutils'

module PkgForge
  ##
  # Builder engine
  class BuildDSL
    include Contracts::Core
    include Contracts::Builtin

    Contract PkgForge::Forge => nil
    def initialize(forge)
      @forge = forge
      nil
    end

    private

    Contract Or[String, Array], Maybe[Hash[String => String]] => nil
    def run(*args)
      @forge.run(*args)
    end

    Contract None => nil
    def configure
      flag_strings = flags.map { |k, v| "--#{k}=#{v}" }
      env = {
        'CC' => 'musl-gcc'
      }
      run ['./configure', flag_strings], env
    end

    Contract None => nil
    def make
      run 'make'
    end

    Contract None => nil
    def install
      run "make DESTDIR=#{tmpdir(:release)} install"
    end

    Contract Or[String, Array[String]] => nil
    def rm(paths)
      FileUtils.rm_r paths
      nil
    end
  end
end
