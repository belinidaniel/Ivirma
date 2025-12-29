/**
 * @description  :  Batch job to synchronize all Providers from specified EMR servers (or all).
 * @author       : Ivo Rocha
 **/
public without sharing class ArtemisProvidersSyncJob implements Schedulable, Database.Batchable<EmrServerDataProcessRequest>, Database.AllowsCallouts {
	private Set<Id> emrServerIds { get; set; }

	public ArtemisProvidersSyncJob() {
		this(new EmrServerQuery().getIds());
	}

	public ArtemisProvidersSyncJob(Set<Id> emrServerIds) {
		this.emrServerIds = emrServerIds;
	}

	public List<EmrServerDataProcessRequest> start(Database.BatchableContext bc) {
		List<EmrServerDataProcessRequest> emrServerDataProcessRequests = new List<EmrServerDataProcessRequest>();

		// Callout to each server to fetch all providers info
		for (Id emrServerId : emrServerIds) {
			ArtemisRestClient restClient = (ArtemisRestClient) EmrRestClientFactory.getRestClientInstance(emrServerId);
			List<ArtemisProviderRestModel> providers = restClient.providers.getProviders();
			for (ArtemisProviderRestModel provider : providers) {
				emrServerDataProcessRequests.add(new EmrServerDataProcessRequest(restClient.emrServer, provider));
			}
		}
		return emrServerDataProcessRequests;
	}

	public void execute(Database.BatchableContext bc, List<EmrServerDataProcessRequest> scope) {
		ArtemisProvidersDataProcessor dataProcessor = new ArtemisProvidersDataProcessor();
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
		label='Execute Artemis Providers Sync Job'
		description='Executes the Artemis Providers Sync Job. Only possible if not already running.'
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
				AND ApexClass.Name = :ArtemisProvidersSyncJob.class.getName()
			LIMIT 1
		];

		if (!runningJobs.isEmpty()) {
			throw new ArtemisProvidersSyncJobException(
				'The Artemis Providers Sync Job is already running. Please wait for it to finish before executing again.'
			);
		}

		Database.executeBatch(new ArtemisProvidersSyncJob(emrServerIds), 50);
	}

	public class ArtemisProvidersSyncJobException extends Exception {
	}
}
