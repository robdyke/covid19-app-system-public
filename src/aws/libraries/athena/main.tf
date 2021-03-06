# Database
resource "aws_athena_database" "this" {
  # databases names cannot contain '-' which will brake for envs like 'te-ci'
  name          = replace(var.database_name, "-", "_")
  bucket        = var.s3_output_bucket
  force_destroy = true
}

# Workgroup
resource "aws_athena_workgroup" "this" {
  name          = "${terraform.workspace}_workgroup"
  force_destroy = true

  configuration {
    enforce_workgroup_configuration = true

    result_configuration {
      # we do not set an output_location here because we want to be able to rename the folders our results land in.
      # this is done in AthenaService.java

      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }
  }
}

# Named Queries

# This table is build based on mock data located in `test/data/0004_create-mock-analytics-data`
resource "aws_athena_named_query" "create_table" {
  name      = "${var.database_name}_create_table"
  database  = aws_athena_database.this.name
  workgroup = aws_athena_workgroup.this.name
  query     = <<EOF
    CREATE EXTERNAL TABLE IF NOT EXISTS ${var.table_name} (
      `startDate` string,
      `endDate` string,
      `postalDistrict` string,
      `deviceModel` string,
      `latestApplicationVersion` string,
      `operatingSystemVersion` string,
      `cumulativeDownloadBytes` int,
      `cumulativeUploadBytes` int,
      `cumulativeCellularDownloadBytes` int,
      `cumulativeCellularUploadBytes` int,
      `cumulativeWifiDownloadBytes` int,
      `cumulativeWifiUploadBytes` int,
      `checkedIn` int,
      `canceledCheckIn` int,
      `receivedVoidTestResult` int,
      `isIsolatingBackgroundTick` int,
      `hasHadRiskyContactBackgroundTick` int,
      `receivedPositiveTestResult` int,
      `receivedNegativeTestResult` int,
      `hasSelfDiagnosedPositiveBackgroundTick` int,
      `completedQuestionnaireAndStartedIsolation` int,
      `encounterDetectionPausedBackgroundTick` int,
      `completedQuestionnaireButDidNotStartIsolation` int,
      `totalBackgroundTasks` int,
      `runningNormallyBackgroundTick` int,
      `completedOnboarding` int,
      `includesMultipleApplicationVersions` boolean
    )
    ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
    LOCATION 's3://${var.s3_input_bucket}/';
  EOF
}

# Metric: onboardingCompletedToday

resource "aws_athena_named_query" "onboardingCompletedToday_beginningOfTime" {
  name      = "${var.database_name}_onboardingCompletedToday_beginningOfTime"
  database  = aws_athena_database.this.name
  workgroup = aws_athena_workgroup.this.name
  query     = <<EOF
    SELECT
      SUBSTRING(endDate, 1, 10) AS date,
      CAST(SUM(completedOnboarding) AS DECIMAL) AS onboarding_completed_today
    FROM ${var.table_name}
    GROUP BY SUBSTRING(endDate, 1, 10)
    ORDER BY date DESC
  EOF
}

# completedOnboarding is an int, meaning that the same person can onboard multiple time (a day)
# note that this is unexpected behaviour and should not be an issue (though is worth noting)
resource "aws_athena_named_query" "onboardingCompletedToday_total" {
  name      = "${var.database_name}_onboardingCompletedToday_total"
  database  = aws_athena_database.this.name
  workgroup = aws_athena_workgroup.this.name
  query     = <<EOF
    SELECT CAST(SUM(completedOnboarding) AS DECIMAL) AS total_onboarding_completed
    FROM ${var.table_name}
  EOF
}

# Metric: activeUsers

resource "aws_athena_named_query" "activeUsers_beginningOfTime" {
  name      = "${var.database_name}_activeUsers_beginningOfTime"
  database  = aws_athena_database.this.name
  workgroup = aws_athena_workgroup.this.name
  query     = <<EOF
  SELECT SUBSTRING(endDate, 1, 10) AS date,
    CAST(COUNT(CASE WHEN deviceModel LIKE 'iPhone%' THEN 1 ELSE NULL END) AS DECIMAL) AS active_users_ios,
    CAST(COUNT(CASE WHEN deviceModel NOT LIKE 'iPhone%' THEN 1 ELSE NULL END) AS DECIMAL) AS active_users_android,
    CAST(COUNT(totalBackgroundTasks) AS DECIMAL) AS active_users_total
  FROM ${var.table_name}
  WHERE totalBackgroundTasks > 0
  GROUP BY SUBSTRING(endDate, 1, 10)
  ORDER BY date DESC
  EOF
}

