/**
 * @description  : This class represents a cancel appointment request in the Artemis Rest API.
 * @author       : Ivo Rocha
 **/
public class ArtemisCancelAppointmentRestModel extends EmrRestClient.RestModel {
	public String reason { get; set; }
	public String cancelledBy { get; set; }
}
