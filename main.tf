module "charts" {
  source = "./charts"

  responsible_team                      = "${var.responsible_team}"
  successful_operations_sli_count_query = "${var.successful_operations_sli_count_query}"
  total_operations_sli_count_query      = "${var.total_operations_sli_count_query}"
  error_operations_sli_count_query      = "${var.error_operations_sli_count_query}"
  operation_time_sli_query              = "${var.operation_time_sli_query}"
  operation_time_sli_unit               = "${var.operation_time_sli_unit}"
  operation_time_slo_target             = "${var.operation_time_slo_target}"
  operation_success_ratio_slo_target    = "${var.operation_success_ratio_slo_target}"
}

module "detectors" {
  source = "./detectors"

  responsible_team                      = "${var.responsible_team}"
  successful_operations_sli_count_query = "${var.successful_operations_sli_count_query}"
  total_operations_sli_count_query      = "${var.total_operations_sli_count_query}"
  error_operations_sli_count_query      = "${var.error_operations_sli_count_query}"
  operation_time_sli_query              = "${var.operation_time_sli_query}"
  operation_time_sli_unit               = "${var.operation_time_sli_unit}"
  operation_time_slo_target             = "${var.operation_time_slo_target}"
  operation_success_ratio_slo_target    = "${var.operation_success_ratio_slo_target}"
}
