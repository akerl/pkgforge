module PkgForge
  ##
  # Add upload methods to Forge
  class Forge
    Contract None => nil
    def push!
      upload_artifacts!
    end

    private

    Contract HashOf[Symbol => String] => nil
    def add_artifact(params)
      state[:artifacts] ||= []
      state[:artifacts] << params
      nil
    end

    Contract None => nil
    def expose_artifacts!
      FileUtils.mkdir_p 'pkg'
      return unless state[:artifacts]
      state[:artifacts].each do |artifact|
        dest = File.join('pkg', artifact[:long_name] || artifact[:name])
        FileUtils.cp artifact[:source], dest
        FileUtils.chmod 0o0644, dest
      end
      nil
    end

    Contract None => String
    def version
      @version ||= `git describe --abbrev=0 --tags`.rstrip
    end

    Contract None => nil
    def upload_artifacts!
      return unless state[:artifacts]
      state[:artifacts].each do |artifact|
        run_local ['targit', '--authfile', '.github', '--create',
                   '--name', artifact[:name],
                   "#{org}/#{name}", version, artifact[:source]]
      end
      nil
    end
  end
end
