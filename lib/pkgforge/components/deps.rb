require 'open-uri'

module PkgForge
  ##
  # Add dep methods to Forge
  class Forge
    attr_writer :deps, :remove_linker_archives, :remove_pkgconfig_files

    Contract None => HashOf[Symbol => String]
    def deps
      @deps ||= {}
    end

    Contract None => Bool
    def remove_linker_archives?
      @remove_linker_archives ||= false
    end

    Contract None => Bool
    def remove_pkgconfig_files?
      @remove_pkgconfig_files ||= false
    end

    private

    Contract None => nil
    def prepare_deps!
      download_deps!
      remove_linker_archives! if remove_linker_archives?
      remove_pkgconfig_files! if remove_pkgconfig_files?
    end

    Contract None => nil
    def download_deps!
      deps.each do |dep_name, dep_version|
        url = "https://github.com/#{org}/#{dep_name}/releases/download/#{dep_version}/#{dep_name}.tar.gz" # rubocop:disable Metrics/LineLength
        open(tmpfile(dep_name), 'wb') { |fh| fh << open(url, 'rb').read }
        run_local "tar -x -C #{tmpdir(dep_name)} -f #{tmpfile(dep_name)}"
      end
      nil
    end

    Contract None => nil
    def remove_linker_archives!
      deps.keys.each do |dep_name|
        File.unlink(*Dir.glob("#{tmpdir(dep_name)}/**/*.la"))
      end
      nil
    end

    Contract None => nil
    def remove_pkgconfig_files!
      deps.keys.each do |dep_name|
        File.unlink(*Dir.glob("#{tmpdir(dep_name)}/**/*.pc"))
      end
      nil
    end
  end

  module DSL
    ##
    # Add dep methods to Forge DSL
    class Forge
      Contract HashOf[Symbol => String] => nil
      def deps(value)
        @forge.deps = value
        nil
      end

      Contract Bool => nil
      def remove_linker_archives(value = true)
        @forge.remove_linker_archives = value
        nil
      end

      Contract Bool => nil
      def remove_pkgconfig_files(value = true)
        @forge.remove_pkgconfig_files = value
        nil
      end
    end
  end
end
