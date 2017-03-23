require 'fileutils'

module PkgForge
  ##
  # Add upload methods to Forge
  class Forge
    attr_writer :package

    Contract None => HashOf[Symbol => Any]
    def package
      @package ||= { type: 'tarball' }
    end

    Contract None => nil
    def package!
      add_license!
      type_method = "#{package[:type]}_prepare_package"
      method_found = respond_to?(type_method, true)
      raise("Unknown package type: #{package[:type]}") unless method_found
      send(type_method)
      expose_artifacts!
    end

    private

    Contract None => nil
    def file_prepare_package
      artifacts = package[:artifacts] || [package[:artifact]].compact
      raise('File package type requires artifacts list') if artifacts.empty?
      artifacts.each do |x|
        x[:source] = File.join(tmpdir(:release), x[:source])
        add_artifact(x)
      end
    end

    Contract None => nil
    def tarball_prepare_package
      add_artifact(
        source: tmpfile(:tarball),
        name: "#{name}.tar.gz",
        long_name: "#{name}-#{git_hash}.tar.gz"
      )
      make_tarball!
    end

    Contract None => nil
    def make_tarball!
      Dir.chdir(tmpdir(:release)) do
        run_local "tar -czvf #{tmpfile(:tarball)} *"
      end
      nil
    end

    Contract None => String
    def git_hash
      `git rev-parse --short HEAD`.rstrip
    end
  end

  module DSL
    ##
    # Add package methods to Forge DSL
    class Forge
      Contract HashOf[Symbol => Any] => nil
      def package(params)
        @forge.package = params
        nil
      end
    end
  end
end
