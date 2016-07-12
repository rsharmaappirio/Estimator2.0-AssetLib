@isTest(seeAllData=false)
public class E2_DataUtil_WSTest {
  
  public static E2_Scope__c scopeTemplate, favScope;
    public static E2_Scope__c childScope;
    public static CMC_Presales_LOE__c estimate;
    public static Id rtTemplateId = E2_RecordTypeClass.getId('E2_Scope__c', E2_Constants.SCOPE_RT_TEMPLATE);
    public static Id rtScopeId = E2_RecordTypeClass.getId('E2_Scope__c', E2_Constants.SCOPE_RT_SCOPE);
    public static E2_Scope_Group__c scopeGroup;
    public static E2_Derived_Effort_Group__c derEffGroup;
    public static List<E2_Derived_Effort__c> derivedEfforts;
    public static E2_Capacity__c capacity;
      
  public static testmethod void testE2_TreeNode() {
    User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
    
    Presales_Request__c psr = [SELECT Id FROM Presales_Request__c];
    estimate = [SELECT Id FROM CMC_Presales_LOE__c];
    scopeTemplate = [SELECT Id FROM E2_Scope__c WHERE RecordTypeId = :rtTemplateId];
    favScope = [SELECT Id FROM E2_Scope__c WHERE RecordTypeId = :rtScopeId AND Parent_Scope__c = null];
    childScope = [SELECT Id FROM E2_Scope__c WHERE RecordTypeId = :rtScopeId AND Parent_Scope__c != null];
    scopeGroup = [SELECT Id FROM E2_Scope_Group__c];
    derEffGroup = [SELECT Id FROM E2_Derived_Effort_Group__c];
    derivedEfforts = [SELECT Id FROM E2_Derived_Effort__c ];
    capacity = [SELECT ID FROM E2_Capacity__c];
    
    System.runAs(sysAdmin){
        Test.startTest();         
          system.assertEquals(E2_dataUtil_WS.getEstimates(estimate.Id).size(), 1);
          system.assertEquals(E2_DataUtil_WS.getScopesByParentScope(favScope.Id).size(), 1);
          system.assertEquals(E2_DataUtil_WS.getChildScopesOfEstimate(estimate.Id).size(), 2);
          system.assertEquals(E2_DataUtil_WS.getChildScopesOfScopeGroup(scopeGroup.Id).size(), 1);
          system.assertEquals(E2_DataUtil_WS.getScopeDetails(estimate.Id).size(), 1);
          system.assertEquals(E2_dataUtil_WS.getChildScopeByParentId(favScope.Id).size(), 1);
          system.assertEquals(E2_dataUtil_WS.getFullScopeDetails(favScope.Id).size(), 1);
          system.assertEquals(E2_DataUtil_WS.getFullScopeDetailsWithLimit(favScope.Id).size(), 1);
          system.assertEquals(E2_DataUtil_WS.getScopeChildList(favScope.Id).size(), 1); 
          
        Test.stopTest();
    }
   }
   
    @testSetup
    private static void createTestData(){
        Account acc = E2_Test_Utils.insertAccount(true);
        Opportunity opp = E2_Test_Utils.insertOpportunity(acc.Id, true);        
        Presales_Request__c psr = E2_Test_Utils.insertPresalesReq(opp.Id, 'Demo', true);
        estimate = E2_Test_Utils.insertEstimate(psr.Id, true);
        
        favScope = E2_Test_Utils.insertScope(false);
        favScope.Presales_LOE__c = estimate.Id;
        favScope.RecordTypeId = rtScopeId;
        favScope.Parent_Scope__c = null;
        favScope.Is_Favourite__c = true;
        favScope.Complexity__c = 'Medium';
        insert favScope;
        
        scopeGroup = E2_Test_Utils.insertScopeGroup(true);
        
        scopeTemplate = E2_Test_Utils.insertScope(false);
        scopeTemplate.RecordTypeId = rtTemplateId;
        scopeTemplate.Parent_Scope__c = null;
        scopeTemplate.Complexity__c = 'Medium';
        scopeTemplate.Scope_Group__c = scopeGroup.Id;
        insert scopeTemplate;
        
        derEffGroup = E2_Test_Utils.insertDerivedEffort(true);
        
        derivedEfforts = new List<E2_Derived_Effort__c>();
        Id devRecordTypeId = Schema.SObjectType.E2_Derived_Effort__c.getRecordTypeInfosByName().get('Template').getRecordTypeId();
        
        derivedEfforts.add(E2_Test_Utils.insertDerivedEffort('Project Manager', 'Build', 'Project Manager', 'Build', devRecordTypeId, derEffGroup.Id, false));
        derivedEfforts.add(E2_Test_Utils.insertDerivedEffort('Project Manager', 'Build', 'Project Manager', Null, devRecordTypeId, derEffGroup.Id, false));
        E2_Derived_Effort__c dE = E2_Test_Utils.insertDerivedEffort('Project Manager', 'Plan', 'Project Manager', 'Plan', devRecordTypeId, derEffGroup.Id, false);
        dE.Original_Allocation_Hours__c = 20;
        dE.UniqueKey__c = derivedEfforts.get(0).UniqueKey__c;
        derivedEfforts.add(dE);
        
        insert derivedEfforts;
        
        E2_Scope__c childSC = E2_Test_Utils.insertScope(false);
        childSC.Presales_LOE__c = estimate.Id;
        childSC.Parent_Scope__c = favScope.Id;
        childSC.Complexity__c = 'Medium';
        insert childSC;  
      
        E2_Effort__c effort1 = E2_Test_Utils.insertEffort(true, childSC.Id);
        
        capacity = new E2_Capacity__c();
        capacity.Estimator__c = estimate.Id;
        insert capacity;
        
        
    }

}