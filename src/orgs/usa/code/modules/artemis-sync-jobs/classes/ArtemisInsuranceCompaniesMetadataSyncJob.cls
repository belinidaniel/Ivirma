/**
 * @description  : Batch job to synchronize all Insurance Companies Metadata from specified EMR servers (or all).
 * @author       : Ivo Rocha
 **/
public without sharing class ArtemisInsuranceCompaniesMetadataSyncJob implements Schedulable, Database.Batchable<EmrServerDataProcessRequest>, Database.AllowsCallouts {
	private Set<Id> emrServerIds { get; set; }

	public ArtemisInsuranceCompaniesMetadataSyncJob() {
		this(new EmrServerQuery().getIds());
	}

	public ArtemisInsuranceCompaniesMetadataSyncJob(Set<Id> emrServerIds) {
		this.emrServerIds = emrServerIds;
	}

	public List<EmrServerDataProcessRequest> start(Database.BatchableContext bc) {
		List<EmrServerDataProcessRequest> emrServerDataProcessRequests = new List<EmrServerDataProcessRequest>();

		// Callout to each server to fetch the insurance companies metadata
		for (Id emrServerId : emrServerIds) {
			ArtemisRestClient restClient = (ArtemisRestClient) EmrRestClientFactory.getRestClientInstance(emrServerId);
			List<ArtemisMetadataInsuranceCompanyRestModel> insuranceCompaniesMetadata = restClient.metadata.getInsuranceCompanies();
			for (ArtemisMetadataInsuranceCompanyRestModel insuranceCompanyMetadata : insuranceCompaniesMetadata) {
				emrServerDataProcessRequests.add(new EmrServerDataProcessRequest(restClient.emrServer, insuranceCompanyMetadata));
			}
		}
		return emrServerDataProcessRequests;
	}

	public void execute(Database.BatchableContext bc, List<EmrServerDataProcessRequest> scope) {
		ArtemisMetaInsuranceCompsDataProcessor dataProcessor = new ArtemisMetaInsuranceCompsDataProcessor();
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
		label='Execute Artemis Insurance Companies Metadata Sync Job'
		description='Executes the Artemis Insurance Companies Metadata Sync Job. Only possible if not already running.'
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
				AND ApexClass.Name = :ArtemisInsuranceCompaniesMetadataSyncJob.class.getName()
			LIMIT 1
		];

		if (!runningJobs.isEmpty()) {
			throw new ArtemisInsuranceCompaniesMetadataSyncJobException(
				'The Artemis Insurance Companies Metadata Sync Job is already running. Please wait for it to finish before executing again.'
			);
		}

		Database.executeBatch(new ArtemisInsuranceCompaniesMetadataSyncJob(emrServerIds), 100);
	}

	public class ArtemisInsuranceCompaniesMetadataSyncJobException extends Exception {
	}
}
