# SignalFx's Terraform SLx Module

This module provides convenient tooling for creating detectors, dashboards and other assets using best practices on the SignalFx platform.

To use it, your service(s) will need to isolate their SLI metrics and any defined SLO thresholds. You can then include this module in your existing Terraform like so:

```
# You can invoke this many times, once for each service!
module "service_a_slx" {
  source = "signalslxTKTKpublicname here"
  # Next, fill in the following variables so we know how to get the metrics
  successful_operations_sli_count_query = "data('demo.trans.count')"
  total_operations_sli_count_query = "data('demo.trans.count')"
  operation_time_sli_query = "data('demo.trans.latency')"
  # Now set the targets for your SLOs
  operation_time_slo_target = 300
}

# You can also mix this in by creating other charts…
resource "signalfx_time_chart" "someother_chart" {
    name = "Farts"

    program_text = <<-EOF
        A = data("cpu.utilization").publish(label="CPU Utilization")
        EOF

    time_range = "-15m"

    plot_type = "LineChart"
    show_data_markers = true
}

# Then define your own dashboard (see the grid below)
resource "signalfx_dashboard" "slx_prefixed_thing" {
    name = "SLx Test Prefix Dashboard"
    dashboard_group = "DzYdCvcAgAA"
    time_range = "-15m"

    grid {
        # And inject the charts we generate into the dashboard easily!
        chart_ids = ["${concat(module.service_a_slx.charts,
                signalfx_time_chart.someother_chart.*.id)}"]
        width = 4
        height = 1
        start_row = 0
    }
}
```

# TODO

* Get it on the public repo
* Generate detectors
* Template vars?
* Add watermarks
* Chart<>Detector Linking
* Team stuff
* Get more opinionated on dashboards, like don't mixin but use groups-per-service
* MOAR?
