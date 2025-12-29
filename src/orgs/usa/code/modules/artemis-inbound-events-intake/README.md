## This is how Inbound Artemis Change Events are processed

1. An ArtemisChangeEvent\_\_e event is received in the system. It is created by the Artemis server.
2. Flow "PlatformEvent_IngestArtemisChangeEvents" is executed upon the receival of the event. It calls an Apex Class FlowAction_ArtemisChangeEventsIntaker, that will:
    1. Fetch the payload of the affected resource in Artemis, using the ArtemisRestClient
    2. Creates an EmrServerInboundRequest\_\_c attached to the EmrServer**c record associated with this event. It populaates the Payload**c field with the callout response.
        - In case of any failure processing the event, this record will be created in an ERROR status. If all goes well, with a "TO_PROCESS" status.
3. With the creation of EmrServerInboundRequest\_\_c, its Trigger handler is executed.
    1. It filters out non "TO_PROCESS" records
    2. Collects into different buckets, the different type of operations that will be required to be executed - based on the Resource\_\_c type (appointment, patient, etc..)
    3. For each resource bucket, calls its main data processor implementation.
        - If successfull, sets the record status to "PROCESSED"
        - Otherwise, error status is tracked
