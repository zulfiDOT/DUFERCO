({
    doInit : function(component, event, helper){
        var recId = component.get("v.recordId");
        let pageRef = component.get("v.pageReference");
        console.log( 'Page Ref is ' + JSON.stringify( pageRef ) );
        let state = pageRef.state; // state holds any query params
        let base64Context = state.inContextOfRef;
        if ( base64Context.startsWith("1\.") ) {
            base64Context = base64Context.substring( 2 );
        }
        let addressableContext = JSON.parse( window.atob( base64Context ) );
        //component.set( "v.recordId", addressableContext.attributes.recordId );
        component.set("v.accID",addressableContext.attributes.recordId);
        
    }, 

    handleSuccess : function(component, event, helper) {
        //var recordId = event.getParams('Id');
        var accID = component.get("v.accID");

        var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
      "recordId": accID/*recordId.Id*/
    });
    navEvt.fire();
    },

    handleCancel : function(component, event, helper) {
        //var recordId = event.getParams('Id');
        var accID = component.get("v.accID");

        var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
      "recordId": accID/*recordId.Id*/
    });
    navEvt.fire();
    }


})