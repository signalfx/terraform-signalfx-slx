variable "service_name" {
  description = "Name of the service being monitored"
}

variable "responsible_team" {
  description = "The ID of the team that owns this service"
}

variable "successful_operations_sli_count_query" {
  description = "The stream query for the monitored service's count of successful operations"
}

variable "total_operations_sli_count_query" {
  description = "The stream query for the monitored service's count of total operations (including failures, errors, etc)"
}

variable "error_operations_sli_count_query" {
  description = "The stream query for the monitored service's count of total errors"
}

variable "operation_time_sli_query" {
  description = "The stream query for the monitored service's operation duration"
}

variable "operation_time_sli_unit" {
  description = "Unit type (Millisecond, etc) for the time SLI query"
}

variable "operation_time_slo_target" {
  description = "A constant value representing the desired (SLO) duration target"
}

variable "operation_success_ratio_slo_target" {
  description = "A constant value representing the desired (SLO) success ratio"
}

variable "operation_slo_success_ratio_detector_id" {
  description = "SLO Success Ratio Detector ID"
}

variable "operation_duration_slo_detector_id" {
  description = "SLO Duration Detector ID"
}
