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
      return send(type_method) if respond_to?(type_method, true)
      raise("Unknown package type: #{package[:type]}")
    end

    private

    Contract None => nil
    def file_prepare_package
      raise('File package type requires "path" setting') unless package[:path]
      @upload_path = File.join(tmpdir(:release), package[:path])
      @upload_name = package[:name] || name
      nil
    end

    Contract None => nil
    def tarball_prepare_package
      @upload_path = tmpfile(:tarball)
      @upload_name = "#{name}.tar.gz"
      make_tarball!
      copy_tarball!
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

    Contract None => nil
    def copy_tarball!
      FileUtils.mkdir_p 'pkg'
      pkg_file = "pkg/#{name}-#{git_hash}.tar.gz"
      FileUtils.cp tmpfile(:tarball), pkg_file
      FileUtils.chmod 0o0644, pkg_file
      nil
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
