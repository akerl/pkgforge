require 'fileutils'

module PkgForge
  ##
  # Add metadata methods to Forge
  class Forge
    attr_writer :name, :org, :license

    Contract None => String
    def name
      @name || raise('No name provided')
    end

    Contract None => String
    def org
      @org || raise('No org provided')
    end

    Contract None => String
    def license
      @license ||= 'LICENSE'
    end

    Contract None => nil
    def add_license!
      src_file = File.join(tmpdir(:build), license)
      dest_dir = File.join(
        tmpdir(:release), 'usr', 'share', 'licenses', name
      )
      dest_file = File.join(dest_dir, 'LICENSE')
      FileUtils.mkdir_p dest_dir
      FileUtils.cp src_file, dest_file
      nil
    end
  end

  module DSL
    ##
    # Add metadata methods to Forge DSL
    class Forge
      Contract String => nil
      def name(value)
        @forge.name = value
        nil
      end

      Contract String => nil
      def org(value)
        @forge.org = value
        nil
      end

      Contract String => nil
      def license(file)
        @forge.license = file
        nil
      end
    end
  end
end
