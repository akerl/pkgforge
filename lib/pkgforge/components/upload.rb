module PkgForge
  ##
  # Add upload methods to Forge
  class Forge
    Contract None => nil
    def push!
      add_license!
      make_tarball!
      update_repo!
      upload_artifact!
    end

    private

    Contract None => nil
    def make_tarball!
      Dir.chdir(tmpdir(:release)) do
        run_local "tar -czvf #{tmpfile(:tarball)} *"
      end
      nil
    end

    Contract None => nil
    def update_repo!
      run_local "git tag -f '#{full_version}'"
      run_local 'git push --tags origin master'
      sleep 2
      nil
    end

    Contract None => nil
    def upload_artifact!
      run_local [
        'targit',
        '--authfile', '.targit',
        '--create',
        '--name', "#{name}.tar.gz",
        "#{org}/#{name}", full_version, tmpfile(:tarball)
      ]
      nil
    end
  end
end
