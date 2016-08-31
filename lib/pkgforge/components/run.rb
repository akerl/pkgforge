module PkgForge
  ##
  # Add run methods to Forge
  class Forge
    Contract Or[String, Array], Or[HashOf[String => String], {}, nil] => nil
    def run(cmd, env = {})
      Dir.chdir(tmpdir(:build)) do
        run_local(cmd, env)
      end
      nil
    end

    Contract Or[String, Array], Or[HashOf[String => String], {}, nil] => nil
    def test_run(cmd, env = {})
      Dir.chdir(tmpdir(:release)) do
        run_local(cmd, env)
      end
    end

    private

    Contract Or[String, Array], Or[HashOf[String => String], {}, nil] => nil
    def run_local(cmd, env = {})
      puts "Running command in #{Dir.pwd}: #{cmd}"
      puts "Using env: #{env}" unless env.empty?
      res = system env, *cmd
      raise('Command failed!') unless res
      nil
    end
  end
end
