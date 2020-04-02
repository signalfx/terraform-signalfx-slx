module "charts" {
  source = "../charts"

  service_name                          = "${var.service_name}"
  responsible_team                      = "${var.responsible_team}"
  successful_operations_sli_count_query = "${var.successful_operations_sli_count_query}"
  total_operations_sli_count_query      = "${var.total_operations_sli_count_query}"
  error_operations_sli_count_query      = "${var.error_operations_sli_count_query}"
  operation_time_sli_query              = "${var.operation_time_sli_query}"
  operation_time_sli_unit               = "${var.operation_time_sli_unit}"
  operation_time_slo_target             = "${var.operation_time_slo_target}"
  operation_success_ratio_slo_target    = "${var.operation_success_ratio_slo_target}"
  operation_slo_success_ratio_detector_id  = "${var.operation_slo_success_ratio_detector_id}"
}

resource "signalfx_dashboard_group" "slx_dashboard_group" {
    name = "${var.service_name} Service Dashboard"
    description = "Dashboards for ${var.service_name}"
    teams = ["${var.responsible_team}"]
}

resource "signalfx_dashboard" "slx_primary_dashboard" {
  name            = "${var.service_name} SLx Metrics"
  dashboard_group = "${signalfx_dashboard_group.slx_dashboard_group.id}"
  time_range      = "-1h"

  chart {
    chart_id = "${module.charts.slx_success_ratio_chart}"
    width = 4
    height = 1
    row = 0
    column = 0
  }
  chart {
    chart_id = "${module.charts.slx_operation_duration_chart}"
    width = 4
    height = 1
    row = 0
    column = 4
  }
  chart {
    chart_id = "${module.charts.slx_error_rate_chart}"
    width = 4
    height = 1
    row = 0
    column = 8
  }
  chart {
    chart_id = "${module.charts.slx_success_ratio_instant_chart}"
    width = 4
    height = 1
    row = 1
    column = 0
  }
  chart {
    chart_id = "${module.charts.slx_operation_duration_instant_chart}"
    width = 4
    height = 1
    row = 1
    column = 4
  }
  chart {
    chart_id = "${module.charts.slx_total_errors_instant_chart}"
    width = 4
    height = 1
    row = 1
    column = 8
  }
  chart {
    chart_id = "${module.charts.slx_total_rate_chart}"
    width = 4
    height = 1
    row = 2
    column = 0
  }
  chart {
    chart_id = "${module.charts.slx_error_budget_chart}"
    width = 4
    height = 1
    row = 2
    column = 4
  }

  event_overlay {
    line = true
    label = "Feature Flag Changes"
    color = "azure"
    signal = "Feature Flag"
    type = "eventTimeSeries"
    source {
      property = "service"
      values = [var.service_name]
    }
  }

  event_overlay {
    line = true
    label = "Deploys"
    color = "green"
    signal = "Deploy"
    type = "eventTimeSeries"
    source {
      property = "service"
      values = [var.service_name]
    }
  }

  selected_event_overlay {
    signal = "Deploy"
    type = "eventTimeSeries"
    source {
      property = "service"
      values = [var.service_name]
    }
  }
}

resource "signalfx_time_chart" "slx_error_type_chart" {
  name = "Error Counts"

  program_text = <<-EOF
        A = data('errors_encountered_total').publish(label='Errors')
        EOF

  plot_type         = "ColumnChart"

  viz_options {
    label = "Errors"
  }
}

resource "signalfx_list_chart" "slx_error_list_chart" {
  name = "Error Counts"

  program_text = <<-EOF
        A = data('errors_encountered_total').publish(label='Errors')
        EOF
}

resource "signalfx_time_chart" "slx_success_ratio_chart_ERROR" {
  name = "Success Ratio"
  description = "Ratio of successes to total operations."

  program_text = <<-EOF
        A = ${var.successful_operations_sli_count_query}.publish(label='Successful Operations', enable=False)
        B = ${var.total_operations_sli_count_query}.publish(label='Total Operations', enable=False)
        C = ((A/B)*100).publish(label='Success Ratio')
        D = alerts(detector_id='${var.operation_slo_success_ratio_detector_id}').publish(label='D')
        EOF

  plot_type         = "LineChart"
  show_data_markers = false

  axis_left {
    max_value = 100
    low_watermark = "${var.operation_success_ratio_slo_target}"
    low_watermark_label = "Target SLO ${var.operation_success_ratio_slo_target}%"
  }

  viz_options {
    label = "Success Ratio"
    value_suffix = "%"
  }
}

resource "signalfx_time_chart" "slx_total_errors_chart_ERROR" {
  name = "Rate of Errors"

  program_text = <<-EOF
        A = ${var.error_operations_sli_count_query}.publish(label='Errors')
        EOF

  plot_type         = "LineChart"
  show_data_markers = false

  viz_options {
    label = "Errors"
    color = "orange"
  }
}

