({
    doInit : function(component, event, helper) {
        var recId = component.get("v.recordId");
        component.set("v.quoteId", recId);
        console.log('v.quoteId', component.get("v.quoteId"));
    },

    closeQA : function(component, event, helper) { 
        $A.get("e.force:closeQuickAction").fire(); 
        $A.get("e.force:refreshView").fire(); 
      } 

})