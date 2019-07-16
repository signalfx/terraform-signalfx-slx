output "charts" {
  value = ["${module.charts.slx_success_ratio_chart}",
  "${module.charts.slx_operation_duration_chart}",
  "${module.charts.slx_error_rate_chart}",
  "${module.charts.slx_success_ratio_instant_chart}",
  "${module.charts.slx_operation_duration_instant_chart}",
  "${module.charts.slx_total_errors_instant_chart}",
  "${module.charts.slx_total_rate_chart}",
  "${module.charts.slx_error_budget_chart}"]
}
