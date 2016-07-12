@isTest(SeeAllData=false)
private class E2_AddNewScopeTemplateControllerTest {

    public static E2_Scope_Group__c scopeGrp;
  public static E2_Scope__c scope;
  public static List<E2_Effort__c> effortLst;  
  public static Id recTypeId = E2_RecordTypeClass.getId('E2_Scope__c', E2_Constants.SCOPE_RT_TEMPLATE);
  public static Presales_Request__c psr;
  
  public static testmethod void testViewScope(){
    scope = [SELECT Id FROM E2_Scope__c WHERE Parent_Scope__c = null];
    scopeGrp = [SELECT Id FROM E2_Scope_Group__c limit 1];
    effortLst = [SELECT Id FROM E2_Effort__c WHERE Scope__c = :scope.Id];
    
    //create sys admin user
    User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
    
    System.runAs(sysAdmin){
        //start test
        Test.startTest();    
        PageReference pageRef = Page.E2_AddNewScopeTemplate;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('scopegroup_id', scopeGrp.Id);
        ApexPages.currentPage().getParameters().put(E2_Constants.URL_KEY_IS_VIEW, 'true');
        ApexPages.StandardController stdController = new ApexPages.StandardController(scope);
        E2_AddNewScopeTemplateController controller = new E2_AddNewScopeTemplateController(stdController);
    
       
      controller.pageAction();
      system.assert(controller.is_View == true);
      ApexPages.currentPage().getParameters().remove('scopegroup_id');
      ApexPages.currentPage().getParameters().remove(E2_Constants.URL_KEY_IS_VIEW);
      
      ApexPages.currentPage().getParameters().put('scopegroup_id', scopeGrp.Id);
      ApexPages.currentPage().getParameters().put(E2_Constants.URL_KEY_IS_EDIT, 'true');
      stdController = new ApexPages.StandardController(scope);
      controller = new E2_AddNewScopeTemplateController(stdController); 
      controller.pageAction();
      system.assert(controller.is_Edit == true);
      
      System.assertEquals(controller.childScopes.size(), 1, '1 child scope should be added in list as master');     
      
      E2_AddNewScopeTemplateController.Scope scope_wrap = controller.childScopes[0];
      scope_wrap.addNewEffort();
      scope_wrap.addNewEffort();
      for(E2_AddNewScopeTemplateController.Effort eff: scope_wrap.efforts){
            
          eff.effort.Is_Active__c = true;
          eff.effort.Effort_Hrs__c = 40;
          eff.effort.Phase__c = 'Build';
          eff.effort.Resource_Role__c = 'Project Manager';
          eff.effort.Complexity_Factor_High__c = 10;
          eff.effort.Complexity_Factor_Low__c = 10;
             
      }  
      System.assertEquals(scope_wrap.getEffortsSize(), 120, 'scope cumulative efforts size should match'); 
      scope_wrap.reload();
      scope_wrap.changeComplexity(); 
        
      controller.saveScope();  
      Set<Id>  childScopeIds = new Set<Id>();                
        for(E2_Scope__c scope4 : E2_DataUtil.getScopeRecordsWithChildRecords(scope.id)){
                for(E2_Scope__c childScope : scope4.Child_Scopes__r){
                     childScopeIds.add(childScope.id);
                }
        }
        
      List<E2_Scope__c> scopeList = E2_DataUtil.getScopeRecordsWithChildForChildScopeIds(childScopeIds);
      System.assertEquals(scopeList[0].Efforts__r.size(), 3, '3 efforts should saved/updated');
      
      for(E2_AddNewScopeTemplateController.Effort eff: scope_wrap.efforts){
         eff.remove();    
      }         
      controller.saveScope();     
      scopeList = E2_DataUtil.getScopeAndChildrenOnScopeIdForEditScope(scope.id);
      System.assertEquals(scopeList[0].Efforts__r.size(), 0, 'all efforts should removed');
         
      controller.addNewScope();
      
      System.assertEquals(controller.childScopes.size(), 2, '1 more child scope should be added in list'); 
        
      for( E2_AddNewScopeTemplateController.Scope scope_wrap1 : controller.childScopes)  {
            scope_wrap1.remove();
      }
        
      controller.saveScope();     
      System.assertEquals([SELECT Id FROM E2_Scope__c WHERE Parent_Scope__c != null].size(), 0, 'both scopes should have been removed');
        

    //stop test
    Test.stopTest(); 
    } 
  }
  
  
  public static testmethod void testAddNewScope(){
    scopeGrp = [SELECT Id FROM E2_Scope_Group__c limit 1];
    psr = [SELECT Id FROM Presales_Request__c];
    
    E2_Scope__c scope1 = E2_Test_Utils.insertScope(false);
    scope1.Scope_Group__c = scopeGrp.Id;
    //create sys admin user
    User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
    
    System.runAs(sysAdmin){
    //start test
    Test.startTest();
      PageReference pageRef = Page.E2_AddNewScopeTemplate;
      Test.setCurrentPage(pageRef);
      ApexPages.currentPage().getParameters().put('scopegroup_id', scopeGrp.Id);
    
      ApexPages.StandardController stdController = new ApexPages.StandardController(scope1);
      E2_AddNewScopeTemplateController controller = new E2_AddNewScopeTemplateController(stdController);
    
      controller.pageAction();
      system.assert(controller.is_New == true);
      
      
      controller.addNewScope();      
      controller.saveScope();  

      ApexPages.currentPage().getParameters().remove('scopegroup_id');
      ApexPages.currentPage().getParameters().remove(E2_Constants.URL_KEY_IS_VIEW);
      
      
      E2_Scope__c pscope1 =  E2_Test_Utils.insertScope(false);
      pscope1.recordTypeId = recTypeId;
      pscope1.Scope_Group__c = scopeGrp.Id;  
      insert pscope1;
    
      
      E2_Scope__c childSC = E2_Test_Utils.insertScope(false);
      childSC.Scope_Group__c = scopeGrp.Id;
      childSC.Parent_Scope__c = pscope1.Id;
      childSC.recordTypeId = recTypeId;
      childSC.Complexity__c = 'Medium';
      insert childSC;  
      
      E2_Effort__c effort1 = E2_Test_Utils.insertEffort(true, childSC.Id);  
      
      ApexPages.currentPage().getParameters().put('scopegroup_id', scopeGrp.Id);
      ApexPages.currentPage().getParameters().put(E2_Constants.URL_KEY_IS_EDIT, 'true');
      stdController = new ApexPages.StandardController(pscope1);
      controller = new E2_AddNewScopeTemplateController(stdController); 
      controller.pageAction();
      system.assert(controller.is_Edit == true);      
      
      controller.childScopes.addAll(controller.childScopes);  
      System.assertEquals(controller.childScopes.size(), 2, '1 more child scope should be added in list'); 
      
      controller.saveScope();     
      System.assertEquals([SELECT Id FROM E2_Scope__c WHERE Parent_Scope__c =: pscope1.Id].size(), 1, 'both scopes should not have been removed');
      
      controller.childScopes.clear();  
      controller.pageAction();
      System.assertEquals(controller.childScopes.size(), 1, '1 child scope should be added in list'); 
      for( E2_AddNewScopeTemplateController.Scope scope_wrap : controller.childScopes)  {
         scope_wrap.efforts.addAll(scope_wrap.efforts);   
      } 
      controller.saveScope();  
      
    //stop test
    Test.stopTest();  
    }
  }
  
