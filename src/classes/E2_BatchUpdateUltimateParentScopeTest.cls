@isTest(seeAllData=false)
public class E2_BatchUpdateUltimateParentScopeTest {
  public static E2_Scope__c scopeParent1, scopeParent2;
  public static CMC_Presales_LOE__c estimate;
  public static Presales_Request__c psr;
  public static Id recTypeId1 = E2_RecordTypeClass.getId(E2_Constants.E2_SCOPE_API_NAME, E2_Constants.SCOPE_RT_SCOPE);
  
  // test method for insert
  public static testmethod void testScopeUltimateParent(){
    estimate = [SELECT Id FROM CMC_Presales_LOE__c]; 
    scopeParent1 = [SELECT ID FROM E2_Scope__c WHERE Parent_Scope__c = null];     
    scopeParent2 = [SELECT ID FROM E2_Scope__c WHERE Parent_Scope__c = :scopeParent1.Id];      
       
    User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
    psr =  [SELECT Id, Description__c, Name,Account_Name__c, Opportunity__r.Account.Id,Opportunity__c 
              FROM Presales_Request__c];
    
    E2_Scope__c scope =  E2_Test_Utils.insertScope(false);
    scope.recordTypeId = recTypeId1;
    scope.Presales_LOE__c = estimate.id;  
    scope.Parent_Scope__c = scopeParent2.Id;
    insert scope; 
       
    System.runAs(sysAdmin){
      //start test
      Test.startTest();
        E2_BatchUpdateUltimateParentScope batch = new E2_BatchUpdateUltimateParentScope();
        ID batchedprocessid = Database.executeBatch(batch);

      //stop test
      Test.stopTest();  
      
      E2_Scope__c resultScope = [SELECT Id, Ultimate_Parent_Scope__c, Ultimate_Parent_Id__c 
                                   From E2_Scope__c WHERE Id =: scope.Id];
      system.assertEquals(resultScope.Ultimate_Parent_Scope__c, scopeParent1.Id);                             
    }    
  }
  
  //create test data
  @testSetup 
  public static void createTestData(){
    Account acc;
    Opportunity opp;
          
    acc = E2_Test_Utils.insertAccount(true);
    opp = E2_Test_Utils.insertOpportunity(acc.Id, true);
    
    psr = E2_Test_Utils.insertPresalesReq(opp.Id, 'Demo', false);
    insert psr;
    
    estimate = E2_Test_Utils.insertEstimate(psr.id, false);  
    insert estimate;
    
    E2_Scope_Group__c scopeGroup = E2_Test_Utils.insertScopeGroup(true);  
      
    scopeParent1 =  E2_Test_Utils.insertScope(false);
    scopeParent1.recordTypeId = recTypeId1;
    scopeParent1.Presales_LOE__c = estimate.id;  
    scopeParent1.Scope_Group__c = scopeGroup.id;
    insert scopeParent1;
    
    scopeParent2 =  E2_Test_Utils.insertScope(false);
    scopeParent2.recordTypeId = recTypeId1;
    scopeParent2.Presales_LOE__c = estimate.id;  
    scopeParent2.Scope_Group__c = scopeGroup.id;
    scopeParent2.Parent_Scope__c = scopeParent1.Id;
    insert scopeParent2;
    
  }
}