# Metric: dataDownloadUsageBytes

resource "aws_athena_named_query" "dataUsageBytes_beginningOfTime" {
  name      = "${var.database_name}_dataUsageBytes_beginningOfTime"
  database  = aws_athena_database.this.name
  workgroup = aws_athena_workgroup.this.name
  query     = <<EOF
    SELECT SUBSTRING(endDate, 1, 10) AS date,
      CAST(SUM(cumulativeDownloadBytes) AS DECIMAL) AS total_data_download_usage,
      CAST(SUM(cumulativeUploadBytes) AS DECIMAL) AS total_data_upload_usage
    FROM ${var.table_name}
    GROUP BY SUBSTRING(endDate, 1, 10)
    ORDER BY date DESC
  EOF
}


# Metric: dataDownloadUsageBytesAverage

resource "aws_athena_named_query" "dataUsageBytesAverage_beginningOfTime" {
  name      = "${var.database_name}_dataUsageBytesAverage_beginningOfTime"
  database  = aws_athena_database.this.name
  workgroup = aws_athena_workgroup.this.name
  query     = <<EOF
    SELECT SUBSTRING(endDate, 1, 10) AS date,
      CAST(AVG(cumulativeDownloadBytes) AS DECIMAL) AS average_download_usage,
      CAST(AVG(cumulativeUploadBytes) AS DECIMAL) AS average_upload_usage
    FROM ${var.table_name}
    GROUP BY SUBSTRING(endDate, 1, 10)
    ORDER BY date DESC
  EOF
}

resource "aws_athena_named_query" "dataUsageBytesAverage_lastDay" {
  name      = "${var.database_name}_dataUsageBytesAverage_lastDay"
  database  = aws_athena_database.this.name
  workgroup = aws_athena_workgroup.this.name
  query     = <<EOF
    SELECT SUBSTRING(endDate, 1, 10) AS date,
      CAST(AVG(cumulativeDownloadBytes) AS DECIMAL) AS average_download_usage,
      CAST(AVG(cumulativeUploadBytes) AS DECIMAL) AS average_upload_usage
    FROM ${var.table_name}
    GROUP BY SUBSTRING(endDate, 1, 10)
    ORDER BY date DESC
    LIMIT 1
  EOF
}

# Metric: qrCodeCheckInCounts

resource "aws_athena_named_query" "qrCodeCheckInCounts_beginningOfTime" {
  name      = "${var.database_name}_qrCodeCheckInCounts_beginningOfTime"
  database  = aws_athena_database.this.name
  workgroup = aws_athena_workgroup.this.name
  query     = <<EOF
    SELECT SUBSTRING(endDate, 1, 10) AS date,
      CAST(SUM(checkedIn) AS DECIMAL) AS total_qr_checkins,
      CAST(SUM(canceledCheckIn) AS DECIMAL) AS total_canceled_qr_checkins
    FROM ${var.table_name}
    GROUP BY SUBSTRING(endDate, 1, 10)
    ORDER BY date DESC
  EOF
}

resource "aws_athena_named_query" "qrCodeCheckInCounts_lastSevenDays" {
  name      = "${var.database_name}_qrCodeCheckInCounts_lastSevenDays"
  database  = aws_athena_database.this.name
  workgroup = aws_athena_workgroup.this.name
  query     = <<EOF
    SELECT SUBSTRING(endDate, 1, 10) AS date,
      CAST(SUM(checkedIn) AS DECIMAL) AS total_qr_checkins,
      CAST(SUM(canceledCheckIn) AS DECIMAL) AS total_canceled_qr_checkins
    FROM ${var.table_name}
    GROUP BY SUBSTRING(endDate, 1, 10)
    ORDER BY date DESC
    LIMIT 7
  EOF
}

# Metric: isolationStatus
# currently assumes that isIsolatingBackgroundTick > 0 counts as a day isolated
resource "aws_athena_named_query" "isolationStatus_beginningOfTime" {
  name      = "${var.database_name}_isolationStatus_beginningOfTime"
  database  = aws_athena_database.this.name
  workgroup = aws_athena_workgroup.this.name
  query     = <<EOF
    SELECT SUBSTRING(endDate, 1, 10) AS date,
      CAST(COUNT(isIsolatingBackgroundTick) AS DECIMAL) AS total_isolations
    FROM ${var.table_name}
    WHERE isIsolatingBackgroundTick>0
    GROUP BY SUBSTRING(endDate, 1, 10)
    ORDER BY date DESC
  EOF
}

