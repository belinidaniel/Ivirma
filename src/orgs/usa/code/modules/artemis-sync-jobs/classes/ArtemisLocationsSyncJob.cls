/**
 * @description  : Batch job to synchronize all Locations from specified EMR servers (or all).
 * @author       : Ivo Rocha
 **/
public without sharing class ArtemisLocationsSyncJob implements Schedulable, Database.Batchable<EmrServerDataProcessRequest>, Database.AllowsCallouts {
	private Set<Id> emrServerIds { get; set; }

	public ArtemisLocationsSyncJob() {
		this(new EmrServerQuery().getIds());
	}

	public ArtemisLocationsSyncJob(Set<Id> emrServerIds) {
		this.emrServerIds = emrServerIds;
	}

	public List<EmrServerDataProcessRequest> start(Database.BatchableContext bc) {
		List<EmrServerDataProcessRequest> emrServerDataProcessRequests = new List<EmrServerDataProcessRequest>();

		// Callout to each server to fetch all locations info
		for (Id emrServerId : emrServerIds) {
			ArtemisRestClient restClient = (ArtemisRestClient) EmrRestClientFactory.getRestClientInstance(emrServerId);
			List<ArtemisLocationRestModel> locations = restClient.locations.getLocations();
			for (ArtemisLocationRestModel location : locations) {
				emrServerDataProcessRequests.add(new EmrServerDataProcessRequest(restClient.emrServer, location));
			}
		}

		return emrServerDataProcessRequests;
	}

	public void execute(Database.BatchableContext bc, List<EmrServerDataProcessRequest> scope) {
		ArtemisLocationsDataProcessor dataProcessor = new ArtemisLocationsDataProcessor();
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
		label='Execute Artemis Locations Sync Job'
		description='Executes the Artemis Locations Sync Job. Only possible if not already running.'
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
				AND ApexClass.Name = :ArtemisLocationsSyncJob.class.getName()
			LIMIT 1
		];

		if (!runningJobs.isEmpty()) {
			throw new ArtemisLocationsSyncJobException(
				'The Artemis Locations Sync Job is already running. Please wait for it to finish before executing again.'
			);
		}

		Database.executeBatch(new ArtemisLocationsSyncJob(emrServerIds), 100);
	}

	public class ArtemisLocationsSyncJobException extends Exception {
	}
}
