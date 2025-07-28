trigger ContactTrigger on Contact (after insert, before update) {
    switch on Trigger.operationType {
        // AFTER INSERT → IDs are assigned
        when AFTER_INSERT {
            ContactSurveyLinkHandler.handleSurveyLinkShortening(Trigger.new, null);
        }
        // BEFORE UPDATE → IDs already exist on update
        when BEFORE_UPDATE {
            ContactSurveyLinkHandler.handleSurveyLinkShortening(Trigger.new, Trigger.oldMap);
        }
    }
}