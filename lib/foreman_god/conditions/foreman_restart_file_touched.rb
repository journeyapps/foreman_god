require 'god'

module God
  module Conditions
    # Adapted from https://gist.github.com/571095
    class ForemanRestartFileTouched < PollCondition
      attr_accessor :restart_file

      def initialize
        super
      end

      def process_start_time
        Time.parse(`ps -o lstart= -p #{self.watch.pid}`) rescue nil
      end

      def restart_file_modification_time
        File.mtime(self.restart_file) rescue Time.at(0)
      end

      def valid?
        valid = true
        valid &= complain("Attribute 'restart_file' must be specified", self) if self.restart_file.nil?
        valid
      end

      def test
        ptime = process_start_time
        if ptime
          ptime < restart_file_modification_time
        else
          false
        end
      end
    end
  end
end
