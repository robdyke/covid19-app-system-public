package uk.nhs.nhsx;

import uk.nhs.nhsx.diagnosiskeyssubmission.model.StoredTemporaryExposureKey;
import uk.nhs.nhsx.diagnosiskeyssubmission.model.StoredTemporaryExposureKeyPayload;

import static java.util.Arrays.asList;

public class TestData {

    public static final String STORED_KEYS_PAYLOAD =
        "{\"temporaryExposureKeys\":[" +
            "{\"key\":\"W2zb3BeMWt6Xr2u0ABG32Q==\",\"rollingStartNumber\":12345,\"rollingPeriod\":144,\"transmissionRisk\":7}," +
            "{\"key\":\"kzQt9Lf3xjtAlMtm7jkSqw==\",\"rollingStartNumber\":12499,\"rollingPeriod\":144,\"transmissionRisk\":7}" +
            "]}";

    public static final StoredTemporaryExposureKeyPayload STORED_KEYS_PAYLOAD_DESERIALIZED =
        new StoredTemporaryExposureKeyPayload(
            asList(
                new StoredTemporaryExposureKey("W2zb3BeMWt6Xr2u0ABG32Q==", 12345, 144),
                new StoredTemporaryExposureKey("kzQt9Lf3xjtAlMtm7jkSqw==", 12499, 144)
            )
        );

    public static final String RISKY_VENUES_UPLOAD_PAYLOAD =
        "# venue_id, start_time, end_time\n" +
            "\"ID1\", \"2019-07-04T13:33:03Z\", \"2019-07-04T15:56:00Z\"\n" +
            "\"ID2\", \"2019-07-06T19:33:03Z\", \"2019-07-06T21:01:07Z\"\n" +
            "\"ID3\", \"2019-07-08T20:05:52Z\", \"2019-07-08T22:35:56Z\"";

    public static final String STORED_RISKY_VENUES_UPLOAD_PAYLOAD =
        "{\"venues\":[" +
            "{\"id\":\"ID1\",\"riskyWindow\":{\"from\":\"2019-07-04T13:33:03Z\",\"until\":\"2019-07-04T15:56:00Z\"}}," +
            "{\"id\":\"ID2\",\"riskyWindow\":{\"from\":\"2019-07-06T19:33:03Z\",\"until\":\"2019-07-06T21:01:07Z\"}}," +
            "{\"id\":\"ID3\",\"riskyWindow\":{\"from\":\"2019-07-08T20:05:52Z\",\"until\":\"2019-07-08T22:35:56Z\"}}" +
            "]}";

    public static final String STORED_ANALYTICS_PAYLOAD_IOS =
        "{\"startDate\":\"2020-07-27T23:00:00Z\",\"endDate\":\"2020-07-28T22:59:00Z\",\"postalDistrict\":\"A1\",\"deviceModel\":\"iPhone11,2\",\"operatingSystemVersion\":\"iPhone OS 13.5.1 (17F80)\",\"latestApplicationVersion\":\"3.0\",\"cumulativeDownloadBytes\":140000000,\"cumulativeUploadBytes\":140000000,\"cumulativeCellularDownloadBytes\":80000000,\"cumulativeCellularUploadBytes\":70000000,\"cumulativeWifiDownloadBytes\":60000000,\"cumulativeWifiUploadBytes\":50000000,\"checkedIn\":1,\"canceledCheckIn\":1,\"receivedVoidTestResult\":1,\"isIsolatingBackgroundTick\":1,\"hasHadRiskyContactBackgroundTick\":1,\"receivedPositiveTestResult\":1,\"receivedNegativeTestResult\":1,\"hasSelfDiagnosedPositiveBackgroundTick\":1,\"completedQuestionnaireAndStartedIsolation\":1,\"encounterDetectionPausedBackgroundTick\":1,\"completedQuestionnaireButDidNotStartIsolation\":1,\"totalBackgroundTasks\":1,\"runningNormallyBackgroundTick\":1,\"completedOnboarding\":1,\"includesMultipleApplicationVersions\":false}";

    public static final String STORED_ANALYTICS_PAYLOAD_ANDROID =
        "{\"startDate\":\"2020-07-27T23:00:00Z\",\"endDate\":\"2020-07-28T22:59:00Z\",\"postalDistrict\":\"A1\",\"deviceModel\":\"HUAWEI LDN-L21\",\"operatingSystemVersion\":\"29\",\"latestApplicationVersion\":\"3.0\",\"cumulativeDownloadBytes\":null,\"cumulativeUploadBytes\":null,\"cumulativeCellularDownloadBytes\":null,\"cumulativeCellularUploadBytes\":null,\"cumulativeWifiDownloadBytes\":null,\"cumulativeWifiUploadBytes\":null,\"checkedIn\":1,\"canceledCheckIn\":1,\"receivedVoidTestResult\":1,\"isIsolatingBackgroundTick\":1,\"hasHadRiskyContactBackgroundTick\":1,\"receivedPositiveTestResult\":1,\"receivedNegativeTestResult\":1,\"hasSelfDiagnosedPositiveBackgroundTick\":1,\"completedQuestionnaireAndStartedIsolation\":1,\"encounterDetectionPausedBackgroundTick\":1,\"completedQuestionnaireButDidNotStartIsolation\":1,\"totalBackgroundTasks\":1,\"runningNormallyBackgroundTick\":1,\"completedOnboarding\":1,\"includesMultipleApplicationVersions\":false}";

    public static final String EXPOSURE_NOTIFICATION_CIRCUIT_BREAKER_PAYLOAD =
        " {\"matchedKeyCount\" : 2,\n" +
        " \"daysSinceLastExposure\": 3,\n" +
        " \"maximumRiskScore\" : 150\n" +
        " }";
}
