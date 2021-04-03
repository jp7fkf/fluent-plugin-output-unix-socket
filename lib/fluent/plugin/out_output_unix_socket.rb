#
# Copyright 2021- jp7fkf
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
require 'json'

module Fluent
  module Plugin
    class OutputUnixSocketOutput < Fluent::Plugin::Output
      Fluent::Plugin.register_output("output_unix_socket", self)

      # Enable threads if you are writing an async buffered plugin.
      helpers :thread

      # Define parameters for your plugin.
      config_param :path, :string, :default => '/var/run/fluent/fluent.sock'

      #config_section :buffer do
      #  config_set_default :flush_mode, :interval
      #  config_set_default :flush_interval, 5
      #  config_set_default :flush_thread_interval, 0.5
      #  config_set_default :flush_thread_burst_interval, 0.5
      #end

      def configure(conf)
        super
      end

      def initialize()
        super
        #@socket = UNIXSocket.new(@path)
	#@socket = @server.accept
      end


      #### Non-Buffered Output #############################
      # Implement `process()` if your plugin is non-buffered.
      # Read "Non-Buffered output" for details.
      ######################################################
      #def process(tag, es)
      #  es.each do |time, record|
      #    puts time.to_f
      #    puts Time.at(time.to_f, 8).iso8601(8)
      #    puts record.to_json
      #    puts record["message"]

      #    #@socket.send(record['message'],0)
      #    #@socket.write(record['message'])
      #    #@socket.write(["tagtag", record.to_json, record["message"]])
      #    #@socket.write([tag, time.to_f, record.to_json])
      #    @socket.write([tag, time.to_f, record["message"]])
      #    #@socket.write([tag, time.to_f, "{\"message\": #{record.to_json}"])
      #  end
      #end

      #### Sync Buffered Output ##############################
      # Implement `write()` if your plugin uses normal buffer.
      # Read "Sync Buffered Output" for details.
      ########################################################
      def write(chunk)
        return if chunk.empty?

	tag = "unix-socket"
        log.debug 'writing data to file', chunk_id: dump_unique_id_hex(chunk.unique_id)

        #begin
        #  UNIXSocket.open(@path) { |socket|
        #    # For standard chunk format (without `#format()` method)
        #    chunk.each do |time, record|
        #      puts Time.at(time.to_f, 8).iso8601(8)
        #      puts record["message"]
        #      socket.write([tag, time.to_f, record["message"]])
        #    end
        #  }
	#rescue
        #  puts '[UNIXSocket]: socket error!!'
	#  #socket.close()
	#  #socket = nil
	#  #self.reconnect()
        #end


        UNIXSocket.open(@path) { |socket|
          # For standard chunk format (without `#format()` method)
          chunk.each do |time, record|
            puts Time.at(time.to_f, 8).iso8601(8)
            puts record["message"]
            socket.write([tag, time.to_f, record["message"]])
          end
        }


        # For custom format (when `#format()` implemented)
        # File.open(real_path, 'w+')

        # or `#write_to(io)` is available
        # File.open(real_path, 'w+') do |file|
        #   chunk.write_to(file)
        # end
      end

      private
      #def reconnect()
      #  if @socket.nil? or @socket.closed?
      #    @socket = UNIXSocket.new(@path)
      #  end
      #end

    end
  end
end
