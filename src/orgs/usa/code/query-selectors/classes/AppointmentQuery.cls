/**
 * @description  : Query object for Appointment__c records.
 * @author       : Ivo Rocha
 **/
public inherited sharing class AppointmentQuery extends QueryObject {
	public AppointmentQuery() {
		super(
			new List<SObjectField>{
				Appointment__c.Id,
				Appointment__c.Name,
				Appointment__c.EmrAppointmentId__c,
				Appointment__c.EmrServer__c,
				Appointment__c.Patient__c,
				Appointment__c.Status__c,
				Appointment__c.CalendarName__c,
				Appointment__c.Provider__c,
				Appointment__c.Location__c,
				Appointment__c.AppointmentType__c,
				Appointment__c.AppointmentDateTime__c,
				Appointment__c.RawProviderId__c,
				Appointment__c.RawLocationId__c,
				Appointment__c.RawPatientId__c
				//TODO: Remaining fields
			},
			Appointment__c.SObjectType
		);
	}

	public AppointmentQuery byEmrServerId(Id serverId) {
		return byEmrServerId(new Set<Id>{ serverId });
	}

	public AppointmentQuery byEmrServerId(Set<Id> serverIds) {
		return (AppointmentQuery) byField(Appointment__c.EmrServer__c, 'IN', serverIds);
	}

	public AppointmentQuery byExternalId(String externalId) {
		return byExternalId(new Set<String>{ externalId });
	}

	public AppointmentQuery byExternalId(Set<String> externalIds) {
		return (AppointmentQuery) byField(Appointment__c.EmrAppointmentId__c, 'IN', externalIds);
	}

	public AppointmentQuery byPatientId(Id patientId) {
		return byPatientId(new Set<Id>{ patientId });
	}

	public AppointmentQuery byPatientId(Set<Id> patientIds) {
		return (AppointmentQuery) byField(Appointment__c.Patient__c, 'IN', patientIds);
	}
}
