resource "signalfx_time_chart" "slx_success_ratio_chart" {
  name = "Success Ratio"

  program_text = <<-EOF
        A = ${var.successful_operations_sli_count_query}.publish('Success Ratio')
        EOF

  time_range = "-15m"

  plot_type         = "LineChart"
  show_data_markers = true
}

resource "signalfx_time_chart" "slx_total_rate_chart" {
  name = "Rate of Operations"

  program_text = <<-EOF
        A = ${var.total_operations_sli_count_query}.publish('Operations')
        EOF

  time_range = "-15m"

  plot_type         = "LineChart"
  show_data_markers = true
}
