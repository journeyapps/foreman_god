require 'god'

module God
  module Conditions
    class ForemanStopFileExists < PollCondition
      attr_accessor :stop_file
      # invert  file    test result
      # ---------------------------
      # false   exists  true
      # false   absent  false
      # true    exists  false
      # true    absent  true
      #
      # default: false
      attr_accessor :invert

      def initialize
        super
        @invert = false
      end

      def valid?
        valid = true
        valid &= complain("Attribute 'invert' must be true or fails", self) unless self.invert === true || self.invert === false
        valid &= complain("Attribute 'stop_file' must be specified", self) if self.stop_file.nil?
        valid
      end

      def test
        File.exist?(stop_file) ^ invert
      end
    end
  end
end
