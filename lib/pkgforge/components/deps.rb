require 'open-uri'

module PkgForge
  ##
  # Add dep methods to Forge
  class Forge
    attr_writer :deps

    Contract None => HashOf[Symbol => String]
    def deps
      @deps ||= {}
    end

    private

    Contract None => nil
    def prepare_deps!
      deps.each do |dep_name, dep_version|
        url = "https://github.com/#{org}/#{dep_name}/releases/download/#{dep_version}/#{dep_name}.tar.gz" # rubocop:disable Metrics/LineLength
        open(tmpfile(dep_name), 'wb') { |fh| fh << open(url, 'rb').read }
        run_local "tar -x -C #{tmpdir(dep_name)} -f #{tmpfile(dep_name)}"
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
    end
  end
end
