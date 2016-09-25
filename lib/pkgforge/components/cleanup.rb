require 'fileutils'

module PkgForge
  ##
  # Add cleanup methods to Forge
  class Forge
    Contract None => nil
    def cleanup!
      @tmpdirs ||= {}
      @tmpfiles ||= {}
      tmpfiles = @tmpfiles.dup
      tmpfiles.delete(:tarball)
      paths = [tmpfiles.values, @tmpdirs.values].flatten
      puts "Cleaning up tmp paths: #{paths}"
      FileUtils.rm_r paths
      nil
    end
  end
end
