require 'fileutils'

module PkgForge
  ##
  # Add upload methods to Forge
  class Forge
    Contract None => nil
    def package!
      add_license!
      make_tarball!
      copy_tarball!
    end

    private

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
      FileUtils.chmod 0644, pkg_file
      nil
    end
  end
end
