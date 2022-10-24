({
    doInit : function(component, event, helper) {
        var recId = component.get("v.recordId");
        component.set("v.quoteId", recId);
    },

    save: function(component, event, helper) {

        component.find('addBilling').handleSave();

    },

    close: function(component, event, helper) {

        // Close the action panel
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },

    preavious: function(component, event, helper) {

        component.find('addBilling').handlePreavious();
    },


    handleButton: function(component, event, helper) {

        component.set('v.disableBtn', event.getParam('disableButton'));
        if(event.getParam('leftButtonLabel')){
            component.set('v.buttonLeftLabel',event.getParam('leftButtonLabel'));
        }
        if(event.getParam('rightButtonLabel')){
            component.set('v.buttonRightLabel',event.getParam('rightButtonLabel'));
        }
        
    }, 

    handleMessage: function(component, message){

        if(message){
            var disabledRightBtn = message.getParam('disableRightButton');
            var disabledLeftBtn = message.getParam('disableLeftButton');
            var leftBtnLabel = message.getParam('leftButtonLabel');
            var rightBtnLabel = message.getParam('rightButtonLabel');
            component.set('v.disableBtn', message.getParam('disableButton'));
            if(disabledLeftBtn !== "undefined"){
                component.set('v.disableLeftBtn',disabledLeftBtn);
            }
            if(rightBtnLabel){
                component.set('v.buttonRightLabel', rightBtnLabel);
            }
            if(leftBtnLabel){
                component.set('v.buttonLeftLabel',leftBtnLabel);
            }
            
        }
    }
})