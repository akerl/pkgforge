require 'fileutils'

module PkgForge
  ##
  # Add source methods to Forge
  class Forge
    private

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
  end
end
