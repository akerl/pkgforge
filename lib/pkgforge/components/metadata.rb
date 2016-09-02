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

    Contract None => ArrayOf[String]
    def licenses
      @licenses ||= ['LICENSE']
    end

    Contract None => nil
    def add_license!
      dest_dir = File.join(tmpdir(:release), 'usr', 'share', 'licenses', name)
      FileUtils.mkdir_p dest_dir
      licenses.each do |license|
        src_file = File.join(tmpdir(:build), license)
        dest_file = File.join(dest_dir, license)
        FileUtils.cp src_file, dest_file
      end
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

      Contract Or[String, ArrayOf[String]] => nil
      def licenses(files)
        files = [files] unless files.is_a? Array
        @forge.license = files
        nil
      end
    end
  end
end
