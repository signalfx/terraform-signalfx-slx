output "slx_success_ratio_chart" {
  value = "${signalfx_time_chart.slx_success_ratio_chart.id}"
}

output "slx_success_rate_chart" {
  value = "${signalfx_time_chart.slx_total_rate_chart.id}"
}
