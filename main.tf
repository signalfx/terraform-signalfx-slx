module "charts" {
  source = "./charts"

  successful_operations_sli_count_query = "${var.successful_operations_sli_count_query}"
  total_operations_sli_count_query      = "${var.total_operations_sli_count_query}"
  operation_time_sli_query              = "${var.operation_time_sli_query}"
  operation_time_slo_target             = "${var.operation_time_slo_target}"
}
