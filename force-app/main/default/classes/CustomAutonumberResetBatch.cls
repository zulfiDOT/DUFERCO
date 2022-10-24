global class CustomAutonumberResetBatch implements Database.Batchable<sObject> {
    
    // The batch job starts
    global Database.Querylocator start(Database.BatchableContext bc){
      List<String> listOfAreas = new List<String>{'MO'} ;//add here more areas to reset
      String query = 'SELECT id, Name, Last_Autonumber__c, ProgressiveNumber__c FROM CustomAutonumber__c WHERE Name IN : listOfAreas';
      System.debug('>>>> start ' + query);
      return Database.getQuerylocator(query);
    } 
    
    // The batch job executes and operates on one batch of records
    global void execute(Database.BatchableContext bc, List<CustomAutonumber__c> scope){
      System.debug('>>>> execute ' + scope.size());
      for(CustomAutonumber__c singleAutonumber : scope){
          //check on name?
          singleAutonumber.Last_Autonumber__c = String.valueOf(0).leftPad(8,'0');
          singleAutonumber.ProgressiveNumber__c = 0;
      }
      update scope;
    }
    
    // The batch job finishes
    global void finish(Database.BatchableContext bc){
      AsyncApexJob job = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :bc.getJobId()]; 
      System.debug('>>>> finish ' + job.Status);
    }
}