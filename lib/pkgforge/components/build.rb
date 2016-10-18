require 'fileutils'

module PkgForge
  ##
  # Add build methods to Forge
  class Forge
    attr_writer :build_block

    Contract None => Proc
    def build_block
      @build_block ||= proc { raise 'No build block provided' }
    end

    Contract None => nil
    def build!
      prepare_source!
      patch_source!
      prepare_deps!
      builder = PkgForge::DSL::Build.new(self)
      builder.instance_eval(&build_block)
    end
  end

  module DSL
    ##
    # Add build method to Forge DSL
    class Forge
      Contract Func[None => nil] => nil
      def build(&block)
        @forge.build_block = block
        nil
      end
    end

    ##
    # Add build methods to Build DSL
    class Build
      Contract Or[String, Array], Or[HashOf[String => String], {}, nil] => nil
      def run(*args)
        @forge.run(*args)
      end

      Contract Maybe[HashOf[String => String]] => nil
      def configure(env = {})
        run ['./configure'] + configure_flag_strings, default_env.merge(env)
      end

      Contract Maybe[HashOf[String => String]] => nil
      def make(env = {})
        run 'make', default_env.merge(env)
      end

      Contract Maybe[HashOf[String => String]] => nil
      def install(env = {})
        run "make DESTDIR=#{@forge.releasedir} install", default_env.merge(env)
      end

      Contract Or[String, ArrayOf[String]] => nil
      def rm(paths)
        paths = [paths] if paths.is_a? String
        paths.map! { |x| File.join(@forge.releasedir, x) }
        FileUtils.rm_r paths
        nil
      end

      private

      Contract None => HashOf[String => String]
      def default_env
        {
          'CC' => 'musl-gcc',
          'CFLAGS' => @forge.cflags.join(' '),
          'LIBS' => @forge.libs.join(' ')
        }
      end
    end
  end
end
