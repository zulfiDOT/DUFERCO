({
    doInit : function(component, event, helper) {
        var recId = component.get("v.recordId");
        component.set("v.quoteId", recId);
    },

    save: function(component, event, helper) {

        component.find('addAddress').handleSave();

    },

    close: function(component, event, helper) {

        // Close the action panel
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },

    preavious: function(component, event, helper) {

        component.find('addAddress').handlePreavious();
    },


    handleButton: function(component, event, helper) {

        component.set('v.disableBtn', event.getParam('disableButton'));
        if(event.getParam('leftButtonLabel')){
            component.set('v.buttonLeftLabel',event.getParam('leftButtonLabel'));
        }
        if(event.getParam('rightButtonLabel')){
            component.set('v.buttonRightLabel',event.getParam('rightButtonLabel'));
        }
        
    }
})