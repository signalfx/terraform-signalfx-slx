# SignalFx's Terraform SLx Module

This module provides convenient tooling for creating detectors, dashboards and other assets using best practices on the SignalFx platform.

![Example Dashboard](https://raw.githubusercontent.com/signalfx/terraform-signalfx-slx/master/images/example.png)

# Features

By using this module you get the following great features:

* consistent, per-service dashboard for all of your services with
* industry best-practices layout with [RED metrics](https://www.weave.works/blog/the-red-method-key-metrics-for-microservices-architecture/) at the total_operations_sli_count_query
* easy to interpret, threshold-based coloring of "instant" values

# How to Use It

To use it, your service(s) will need to isolate their SLI metrics and any defined SLO thresholds. You can then include this module in your existing Terraform like so:

```
# You can invoke this many times, once for each service!
module "service_a_slx" {
  source = "signalslx"

  successful_operations_sli_count_query = "data('demo.trans.count').sum()"
  total_operations_sli_count_query = "data('demo.trans.count').sum()"
  error_operations_sli_count_query = "data('demo.trans.count', filter=filter('error', 'true')).sum()"
  operation_time_sli_query = "data('demo.trans.latency').percentile(pct=95)"
  operation_time_sli_unit = "Millisecond"
  operation_time_slo_target = 250
  operation_success_ratio_slo_target = 100
}

resource "signalfx_time_chart" "someother_chart" {
    name = "Custom Chart!"

    program_text = <<-EOF
        A = data("cpu.utilization").publish(label="CPU Utilization")
        EOF

    time_range = "-15m"

    plot_type = "LineChart"
    show_data_markers = true
}

resource "signalfx_dashboard" "slx_prefixed_thing" {
    name = "SLx Test Prefix Dashboard"
    dashboard_group = "DzYdCvcAgAA"
    time_range = "-15m"

    grid {
        chart_ids = ["${concat(module.service_a_slx.charts,
                signalfx_time_chart.someother_chart.*.id)}"]
        width = 4
        height = 1
        start_row = 0
    }
}
```

# TODO

* Write some accompanying content
* Get it on the public repo
* Generate detectors
* Template vars?
* Add watermarks
* Chart<>Detector Linking
* Team stuff
* Get more opinionated on dashboards, like don't mixin but use groups-per-service
* Use a dashboard-group per service, put red here, have other things use the id to add?
* Deploys
* More IA (service dashboards, etc)
* MOAR?