resource "signalfx_single_value_chart" "slx_total_errors_instant_chart_ERROR" {
    name = "Current Error Rate"

    program_text = <<-EOF
        A = ${var.error_operations_sli_count_query}.publish(label='Errors')
        EOF

    description = "Rate of Errors"

    refresh_interval = 1
    max_precision = 2
    is_timestamp_hidden = true

    viz_options {
      label = "Errors"
      color = "orange"
      value_suffix = "errors/sec"
    }
}

resource "signalfx_dashboard" "slx_error_dashboard" {
  name            = "${var.service_name} Error Investigation"
  dashboard_group = "${signalfx_dashboard_group.slx_dashboard_group.id}"
  time_range      = "-1h"

  chart {
    chart_id = "${signalfx_time_chart.slx_success_ratio_chart_ERROR.id}"
    width = 4
    height = 1
    row = 0
    column = 0
  }
  chart {
    chart_id = "${signalfx_time_chart.slx_total_errors_chart_ERROR.id}"
    width = 4
    height = 1
    row = 0
    column = 4
  }
  chart {
    chart_id = "${signalfx_single_value_chart.slx_total_errors_instant_chart_ERROR.id}"
    width = 4
    height = 1
    row = 0
    column = 8
  }
  chart {
    chart_id = "${signalfx_time_chart.slx_error_type_chart.id}"
    width = 6
    height = 1
    row = 1
    column = 0
  }
  chart {
    chart_id = "${signalfx_list_chart.slx_error_list_chart.id}"
    width = 6
    height = 1
    row = 1
    column = 6
  }


  event_overlay {
    line = true
    label = "Feature Flag Changes"
    color = "azure"
    signal = "Feature Flag"
    type = "eventTimeSeries"
    source {
      property = "service"
      values = [var.service_name]
    }
  }

  selected_event_overlay {
    signal = "Feature Flag"
    type = "eventTimeSeries"
    source {
      property = "service"
      values = [var.service_name]
    }
  }

  event_overlay {
    line = true
    label = "Deploys"
    color = "green"
    signal = "Deploy"
    type = "eventTimeSeries"
    source {
      property = "service"
      values = [var.service_name]
    }
  }

  selected_event_overlay {
    signal = "Deploy"
    type = "eventTimeSeries"
    source {
      property = "service"
      values = [var.service_name]
    }
  }
}

resource "signalfx_text_chart" "error_budget_explanation" {
  name = "Error Budget Consumption"
  markdown = <<-EOF
  Evaluates the error budget, by day, and compares to same day, previous week. Also calculates a difference as a line for easy comparison.
  EOF
}

resource "signalfx_time_chart" "error_budget_hourly_chart" {
  name = "Error Budget Consumption, Daily"
  description = "Percentage of error budget consumed, by day."

  program_text = <<-EOF
    A = ${var.error_operations_sli_count_query}.sum(cycle='day', cycle_start='0h', partial_values=True).publish(label='Failed Operations', enable=False)
    B = ${var.total_operations_sli_count_query}.sum(cycle='day', cycle_start='0h', partial_values=True).publish(label='Total Operations', enable=False)
    C = (((A/B)/${100.0 - var.operation_success_ratio_slo_target})*10000).publish(label='Budget Consumed')
    D = data('errors_encountered_total').sum().sum(cycle='day', cycle_start='0h', partial_values=True).timeshift('1d').publish(label='Failed Operations, Previous Week', enable=False)
    E = data('request_duration_millis_count').sum().sum(cycle='day', cycle_start='0h', partial_values=True).timeshift('1d').publish(label='Total Operations, Previous Week', enable=False)
    F = (((D/E)/3)*10000).publish(label='Previous Week')
    G = (F-C).publish(label='Daily Change (Previous - Current)')
    EOF

  plot_type         = "ColumnChart"
  show_data_markers = false
  axes_include_zero = true
  on_chart_legend_dimension = "plot_label"

  axis_left {
    low_watermark = "${var.operation_success_ratio_slo_target / 100}"
    low_watermark_label = "Target SLO = ${var.operation_success_ratio_slo_target}%"
    max_value = 100
  }

  viz_options {
    label = "Budget Consumed"
    value_suffix = "%"
    color = "blue"
  }
  viz_options {
    label = "Previous Week"
    value_suffix = "%"
    color = "azure"
  }
  viz_options {
    label = "Daily Change (Previous - Current)"
    axis = "right"
    color = "violet"
    plot_type = "LineChart"
  }
}

resource "signalfx_dashboard" "slx_error_budget_dashboard" {
  name            = "${var.service_name} Error Budget"
  dashboard_group = "${signalfx_dashboard_group.slx_dashboard_group.id}"
  time_range      = "-1w"

  chart {
    chart_id = "${signalfx_text_chart.error_budget_explanation.id}"
    width = 2
    height = 1
    row = 0
    column = 0
  }

  chart {
    chart_id = "${signalfx_time_chart.error_budget_hourly_chart.id}"
    width = 10
    height = 1
    row = 0
    column = 2
  }
}
