require 'fileutils'
require 'open-uri'

module PkgForge
  ##
  # Add source methods to Forge
  class Forge
    attr_writer :source

    Contract None => HashOf[Symbol => Any]
    def source
      @source ||= { type: 'git' }
    end

    private

    Contract None => nil
    def prepare_source!
      type_method = "#{source[:type]}_prepare_source"
      return send(type_method) if respond_to?(type_method, true)
      raise("Unknown source type: #{source[:type]}")
    end

    Contract None => nil
    def git_prepare_source
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
    def tar_prepare_source
      dest_file = tmpfile(:source_tar)
      File.open(dest_file, 'wb') do |fh|
        open(source[:url], 'rb') { |request| fh.write request.read }
      end
      run "tar -xf #{dest_file} --strip-components=1"
    end
  end
end
