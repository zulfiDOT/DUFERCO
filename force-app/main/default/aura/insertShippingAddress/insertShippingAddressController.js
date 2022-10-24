({
    doInit : function(component, event, helper) {
        var recId = component.get("v.recordId");
        component.set("v.quoteId", recId);
    },

    close: function(component, event, helper) {

        // Close the action panel
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },

    save: function(component, event, helper) {

        component.find('addAddress').handleSave();
        
    },

    handleSelected: function(component, event, helper) {

        component.set('v.disableBtn', false);
        
    }
})