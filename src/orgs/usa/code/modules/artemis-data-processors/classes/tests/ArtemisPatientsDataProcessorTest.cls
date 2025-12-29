/**
 * @description  : Unit tests for ArtemisPatientsDataProcessor
 * @author 	     : Ivo Rocha
 * @testSuite    : ArtemisDataProcessors
 **/
@isTest
private class ArtemisPatientsDataProcessorTest {
	@TestSetup
	static void makeData() {
		EmrServer__c emrServer = new EmrServer__c(
			Name = 'XPTO',
			ApiSchemaSpec__c = 'XPTO',
			NamedCredential__c = 'https://unit.xpto.test',
			TimeoutRequestPeriod__c = 50000,
			InboundRequestsRetentionPeriod__c = 10,
			OutboundRequestsRetentionPeriod__c = 15
		);
		insert emrServer;

		Account patient = new Account(RecordTypeId = RecordTypes.ACCOUNT_PATIENT.id, FirstName = 'Foo', LastName = 'Bar');
		insert patient;

		EmrServerAccountReference__c ermPatientReference = new EmrServerAccountReference__c(
			EmrServer__c = emrServer.Id,
			Account__c = patient.Id,
			Identifier__c = '12345',
			IsPrimary__c = true
		);
		insert ermPatientReference;
	}

	@isTest
	static void shouldUpdateExistingPatient() {
		EmrServer emrServer = EmrServer.getInstance('XPTO');

		ArtemisPatientRestModel payloadModel = new ArtemisPatientRestModel();
		payloadModel.id = '12345';
		payloadModel.salutation = 'Mr.';
		payloadModel.prefersName = 'Foo';
		payloadModel.firstName = 'Foo';
		payloadModel.middleName = 'Bar';
		payloadModel.lastName = 'Bar';
		payloadModel.suffix = 'Jr.';
		payloadModel.socialSecurityNumber = '123456789';
		payloadModel.dateOfBirth = Date.newInstance(1990, 1, 1);
		payloadModel.patientType = 'Patient';

		ArtemisPatientsDataProcessor processor = new ArtemisPatientsDataProcessor();
		processor.add(emrServer, payloadModel);

		Test.startTest();
		List<EmrServerDataProcessRequestResult> results = processor.process();
		Test.stopTest();

		Assert.isNotNull(results, 'Results should not be null');
		Assert.areEqual(1, results.size(), 'There should be one result');
		Assert.isTrue(results[0].isSuccess(), 'The result should be successful');

		Assert.areEqual(1, [SELECT COUNT() FROM Account WHERE RecordTypeId = :RecordTypes.ACCOUNT_PATIENT.id], 'There should be one patient in the database');
		EmrServerAccountReference__c ermPatientReference = (EmrServerAccountReference__c) new EmrServerAccountReferenceQuery()
			.byEmrServerId(emrServer.emrServerId)
			.byIdentifier(payloadModel.id)
			.getFirstOrNull();

		Account patient = (Account) new PatientQuery().withErmServerReference(ermPatientReference).getFirstOrNull();
		Assert.areEqual(payloadModel.firstName, patient.FirstName, 'The patient should have the correct first name');
		Assert.areEqual(payloadModel.lastName, patient.LastName, 'The patient should have the correct last name');
		Assert.areEqual(payloadModel.salutation, patient.Salutation, 'The patient should have the correct salutation');
		Assert.areEqual(payloadModel.prefersName, patient.PreferredFirstName__pc, 'The patient should have the correct preferred first name');
		Assert.areEqual(payloadModel.middleName, patient.MiddleName, 'The patient should have the correct middle name');
		Assert.areEqual(payloadModel.suffix, patient.Suffix, 'The patient should have the correct suffix');
		Assert.areEqual(payloadModel.socialSecurityNumber, patient.SocialSecurityNumber__pc, 'The patient should have the correct social security number');
		Assert.areEqual(payloadModel.dateOfBirth, patient.PersonBirthdate, 'The patient should have the correct date of birth');
		//Assert.areEqual(payloadModel.patientType, patient.PersonPatientType__pc, 'The patient should have the correct patient type');
	}

	//TODO: test for new patient creation when respective logic is implemented in the processor
}
