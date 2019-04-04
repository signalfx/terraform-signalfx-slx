# SignalFx's Terraform SLx Module

This module provides convenient tooling for creating detectors, dashboards and other assets using best practices on the SignalFx platform.

![Example Dashboard](images/example.png?raw=true)

**Note:** This module is considered "alpha" content and should not yet be relied on for production usage. See the [TODO section](#TODO) below.

# Features

By using this module you get the following great features:

* externally managed template for generating per-service dashboards and detectors (using this Terraform module)
  * versions so you can opt in to new behavior at your own pace
* industry best-practices layout with [RED metrics](https://www.weave.works/blog/the-red-method-key-metrics-for-microservices-architecture/) at the top
* Numerous features from extensive dashboard research
  * Units wherever applicable to ease comprehension
  * Per-user opt-in for color blind modes
  * on-chart watermarks showing SLO targets
  * easy to interpret, threshold-based coloring of "instant" values
* support for adding your own important charts below the built in content

# How to Use It

First, install the [SignalFx Terraform provider](https://github.com/signalfx/terraform-provider-signalfx).

Next, your service(s) will need to isolate their SLI metrics and any defined SLO thresholds.

To create resources using this module, you can then include it in your existing Terraform like so:

```
# You can invoke this many times, once for each service!
module "service_a_slx" {
  source = "github.com/signalfx/terraform-signalfx-slx"
  version = "0.0.1"

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
* Generate detectors
* Template vars?
* Chart<>Detector Linking
* Team stuff
* Get more opinionated on dashboards, like don't mixin but use groups-per-service
* Deploys
* More IA (service dashboards, etc)
* MOAR?
