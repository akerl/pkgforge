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
      run_local "git clone --recursive '#{source[:path]}' #{tmpdir(:build)}"
    end

    Contract None => nil
    def tar_prepare_source
      dest_file = tmpfile(:source_tar)
      File.open(dest_file, 'wb') do |fh|
        open(source[:url], 'rb') do |request| # rubocop:disable Security/Open
          fh.write request.read
        end
        verify_file(dest_file, source[:checksum])
      end
      run "tar -xf #{dest_file} --strip-components=1"
    end

    Contract None => nil
    def empty_prepare_source
      # This source type is a no-op
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
