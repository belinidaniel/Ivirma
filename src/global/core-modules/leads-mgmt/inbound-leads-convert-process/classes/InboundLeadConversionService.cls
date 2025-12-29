/**
 * @description  : Service class for Inbound Leads.
 * @author       : Ivo Rocha
 * @testSuite    : InboundLeadsProcessing
 **/
public without sharing class InboundLeadConversionService {
	public static void process(List<Id> inboundLeadIds) {
		InboundLeadConversion conversion = new InboundLeadConversion(new Set<Id>(inboundLeadIds));
		conversion.convert();
	}
}
