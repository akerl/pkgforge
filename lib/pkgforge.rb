require 'contracts'

require 'pkgforge/base'
require 'pkgforge/version'
require 'pkgforge/components/build'
require 'pkgforge/components/cflags'
require 'pkgforge/components/configure'
require 'pkgforge/components/deps'
require 'pkgforge/components/dirs'
require 'pkgforge/components/metadata'
require 'pkgforge/components/patch'
require 'pkgforge/components/run'
require 'pkgforge/components/source'
require 'pkgforge/components/test'
require 'pkgforge/components/upload'
require 'pkgforge/components/version'

##
# DSL engine for compiling Arch packages
module PkgForge
  include Contracts::Core
  include Contracts::Builtin

  DEFAULT_FILE = './.pkgforge'.freeze

  class << self
    ##
    # Insert a helper .new() method for creating a Forge object
    def new(*args)
      self::Forge.new(*args)
    end

    ##
    # Method for loading in DSL file
    Contract Maybe[HashOf[Symbol => Any]] => PkgForge::Forge
    def load_from_file(params = {})
      file = params[:file] || DEFAULT_FILE
      forge = Forge.new(params)
      dsl = ForgeDSL.new(forge, params)
      dsl.instance_eval(File.read(file), file)
      forge
    end
  end
end
