require 'tmpdir'
require 'tempfile'
require 'fileutils'
require 'open-uri'

##
# Declare actual Forge with package-building
module PkgForge
  ##
  # Real Forge object
  class Forge
    include Contracts::Core
    include Contracts::Builtin

    attr_accessor :name, :org, :deps, :flags, :version_block, :patches,
                  :build_block, :license

    Contract Maybe[HashOf[Symbol => Any]] => nil
    def initialize(params = {})
      @options = params
      license = 'LICENSE'
      deps = {}
      flags = {}
      patches = []
      nil
    end

    Contract None => nil
    def build!
      prepare_source!
      patch_source!
      prepare_deps!
      build_block.call
      add_license!
    end

    Contract None => nil
    def push!
    end

    private

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

    Contract String => String
    def dep(package)
      tmpdir(package.to_sym)
    end

    Contract Or[String, Array], Maybe[Hash[String => String]] => nil
    def run(cmd, env = {})
      Dir.chdir(tmpdir(:build)) do
        run_local(cmd, env)
      end
    end

    Contract Or[String, Array], Maybe[Hash[String => String]] => nil
    def run_local(cmd, env = {})
      puts "Running command in #{Dir.pwd}: #{cmd}"
      res = system env, cmd
      raise('Command failed!') unless res
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
    end

    Contract None => String
    def version
      version_block.call
    end

    Contract None => nil
    def prepare_source!
      dest = tmpdir(:build)
      dest_git = File.join(dest, '.git')
      dest_git_config = File.join(dest_git, 'config')
      run_local 'git submodule update --init'
      FileUtils.cp_r 'upstream/.', dest
      FileUtils.rm_r dest_git
      FileUtils.cp_r '.git/modules/upstream', dest_git
      new_config = File.readlines(dest_git_config).grep_v(/worktree =/).join
      File.open(dest_git_config, 'w') { |fh| fh << new_config }
    end

    Contract None => nil
    def patch_source!
      patches.each do |patch|
        run_local "patch -d #{tmpdir(:build)} -p1 < patches/#{patch}"
      end
    end

    Contract None => nil
    def prepare_deps!
      deps.each do |package, version|
        url = "https://github.com/#{org}/#{package}/releases/download/#{version}/#{package}.tar.gz" # rubocop:disable Metrics/LineLength
        open(tmpfile(package), 'wb') { |fh| fh << open(url, 'rb') }
        run_local "tar -x -C #{tmpdir(package)} -f #{tmpfile(package)}"
      end
    end

    Contract None => nil
    def add_license!
      src_file = File.join(tmpdir(:build), license)
      dest_dir = File.join(tmpdir(:release), 'usr', 'share', 'licenses', package)
      dest_file = File.join(dest_dir, 'LICENSE')
      FileUtils.mkdir_p dest_dir
      FileUtils.cp src_file, dest_file
    end
  end
end
