module PkgForge
  ##
  # Build methods
  module Build
    include Contracts::Core
    include Contracts::Builtin

    private

    Contract None => nil
    def configure
      flag_strings = flags.map { |k, v| "--#{k}=#{v}" }
      env = {
        'CC' => 'musl-gcc'
      }
      run ['./configure', flag_strings], env
    end

    Contract None => nil
    def make
      run 'make'
    end

    Contract None => nil
    def install
      run "make DESTDIR=#{tmpdir(:release)} install"
    end

    Contract Or[String, Array[String]] => nil
    def rm(paths)
      FileUtils.rm_r paths
      nil
    end

    Contract None => nil
    def prepare_source!
      dest = tmpdir(:build)
      dest_git = File.join(dest, '.git')
      dest_git_config = File.join(dest_git, 'config')
      run_local 'git submodule update --init'
      FileUtils.cp_r 'upstream/.', dest
      FileUtils.rm_r dest_git
      FileUtils.cp_r '.git/modules/upstream', dest_git
      new_config = File.readlines(dest_git_config).grep_v(/worktree =/).join
      File.open(dest_git_config, 'w') { |fh| fh << new_config }
      nil
    end

    Contract None => nil
    def patch_source!
      patches.each do |patch|
        run_local "patch -d #{tmpdir(:build)} -p1 < patches/#{patch}"
      end
      nil
    end

    Contract None => nil
    def prepare_deps!
      deps.each do |dep_name, dep_version|
        url = "https://github.com/#{org}/#{dep_name}/releases/download/#{dep_version}/#{dep_name}.tar.gz" # rubocop:disable Metrics/LineLength
        open(tmpfile(dep_name), 'wb') { |fh| fh << open(url, 'rb').read }
        run_local "tar -x -C #{tmpdir(dep_name)} -f #{tmpfile(dep_name)}"
      end
      nil
    end

    Contract None => nil
    def add_license!
      src_file = File.join(tmpdir(:build), license)
      dest_dir = File.join(
        tmpdir(:release), 'usr', 'share', 'licenses', package
      )
      dest_file = File.join(dest_dir, 'LICENSE')
      FileUtils.mkdir_p dest_dir
      FileUtils.cp src_file, dest_file
      nil
    end

    Contract None => nil
    def make_tarball!
      Dir.chdir(tmpdir(:release)) do
        run_local "tar -czvf #{tmpfile(:tarball)} *"
      end
      nil
    end
  end
end
