module PkgForge
  ##
  # Version engine
  class VersionDSL
    include Contracts::Core
    include Contracts::Builtin

    Contract PkgForge::Forge => nil
    def initialize(forge)
      @forge = forge
      nil
    end

    private

    Contract Maybe[Regexp], Maybe[String] => String
    def git_tag(regex = nil, replace = '\1')
      tag = `git describe --tags`.rstrip
      tag.gsub!(regex, replace) if regex
      tag
    end
  end
end
