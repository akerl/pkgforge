require 'json'

module PkgForge
  ##
  # Add state methods to Forge
  class Forge
    Contract String => nil
    def load_state(statefile)
      state = JSON.parse(File.read(statefile))
      @tmpfiles = state[:tmpfiles]
      @tmpdirs = state[:tmpdirs]
    end

    Contract String => nil
    def write_state!(statefile)
      File.open(statefile, 'w') do |fh|
        fh << {
          tmpfiles: @tmpfiles,
          tmpdirs: @tmpdirs
        }.to_json
      end
      nil
    end
  end
end
