module PkgForge
  ##
  # Helpers for pushing
  module Push
    include Contracts::Core
    include Contracts::Builtin

    private

    Contract None => nil
    def bump_revision!
      new_revision = File.read('version').to_i + 1
      File.open('version', 'w') { |fh| fh << "#{new_revision}\n" }
      nil
    end

    Contract None => nil
    def update_repo!
      run_local "git commit -am '#{full_version}'"
      run_local "git tag -f '#{full_version}'"
      run_local 'git push --tags origin master'
      sleep 2
      nil
    end

    Contract None => nil
    def upload_artifact!
      run_local [
        'targit',
        '-c',
        '-f',
        "#{org}/#{package}",
        full_version,
        tmpfile(:tarball)
      ]
      nil
    end
  end
end
