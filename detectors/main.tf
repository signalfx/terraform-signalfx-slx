resource "signalfx_detector" "slx_success_ratio_slo_detector" {
    name = "Success Ratio SLO"
    description = "Success Ratio is below SLO"
    teams = ["${var.responsible_team}"]
    max_delay = 30
    program_text = <<-EOF
A = ${var.successful_operations_sli_count_query}.publish(label='Successful Operations', enable=False)
B = ${var.total_operations_sli_count_query}.publish(label='Total Operations', enable=False)
C = ((A/B)*100).publish(label='Success Ratio')

detect(when(C < ${var.operation_success_ratio_slo_target}, lasting='${var.operation_success_ratio_slo_target}')).publish('Success Ratio Detector')
    EOF

    rule {
        description = "SLO violation "
        severity = "Critical"
        detect_label = "Success Ratio Detector"
        notifications = ["Team,${var.responsible_team}"]
    }
}

resource "signalfx_detector" "slx_operation_duration_slo_detector" {
    name = "Operation Duration SLO"
    description = "Operation Duration is below SLO"
    teams = ["${var.responsible_team}"]
    max_delay = 30
    program_text = <<-EOF
A = ${var.operation_time_sli_query}.publish(label='Operation Duration')

detect(when(A < ${var.operation_time_slo_target}, lasting='${var.operation_success_ratio_slo_duration}')).publish('Operation Duration Detector')
    EOF

    rule {
        description = "SLO violation"
        severity = "Critical"
        detect_label = "Operation Duration Detector"
        notifications = ["Team,${var.responsible_team}"]
    }
}
