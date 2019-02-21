output "charts" {
  value = ["${module.charts.slx_success_ratio_chart}", "${module.charts.slx_success_rate_chart}"]
}
