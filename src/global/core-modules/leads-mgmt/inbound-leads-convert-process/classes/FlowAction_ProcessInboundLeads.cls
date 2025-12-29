/**
 * @description  : Flow action to process inbound leads.
 * @author       : Ivo Rocha
 * @testSuite    : InboundLeadsProcessing
 **/
public without sharing class FlowAction_ProcessInboundLeads {
	@InvocableMethod(label='Process Inbound Leads')
	public static void process(List<Id> inboundLeadIds) {
		InboundLeadConversionService.process(inboundLeadIds);
	}
}
