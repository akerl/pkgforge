module PkgForge
  ##
  # Add patch methods to Forge
  class Forge
    attr_writer :patches

    Contract None => ArrayOf[String]
    def patches
      @patches ||= []
    end

    Contract String => nil
    def run_patch(file)
      run_local "patch -d #{tmpdir(:build)} -p1 < patches/#{file}"
    end

    private

    Contract None => nil
    def patch_source!
      patches.each { |patch| run_patch(patch) }
      nil
    end
  end

  module DSL
    ##
    # Add patch methods to Forge DSL
    class Forge
      Contract String => nil
      def patch(file)
        @forge.patches << file
        nil
      end
    end

    ##
    # Add patch methods to Build DSL
    class Build
      Contract String => nil
      def patch(file)
        @forge.run_patch(file)
      end
    end
  end
end
