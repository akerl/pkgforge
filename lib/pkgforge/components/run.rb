module PkgForge
  ##
  # Add run methods to Forge
  class Forge
    Contract Or[String, Array], Or[HashOf[String => String], {}, nil] => nil
    def run(cmd, env = {})
      puts "Running command in #{Dir.pwd}: #{cmd}"
      puts "Using env: #{env}" unless env.empty?
      res = system env, *cmd
      raise('Command failed!') unless res
      nil
    end
  end
end
