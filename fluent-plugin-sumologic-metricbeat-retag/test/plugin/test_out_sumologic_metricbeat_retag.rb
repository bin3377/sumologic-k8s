require "helper"
require "fluent/plugin/out_sumologic_metricbeat_retag.rb"

class SumologicMetricbeatRetagOutputTest < Test::Unit::TestCase
  
  setup do
    Fluent::Test.setup
  end

  sub_test_case "rewrite tag" do
    test "simple" do
      config = %{}
      d = create_driver(config)
      d.run(default_tag: "input.access") do
        d.feed({'metricset' => {'name' => 'event', 'module' => 'kubernetes', 'host' => 'kube-state-metrics:8080'}, 'event' => {'dataset' => 'kubernetes.event'}})
        d.feed({'metricset' => {'rtt' => 18658, 'name' => 'io', 'module' => 'system', 'host' => 'localhost:10255' }, 'event' => {'duration' => 18658212, 'dataset' => 'kubernetes.system'}})
        d.feed({'metricset' => {'rtt' => 18658, 'name' => 'cpu', 'host' => 'localhost:10255' }, 'event' => {'duration' => 18658212, 'dataset' => 'kubernetes.system'}})
        d.feed({'domain' => 'news.google.com', 'path' => '/', 'agent' => 'Googlebot-Mobile', 'response_time' => 900000}) #ignored
      end
      events = d.events
      assert_equal 3, events.length
      assert_equal 'metricset.kubernetes.event', events[0][0] # tag
      assert_equal 'metricset.system.io', events[1][0] # tag
      assert_equal 'metricset.cpu', events[2][0] # tag
      assert_equal 18658212, events[2][2]['event']['duration'] # message
    end
  end

  private

  def create_driver(conf)
    Fluent::Test::Driver::Output.new(Fluent::Plugin::SumologicMetricbeatRetagOutput).configure(conf)
  end

end
