module PkgForge
  ##
  # Helpers for pushing
  module Push
    include Contracts::Core
    include Contracts::Builtin

    private

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
