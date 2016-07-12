@isTest(seeAllData=false)
public class E2_SelectScopeTemplateControllerTest {
  public static E2_Scope__c scopeTemplate, favScope;
  public static CMC_Presales_LOE__c estimate;
  public static Id rtTemplateId = E2_RecordTypeClass.getId('E2_Scope__c', E2_Constants.SCOPE_RT_TEMPLATE);
  public static Id rtScopeId = E2_RecordTypeClass.getId('E2_Scope__c', E2_Constants.SCOPE_RT_SCOPE);
  public static E2_Scope_Group__c scopeGroup;
  public static User sysAdmin;
  
  public static testmethod void testSelectScope1(){
    Profile p = [SELECT id from profile where name =: E2_Constants.PROFILE_SYS_ADMIN ];
    sysAdmin = new User();
    sysAdmin.Id = UserInfo.getUserId(); //E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
    sysAdmin.profileid = p.Id;
    update sysAdmin;
    
    scopeTemplate = [SELECT Id FROM E2_Scope__c WHERE RecordTypeId = :rtTemplateId];
    favScope = [SELECT Id FROM E2_Scope__c WHERE RecordTypeId = :rtScopeId];
    scopeGroup = [SELECT Id, Name FROM E2_Scope_Group__c];
    System.runAs(sysAdmin){
    Test.startTest();
      PageReference pageRef = Page.E2_AddNewScope;
      Test.setCurrentPage(pageRef);
      E2_SelectScopeTemplateController controller = new E2_SelectScopeTemplateController();
      controller.pageAction();
      controller.scopeName = null;
      controller.sortDirection = null;
      system.assertEquals(controller.scopeName, '');
      controller.scopeGroups = null;
      List<SelectOption> scopeGroups;
      system.assert(controller.scopeGroups.size() == 1);
      controller.selectedPageNumber = 3;
      //sort the result
      controller.sortExpression = null;
      controller.getSortDirection();
      system.assertEquals(controller.sortDirection, 'ByAsc');
      controller.sortDirection = 'ByAsc';
      system.assertEquals(controller.sortExpression, null);
      controller.sortList();
      controller.selectedCon = 1;
      controller.isTemplatePage = false;
      //asserts to get the result
      system.assertEquals(controller.scopeList.size(), 1, '1 Scope Template record not loaded');
      system.assertEquals(controller.favScopeList.size(), 1, '1 Scope record not loaded');
      //system.assertEquals(controller.conList.size(), 2, 'Scope records not in selection listd');
      //search by complexity
      controller.scopeName = '';
      controller.searchScopeRecords();
      controller.getList();
       controller.selectedCon = 1;
      controller.getList();
      //asserts to get the result
      system.assert(controller.scopeList.size() > 0);
      system.assert(controller.favScopeList.size() > 0);
      //sort the result
      controller.sortExpression = 'ByScopeName';
      controller.getSortDirection();
      controller.sortDirection = 'ByAsc';
      controller.sortList();
      
      //search by scope name
      controller.scopeName = 'Test Scope';
      controller.searchScopeRecords();
      
      controller.getList();
      system.assert(controller.scopeList.size() > 0);
      system.assert(controller.favScopeList.size() > 0); 
      
      //sort the result
      controller.sortExpression = 'ByComplexity';
      controller.sortExpression = 'ByComplexity';
      controller.sortDirection = 'ByAsc';
      controller.sortList();
      controller.sortExpression = 'ByGroup';
      controller.sortDirection = 'ByAsc';
      controller.sortList();
      controller.sortExpression = 'ByEfforts';
      controller.sortDirection = 'ByDesc';
      controller.sortList();
      
      controller.resetResults();

      Test.stopTest(); 
    }
      
     
  }

  
   @testSetup
  private static void createTestData(){
    Account acc = E2_Test_Utils.insertAccount(true);
    Opportunity opp = E2_Test_Utils.insertOpportunity(acc.Id, true);
    
    Presales_Request__c psr = E2_Test_Utils.insertPresalesReq(opp.Id, 'Demo', true);
    estimate = E2_Test_Utils.insertEstimate(psr.Id, true);
    
    scopeGroup = E2_Test_Utils.insertScopeGroup(true);
    
    scopeTemplate = E2_Test_Utils.insertScope(false);
    //scopeTemplate.Presales_LOE__c = estimate.Id;
    scopeTemplate.RecordTypeId = rtTemplateId;
    scopeTemplate.Parent_Scope__c = null;
    scopeTemplate.Complexity__c = 'Low';
    insert scopeTemplate;
    

    favScope = E2_Test_Utils.insertScope(false);
    favScope.Presales_LOE__c = estimate.Id;
    favScope.RecordTypeId = rtScopeId;
    favScope.Is_Favourite__c = true;
    favScope.Complexity__c = 'Medium';
    favScope.OwnerId = UserInfo.getUserId();
    favScope.Scope_Group__c = scopeGroup.Id;
    insert favScope;
    system.debug('====favScope>>' +favScope); 
    
    
  }

}