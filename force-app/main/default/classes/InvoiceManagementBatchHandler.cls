public with sharing class InvoiceManagementBatchHandler {

    //Lutech AT 07/09/2022 CR#44604 - Controlli pre fatturazione
    @InvocableMethod
    public static void controlloDelleFatture(List<Id> invoiceIds){
        
        blng__Invoice__c invoiceToVerify = [SELECT Id
                                                  ,Name
                                                  ,BillingProfile__r.PaymentMethod__c
                                                  ,BillingProfile__r.BillingAddress__r.StreetName__c
                                                  ,BillingProfile__r.BillingAddress__r.StreetNumber__c
                                                  ,BillingProfile__r.BillingAddress__r.ZipCode__c
                                                  ,BillingProfile__r.BillingAddress__r.City__c
                                                  ,BillingProfile__r.BillingAddress__r.Province__c
                                                  ,BillingProfile__r.BillingAddress__r.Country__c
                                                  ,BillingProfile__r.BillingEmail__c
                                            	  ,BillingProfile__r.SdiCode__c
                                                  ,blng__Account__r.CustomerAddress__r.StreetName__c
                                                  ,blng__Account__r.CustomerAddress__r.StreetNumber__c
                                                  ,blng__Account__r.CustomerAddress__r.ZipCode__c
                                                  ,blng__Account__r.CustomerAddress__r.City__c
                                                  ,blng__Account__r.CustomerAddress__r.Province__c
                                                  ,blng__Account__r.CustomerAddress__r.Country__c
                                                  ,blng__Account__r.IDTERPDatamax__c
                                                  ,blng__Account__r.IsPersonAccount 
                                                  ,blng__Account__r.Nation__c
                                                  ,blng__Account__r.FiscalCode__c 
                                                  ,blng__Account__r.FormaAnagrafica__c
                                                  ,blng__Account__r.VatNumber__c
                                            	  ,blng__TotalAmount__c
                                            	  ,BillingProfile__r.PaymentMethod__r.MandateCode__c
                                                  ,BillingProfile__r.IBANBank__c
                                                  ,BillingProfile__r.PaymentMethod__r.blng__PaymentType__c
                                                  ,BillingProfile__r.Bank__c
                                                  ,BillingProfile__r.SwiftCodeBank__c
                                            	  ,EstimatedTaxAmount__c
                                            	  ,blng__TaxAmount__c
                                            	  ,InvoiceValidationStatus__c 
                                            	  ,InvoiceValidationResult__c 
                                                  FROM blng__Invoice__c 
                                                  WHERE Id = :invoiceIds[0] 
                                            	  LIMIT 1
                                                 ];
        
        
        Boolean isError =  false;
        String errorMsg =  '';
        List<String> customErr1 =  Label.Controlli_pre_fatturazione_1.split(';');// Error message for 1
        List<String> customErr2 =  Label.Controlli_pre_fatturazione_2.split(';');// Error message for 2,3,4,5
        List<String> customErr3 =  Label.Billing_Profile_PaymentMethod_PaymentType.split(';');// Error message for 8,9
        List<String> customErr4 =  Label.InvoiceLineControlli.split(';');// Error message for 10,11,13
        //1 -- campi  obbligatoriamente compilati 
        if(String.isEmpty(invoiceToVerify.BillingProfile__r.PaymentMethod__c)){
            errorMsg += customErr1[0]+';' +'\n';
            isError =  true; 
        }
        if(String.isEmpty(invoiceToVerify.BillingProfile__r.BillingAddress__r.StreetName__c)){
            errorMsg += customErr1[1]+';' +'\n';
            isError =  true; 
        }
        if(String.isEmpty(invoiceToVerify.BillingProfile__r.BillingAddress__r.StreetNumber__c)){
            errorMsg += customErr1[2]+';' +'\n';
            isError =  true; 
        }
        if(String.isEmpty(invoiceToVerify.BillingProfile__r.BillingAddress__r.ZipCode__c)){
            errorMsg += customErr1[3]+';' +'\n';
            isError =  true; 
        }
        if(String.isEmpty(invoiceToVerify.BillingProfile__r.BillingAddress__r.City__c)){
            errorMsg += customErr1[4]+';' +'\n';
            isError =  true; 
        }
        if(String.isEmpty(invoiceToVerify.BillingProfile__r.BillingAddress__r.Province__c)){
            errorMsg += customErr1[5]+';' +'\n';
            isError =  true; 
        }
        if(String.isEmpty(invoiceToVerify.BillingProfile__r.BillingAddress__r.Country__c)){
            errorMsg += customErr1[6]+';' +'\n';
            isError =  true; 
        }
        if(String.isEmpty(invoiceToVerify.BillingProfile__r.BillingEmail__c)){
            errorMsg += customErr1[7]+';' +'\n';
            isError =  true; 
        }
        if(String.isEmpty(invoiceToVerify.blng__Account__r.CustomerAddress__r.StreetName__c)){
            errorMsg += customErr1[8]+';' +'\n';
            isError =  true; 
        }
        if(String.isEmpty(invoiceToVerify.blng__Account__r.CustomerAddress__r.StreetNumber__c)){
            errorMsg += customErr1[9]+';' +'\n';
            isError =  true; 
        }
        if(String.isEmpty(invoiceToVerify.blng__Account__r.CustomerAddress__r.ZipCode__c)){
            errorMsg += customErr1[10]+';' +'\n';
            isError =  true; 
        }
        if(String.isEmpty(invoiceToVerify.blng__Account__r.CustomerAddress__r.City__c)){
            errorMsg += customErr1[11]+';' +'\n';
            isError =  true; 
        }
        if(String.isEmpty(invoiceToVerify.blng__Account__r.CustomerAddress__r.Province__c)){
            errorMsg += customErr1[12]+';' +'\n';
            isError =  true; 
        }
        if(String.isEmpty(invoiceToVerify.blng__Account__r.CustomerAddress__r.Country__c)){
            errorMsg += customErr1[13]+';' +'\n';
            isError =  true; 
        }
        if(String.isEmpty(invoiceToVerify.blng__Account__r.IDTERPDatamax__c)){
            errorMsg += customErr1[14]+';' +'\n';
            isError =  true; 
        }
		//2  - blng__Account__r.Nation__c == "IT" 3,4,5
        if( invoiceToVerify.blng__Account__r.Nation__c == 'IT'){
           
            if(!String.isEmpty(invoiceToVerify.BillingProfile__r.BillingAddress__r.ZipCode__c)
               && invoiceToVerify.BillingProfile__r.BillingAddress__r.ZipCode__c.length() == 5 
               && invoiceToVerify.BillingProfile__r.BillingAddress__r.ZipCode__c.isNumeric() ){
               }else{
                   errorMsg += customErr2[0]+';' +'\n';
                   isError =  true; 
               }
            if(!String.isEmpty(invoiceToVerify.blng__Account__r.CustomerAddress__r.ZipCode__c)
               && invoiceToVerify.blng__Account__r.CustomerAddress__r.ZipCode__c.length() == 5 
               && invoiceToVerify.blng__Account__r.CustomerAddress__r.ZipCode__c.isNumeric() ){
               }else{
                   errorMsg += customErr2[1]+';' +'\n';
                   isError =  true; 
               }
            if(invoiceToVerify.BillingProfile__r.SdiCode__c=='XXXXXXX'){
                errorMsg += customErr2[2]+';' +'\n';
                   isError =  true; 
            }
            //3-Se blng__Account__r.IsPersonAccount == true && blng__Account__r.Nation__c == "IT"
            if(invoiceToVerify.blng__Account__r.IsPersonAccount){
                if(String.isEmpty(invoiceToVerify.blng__Account__r.FiscalCode__c)){
                   errorMsg += customErr2[3]+';' +'\n';
                   isError =  true; 
                }
            }
            //4 -- Se blng__Account__r.IsPersonAccount == false && blng__Account__r.Nation__c == "IT" && (blng__Account__r.FormaAnagrafica__c == ‘CONDOMINIO’ || blng__Account__r.FormaAnagrafica__c == ‘CONDOMINIA’)
			if(!invoiceToVerify.blng__Account__r.IsPersonAccount 
               && (invoiceToVerify.blng__Account__r.FormaAnagrafica__c == 'CONDOMINIO' || invoiceToVerify.blng__Account__r.FormaAnagrafica__c == 'CONDOMINIA')
              ){
                if(String.isEmpty(invoiceToVerify.blng__Account__r.FiscalCode__c)){
                   errorMsg += customErr2[4]+';' +'\n';
                   isError =  true; 
                }
            }
            //5 --Se blng__Account__r.IsPersonAccount == false && blng__Account__r.Nation__c == "IT" && blng__Account__r.FormaAnagrafica__c != ‘CONDOMINIO’ && blng__Account__r.FormaAnagrafica__c != ‘CONDOMINIA’
			if(!invoiceToVerify.blng__Account__r.IsPersonAccount 
               && (invoiceToVerify.blng__Account__r.FormaAnagrafica__c != 'CONDOMINIO' || invoiceToVerify.blng__Account__r.FormaAnagrafica__c != 'CONDOMINIA')
              ){
                if(String.isEmpty(invoiceToVerify.blng__Account__r.VatNumber__c)){
                   errorMsg += customErr2[5]+';' +'\n';
                   isError =  true; 
                }
            }
        }
        
        //6- Il campo blng__TotalAmount__c deve essere positivo
        if(invoiceToVerify.blng__TotalAmount__c < 0){
            errorMsg += Label.TotalAmount_deve_essere_positivo +';' +'\n';
            isError =  true;
        }
        
        //7 -I seguenti campi devono essere valorizzati con uno dei valori previsti dal campo Nation__c dell’oggetto Account:
		List<String> pickListValuesList= new List<String>();
		Schema.DescribeFieldResult fieldResult = Account.Nation__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
			pickListValuesList.add(pickListVal.getLabel());
		} 
        
        if(!String.isEmpty(invoiceToVerify.BillingProfile__r.BillingAddress__r.Country__c)
           && pickListValuesList.contains(invoiceToVerify.BillingProfile__r.BillingAddress__r.Country__c)){
           }else{
               errorMsg += Label.Billing_Profile_Billing_Address_Country +';' +'\n';
               isError =  true;
           }
        if(!String.isEmpty(invoiceToVerify.blng__Account__r.CustomerAddress__r.Country__c)
           && pickListValuesList.contains(invoiceToVerify.blng__Account__r.CustomerAddress__r.Country__c)){
           }else{
               errorMsg += Label.Account_Customer_Address_Country +';' +'\n';
               isError =  true;
           }
        
        //8 - Se BillingProfile__r.PaymentMethod__r.blng__PaymentType__c == ‘1’
        if(invoiceToVerify.BillingProfile__r.PaymentMethod__r.blng__PaymentType__c == '1'){
            if(String.isEmpty(invoiceToVerify.BillingProfile__r.PaymentMethod__r.MandateCode__c)){
                errorMsg += customErr3[0]+';' +'\n';
                isError =  true;
            }
        }
        
        //9 - Se BillingProfile__r.PaymentMethod__r.blng__PaymentType__c == ‘2’ i seguenti campi devono essere popolati:
        if(invoiceToVerify.BillingProfile__r.PaymentMethod__r.blng__PaymentType__c == '2'){
            if(String.isEmpty(invoiceToVerify.BillingProfile__r.Bank__c)){
                errorMsg += customErr3[1]+';' +'\n';
                isError =  true;
            }
            if(String.isEmpty(invoiceToVerify.BillingProfile__r.IBANBank__c)){
                errorMsg += customErr3[2]+';' +'\n';
                isError =  true;
            }
            if(String.isEmpty(invoiceToVerify.BillingProfile__r.SwiftCodeBank__c)){
                errorMsg += customErr3[3]+';' +'\n';
                isError =  true;
            }
        }
        
        List<blng__InvoiceLine__c> invoiceLineToVerify = [SELECT Id,Name,blng__TaxStatus__c,blng__TaxPercentageApplied__c,
                                                          		NaturaSDI__c
                                                         FROM blng__InvoiceLine__c 
                                                         WHERE blng__Invoice__c = :invoiceIds[0]];
        
        
        Boolean taxStatusCompleted = true;
        for(blng__InvoiceLine__c inL : invoiceLineToVerify){
            //10 - Ogni Invoice Line deve avere il campo blng__TaxStatus__c == ‘Completed’
            if(taxStatusCompleted && inL.blng__TaxStatus__c != 'Completed'){
                taxStatusCompleted = false;
            }
            //11 -  Ogni Invoice Line, se ha il campo blng__TaxPercentageApplied__c == 0, allora il campo NaturaSDI__c deve essere popolato
            if(inL.blng__TaxPercentageApplied__c == 0){
                if(String.isEmpty(inL.NaturaSDI__c)){
                    errorMsg += customErr4[1]+' - '+inL.Name +' ;' +'\n';
                    isError =  true;
                }
            }
        }
        if(!taxStatusCompleted){//10 - Ogni Invoice Line deve avere il campo blng__TaxStatus__c == ‘Completed’
            errorMsg += customErr4[0]+';' +'\n';
            isError =  true;
        }
        if(invoiceLineToVerify.size()==0){//13 -- La Invoice deve avere almeno una Invoice Line.
            errorMsg += customErr4[2]+';' +'\n';
            isError =  true;
        }
        //12 Il campo EstimatedTax__c (*) deve essere uguale al campo blng__TaxAmount__c.
        if(invoiceToVerify.EstimatedTaxAmount__c != invoiceToVerify.blng__TaxAmount__c){
            errorMsg += Label.TaxAmount+';' +'\n';
            isError =  true;
        }
        
        if(isError){
            invoiceToVerify.InvoiceValidationStatus__c = 'Error';
            invoiceToVerify.InvoiceValidationResult__c  = errorMsg;
        }else{
            invoiceToVerify.InvoiceValidationStatus__c = 'Success';
        }
        
        update invoiceToVerify;
        
    }

}