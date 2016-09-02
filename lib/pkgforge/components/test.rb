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
        cmd.unshift('/usr/bin/env') if cmd.is_a? Array
        cmd << ';' if cmd.is_a? String
        env['PATH'] ||= './usr/bin'
        env['LD_LIBRARY_PATH'] ||= ld_library_path
        @forge.test_run(cmd, env)
      end

      private

      Contract None => String
      def ld_library_path
        @forge.deps.keys.map { |x| "#{@forge.dep(x)}/usr/lib" }.join(':')
      end
    end
  end
end
