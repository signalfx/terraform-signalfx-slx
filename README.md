>ℹ️&nbsp;&nbsp;SignalFx was acquired by Splunk in October 2019. See [Splunk SignalFx](https://www.splunk.com/en_us/investor-relations/acquisitions/signalfx.html) for more information.

# SignalFx's Terraform SLx Module

This module provides convenient tooling for creating detectors, dashboards and other assets using best practices on the SignalFx platform.

![Example Dashboard](images/example.png?raw=true)

**Note:** This module is considered "alpha" content and should not yet be relied on for production usage. See the [TODO section](#TODO) below.

# Features

By using this module you get the following great features:

* externally managed template for generating per-service dashboards and detectors (using this Terraform module)
  * versions so you can opt in to new behavior at your own pace
* industry best-practices layout with [RED metrics](https://www.weave.works/blog/the-red-method-key-metrics-for-microservices-architecture/) at the top
* numerous best-practices from extensive dashboard research (parts [1](http://onemogin.com/observability/dashboards/practitioners-guide-to-system-dashboard-design.html), [2](http://onemogin.com/observability/dashboards/practitioners-guide-to-system-dashboard-design-p2.html), [3](http://onemogin.com/observability/dashboards/practitioners-guide-to-system-dashboard-design-p3.html), and [4](http://onemogin.com/observability/dashboards/practitioners-guide-to-system-dashboard-design-p4.html))
  * units and bounds wherever applicable to ease comprehension
  * pleasing wider-than-tall 3-wide grid
  * per-user opt-in for [color blind modes](https://docs.signalfx.com/en/latest/getting-started/get-around-ui.html#user-profile-avatar-and-color-theme)
  * on-chart watermarks showing SLO targets
  * easy to interpret, threshold-based coloring of "instant" values
* team links for [dashboards and detectors](https://docs.signalfx.com/en/latest/managing/teams/link-content.html)
* alerting based on SLO violations
  * configurable (defaults to 1m) notification of SLO violations
  * detectors notify team to leverage [notification policies](https://docs.signalfx.com/en/latest/managing/teams/team-notifications.html)
  * alerts are linked to relevant charts in dashboards for signaling problems
* error budget support
  * uses the error ratio (97% success SLO gives a 3% error budget)
  * visualization on main dashboard
  * detector that issues `info` level alerts to team
* support for adding your own important charts below the built in content
* situational awareness
  * deploy events
  * feature flag events

# How to Use It

You'll be using the [SignalFx Terraform provider](https://github.com/terraform-providers/terraform-provider-signalfx).

Next, your service(s) will need to isolate their SLI metrics and any defined SLO thresholds.

**Note:** When you specify the queries, remember to specify the [appropriate rollup policy](https://docs.signalfx.com/en/latest/reference/analytics-docs/intro-analytics.html#rollup-policies). Depending on metric type and meaning, you might want to use average, sum, min or max!

To create resources using this module, you can then include it in your existing Terraform like so:

```
# You can invoke this many times, once for each service!
module "service_fartsapi_slx" {
  source = "github.com/signalfx/terraform-signalfx-slx"
  version = "0.0.1"

  service_name                          = "FartAPI"
  responsible_team                      = "abc123"
  successful_operations_sli_count_query = "data('request_duration_millis_count', filter=filter('code', '200')).sum()"
  total_operations_sli_count_query      = "data('request_duration_millis_count').sum()"
  error_operations_sli_count_query      = "data('errors_encountered_total').sum()"
  operation_time_sli_query              = "data('request_duration_millis_quantile', filter=filter('quantile', '0.990000')).mean()"
  operation_time_sli_unit               = "Millisecond"
  operation_time_slo_target             = 500
  operation_success_ratio_slo_target    = 97.00
}

# You can also define your own charts to add to the end!
resource "signalfx_time_chart" "someother_chart" {
    name = "Custom Chart!"

    program_text = <<-EOF
        A = data("cpu.utilization").publish(label="CPU Utilization")
        EOF

    time_range = 900

    plot_type = "LineChart"
    show_data_markers = true
}

# Make a dashboard group to put it in
resource "signalfx_dashboard_group" "slx_example" {
    name = "SLx Example"
    description = "Cool dashboard group"
    teams = ["abc123"]
}

# Create the actual dashboard using the output of the module. (See `chart_ids`)
resource "signalfx_dashboard" "slx_prefixed_thing" {
    name = "SLx Test Prefix Dashboard"
    dashboard_group = "${signalfx_dashboard_group.slx_example.id}"
    time_range = "-15m"

    grid {
        chart_ids = concat(module.service_a_slx.charts,
                signalfx_time_chart.someother_chart.*.id)
        width = 4
        height = 1
    }
}
```

# Events

To work with the deploy and feature flag events, use the following event names:

* `Deploy` for deploys with tag `service` that matches the service name argument
* `Feature Flag` for feature flags with tag `service` that matches the service name argument

# TODO

* Write some accompanying content
* Template vars?
* More IA (service dashboards, etc)
* Runbooks
* Customizable event signal definitions

# PROBLEMS

* Can't use secondary visualization of Linear because the labels overlap when super close.
