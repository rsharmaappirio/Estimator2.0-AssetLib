/**=====================================================================
 * Appirio, Inc
 * Name: E2_BatchUpdateUltimateParentScope
 * Description: Batch class to update Ultimate Parent on Scope. This class will run once
                and update Ultimate Parent on all the existing Scope records where Parent is not null
 * Created Date: August 9th, 2016
 * Created By: Arpita Bose (Appirio)
 * 
 * Date Modified      Modified By                  Description of the update
 *  
*  =====================================================================*/
global class E2_BatchUpdateUltimateParentScope implements  Database.Batchable<sObject>, Database.Stateful {

  // Start method
  global Database.QueryLocator start(Database.BatchableContext BC){
    //query all scopes where Parent Scope is not null
    String query = '';
    query = 'SELECT Id, Ultimate_Parent_Id__c, Ultimate_Parent_Scope__c '+                         
            'FROM E2_Scope__c '+ 
            'WHERE Parent_Scope__c != null';
   
    return Database.getQueryLocator(query);
  }

  // Execute method
  global void execute(Database.BatchableContext BC, List<sObject> scope) {
    List<E2_Scope__c> scopeLstToUpdate = new List<E2_Scope__c>();
    //assign Ultimate Parent Id if it's not null, to ultimate Parent Scope
    for(E2_Scope__c sc : (List<E2_Scope__c>)scope){
      if(!string.isBlank(sc.Ultimate_Parent_Id__c)) {
          sc.Ultimate_Parent_Scope__c = sc.Ultimate_Parent_Id__c;
          scopeLstToUpdate.add(sc);
      }
    }
     //update scopes
     if(!scopeLstToUpdate.isEmpty()){
         update scopeLstToUpdate;
     }
  }

  // Finish method
  global void finish(Database.BatchableContext BC) {
    
  }
}