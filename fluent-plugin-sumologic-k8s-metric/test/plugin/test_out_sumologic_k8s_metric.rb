require "helper"
require "fluent/plugin/out_sumologic_k8s_metric.rb"

class SumologicK8sMetricOutputTest < Test::Unit::TestCase

  setup do
    Fluent::Test.setup
  end

  sub_test_case "transform to carbon v2 payload" do
    test "pod metricset" do

      config = %{}
      input = JSON.parse(File.read('test/resources/input-pod.json'))
      output = JSON.parse(File.read('test/resources/output-pod.json'))

      d = create_driver(config)
      d.run(default_tag: "metricset.kubernetes.pod") do
        d.feed(input)
      end

      events = d.events
      assert_equal 1, events.length
      assert_equal 'carbon.v2.metricset.kubernetes.pod', events[0][0] # tag
      assert_equal Time.parse("2019-02-05T19:32:45Z"), events[0][1] # time
      assert_equal output, events[0][2] # record

    end
  end

  private

  def create_driver(conf)
    Fluent::Test::Driver::Output.new(Fluent::Plugin::SumologicK8sMetricOutput).configure(conf)
  end

end
