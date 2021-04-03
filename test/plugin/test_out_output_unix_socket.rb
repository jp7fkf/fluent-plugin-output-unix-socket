require "helper"
require "fluent/plugin/out_output_unix_socket.rb"

class OutputUnixSocketOutputTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup
  end

  test "failure" do
    flunk
  end

  private

  def create_driver(conf)
    Fluent::Test::Driver::Output.new(Fluent::Plugin::OutputUnixSocketOutput).configure(conf)
  end
end
