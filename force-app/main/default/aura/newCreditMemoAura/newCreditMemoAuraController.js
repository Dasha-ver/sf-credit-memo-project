({
    doInit : function(component, event, helper) {
        var action = component.get("c.getDefaultNoteForLightning");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var notesText = response.getReturnValue();
                
                var createRecordEvent = $A.get("e.force:createRecord");
                createRecordEvent.setParams({
                    "entityApiName": "Credit_Memo__c",
                    "defaultFieldValues": {
                        "Notes__c" : notesText
                    }
                });
                createRecordEvent.fire();
                
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        
        $A.enqueueAction(action);
    }
})