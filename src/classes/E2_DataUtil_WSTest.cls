/**=====================================================================
 * Appirio, Inc
 * Name: E2_DataUtil_WSTest
 * Description: Include all test nethod to perform unit test over E2_DataUtil_WS class 
 * Created Date: Apr 22th, 2016
 * Created By: Rohit Sharma (Appirio)
 * 
 * Date Modified      Modified By                  Description of the update
 * Nov 22, 2016       Jitendra Jangid              Added new test methods(testGetChildScopesById(),testGetUltimateScopeLOE(),testGetParentScopeIds(),testGetAnswersDetails(),testGetFullScopesDetailsWithLimit() ) to increase test coverage
 * Nov 24, 2016       Jitendra Jangid              Moved all SOQL queries inside Start and Stop test block for all test methods.
*  =====================================================================*/

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
    public static E2_Recommended_Asset__c recommendedAsset;
      
    public static testmethod void testGetChildScopesById(){
       User sysAdmin= getSysAdmin();
       
       system.runAs(sysAdmin){
           Test.startTest();
       
           List<E2_Scope__c> lsScope=[Select ID FROM E2_Scope__c WHERE RecordTypeId = :rtScopeId];
           Set<ID> setScopeID=new Set<ID>();
           for(E2_Scope__c scope:lsScope){
               setScopeID.add(scope.ID);
           }
           
           lsScope=E2_dataUtil_WS.getChildScopesById(setScopeID);
           System.assertEquals(2, lsScope.size());
           
           Test.stopTest();
       }
       
        
    }  
      
      
    public static testmethod void testGetUltimateScopeLOE(){
        User sysAdmin= getSysAdmin();
        
        system.runAs(sysAdmin){
           Test.startTest();
           
           E2_Scope__c parentScope=[Select id FROM E2_Scope__c WHERE Parent_Scope__c = null AND RecordTypeId = :rtScopeId ];
           String scopeID=parentScope.id;
           
           List<E2_Scope__c> lsScope=E2_dataUtil_WS.getUltimateScopeLOE(scopeID.substring(0,15));
           System.assertEquals(1, lsScope.size());
           
           Test.stopTest();
        }
    }
    
    public static testmethod void testGetParentScopeIds(){
        User sysAdmin= getSysAdmin();
       
        system.runAs(sysAdmin){
           Test.startTest();
           
           E2_Scope__c parentScope=[Select ID FROM E2_Scope__c WHERE Parent_Scope__c = null AND RecordTypeId = :rtScopeId ];
       
           Set<String> setScopeID=new Set<String>();
           setScopeID.add(parentScope.id);
           
           List<E2_Scope__c> lsChildScope=E2_dataUtil_WS.getParentScopeIds(setScopeID);
           System.assertEquals(1,lsChildScope.size());
           
           Test.stopTest();
        }
    }
    
    public static testmethod void testGetAnswersDetails(){
        
        User sysAdmin= getSysAdmin();
        
        system.runAs(sysAdmin){
           Test.startTest();
           
           List<E2_Question__c> lsQuestion=[Select id from E2_Question__c];
           Set<ID> setQuestionID=new Set<ID>();
           for(E2_Question__c question:lsQuestion){
               setQuestionID.add(question.ID);
           }
           
           List<E2_Answer__c> lsAnswer=E2_dataUtil_WS.getAnswersDetails(setQuestionID);
           System.assertEquals(2,lsAnswer.size());
           
           Test.stopTest();
        }
    }
    
    public static testmethod void testGetFullScopesDetailsWithLimit(){
        
        User sysAdmin= getSysAdmin();
       
        system.runAs(sysAdmin){
           Test.startTest();
        
           E2_Scope__c parentScope= [Select ID FROM E2_Scope__c WHERE Parent_Scope__c = null AND RecordTypeId = :rtScopeId ];
           List<String> lsScopeID=new List<String>();
           lsScopeID.add(parentScope.id);
           
           List<E2_Scope__c> lsScope=E2_dataUtil_WS.getFullScopesDetailsWithLimit(lsScopeID);
           System.assertEquals(1,lsScope.size());
           
           Test.stopTest(); 
        }
    }
    
      
      
  public static testmethod void testE2_TreeNode() {
    User sysAdmin = getSysAdmin();
    
    System.runAs(sysAdmin){
        Test.startTest();   
        
        Presales_Request__c psr = [SELECT Id FROM Presales_Request__c];
        estimate = [SELECT Id FROM CMC_Presales_LOE__c];
        scopeTemplate = [SELECT Id FROM E2_Scope__c WHERE RecordTypeId = :rtTemplateId];
        favScope = [SELECT Id FROM E2_Scope__c WHERE RecordTypeId = :rtScopeId AND Parent_Scope__c = null];
        childScope = [SELECT Id FROM E2_Scope__c WHERE RecordTypeId = :rtScopeId AND Parent_Scope__c != null];
        scopeGroup = [SELECT Id FROM E2_Scope_Group__c];
        derEffGroup = [SELECT Id FROM E2_Derived_Effort_Group__c];
        derivedEfforts = [SELECT Id FROM E2_Derived_Effort__c ];
        capacity = [SELECT ID FROM E2_Capacity__c];
        recommendedAsset = [SELECT Scope__c, Asset__c FROM E2_Recommended_Asset__c];
        
        
          system.assertEquals(E2_dataUtil_WS.getEstimates(estimate.Id).size(), 1);
          system.assertEquals(E2_DataUtil_WS.getScopesByParentScope(favScope.Id).size(), 1);
          system.assertEquals(E2_DataUtil_WS.getChildScopesOfEstimate(estimate.Id).size(), 2);
          system.assertEquals(E2_DataUtil_WS.getChildScopesOfScopeGroup(scopeGroup.Id).size(), 1);
          system.assertEquals(E2_DataUtil_WS.getScopeDetails(estimate.Id).size(), 1);
          system.assertEquals(E2_dataUtil_WS.getChildScopeByParentId(favScope.Id).size(), 1);
          system.assertEquals(E2_dataUtil_WS.getFullScopeDetails(favScope.Id).size(), 1);
          //system.assertEquals(E2_DataUtil_WS.getFullScopeDetailsWithLimit(favScope.Id).size(), 1);
          system.assertEquals(E2_DataUtil_WS.getScopeChildList(favScope.Id).size(), 1); 
          system.assertEquals(E2_DataUtil_WS.getRelatedAssets('test', new List<String>{recommendedAsset.Asset__c}).size(), 1);
          system.assertEquals(E2_DataUtil_WS.getAssetContributors(new List<CMC_Asset__c>()).size(), 0);
          system.assertEquals(E2_DataUtil_WS.getRecommendedAssetsForScope(scopeTemplate.id).size(), 1);
          system.assertEquals(E2_DataUtil_WS.getAssetsMap(new Set<Id>{recommendedAsset.Asset__c}).size(), 1);
        Test.stopTest();
    }
   }
   
   private static User getSysAdmin(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      return sysAdmin;
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
        
        E2_Effort__c parentEffort=E2_Test_Utils.insertEffort(true,favScope.Id);
        
        
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
        childSC.Ultimate_Parent_Scope__c=favScope.Id;
        insert childSC;  
      
        E2_Effort__c effort1 = E2_Test_Utils.insertEffort(true, childSC.Id);
        
        capacity = new E2_Capacity__c();
        capacity.Estimator__c = estimate.Id;
        insert capacity;
        
        //Insert Question and Answer
        E2_Question__c question_1=E2_Test_Utils.insertQuestions(favScope.id,true);
        E2_Answer__c answer_1=E2_Test_Utils.insertAnswer(question_1.id,true);
        
        E2_Question__c question_2=E2_Test_Utils.insertQuestions(favScope.id,true);
        E2_Answer__c answer_2=E2_Test_Utils.insertAnswer(question_2.id,true);
        
        
        List<CMC_Asset__c> lstAssets = new List<CMC_Asset__c>();
        lstAssets.add(E2_Test_Utils.insertAsset('Test Asset 1', 'Test asset record', 'Component', 'User Interface', 
                                                'Apex', 'Salesforce;Data integration', 1, 'Active', false));
        lstAssets.add(E2_Test_Utils.insertAsset('Test Asset 2', 'Test asset record', 'Component', 'User Interface', 
                                                'Apex', 'Salesforce;Data integration', 1, 'Active', false));
        insert lstAssets;
        
        recommendedAsset = E2_Test_Utils.insertRecommendedAsset(scopeTemplate.id, lstAssets[0].id, true);
    }

}