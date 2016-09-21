@isTest(seeAllData=false)
public class E2_DataUtilTest {
    
    public static E2_Scope__c scopeTemplate, favScope;
    public static E2_Scope__c childScope;
    public static CMC_Presales_LOE__c estimate;
    public static Id rtTemplateId = E2_RecordTypeClass.getId('E2_Scope__c', E2_Constants.SCOPE_RT_TEMPLATE);
    public static Id rtScopeId = E2_RecordTypeClass.getId('E2_Scope__c', E2_Constants.SCOPE_RT_SCOPE);
    public static E2_Scope_Group__c scopeGroup;
    public static E2_Derived_Effort_Group__c derEffGroup;
    public static List<E2_Derived_Effort__c> derivedEfforts;
    public static E2_Capacity__c capacity;
    public static E2_Question__c question;
    public static E2_Answer__c answer;
    public static User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
    public static E2_Favourite_Scope__c fav_scope;
    public static pse__Rate_Card__c rateCard;
    public static E2_Estimate_Rate_Card__c estimateRC;
    public static E2_Milestone_Library__c milestoneLib;
    public static E2_Action_Scope__c actionScope;
    public static PermissionSet permission;
        
    public static testmethod void testE2_TreeNode() {
    
    System.runAs(sysAdmin){
        createTestData();
        Test.startTest();
            Presales_Request__c psr = [SELECT Id FROM Presales_Request__c];
            estimate = [SELECT Id FROM CMC_Presales_LOE__c];
            scopeTemplate = [SELECT Id FROM E2_Scope__c WHERE RecordTypeId = :rtTemplateId];
            favScope = [SELECT Id FROM E2_Scope__c WHERE RecordTypeId = :rtScopeId AND Parent_Scope__c = null];
            childScope = [SELECT Id FROM E2_Scope__c WHERE RecordTypeId = :rtScopeId AND Parent_Scope__c != null];
            Set<Id>  childScopeIds = new Set<Id> ();
            childScopeIds.add(childScope.Id);
            scopeGroup = [SELECT Id FROM E2_Scope_Group__c];
            derEffGroup = [SELECT Id FROM E2_Derived_Effort_Group__c];
            derivedEfforts = [SELECT Id FROM E2_Derived_Effort__c ];
            capacity = [SELECT ID FROM E2_Capacity__c];
            question = [SELECT Id FROM E2_Question__c];
            answer = [SELECT Id FROM E2_Answer__c];
            fav_scope = [SELECT Id, User__c, Scope__c FROM E2_Favourite_Scope__c];
            rateCard = [SELECT Id FROM pse__Rate_Card__c];
            estimateRC = [SELECT Id FROM E2_Estimate_Rate_Card__c];
            milestoneLib = [SELECT Id FROM E2_Milestone_Library__c ];
            actionScope = [SELECT Id FROM E2_Action_Scope__c];
            permission = [SELECT Id FROM PermissionSet WHERE Name = :E2_Constants.STM_PERMISSION_SET];
             
            Set<Id> estimateIds = new Set<Id>();
            estimateIds.add(estimate.Id);
            List<Presales_Request__c> psrs = E2_dataUtil.getPSRDetailOnPsrId(psr.Id);
            system.assertEquals(psrs.size(), 1);
            system.assertEquals(E2_dataUtil.getEstimateDetailOnId(estimate.Id).size(), 1);
            system.assert(E2_DataUtil.getScopesOnTemplateScopeSearchTemplate('Test Scope', scopeGroup.Id, rtTemplateId) != null);
            system.assert(E2_DataUtil.getFavScopesOnTemplateScopeSearchByUser('Test Scope', sysAdmin.Id, null)!= null);
            system.assert(E2_DataUtil.getDerivedEffortGroup('Central SFDC Traditional Test') != null);
            system.assertEquals(E2_DataUtil.getDerivedEffort(derEffGroup.Id).size(), 3);
            system.assertEquals(E2_dataUtil.getScopeRecordsWithChildRecords(favScope.Id).size(), 1);
            system.assertEquals(E2_dataUtil.getScopeAndChildrenOnScopeIdForEditScope(favScope.Id).size(), 1);
            system.assertEquals(E2_DataUtil.getEffortsListByEstimateId(estimate.Id).size(), 1);
            system.assertEquals(E2_DataUtil.getCapacityListByEstimateId(estimate.Id).size(), 1); 
            system.assertEquals(E2_DataUtil.getEstimateDetailForAccess(estimate.Id).size(), 1);
            system.assertEquals(E2_DataUtil.getDerivedEffortGroupById(derEffGroup.Id).size(), 1);
            system.assertEquals(E2_DataUtil.getAllDerivedEffort(derEffGroup.Id).size(), 3);
            List<E2_Derived_Effort_Group__c> derEffGrpList = E2_DataUtil.getDerivedEffortGroupById(derEffGroup.Id);
            List<E2_Scope_Group__c> scopeGrpList = E2_DataUtil.getAllScopeGroups();
            system.assertEquals(E2_DataUtil.getScopeRecordsWithChildForChildScopeIds(childScopeIds).size(), 1);
            system.assertEquals(E2_DataUtil.getEffortsOnEstimateIds(estimateIds).size(), 1);
            system.assertEquals(scopeGrpList.size(), 1);
            
            List<E2_Recommended_Asset__c> lstRecommendedAssets = E2_DataUtil.getRecommendedAssetsForScope(scopeTemplate.Id);
            system.assertEquals(lstRecommendedAssets.size(), 1);
            system.assertNotEquals(E2_DataUtil.getAssetsMap(new Set<Id>{lstRecommendedAssets[0].Asset__c}), null);
            List<E2_Scope__c> lstScope = E2_DataUtil.getActiveChildScopesOfEstimate(estimate.Id);
            system.assertEquals(lstScope.size(), 2);
            
            lstScope = E2_DataUtil.getScopesOnTemplate(scopeTemplate.Id);
            system.assertEquals(lstScope.size(), 1);
            system.assertEquals(E2_DataUtil.getScopeQuestions(favScope.Id).size(), 1);
            Set<Id> scopeId = new Set<Id>();
            scopeId.add(favScope.Id);
            system.assertEquals(E2_DataUtil.getParentScopeIds(scopeId).size(), 1);
            
            List<E2_Favourite_Scope__c> favscopeLst =  E2_DataUtil.getFavScopeForCurrentUser();
            system.assertEquals(favscopeLst.size(), 1);
            favscopeLst = E2_DataUtil.getFavScopeForCurrentUserAndScopeId(fav_scope.Id);
            system.assertNotEquals(favscopeLst.size(), 1);
            system.assertEquals(E2_DataUtil.getEstimateRateCardRecs(estimate.Id).size(), 1);
            system.assertEquals(E2_DataUtil.getEstimateRateCards(estimate.Id).size(), 1);
            Set<Id> rateCardIds = new Set<Id>();
            rateCardIds.add(rateCard.Id);
            system.assertEquals(E2_DataUtil.getpseRateCardRecs(rateCardIds, E2_Constants.CURRENCY_ISO_CODE_USD).size(), 0);
            system.assertEquals(E2_DataUtil.getPSERateCardRecords(E2_Constants.CURRENCY_ISO_CODE_USD).size(), 1);
            system.assert(E2_DataUtil.getE2Questions(question.Id) <> null);
            system.assertEquals(E2_DataUtil.getMilestoneScheduleTemplates().size(), 1);
            set<Id> answers = new set<Id>();
            answers.add(answer.Id);
            system.assertEquals(E2_DataUtil.getRelatedScopes(answers) .size(), 1);
            system.assertEquals(E2_DataUtil.getPermissionSet().size(), 1);
            List<PermissionSet> permissionSetIds = new List<PermissionSet>();
            permissionSetIds.add(permission);
            User testUser = E2_DataUtil.getPermissionSetAssignmentForUser(permissionSetIds);
            system.assert(testUser <> null);
            
        Test.stopTest();
    }
   }
   
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
        
