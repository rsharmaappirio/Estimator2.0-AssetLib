@isTest(seeAllData=false)
public class E2_EditScopeControllerTest {
  public static E2_Scope__c scope;
  public static CMC_Presales_LOE__c estimate;
  public static List<E2_Effort__c> effortLst;  
  public static Id recTypeId1 = E2_RecordTypeClass.getId('E2_Scope__c', E2_Constants.SCOPE_RT_SCOPE);
  
   public static testmethod void testForNoScope(){
    estimate = [SELECT Id FROM CMC_Presales_LOE__c]; 
    User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
    
    System.runAs(sysAdmin){
        //start test
        Test.startTest();
          E2_Scope__c scope1 = E2_Test_Utils.insertScope(false);
          PageReference pageRef = Page.E2_EditScope;
          Test.setCurrentPage(pageRef);
          ApexPages.currentPage().getParameters().put(E2_Constants.URL_KEY_ESTIMATE_ID, estimate.Id);
        
          ApexPages.StandardController stdController = new ApexPages.StandardController(scope1);
          E2_EditScopeController controller = new E2_EditScopeController(stdController);
        
          controller.pageAction();
          boolean b = false;
          if (controller.errorMessage.contains('No scope defined to edit!!!') ){ 
                b = true;
          }
          system.assertEquals(b, true, 'Should return true when no scope defined');
        
        //stop test
        Test.stopTest();  
    }
  }    
  
  public static testmethod void testEditScope(){
    scope = [SELECT Id FROM E2_Scope__c];
    estimate = [SELECT Id FROM CMC_Presales_LOE__c];
    effortLst = [SELECT Id FROM E2_Effort__c WHERE Scope__c = :scope.Id];
   
    User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
    
    E2_Scope__c source_scope =  E2_Test_Utils.insertScope(false);
    source_scope.recordTypeId = recTypeId1;
    source_scope.Presales_LOE__c = estimate.id;  
    insert source_scope;
    
    scope.Source_Scope__c = source_scope.Id;
    update scope;
      
    System.runAs(sysAdmin){
    
    //start test
    Test.startTest();
      PageReference pageRef = Page.E2_EditScope;
      Test.setCurrentPage(pageRef);
      ApexPages.currentPage().getParameters().put(E2_Constants.URL_KEY_ESTIMATE_ID, estimate.Id);
    
      ApexPages.StandardController stdController = new ApexPages.StandardController(scope);
      E2_EditScopeController controller = new E2_EditScopeController(stdController);
    
      controller.pageAction();
      System.assertEquals(controller.childScopes.size(), 1, '1 child scope should be added in list as master');     
      
      E2_EditScopeController.Scope scope_wrap = controller.childScopes[0];
      scope_wrap.addNewEffort();
      scope_wrap.addNewEffort();
      scope_wrap.hasClonedEfforts = true;
      for(E2_EditScopeController.Effort eff: scope_wrap.efforts){
            
          eff.effort.Is_Active__c = true;
          eff.effort.Effort_Hrs__c = 40;
          eff.effort.Phase__c = 'Build';
          eff.effort.Resource_Role__c = 'Project Manager';
          eff.effort.Complexity_Factor_High__c = 10;
          eff.effort.Complexity_Factor_Low__c = 10;
             
      }  
      System.assertEquals(scope_wrap.getEffortsSize(), 80, 'scope cumulative efforts size should match'); 
      scope_wrap.reload();
      scope_wrap.changeComplexity();  
        
      controller.saveScope();     
      List<E2_Scope__c> scopeList = E2_DataUtil.getScopeAndChildrenOnScopeIdForEditScope(scope.id);
      System.assertEquals(scopeList[0].Efforts__r.size(), 2, '2 efforts should saved');
      
      for(E2_EditScopeController.Effort eff: scope_wrap.efforts){
         eff.remove();    
      }         
      controller.saveScope();     
      scopeList = E2_DataUtil.getScopeAndChildrenOnScopeIdForEditScope(scope.id);
      System.assertEquals(scopeList[0].Efforts__r.size(), 0, 'both efforts should removed');
        
      scope_wrap.remove();
        
      controller.getEffortsInstanceList();
        
    //stop test
    Test.stopTest();  
    }
  }
  
