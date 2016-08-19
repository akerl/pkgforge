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

    attr_accessor :name, :org, :deps, :flags, :version_block, :patches,
                  :build_block, :license

    Contract Maybe[HashOf[Symbol => Any]] => nil
    def initialize(params = {})
      @options = params
      @license = 'LICENSE'
      @deps = {}
      @flags = {}
      @patches = []
      nil
    end

    Contract None => nil
    def build!
      prepare_source!
      patch_source!
      prepare_deps!
      builder = BuildDSL.new(self)
      builder.instance_eval &build_block
      add_license!
      make_tarball!
    end

    Contract None => nil
    def push!
      bump_revision!
      update_repo!
      upload_artifact!
    end
  end
end