        List<CMC_Asset__c> lstAssets = new List<CMC_Asset__c>();
        lstAssets.add(E2_Test_Utils.insertAsset('Test Asset 1', 'Test asset record', 'Component', 'User Interface', 
                                                'Apex', 'Salesforce;Data integration', 1, 'Active', false));
        lstAssets.add(E2_Test_Utils.insertAsset('Test Asset 2', 'Test asset record', 'Component', 'User Interface', 
                                                'Apex', 'Salesforce;Data integration', 1, 'Active', false));
        insert lstAssets;
        
        E2_Recommended_Asset__c recommendedAsset = E2_Test_Utils.insertRecommendedAsset(scopeTemplate.id, lstAssets[0].id, true);
        
        question = E2_Test_Utils.insertQuestions(favScope.Id, true);
        answer = E2_Test_Utils.insertAnswer(question.Id, true);
        
        fav_scope = new E2_Favourite_Scope__c(Scope__c = favScope.Id, User__c = sysAdmin.Id);
        insert fav_scope;
        
        pse__Region__c region = E2_Test_Utils.insertRegion(true);
        pse__Practice__c practice = E2_Test_Utils.insertPractice(true);
    
        rateCard = E2_Test_Utils.insertRateCard(acc.Id, region.Id, practice.Id, true);
        estimateRC = E2_Test_Utils.insertEstimateRateCard(estimate.Id, true);
        
        milestoneLib = E2_Test_Utils.insertMilestoneLibrary(true);
        actionScope = new E2_Action_Scope__c(Answer__c = answer.Id, Scope__c = favScope.Id);
        insert actionScope;
        
    }
}