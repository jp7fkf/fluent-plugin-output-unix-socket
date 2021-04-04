#
# Copyright 2021 jp7fkf
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "fluent/plugin/output"

require 'socket'

module Fluent
  module Plugin
    class OutputUnixSocketOutput < Fluent::Plugin::Output
      Fluent::Plugin.register_output("output_unix_socket", self)

      # Define parameters for your plugin.
      config_param :path, :string, :default => '/var/run/fluent/fluent.sock'

      config_section :buffer do
        config_set_default :chunk_keys, ['tag']
        config_set_default :flush_mode, :interval
        config_set_default :flush_interval, 5
        config_set_default :flush_thread_interval, 0.5
        config_set_default :flush_thread_burst_interval, 0.5
      end

      def configure(conf)
        super
      end

      def initialize()
        super
      end

      def start()
        super
	prefer_buffered_processing()
	prefer_delayed_commit()
      end

      def shutdown()
        super
      end


      #### Non-Buffered Output #############################
      # Implement `process()` if your plugin is non-buffered.
      # Read "Non-Buffered output" for details.
      ######################################################
      def process(tag, es)
        UNIXSocket.open(@path) { |socket|
          es.each do |time, record|
            socket.write([tag, time.to_f, record["message"]])
          end
        }
      end

      #### Sync Buffered Output ##############################
      # Implement `write()` if your plugin uses normal buffer.
      # Read "Sync Buffered Output" for details.
      ########################################################
      def write(chunk)
        return if chunk.empty?

	if chunk.metadata.tag.nil?
	  tag = "unix-socket"
	else
          tag = chunk.metadata.tag
        end

        log.debug 'writing data to file', chunk_id: dump_unique_id_hex(chunk.unique_id)

        UNIXSocket.open(@path) { |socket|
          chunk.each do |time, record|
            puts Time.at(time.to_f, 8).iso8601(8)
            puts record["message"]
            socket.write([tag, time.to_f, record["message"]])#.to_msgpack)
          end
        }
      end

      private
      def prefer_buffered_processing()
        true
      end

      def prefer_delayed_commit()
        true
      end

    end
  end
end
