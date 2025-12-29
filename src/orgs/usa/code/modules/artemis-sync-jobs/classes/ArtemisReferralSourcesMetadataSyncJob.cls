/**
 * @description  :  Batch job to synchronize all Referral Sources Metadata from specified EMR servers (or all).
 * @author       : Ivo Rocha
 **/
public without sharing class ArtemisReferralSourcesMetadataSyncJob implements Schedulable, Database.Batchable<EmrServerDataProcessRequest>, Database.AllowsCallouts {
	private Set<Id> emrServerIds { get; set; }

	public ArtemisReferralSourcesMetadataSyncJob() {
		this(new EmrServerQuery().getIds());
	}

	public ArtemisReferralSourcesMetadataSyncJob(Set<Id> emrServerIds) {
		this.emrServerIds = emrServerIds;
	}

	public List<EmrServerDataProcessRequest> start(Database.BatchableContext bc) {
		List<EmrServerDataProcessRequest> emrServerDataProcessRequests = new List<EmrServerDataProcessRequest>();

		// Callout to each server to fetch the referral sources metadata
		for (Id emrServerId : emrServerIds) {
			ArtemisRestClient restClient = (ArtemisRestClient) EmrRestClientFactory.getRestClientInstance(emrServerId);
			List<ArtemisMetadataReferralSourceRestModel> referralSourcesMetadata = restClient.metadata.getReferralSources();
			for (ArtemisMetadataReferralSourceRestModel referralSourceMetadata : referralSourcesMetadata) {
				emrServerDataProcessRequests.add(new EmrServerDataProcessRequest(restClient.emrServer, referralSourceMetadata));
			}
		}

		return emrServerDataProcessRequests;
	}

	public void execute(Database.BatchableContext bc, List<EmrServerDataProcessRequest> scope) {
		ArtemisMetaReferralSourcesDataProcessor dataProcessor = new ArtemisMetaReferralSourcesDataProcessor();
		dataProcessor.add(scope);

		List<EmrServerDataProcessRequestResult> results = dataProcessor.process();
	}

	public void finish(Database.BatchableContext bc) {
	}

	public void execute(SchedulableContext SC) {
		executeNow();
	}

	public static void executeNow() {
		executeNow(new EmrServerQuery().getIds());
	}

	@InvocableMethod(
		label='Execute Artemis Referral Sources Metadata Sync Job'
		description='Executes the Artemis Referral Sources Metadata Sync Job. Only possible if not already running.'
		category='Artemis Sync Jobs'
	)
	public static void executeNow(List<Id> emrServerIds) {
		executeNow(new Set<Id>(emrServerIds));
	}

	public static void executeNow(Set<Id> emrServerIds) {
		List<AsyncApexJob> runningJobs = [
			SELECT Id
			FROM AsyncApexJob
			WHERE
				JobType = 'BatchApex'
				AND Status IN ('Holding', 'Preparing', 'Processing', 'Queued')
				AND ApexClass.Name = :ArtemisReferralSourcesMetadataSyncJob.class.getName()
			LIMIT 1
		];

		if (!runningJobs.isEmpty()) {
			throw new ArtemisReferralSourcesMetadataSyncJobException(
				'The Artemis Referral Sources Metadata Sync Job is already running. Please wait for it to finish before executing again.'
			);
		}

		Database.executeBatch(new ArtemisReferralSourcesMetadataSyncJob(emrServerIds), 100);
	}

	public class ArtemisReferralSourcesMetadataSyncJobException extends Exception {
	}
}
