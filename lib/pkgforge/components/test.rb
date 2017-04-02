require 'fileutils'

module PkgForge
  ##
  # Add test methods to Forge
  class Forge
    attr_writer :test_block

    Contract None => Proc
    def test_block
      @test_block ||= proc { raise 'No test block provided' }
    end

    Contract None => nil
    def test!
      tester = PkgForge::DSL::Test.new(self)
      tester.instance_eval(&test_block)
      nil
    end

    Contract Or[String, Array], Or[HashOf[String => String], {}, nil] => nil
    def test_run(cmd, env = {})
      cmd.unshift('/usr/bin/env') if cmd.is_a? Array
      cmd.prepend('/usr/bin/env ') if cmd.is_a? String
      env['PATH'] ||= './usr/bin'
      lib_override do
        Dir.chdir(tmpdir(:release)) do
          run_local(cmd, env)
        end
      end
    end

    private

    Contract None => String
    def lib_path_file
      '/etc/ld-musl-x86_64.path'
    end

    Contract Func[None => nil] => nil
    def lib_override
      old_lib_paths = File.read(lib_path_file) if File.exist?(lib_path_file)
      puts "Setting library path: #{ld_library_path}"
      File.open(lib_path_file, 'w') { |fh| fh << ld_library_path }
      yield
    ensure
      reset_lib_path_file(old_lib_paths)
    end

    Contract Maybe[String] => nil
    def reset_lib_path_file(old_lib_paths)
      if old_lib_paths
        File.open(lib_path_file, 'w') { |fh| fh << old_lib_paths }
      else
        File.unlink(lib_path_file)
      end
      nil
    end

    Contract None => String
    def ld_library_path
      paths = ["#{releasedir}/usr/lib"]
      paths += deps.keys.map { |x| "#{dep(x)}/usr/lib" }
      paths.join(':')
    end
  end

  module DSL
    ##
    # Add test methods to Forge DSL
    class Forge
      def test(&block)
        @forge.test_block = block
        nil
      end
    end

    ##
    # Add test methods to Test DSL
    class Test
      Contract Or[String, Array], Or[HashOf[String => String], {}, nil] => nil
      def run(cmd, env = {})
        @forge.test_run(cmd, env)
      end
    end
  end
end
