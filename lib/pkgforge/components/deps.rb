require 'open-uri'
require 'digest'

module PkgForge
  ##
  # Add dep methods to Forge
  class Forge
    attr_writer :deps, :remove_linker_archives, :remove_pkgconfig_files

    Contract None => HashOf[Symbol => Or[String, Hash]]
    def deps
      @deps ||= {}
    end

    Contract None => Bool
    def remove_linker_archives?
      @remove_linker_archives ||= false
    end

    Contract None => Bool
    def remove_pkgconfig_files?
      @remove_pkgconfig_files ||= false
    end

    private

    Contract None => nil
    def prepare_deps!
      download_deps!
      remove_linker_archives! if remove_linker_archives?
      remove_pkgconfig_files! if remove_pkgconfig_files?
    end

    Contract None => nil
    def download_deps!
      deps.each do |dep_name, dep_hash|
        file = tmpfile(dep_name)
        dir = tmpdir(dep_name)
        download_file(dep_name, dep_hash, file)
        verify_file(file, dep_hash[:checksum])
        extract_file(file, dir)
      end
      nil
    end

    Contract Symbol, HashOf[String => String], String => nil
    def download_file(dep_name, dep_hash, file)
      dep_hash[:org] ||= org
      dep_hash[:site] ||= 'https://github.com'
      url = "#{dep_hash[:site]}/#{dep_hash[:org]}/#{dep_name}/releases/download/#{dep_hash[:version]}/#{dep_name}.tar.gz" # rubocop:disable Metrics/LineLength
      File.open(file, 'wb') do |fh|
        fh << open(url, 'rb').read # rubocop:disable Security/Open
      end
      nil
    end

    Contract String, Maybe[String] => nil
    def verify_file(file, expected = nil)
      case expected
      when nil
        raise "No checksum provided for #{file}"
      when 'skip'
        puts "Skipping checksum for #{file}"
      else
        actual = Digest::SHA256.file(file).hexdigest
        return if actual == expected
        raise "Checksum fail for #{file}: #{actual} (actual) != #{expected} (expected)" # rubocop:disable Metrics/LineLength
      end
    end

    Contract String, String => nil
    def extract_file(file, dir)
      run_local "tar -x -C #{dir} -f #{file}"
    end

    Contract None => nil
    def remove_linker_archives!
      deps.keys.each do |dep_name|
        File.unlink(*Dir.glob("#{tmpdir(dep_name)}/**/*.la"))
      end
      nil
    end

    Contract None => nil
    def remove_pkgconfig_files!
      deps.keys.each do |dep_name|
        File.unlink(*Dir.glob("#{tmpdir(dep_name)}/**/*.pc"))
      end
      nil
    end
  end

  module DSL
    ##
    # Add dep methods to Forge DSL
    class Forge
      Contract HashOf[Symbol => Or[String, Hash]] => nil
      def deps(value)
        value = value.map { |k, v| [k, v.is_a?(Hash) ? v : { version: v }] }
        @forge.deps = Hash[value]
        nil
      end

      Contract Bool => nil
      def remove_linker_archives(value = true)
        @forge.remove_linker_archives = value
        nil
      end

      Contract Bool => nil
      def remove_pkgconfig_files(value = true)
        @forge.remove_pkgconfig_files = value
        nil
      end
    end
  end
end
