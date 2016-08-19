module PkgForge
  ##
  # Helper functions for building packages
  module Helpers
    include Contracts::Core
    include Contracts::Builtin

    Contract String => String
    def dep(package)
      tmpdir(package.to_sym)
    end

    Contract None => String
    def releasedir
      tmpdir(:release)
    end

    Contract Or[String, Array], Or[Hash[String => String], {}, nil] => nil
    def run(cmd, env = {})
      Dir.chdir(tmpdir(:build)) do
        run_local(cmd, env)
      end
      nil
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

    Contract Or[String, Array], Or[Hash[String => String], {}, nil] => nil
    def run_local(cmd, env = {})
      puts "Running command in #{Dir.pwd}: #{cmd}"
      puts "Using env: #{env}" unless env.empty?
      res = system env, *cmd
      raise('Command failed!') unless res
      nil
    end

    Contract None => String
    def version
      @version ||= Dir.chdir(tmpdir(:build)) { version_block.call }
    end

    Contract None => Num
    def revision
      File.read('version').to_i
    end

    Contract None => String
    def full_version
      "#{version}-#{revision}"
    end
  end
end
