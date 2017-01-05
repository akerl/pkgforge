require 'fileutils'

module PkgForge
  ##
  # Add cleanup methods to Forge
  class Forge
    Contract None => nil
    def cleanup!
      state[:tmpdirs] ||= {}
      state[:tmpfiles] ||= {}
      paths = state.values_at(:tmpdirs, :tmpfiles).map(&:values).flatten
      puts "Cleaning up tmp paths: #{paths}"
      FileUtils.rm_rf paths
      nil
    end
  end
end
