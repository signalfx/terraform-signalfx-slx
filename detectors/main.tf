resource "signalfx_detector" "slx_success_ratio_slo_detector" {
    name = "${var.service_name} - Success Ratio SLO"
    description = "Verifies Success Ratio is not violating the SLO"
    teams = ["${var.responsible_team}"]
    max_delay = 30
    program_text = <<-EOF
A = ${var.successful_operations_sli_count_query}.publish(label='Successful Operations', enable=False)
B = ${var.total_operations_sli_count_query}.publish(label='Total Operations', enable=False)
C = ((A/B)*100).publish(label='Success Ratio')

detect(when(C < ${var.operation_success_ratio_slo_target}, lasting='${var.operation_success_ratio_slo_duration}')).publish('Success Ratio Detector')
    EOF

    rule {
        description = "SLO violation"
        severity = "Critical"
        detect_label = "Success Ratio Detector"
        notifications = ["Team,${var.responsible_team}"]
    }
}

resource "signalfx_detector" "slx_operation_duration_slo_detector" {
    name = "${var.service_name} - Operation Duration SLO"
    description = "Verifies that operation duration is not violating the SLO"
    teams = ["${var.responsible_team}"]
    max_delay = 30
    program_text = <<-EOF
A = ${var.operation_time_sli_query}.publish(label='Operation Duration')

detect(when(A > ${var.operation_time_slo_target}, lasting='${var.operation_success_ratio_slo_duration}')).publish('Operation Duration Detector')
    EOF

    rule {
        description = "SLO violation"
        severity = "Critical"
        detect_label = "Operation Duration Detector"
        notifications = ["Team,${var.responsible_team}"]
    }
}

resource "signalfx_detector" "slx_error_budget_detector" {
  name = "${var.service_name} - Error Budgets"
  description = "Verifies that the error budget is not being violated"
  teams = ["${var.responsible_team}"]
  max_delay = 30
  program_text = <<-EOF
A = ${var.error_operations_sli_count_query}.sum(cycle='hour', cycle_start='0m', partial_values=True).publish(label='Failed Operations', enable=False)
B = ${var.total_operations_sli_count_query}.sum(cycle='hour', cycle_start='0m', partial_values=True).publish(label='Total Operations', enable=False)
C = (((A/B)/${100.0 - var.operation_success_ratio_slo_target})*100).publish(label='Percentage of Error Budget Consumed', enable=False)

detect(when(C > (${100.0 - var.operation_success_ratio_slo_target})*100)).publish("Error Budget Violation")
  EOF

  rule {
    description = "Error Budget Exceeded"
    severity = "Info"
    detect_label = "Error Budget Violation"
    notifications = ["Team,${var.responsible_team}"]
  }
}
