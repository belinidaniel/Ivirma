/**
 * @description  : This class represents an appointment in the Artemis Rest API.
 * @author       : Ivo Rocha
 **/
public class ArtemisAppointmentRestModel extends EmrRestClient.RestModel {
	@InvocableVariable
	@AuraEnabled
	public String id;

	@InvocableVariable
	@AuraEnabled
	public String patientId;

	@InvocableVariable
	@AuraEnabled
	public String providerId;

	@InvocableVariable
	@AuraEnabled
	public String locationId;

	@InvocableVariable
	@AuraEnabled
	public String appointmentType;

	@InvocableVariable
	@AuraEnabled
	public String appointmentStatus;

	@InvocableVariable
	@AuraEnabled
	public DateTime appointmentDateTime;

	@InvocableVariable
	@AuraEnabled
	public Long duration;

	@InvocableVariable
	@AuraEnabled
	public String status;

	@InvocableVariable
	@AuraEnabled
	public String confirmationStatus;

	@InvocableVariable
	@AuraEnabled
	public String statusReason;

	@InvocableVariable
	@AuraEnabled
	public String scheduledBy;

	@InvocableVariable
	@AuraEnabled
	public DateTime scheduledDateTime;

	@InvocableVariable
	@AuraEnabled
	public String cptCode;

	/**
	 * @description  : Converts the current ArtemisAppointmentRestModel instance to an Appointment__c object record.
	 * @return Appointment__c A new Appointment__c object record.
	 */
	public Appointment__c toSObject() {
		return toSObject(null, null);
	}

	/**
	 * @description  : Converts the current ArtemisAppointmentRestModel instance to an Appointment__c object record.
	 * @param recordId The Id of the Appointment__c object record, if existing.
	 * @return Appointment__c A new Appointment__c object record.
	 */
	public Appointment__c toSObject(Id recordId) {
		return toSObject(recordId, null);
	}

	/**
	 * @description  : Converts the current ArtemisAppointmentRestModel instance to an Appointment__c object record.
	 * @param contextRefs The context references for the Appointment__c object record.
	 * @return Appointment__c A new Appointment__c object record.
	 */
	public Appointment__c toSObject(ToSObjectContextRefs contextRefs) {
		return toSObject(null, contextRefs);
	}

	/**
	 * @description  : Converts the current ArtemisAppointmentRestModel instance to an Appointment__c object record.
	 * @param recordId The Id of the Appointment__c object record, if existing.
	 * @param contextRefs The context references for the Appointment__c object record.
	 * @return Appointment__c A new Appointment__c object record.
	 */
	public Appointment__c toSObject(Id recordId, ToSObjectContextRefs contextRefs) {
		Appointment__c appointment = new Appointment__c(Id = recordId);
		appointment.EmrAppointmentId__c = this.id;
		appointment.AppointmentComment__c = null; //TODO
		appointment.AppointmentDateTime__c = this.appointmentDateTime;
		appointment.AppointmentType__c = this.appointmentType;
		appointment.CalendarName__c = null; //TODO
		appointment.CancelationDateTime__c = null; //TODO
		appointment.CancelReason__c = null; //TODO
		appointment.ConfirmationDateTime__c = null; //TODO
		appointment.CptCode__c = this.cptCode;
		appointment.ScheduledDateTime__c = this.scheduledDateTime;
		appointment.SigninFlag__c = null;
		appointment.Status__c = this.appointmentStatus;
		appointment.ConfirmationStatus__c = this.confirmationStatus;

		appointment.RawProviderId__c = this.providerId;
		appointment.Provider__c = contextRefs?.sfProviderId;

		appointment.RawPatientId__c = this.patientId;
		appointment.Patient__c = contextRefs?.sfPatientId;

		appointment.RawLocationId__c = this.locationId;
		appointment.Location__c = contextRefs?.sfLocationId;

		//appointment.RawScheduledBy__c = this.scheduledBy;
		//appointment.ScheduledBy__c = contextRefs?.sfScheduledById;

		return appointment;
	}

	public class ToSObjectContextRefs {
		public Id sfLocationId { get; set; }
		public Id sfPatientId { get; set; }
		public Id sfProviderId { get; set; }
		public Id sfScheduledById { get; set; }
	}
}
