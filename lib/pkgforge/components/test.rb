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

    Contract Func[None => nil] => nil
    def lib_override
      lib_path_file = '/etc/ld-musl-x86_64.path'
      old_lib_paths = File.read(path_file)
      File.open(lib_path_file, 'w') { |fh| fh << ld_library_path }
      yield
    ensure
      File.open(lib_path_file, 'w') { |fh| fh << old_lib_paths }
      nil
    end

    Contract None => String
    def ld_library_path
      deps.keys.map { |x| "#{dep(x)}/usr/lib" }.join("\n")
    end
  end

  module DSL
    ##
    # Add test methods to Forge DSL
    class Forge
      Contract Func[None => nil] => nil
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
