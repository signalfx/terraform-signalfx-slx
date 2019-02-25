output "slx_success_ratio_chart" {
  value = "${signalfx_time_chart.slx_success_ratio_chart.id}"
}

output "slx_operation_duration_chart" {
  value = "${signalfx_time_chart.slx_operation_duration_chart.id}"
}

output "slx_success_ratio_instant_chart" {
  value = "${signalfx_single_value_chart.slx_success_ratio_instant_chart.id}"
}

output "slx_operation_duration_instant_chart" {
  value = "${signalfx_single_value_chart.slx_operation_duration_instant_chart.id}"
}

output "slx_total_errors_instant_chart" {
  value = "${signalfx_single_value_chart.slx_total_errors_instant_chart.id}"
}

output "slx_total_rate_chart" {
  value = "${signalfx_time_chart.slx_total_rate_chart.id}"
}

output "slx_error_rate_chart" {
  value = "${signalfx_time_chart.slx_total_errors_chart.id}"
}
