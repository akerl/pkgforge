module PkgForge
  ##
  # Add upload methods to Forge
  class Forge
    Contract None => nil
    def push!
      upload_artifact!
    end

    private

    Contract None => String
    def version
      @version ||= `git describe --abbrev=0 --tags`.rstrip
    end

    Contract None => nil
    def upload_artifact!
      run_local [
        'targit',
        '--authfile', '.github',
        '--create',
        '--name', "#{name}.tar.gz",
        "#{org}/#{name}", version, tmpfile(:tarball)
      ]
      nil
    end
  end
end
