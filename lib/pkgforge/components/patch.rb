module PkgForge
  ##
  # Add patch methods to Forge
  class Forge
    attr_writer :patches

    Contract None => ArrayOf[String]
    def patches
      @patches ||= []
    end

    private

    Contract None => nil
    def patch_source!
      patches.each do |patch|
        run_local "patch -d #{tmpdir(:build)} -p1 < patches/#{patch}"
      end
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
  end
end
