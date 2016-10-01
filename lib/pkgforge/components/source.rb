require 'fileutils'
require 'open-uri'

module PkgForge
  ##
  # Add source methods to Forge
  class Forge
    attr_writer :source

    Contract None => HashOf[Symbol => Any]
    def source
      @source ||= { type: 'git', path: 'upstream' }
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
      run_local 'git submodule update --init --recursive'
      FileUtils.cp_r "#{source[:path]}/.", tmpdir(:build)
      git_fix_submodule unless source[:path] == '.'
    end

    Contract None => nil
    def git_fix_submodule
      dest_git = File.join(tmpdir(:build), '.git')
      dest_git_config = File.join(dest_git, 'config')
      FileUtils.rm dest_git
      FileUtils.cp_r ".git/modules/#{source[:path]}", dest_git
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

  module DSL
    ##
    # Add source methods to Forge DSL
    class Forge
      Contract HashOf[Symbol => Any] => nil
      def source(params)
        @forge.source = params
        nil
      end
    end
  end
end
