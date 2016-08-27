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

    Contract Or[String, Array], Or[Hash[String => String], {}, nil] => nil
    def run(*args)
      @forge.run(*args)
    end

    Contract None => nil
    def configure
      flag_strings = @forge.configure_flags.map do |flag, value|
        "--#{flag}#{'=' if value}#{value}"
      end
      env = {
        'CC' => 'musl-gcc',
        'CFLAGS' => @forge.cflags
      }
      run ['./configure'] + flag_strings, env
    end

    Contract None => nil
    def make
      run 'make'
    end

    Contract None => nil
    def install
      run "make DESTDIR=#{@forge.releasedir} install"
    end

    Contract Or[String, Array[String]] => nil
    def rm(paths)
      paths = [paths] if paths.is_a? String
      paths.map { |x| File.join(@forge.releasedir, x) }
      FileUtils.rm_r paths
      nil
    end
  end
end
