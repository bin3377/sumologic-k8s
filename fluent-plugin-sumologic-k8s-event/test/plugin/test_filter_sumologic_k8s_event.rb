require "helper"
require "fluent/plugin/filter_sumologic_k8s_event.rb"
require 'json'

class SumologicK8sEventFilterTest < Test::Unit::TestCase

  setup do
    Fluent::Test.setup
  end

  test 'transform from metric set' do
    conf = %{}
    input = JSON.parse(File.read('test/resources/input.json'))
    output = JSON.parse(File.read('test/resources/output.json'))
    
    d = create_driver(conf)
    d.run(default_tag: "input.access") do
      d.feed(input)
    end
    assert_equal(output, d.filtered_records[0])
  end
    
  private

  def create_driver(conf)
    Fluent::Test::Driver::Filter.new(Fluent::Plugin::SumologicK8sEventFilter).configure(conf)
  end

end
