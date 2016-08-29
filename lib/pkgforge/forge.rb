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
    include PkgForge::Helpers
    include PkgForge::Prepare
    include PkgForge::Push

    attr_accessor :name, :org, :deps, :configure_flags, :version_block,
                  :patches, :build_block, :test_block, :license, :cflags,
                  :libs

    Contract Maybe[HashOf[Symbol => Any]] => nil
    def initialize(params = {})
      @options = params
      @license = 'LICENSE'
      @deps = {}
      @flags = {}
      @patches = []
      @build_block = proc { raise('No build block provided') }
      @test_block = proc { raise('No test block provided') }
      nil
    end

    Contract None => nil
    def build!
      prepare_source!
      patch_source!
      prepare_deps!
      builder = BuildDSL.new(self)
      builder.instance_eval(&build_block)
    end

    Contract None => nil
    def test!
      tester = TestDSL.new(self)
      tester.instance_eval(&test_block)
    end

    Contract None => nil
    def push!
      add_license!
      make_tarball!
      update_repo!
      upload_artifact!
    end
  end
end
