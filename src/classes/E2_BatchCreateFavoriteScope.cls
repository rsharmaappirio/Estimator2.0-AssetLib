/**=====================================================================
 * Appirio, Inc
 * Name: E2_BatchCreateFavoriteScope
 * Description: T-525253: Batch class to create E2_Favourite_Scope__c record for all the scopes 
                where Is_Favourite is true. This class will run only once to insert.
 * Created Date: August 9th, 2016
 * Created By: Arpita Bose (Appirio)
 * 
 * Date Modified      Modified By                  Description of the update
 *  
*  =====================================================================*/
global class E2_BatchCreateFavoriteScope implements  Database.Batchable<sObject>, Database.Stateful {
  
  // Start method
  global Database.QueryLocator start(Database.BatchableContext BC){
    //fetch all the scope records where Is_Favourite__c = true
    String query = '';
    query = 'SELECT Id, Name, Is_Favourite__c, CreatedById '+                       
                 'FROM E2_Scope__c '+ 
                 'WHERE Is_Favourite__c = true '+
                 ' ORDER By Name';
    return Database.getQueryLocator(query);
    
  }

  // Execute method
  global void execute(Database.BatchableContext BC, List<sObject> scope) {
    Set<Id> scopeIds = new Set<Id>();
    List<E2_Scope__c> scopeLst = new List<E2_Scope__c>();
    Map<String,E2_Favourite_Scope__c> favScopesMap = new Map<String,E2_Favourite_Scope__c>();
    List<E2_Favourite_Scope__c> favScopesToInsert = new List<E2_Favourite_Scope__c>();
    
    for(E2_Scope__c sc : (List<E2_Scope__c>)scope){
      scopeLst.add(sc);
      scopeIds.add(sc.Id);
    }
    
    // create a map of Favorite Scopes for all the above scopeIds( where Is_Favourite__c = true)
    for(E2_Favourite_Scope__c favSC : [SELECT Id, Scope__c, User__c, Unique_Scope_User_Id__c  
                                          FROM E2_Favourite_Scope__c 
                                          WHERE Scope__c IN:scopeIds] ){
      favScopesMap.put(favSC.Unique_Scope_User_Id__c, favSC);                                        
    }
    
    // insert Favorite Scopes if it's not exist in the above map for the scope list
    for(E2_Scope__c sc : scopeLst){
      String uniqueKey = sc.Id +'-'+ sc.CreatedById; 
      if(!favScopesMap.containsKey(uniqueKey)){
	      E2_Favourite_Scope__c newFavScope = new E2_Favourite_Scope__c();
	      newFavScope.Scope__c = sc.Id;
	      newFavScope.User__c = sc.CreatedById;
	      newFavScope.Unique_Scope_User_Id__c = uniqueKey;
	      favScopesToInsert.add(newFavScope);
      }  
    }
    //insert
    if(!favScopesToInsert.isEmpty()){
      insert favScopesToInsert;
    }
 
  }
  
  // Finish method
  global void finish(Database.BatchableContext BC) {
    
  }
}