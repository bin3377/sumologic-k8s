require "fluent/plugin/output"

module Fluent::Plugin
  class SumologicMetricbeatRetagOutput < Fluent::Plugin::Output
    Fluent::Plugin.register_output("sumologic_metricbeat_retag", self)

    helpers :event_emitter, :record_accessor

    def configure(conf)
      super
      # do the usual configuration here
      @metricset_module = record_accessor_create('$.metricset.module')
      @metricset_name = record_accessor_create('$.metricset.name')
    end
    
    def multi_workers_ready?
      true
    end
  
    def process(tag, es)
      es.each do |time, record|
        metricset_module_value = @metricset_module.call(record)
        metricset_name_value = @metricset_name.call(record)
        if metricset_name_value.nil?
          log.trace("sumologic_metricbeat_retag: tag has not been rewritten", record)
          next
        end
        rewritten_tag = if metricset_module_value.nil?
          "metricset.#{metricset_name_value}"
        else
          "metricset.#{metricset_module_value}.#{metricset_name_value}"
        end
        log.trace("sumologic_metricbeat_retag: tag=#{tag}, rewritten_tag=#{rewritten_tag}", record)
        router.emit(rewritten_tag, time, record)
      end
    end

  end
end
