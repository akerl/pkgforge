require 'fileutils'

module PkgForge
  ##
  # Test engine
  class TestDSL
    include Contracts::Core
    include Contracts::Builtin

    Contract PkgForge::Forge => nil
    def initialize(forge)
      @forge = forge
      nil
    end

    private

    Contract Or[String, Array], Or[Hash[String => String], {}, nil] => nil
    def run(cmd, env = {})
      env['PATH'] ||= './usr/bin'
      @forge.test_run(cmd, env)
    end
  end
end