resource "aws_athena_named_query" "isolationStatus_lastSevenDays" {
  name      = "${var.database_name}_isolationStatus_lastSevenDays"
  database  = aws_athena_database.this.name
  workgroup = aws_athena_workgroup.this.name
  query     = <<EOF
    SELECT SUBSTRING(endDate, 1, 10) AS date,
      CAST(COUNT(isIsolatingBackgroundTick) AS DECIMAL) AS total_isolations
    FROM ${var.table_name}
    WHERE isIsolatingBackgroundTick>0
    GROUP BY SUBSTRING(endDate, 1, 10)
    ORDER BY date DESC
    LIMIT 7
  EOF
}

# Metric: symptomaticQuestionnaireResults

resource "aws_athena_named_query" "symptomaticQuestionnaireResults_beginningOfTime" {
  name      = "${var.database_name}_symptomaticQuestionnaireResults_beginningOfTime"
  database  = aws_athena_database.this.name
  workgroup = aws_athena_workgroup.this.name
  query     = <<EOF
    SELECT
      SUBSTRING(endDate, 1, 10) AS date,
      CAST(COUNT(CASE WHEN completedQuestionnaireAndStartedIsolation>0 THEN 1 END) AS DECIMAL) AS positive,
      CAST(COUNT(CASE WHEN completedQuestionnaireButDidNotStartIsolation>0 THEN 1 END) AS DECIMAL) AS negative
    FROM ${var.table_name}
    GROUP BY SUBSTRING(endDate, 1, 10)
    ORDER BY date DESC
  EOF
}

resource "aws_athena_named_query" "symptomaticQuestionnaireResults_lastSevenDays" {
  name      = "${var.database_name}_symptomaticQuestionnaireResults_lastSevenDays"
  database  = aws_athena_database.this.name
  workgroup = aws_athena_workgroup.this.name
  query     = <<EOF
    SELECT
      SUBSTRING(endDate, 1, 10) AS date,
      CAST(COUNT(CASE WHEN completedQuestionnaireAndStartedIsolation>0 THEN 1 END) AS DECIMAL) AS positive,
      CAST(COUNT(CASE WHEN completedQuestionnaireButDidNotStartIsolation>0 THEN 1 END) AS DECIMAL) AS negative
    FROM ${var.table_name}
    GROUP BY SUBSTRING(endDate, 1, 10)
    ORDER BY date DESC
    LIMIT 7
  EOF
}

# Metric: virologyExamination

resource "aws_athena_named_query" "virologyExamination_beginningOfTime" {
  name      = "${var.database_name}_virologyExamination_beginningOfTime"
  database  = aws_athena_database.this.name
  workgroup = aws_athena_workgroup.this.name
  query     = <<EOF
    SELECT SUBSTRING(endDate, 1, 10) AS date,
      CAST(COUNT(receivedpositivetestresult) AS DECIMAL) AS void_test_result,
      CAST(COUNT(receivedpositivetestresult) AS DECIMAL) AS positive_test_result,
      CAST(COUNT(receivednegativetestresult) AS DECIMAL) AS negative_test_result,
      CAST(SUM(IF(completedQuestionnaireAndStartedIsolation>0,1,0)) AS DECIMAL) AS recommended_to_take_test
    FROM ${var.table_name}
    WHERE completedQuestionnaireAndStartedIsolation>0
    GROUP BY SUBSTRING(endDate, 1, 10)
    ORDER BY date DESC
  EOF
}

resource "aws_athena_named_query" "virologyExamination_lastSevenDays" {
  name      = "${var.database_name}_virologyExamination_lastSevenDays"
  database  = aws_athena_database.this.name
  workgroup = aws_athena_workgroup.this.name
  query     = <<EOF
    SELECT SUBSTRING(endDate, 1, 10) AS date,
      CAST(COUNT(receivedVoidTestResult) AS DECIMAL) AS void_test_result,
      CAST(COUNT(receivedPositiveTestResult) AS DECIMAL) AS positive_test_result,
      CAST(COUNT(receivedNegativeTestResult) AS DECIMAL) AS negative_test_result,
      CAST(SUM(IF(completedQuestionnaireAndStartedIsolation>0,1,0)) AS DECIMAL) AS recommended_to_take_test
    FROM ${var.table_name}
    WHERE completedQuestionnaireAndStartedIsolation>0
    GROUP BY SUBSTRING(endDate, 1, 10)
    ORDER BY date DESC
    LIMIT 7
  EOF
}
