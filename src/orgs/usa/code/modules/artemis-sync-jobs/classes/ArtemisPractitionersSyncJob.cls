/**
 * @description  : Batch job to synchronize all Practitioners from specified EMR servers (or all).
 * @author       : Ivo Rocha
 **/
public without sharing class ArtemisPractitionersSyncJob implements Schedulable, Database.Batchable<EmrServerDataProcessRequest>, Database.AllowsCallouts {
	private Set<Id> emrServerIds { get; set; }

	public ArtemisPractitionersSyncJob() {
		this(new EmrServerQuery().getIds());
	}

	public ArtemisPractitionersSyncJob(Set<Id> emrServerIds) {
		this.emrServerIds = emrServerIds;
	}

	public List<EmrServerDataProcessRequest> start(Database.BatchableContext bc) {
		List<EmrServerDataProcessRequest> emrServerDataProcessRequests = new List<EmrServerDataProcessRequest>();

		// Callout to each server to fetch all practitioners info
		for (Id emrServerId : emrServerIds) {
			ArtemisRestClient restClient = (ArtemisRestClient) EmrRestClientFactory.getRestClientInstance(emrServerId);
			List<ArtemisPractitionerRestModel> practitioners = restClient.practitioners.getPractitioners();
			for (ArtemisPractitionerRestModel practitioner : practitioners) {
				emrServerDataProcessRequests.add(new EmrServerDataProcessRequest(restClient.emrServer, practitioner));
			}
		}
		return emrServerDataProcessRequests;
	}

	public void execute(Database.BatchableContext bc, List<EmrServerDataProcessRequest> scope) {
		ArtemisPractitionersDataProcessor dataProcessor = new ArtemisPractitionersDataProcessor();
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
		label='Execute Artemis Practitioners Sync Job'
		description='Executes the Artemis Practitioners Sync Job. Only possible if not already running.'
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
				AND ApexClass.Name = :ArtemisPractitionersSyncJob.class.getName()
			LIMIT 1
		];

		if (!runningJobs.isEmpty()) {
			throw new ArtemisPractitionersSyncJobException(
				'The Artemis Practitioners Sync Job is already running. Please wait for it to finish before executing again.'
			);
		}

		Database.executeBatch(new ArtemisPractitionersSyncJob(emrServerIds), 50);
	}

	public class ArtemisPractitionersSyncJobException extends Exception {
	}
}
