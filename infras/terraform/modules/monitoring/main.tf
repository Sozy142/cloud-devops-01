# ==============================================================================
# JENKINS CONTROLLER ALARMS
# ==============================================================================
# CPU utilization alarm
resource "aws_cloudwatch_metric_alarm" "controller_cpu_high" {
  alarm_name          = "${var.project_name}-controller-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This metric monitors EC2 CPU utilization"
  dimensions = {
    InstanceId = var.controller_instance_id
  }
  alarm_actions       = [var.sns_topic_arn]
  ok_actions          = [var.sns_topic_arn]
  tags                = var.common_tags
}

# Instance status check alarm
resource "aws_cloudwatch_metric_alarm" "controller_status_check" {
  alarm_name          = "${var.project_name}-controller-status-check"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 1
  alarm_description   = "This metric monitors EC2 instance status check failures"
  dimensions = {
    InstanceId = var.controller_instance_id
  }
  alarm_actions       = [var.sns_topic_arn]
  ok_actions          = [var.sns_topic_arn]
  tags                = var.common_tags
}


# ==============================================================================
# NAT INSTANCE ALARMS
# ==============================================================================


resource "aws_cloudwatch_metric_alarm" "nat_status_check" {
  alarm_name          = "${var.project_name}-nat-status-check"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Maximum"
  threshold           = 0
  alarm_description   = "NAT instance status check failed - private subnet may lose internet"
  alarm_actions       = [var.sns_topic_arn]

  dimensions = {
    InstanceId = var.nat_instance_id
  }

  tags = var.common_tags
}

# ==============================================================================
# ALB ALARMS
# ==============================================================================

resource "aws_cloudwatch_metric_alarm" "alb_5xx_errors" {
  alarm_name          = "${var.project_name}-alb-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "ALB is receiving too many 5xx errors from Jenkins"
  alarm_actions       = [var.sns_topic_arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  tags = var.common_tags
}