require 'json'
require 'cymbal'

module PkgForge
  ##
  # Add state methods to Forge
  class Forge
    Contract nil => Hash
    def state
      @state ||= {}
    end

    Contract String => nil
    def load_state!(statefile)
      @state = Cymbal.symbolize(JSON.parse(File.read(statefile)))
      nil
    end

    Contract String => nil
    def write_state!(statefile)
      File.open(statefile, 'w') do |fh|
        fh << state.to_json
      end
      nil
    end
  end
end
