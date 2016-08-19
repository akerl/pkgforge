require 'contracts'

require 'pkgforge/version'
require 'pkgforge/forge'
require 'pkgforge/forgedsl'

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
  end

  ##
  # Method for loading in DSL file
  Contract Maybe[HashOf[Symbol => Any]] => self::Forge
  def load_from_file(params = {})
    file = params[:file] || DEFAULT_FILE
    forge = Forge.new(params)
    dsl = ForgeDSL.new(forge, params)
    dsl.instance_eval(File.read(file), file)
    forge
  end
end