    static testmethod void processClipboardDataTest(){
        scopeGrp = [SELECT Id FROM E2_Scope_Group__c limit 1];
        
        E2_Scope__c scope1 = E2_Test_Utils.insertScope(false);
        scope1.Scope_Group__c = scopeGrp.Id;
        //create sys admin user
        User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
    
        System.runAs(sysAdmin){
            //start test
            Test.startTest();
              PageReference pageRef = Page.E2_AddNewScopeTemplate;
              Test.setCurrentPage(pageRef);
              ApexPages.currentPage().getParameters().put('scopegroup_id', scopeGrp.Id);
            
              ApexPages.StandardController stdController = new ApexPages.StandardController(scope1);
              E2_AddNewScopeTemplateController controller = new E2_AddNewScopeTemplateController(stdController);
            
              controller.pageAction();
              system.assert(controller.is_New == true);
              
              controller.clipboardData = '[ {"property1" : "", "property2" : "", "property3" : ""}]';
              controller.processClipboardData();
              
              System.assertEquals(controller.childScopes.size(), 1, 'should have 1 childscope added');
            
              Test.stopTest();
        }    
   }  
    
   //create test data
  @testSetup static void createTestData(){
    
    User solArchitect, accExecutive, delReviewer; 
    Account acc;
    Opportunity opp;
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
    
    scopeGrp = E2_Test_Utils.insertScopeGroup(true);
      
    scope1 =  E2_Test_Utils.insertScope(false);
    scope1.recordTypeId = recTypeId;
    scope1.Scope_Group__c = scopeGrp.id;  
    insert scope1;
    
      
    E2_Scope__c childSC = E2_Test_Utils.insertScope(false);
    childSC.Scope_Group__c = scopeGrp.Id;
    childSC.Parent_Scope__c = scope1.Id;
    childSC.recordTypeId = recTypeId;
    childSC.Complexity__c = 'Medium';
    insert childSC;  
      
    E2_Effort__c effort1 = E2_Test_Utils.insertEffort(true, childSC.Id);  
      
  }
}