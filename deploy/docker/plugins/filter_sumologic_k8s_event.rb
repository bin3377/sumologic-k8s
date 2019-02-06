require "fluent/plugin/filter"

module Fluent::Plugin
  class SumologicK8sEventFilter < Fluent::Plugin::Filter
    Fluent::Plugin.register_filter("sumologic_k8s_event", self)

    helpers :record_accessor

    def configure(conf)
      super
      @timestamp = record_accessor_create('$.@timestamp')
      @kubernetes_event = record_accessor_create('$.kubernetes.event')
      @host_name = record_accessor_create('$.host.name')
      @meta_cloud = record_accessor_create('$.meta.cloud')
    end

    def filter(tag, time, record)
      log.trace("sumologic_k8s_event: tag=#{tag}, time=#{time}, record=#{record}", record)
      rewritten_record = {}
      rewritten_record['timestamp'] = @timestamp.call(record)
      rewritten_record['event'] = @kubernetes_event.call(record)
      rewritten_record['host'] = @host_name.call(record)
      rewritten_record['cloud'] = @meta_cloud.call(record)
      log.trace("sumologic_k8s_event: rewritten_record=#{rewritten_record}", record)
      rewritten_record
    end
  end
end
