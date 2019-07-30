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
}
