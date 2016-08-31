module PkgForge
  ##
  # Add version methods to Forge
  class Forge
    attr_writer :version_block

    Contract None => Proc
    def version_block
      @version_block ||= proc { raise 'No version block provided' }
    end

    Contract None => String
    def version
      @version ||= Dir.chdir(tmpdir(:build)) do
        PkgForge::DSL::Version.new(self).instance_eval(&version_block)
      end
    end

    Contract None => Num
    def revision
      @revision ||= `git describe --abbrev=0 --tags`.split('-').last.to_i + 1
    end

    Contract None => String
    def full_version
      "#{version}-#{revision}"
    end
  end

  module DSL
    ##
    # Add version methods to Forge DSL
    class Forge
      Contract Func[None => Maybe[String]] => nil
      def version(&block)
        @forge.version_block = block
        nil
      end
    end

    ##
    # Add version methods to Version DSL
    class Version
      Contract Maybe[Regexp], Maybe[String] => String
      def git_tag(regex = nil, replace = '\1')
        tag = `git describe --tags`.rstrip
        tag.gsub!(regex, replace) if regex
        tag
      end
    end
  end
end
