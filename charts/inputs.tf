variable "successful_operations_sli_count_query" {
  description = "The stream query for the monitored service's count of successful operations"
}

variable "total_operations_sli_count_query" {
  description = "The stream query for the monitored service's count of total operations (including failures, errors, etc)"
}

variable "operation_time_sli_query" {
  description = "The stream query for the monitored service's operation duration"
}

variable "operation_time_slo_target" {
  description = "A constant value representing the desired (SLO) duration target"
}