  public static testmethod void testEditScope2(){
    
      
    scope = [SELECT Id FROM E2_Scope__c];
    estimate = [SELECT Id FROM CMC_Presales_LOE__c];
    effortLst = [SELECT Id FROM E2_Effort__c WHERE Scope__c = :scope.Id];
    User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
    
    E2_Scope__c scope1 =  E2_Test_Utils.insertScope(false);
    scope1.recordTypeId = recTypeId1;
    scope1.Presales_LOE__c = estimate.id;  
    insert scope1;  
      
    System.runAs(sysAdmin){
    //start test
    Test.startTest();
      PageReference pageRef = Page.E2_EditScope;
      Test.setCurrentPage(pageRef);
      ApexPages.currentPage().getParameters().put(E2_Constants.URL_KEY_ESTIMATE_ID, estimate.Id);
    
      ApexPages.StandardController stdController = new ApexPages.StandardController(scope);
      E2_EditScopeController controller = new E2_EditScopeController(stdController);
    
      controller.pageAction();
      System.assertEquals(controller.childScopes.size(), 1, '1 child scope should be added in list'); 
      for(E2_Scope__c sc : E2_DataUtil.getScopeAndChildrenOnScopeIdForEditScope(scope1.id)){
            controller.childScopes.add(new E2_EditScopeController.Scope(sc, sc.Efforts__r));            
      }  
      System.assertEquals(controller.childScopes.size(), 2, '1 more child scope should be added in list'); 
        
        for( E2_EditScopeController.Scope scope_wrap : controller.childScopes)  {
            scope_wrap.remove();
        }
        
      controller.saveScope();     
      System.assertEquals([SELECT Id FROM E2_Scope__c].size(), 0, 'both scopes should have been removed');
      
     
       
    //stop test
    Test.stopTest(); 
    } 
  }
  
  public static testmethod void testEditScope3(){
    
      
    scope = [SELECT Id FROM E2_Scope__c];
    estimate = [SELECT Id FROM CMC_Presales_LOE__c];
    effortLst = [SELECT Id FROM E2_Effort__c WHERE Scope__c = :scope.Id];
    User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
    
    E2_Scope__c scope1 =  E2_Test_Utils.insertScope(false);
    scope1.recordTypeId = recTypeId1;
    scope1.Presales_LOE__c = estimate.id;  
    insert scope1;  
    
    E2_Effort__c source_effort = E2_Test_Utils.insertEffort(true, scope.Id);
    
    E2_Effort__c effort1 = E2_Test_Utils.insertEffort(false, scope.Id);
    E2_Effort__c effort2 = E2_Test_Utils.insertEffort(false, scope1.Id);
    effort2.Source_Effort__c = source_effort.Id;
    List<E2_Effort__c> effortLst1 = new List<E2_Effort__c>();
    effortLst1.add(effort1);
    effortLst1.add(effort2);
    insert effortLst1;  
      
    System.runAs(sysAdmin){
    //start test
    Test.startTest();
      PageReference pageRef = Page.E2_EditScope;
      Test.setCurrentPage(pageRef);
      ApexPages.currentPage().getParameters().put(E2_Constants.URL_KEY_ESTIMATE_ID, estimate.Id);
    
      ApexPages.StandardController stdController = new ApexPages.StandardController(scope);
      E2_EditScopeController controller = new E2_EditScopeController(stdController);
    
      controller.pageAction();
      System.assertEquals(controller.childScopes.size(), 1, '1 child scope should be added in list'); 
      for(E2_Scope__c sc : E2_DataUtil.getScopeAndChildrenOnScopeIdForEditScope(scope1.id)){
            controller.childScopes.add(new E2_EditScopeController.Scope(sc, sc.Efforts__r));            
      }  
      System.assertEquals(controller.childScopes.size(), 2, '1 more child scope should be added in list'); 
      controller.childScopes.addAll(controller.childScopes);  
      System.assertEquals(controller.childScopes.size(), 4, '1 more child scope should be added in list'); 
               
      controller.saveScope();     
      System.assertEquals([SELECT Id FROM E2_Scope__c].size(), 2, 'both scopes should not have been removed');
      
      controller.childScopes.clear();  
      controller.pageAction();
      System.assertEquals(controller.childScopes.size(), 1, '1 child scope should be added in list'); 
      for( E2_EditScopeController.Scope scope_wrap : controller.childScopes)  {
         scope_wrap.efforts.addAll(scope_wrap.efforts);   
      } 
      controller.saveScope();  

       
    //stop test
    Test.stopTest(); 
    } 
  }  
    
  //create test data
  @testSetup static void createTestData(){
    
    User solArchitect, accExecutive, delReviewer; 
    Account acc;
    Opportunity opp;
    Presales_Request__c psr;
    E2_Scope__c scope1; 
      
    acc = E2_Test_Utils.insertAccount(true);
    opp = E2_Test_Utils.insertOpportunity(acc.Id, true);
    
    solArchitect = E2_Test_Utils.insertSysAdminUser(false);
    solArchitect.firstName = 'Test SA';
    insert solArchitect;
    
    accExecutive = E2_Test_Utils.insertSysAdminUser(false);
    accExecutive.firstName = 'Test AE';
    insert accExecutive;
    
    delReviewer = E2_Test_Utils.insertSysAdminUser(false);
    delReviewer.firstName = 'Test Reviewer';
    insert delReviewer;
    
    psr = E2_Test_Utils.insertPresalesReq(opp.Id, 'Demo', false);
    insert psr;
    
    CMC_Presales_LOE__c estimate1 = E2_Test_Utils.insertEstimate(psr.id, false);  
    insert estimate1;
      
    scope1 =  E2_Test_Utils.insertScope(false);
    scope1.recordTypeId = recTypeId1;
    scope1.Presales_LOE__c = estimate1.id;  
    insert scope1;

  }

}