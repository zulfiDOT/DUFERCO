/*
 *   @TestClass: ConversioneLeadTest
*/
public without sharing class ConversioneLead 
{
    @AuraEnabled(cacheable=true) 
    public static Settings__c getCustomSettings()
    {
        return Settings__c.getOrgDefaults();
    }

    @AuraEnabled
    public static lead GetLead(string recordId) 
    {
        lead lid = new lead();

        /**
            * @description: esegue una query includendo in automatico tutti i campi dell'oggetto
            * @return: lista di risultati di tipo "sObject" generico. È possibile fare il cast del risulta in una lista dell'oggetto specifico
            */ 
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get('Lead').getDescribe().fields.getMap();
        list<string> list_field = new list<string>(fieldMap.keyset());
    
        string qrSelect = 'select '+string.join(list_field , ',');//SELECT con tutti i campi dell'oggetto
        string qrFrom = ' from '+'Lead';//FROM oggetto
        string qrWhere = ' where id = :recordId'; //WHERE filtri query
        string qrOrder = ' order by '; //ORDER BY ordinamento risultati query
        
        //creo una variabile di tipo "Tipo lista<Oggetto>"
        System.Type listType = System.Type.forName('List<Lead>');
        //istanzio una lista vuota del tipo "listType", in modo da poter fare il cast di "result" nel tipo corretto al di fuori del metodo
        List<Lead> resultQuery = (List<Lead>)listType.newInstance();
    
        //aggiungere where/order se correttamente valorizzati nelle variabili
        //---(la lista funziona anche con un solo record: se non trova nulla non va in errore ma restituisce una lista vuota)---
        resultQuery = database.query(qrSelect + qrFrom + qrWhere /*+ qrOrder*/);
        System.debug('result '+resultQuery);
        if(resultQuery.size() > 0 && resultQuery.size() <= 1)
        {
            lid = resultQuery[0];
        }
        else 
        {
            throw new AuraHandledException('Si è verificato un errore');
        }
    
        return lid;
    }
    
    @AuraEnabled
    public static string CheckDataLead(lead lid)
    {
        try 
        {
            string result = 'Non è possibile procedere con la conversione del Lead in quanto non sono compilati correttamente i seguenti campi: ';
            System.debug('lid '+lid);
            
            
            if(lid.Company != null && lid.VatNumber__c == null) {
				result += Lead.Company.getDescribe().getLabel()+', ';
				result += Lead.VatNumber__c.getDescribe().getLabel()+', ';
			}
			else if(lid.Company == null && lid.FiscalCode__c == null) {
				result += Lead.Company.getDescribe().getLabel()+', ';
				result += Lead.FiscalCode__c.getDescribe().getLabel()+', ';
			}
			else if(lid.FirstName == null) {
				result += Lead.FirstName.getDescribe().getLabel()+', ';
			}
			else if( lid.LastName == null) {
				result += Lead.LastName.getDescribe().getLabel()+', ';
			}
			else if(lid.Email == null) {
				result += Lead.Email.getDescribe().getLabel()+', ';
			}
			else if(lid.Nation__c == null) {
				result += Lead.Nation__c.getDescribe().getLabel()+', ';
			}
			else if(lid.Company__c == null) {
				result += Lead.Company__c.getDescribe().getLabel()+', ';
			}
			
		   
            else 
            {
               return result = 'OK';
            }
            result = result.removeEnd(', ');
            return result + '.';
        }
        catch (Exception e) 
        {
            throw new AuraHandledException(e.getMessage());
        }
    }
	

    @AuraEnabled
    public static Account checkAccount(lead lid)
    {
        string result = '';
        String RecordTypeDeveloperName = '';
        Account acc;
        Settings__c sett = Settings__c.getOrgDefaults();

        if(lid.Company==null) RecordTypeDeveloperName = 'PersonAccount'; 
        if(lid.Company<>null) RecordTypeDeveloperName = 'Business';
        /*AND
        Nation__c = Nation__c
        AND (
        Email__c = Email
        OR
        FiscalCode__c = FiscalCode__c
        OR
        VatNumber__c = VatNumber__c*/
        String Nation = lid.Nation__c;
        String Email = lid.Email;
        String FiscalCode = lid.FiscalCode__c;
        String VatNumber = lid.VatNumber__c;
        System.debug(Email);
        System.debug(FiscalCode);
        System.debug(VatNumber);
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get('Account').getDescribe().fields.getMap();
        list<string> list_field = new list<string>(fieldMap.keyset());
    
        string qrSelect = 'select '+string.join(list_field , ',') +', RecordType.DeveloperName, recordType.Name,'+
                            'toLabel(Nation__c)Nazione, toLabel(Company__c)Company';//SELECT con tutti i campi dell'oggetto
        string qrFrom = ' from Account';//FROM oggetto
        string qrWhere = ' where RecordType.DeveloperName = :RecordTypeDeveloperName AND '+ 
                            'Nation__c = :Nation AND '+
                            ((Email != null)?((lid.Company == null)?'(PersonEmail  = :Email ': '(Email__c = :Email ') : '(')+
                            ((FiscalCode != null)?'OR FiscalCode__c = :FiscalCode ': '')+
                            ((VatNumber != null)?'OR VatNumber__c = :VatNumber)': ')'); //WHERE filtri query
        System.debug(qrWhere);
        string qrOrder = ' order by '; //ORDER BY ordinamento risultati query
        
        //creo una variabile di tipo "Tipo lista<Oggetto>"
        System.Type listType = System.Type.forName('List<Account>');
        //istanzio una lista vuota del tipo "listType", in modo da poter fare il cast di "result" nel tipo corretto al di fuori del metodo
        List<Account> resultQuery = (List<Account>)listType.newInstance();
    
        //aggiungere where/order se correttamente valorizzati nelle variabili
        //---(la lista funziona anche con un solo record: se non trova nulla non va in errore ma restituisce una lista vuota)---
        resultQuery = database.query(qrSelect + qrFrom + qrWhere /*+ qrOrder*/);
        System.debug('resutl '+resultQuery);

        if(resultQuery.size() > 0)
        {
            acc = resultQuery[0];
        }

        return acc;
    }

    @AuraEnabled
    public static string ConvertLead(string accountId, lead lid)
    {
        string result = '';

        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(lid.id);

        LeadStatus convertStatus = [SELECT Id, apiname  FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.apiname );

        lc.setAccountId(accountId);
        /*if(lid.Company == null)
        {
            lc.setRelatedPersonAccountId(accountId);
        }*/
        lc.setDoNotCreateOpportunity(false);

        //One or more leads couldn't be converted. Specify an account if relatedPersonAccountId is not null.

        if(!Test.IsRunningTest())Database.LeadConvertResult lcr = Database.convertLead(lc);
        return result;
    }
}