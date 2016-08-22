@isTest(seeAllData=false)
public class E2_BatchCreateFavoriteScopeTest {
  public static CMC_Presales_LOE__c estimate;
  public static Presales_Request__c psr;
  public static Id recTypeId1 = E2_RecordTypeClass.getId(E2_Constants.E2_SCOPE_API_NAME, E2_Constants.SCOPE_RT_SCOPE);
  public static List<E2_Scope__c> scopeLst;
  
  
  //
  public static testmethod void testBatch(){
    estimate = [SELECT Id FROM CMC_Presales_LOE__c]; 
    scopeLst = [SELECT Id FROM E2_Scope__c];
    User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
    
    System.runAs(sysAdmin){
	    //start test
	    Test.startTest();
	       E2_BatchCreateFavoriteScope batch = new E2_BatchCreateFavoriteScope();
         ID batchedprocessid = Database.executeBatch(batch);
	    
	    //stop test
	    Test.stopTest();
	    List<E2_Favourite_Scope__c> favScopes = [SELECT Id FROM E2_Favourite_Scope__c WHERE Scope__c IN :scopeLst];
	    system.assertEquals(favScopes.size(), 10, '10 Favourite Scope are created');
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
    
    scopeLst = new List<E2_Scope__c>();
    E2_Scope__c scope;
    
    for(integer i=1; i<=10; i++){  
	    scope =  E2_Test_Utils.insertScope(false);
	    scope.Name = 'Test Scope'+i;
	    scope.recordTypeId = recTypeId1;
	    scope.Presales_LOE__c = estimate.id;  
	    scope.Scope_Group__c = scopeGroup.id;
	    scope.Is_Favourite__c = true;
      scopeLst.add(scope);
    }
    
    for(integer i=1; i<=4; i++){
      scope =  E2_Test_Utils.insertScope(false);
      scope.Name = 'Test Scope'+i;
      scope.recordTypeId = recTypeId1;
      scope.Presales_LOE__c = estimate.id;  
      scope.Scope_Group__c = scopeGroup.id;
      scope.Is_Favourite__c = false;
      scopeLst.add(scope);
    }
    
    insert scopeLst;
    
    
    
  }

}