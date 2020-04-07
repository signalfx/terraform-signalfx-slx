resource "signalfx_time_chart" "slx_success_ratio_chart" {
  name        = "Success Ratio"
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
    max_value           = 100
    low_watermark       = var.operation_success_ratio_slo_target
    low_watermark_label = "Target SLO ${var.operation_success_ratio_slo_target}%"
  }

  viz_options {
    label        = "Success Ratio"
    value_suffix = "%"
  }
}

resource "signalfx_time_chart" "slx_operation_duration_chart" {
  name        = "Operation Duration"
  description = "Total duration of operations"

  program_text = <<-EOF
        A = ${var.operation_time_sli_query}.publish(label='Operation Duration')
        B = alerts(detector_id='${var.operation_duration_slo_detector_id}').publish(label='B')
        EOF

  plot_type         = "LineChart"
  show_data_markers = false

  axis_left {
    low_watermark       = var.operation_time_slo_target
    low_watermark_label = "Target SLO ${var.operation_time_slo_target} ${var.operation_time_sli_unit}s"
  }

  viz_options {
    label      = "Operation Duration"
    value_unit = var.operation_time_sli_unit
  }
}

resource "signalfx_time_chart" "slx_total_errors_chart" {
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

resource "signalfx_single_value_chart" "slx_success_ratio_instant_chart" {
  name = "Current Success Ratio"

  program_text = <<-EOF
        A = ${var.successful_operations_sli_count_query}.publish(label='Successful Operations', enable=False)
        B = ${var.total_operations_sli_count_query}.publish(label='Total Operations', enable=False)
        C = ((A/B)*100).publish(label='Success Ratio')
        D = alerts(detector_id='${var.operation_slo_success_ratio_detector_id}').publish(label='D')
        EOF

  description = "Colored by SLO (${var.operation_success_ratio_slo_target}%)"

  viz_options {
    label        = "Success Ratio"
    value_suffix = "%"
  }

  refresh_interval    = 1
  max_precision       = 2
  is_timestamp_hidden = true
  color_by            = "Scale"
  color_scale {
    lt    = var.operation_success_ratio_slo_target
    color = "orange"
  }
  color_scale {
    gte   = var.operation_success_ratio_slo_target
    color = "green"
  }
}

resource "signalfx_single_value_chart" "slx_operation_duration_instant_chart" {
  name = "Current Operation Duration"

  program_text = <<-EOF
        A = ${var.operation_time_sli_query}.publish(label='Operation Duration')
        B = alerts(detector_id='${var.operation_duration_slo_detector_id}').publish(label='B')
        EOF

  description = "Colored by SLO (${var.operation_time_slo_target} ${var.operation_time_sli_unit}s)"

  viz_options {
    label      = "Operation Duration"
    value_unit = var.operation_time_sli_unit
  }

  refresh_interval    = 1
  max_precision       = 2
  is_timestamp_hidden = true
  color_by            = "Scale"
  color_scale {
    gt    = var.operation_time_slo_target
    color = "orange"
  }
  color_scale {
    lte   = var.operation_time_slo_target
    color = "green"
  }
}

resource "signalfx_single_value_chart" "slx_total_errors_instant_chart" {
  name = "Current Error Rate"

  program_text = <<-EOF
        A = ${var.error_operations_sli_count_query}.publish(label='Errors')
        EOF

  description = "Rate of Errors"

  refresh_interval    = 1
  max_precision       = 2
  is_timestamp_hidden = true

  viz_options {
    label        = "Errors"
    color        = "orange"
    value_suffix = "errors/sec"
  }
}

resource "signalfx_time_chart" "slx_total_rate_chart" {
  name = "Rate of Operations"

  program_text = <<-EOF
        A = ${var.total_operations_sli_count_query}.publish(label='Operations')
        EOF

  plot_type         = "LineChart"
  show_data_markers = false
}
