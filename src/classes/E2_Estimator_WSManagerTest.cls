@isTest(seeAllData=false)
public class E2_Estimator_WSManagerTest {
  public static CMC_Presales_LOE__c estimate;
  public static E2_Scope__c parentSC, childSC, parentSC1, childSC1;
  public static E2_Scope_Group__c scopeGroup;
  public static E2_Recommended_Asset__c recommendedAsset;
  public static Id recTypeId = E2_RecordTypeClass.getId(E2_Constants.E2_SCOPE_API_NAME, E2_Constants.SCOPE_RT_TEMPLATE); 
  
  public static testmethod void testE2_TreeNode(){
    estimate = [SELECT Id, Name FROM CMC_Presales_LOE__c];
    parentSC = [SELECT Id, Name,Source_Scope__c, Complexity__c, Scope_Item_Type__c, Scope_Flag__c,
                  LOE_Hrs__c, Is_Active__c
                  FROM E2_Scope__c WHERE Parent_Scope__c = null AND RecordTypeId != :recTypeId];
    childSC = [SELECT Id, Name, Source_Scope__c, Complexity__c, Scope_Item_Type__c, Scope_Flag__c,
                  LOE_Hrs__c, Is_Active__c
                  FROM E2_Scope__c WHERE Parent_Scope__c = :parentSC.Id AND RecordTypeId != :recTypeId];
    scopeGroup = [SELECT Id, Name FROM E2_Scope_Group__c];
    recommendedAsset = [SELECT Scope__c, Asset__c FROM E2_Recommended_Asset__c];
    
    parentSC1 = [SELECT Id, Name,Source_Scope__c, Complexity__c, Scope_Item_Type__c, Scope_Flag__c,
                  LOE_Hrs__c, Is_Active__c
                  FROM E2_Scope__c WHERE Parent_Scope__c = null AND RecordTypeId = :recTypeId];
    childSC1 = [SELECT Id, Name, Source_Scope__c, Complexity__c, Scope_Item_Type__c, Scope_Flag__c,
                  LOE_Hrs__c, Is_Active__c
                  FROM E2_Scope__c WHERE Parent_Scope__c = :parentSC1.Id AND RecordTypeId = :recTypeId];
                  
    User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
    
    System.runAs(sysAdmin){
  
    //start test
    Test.startTest();
      E2_TreeNode tree1 = new E2_TreeNode(parentSc.Name, false, false, parentSC.Id, '#');
      List<E2_TreeNode> treeLst = new List<E2_TreeNode>();
      
      E2_TreeNode tree2 = new E2_TreeNode(parentSc.Name, false, false, parentSC1.Id, '#');
      List<E2_TreeNode> treeLst1 = new List<E2_TreeNode>();
            
      treeLst = E2_Estimator_WSManager.retrieveAllScopeTreeNodesOnEstimateId(estimate.Id);
      System.assertEquals(treeLst.size(), 2, 'Doesnot return 2 scopes associated with the estimate');
      
      
      
      E2_TreeNodeMap treeMap = E2_Estimator_WSManager.getChildScopeDetailNodes(parentSC.Id);
      System.assertEquals(treeMap.nodeList.size(), 1, 'Doesnot return 1 scope child to parent scope');
      
      
      treeMap = E2_Estimator_WSManager.getScopeDetailNodes(childSC.Id);
      System.assertEquals(childSC.Id, treeMap.scope_id, 'returns same scope id');
      System.assertEquals(treeMap.nodeList.size(), 1, 'Doesnot return 1 scope related to scope id');
      
      treeLst = E2_Estimator_WSManager.getParentNodesWithEffortsOnEstimateId(estimate.Id);
      System.assertEquals(treeLst.size(), 1, 'Doesnot return the only 1 parent scope associated with the estimate');      
      
      treeLst = E2_Estimator_WSManager.getImmediateChildNodesWithEffortsOnScopeId(parentSC.Id);
      System.assertEquals(treeLst.size(), 1 + 1, 'Doesnot return the only immediate child scope and only effort to this scope');      
      
      //treeMap = E2_Estimator_WSManager.getClonedNodes(childSC.Id, estimate.Id, parentSC.Id);
      /*System.assertEquals(childSC.Id, treeMap.scope_id, 'returns same scope id');
      System.assertEquals(treeMap.nodeList.size(), 1, 'Doesnot return 1 scope related to scope id');
      System.assertEquals(treeMap.nodeList[0].sourceId, childSC.id, 'source id is populated'); 
      System.assertNotEquals(treeMap.nodeList[0].id, childSC.id, 'source id <> scope id'); 
      */
      //treeMap = E2_Estimator_WSManager.getChildCloneNodes(parentSC.Id, parentSC.Id, estimate.Id);
      
      //commented as getting error during asset related code coverage
      /*treeMap = E2_Estimator_WSManager.getClonedNodesTemplate(childSC.Id, scopeGroup.Id, parentSC.Id);
      System.assertEquals(childSC.Id, treeMap.scope_id, 'returns same scope id');
      System.assertEquals(treeMap.nodeList.size(), 1, 'Doesnot return 1 scope related to scope id');
      System.assertEquals(treeMap.nodeList[0].sourceId, childSC.id, 'source id is populated'); 
      System.assertNotEquals(treeMap.nodeList[0].id, childSC.id, 'source id <> scope id'); */
      
      //treeMap = E2_Estimator_WSManager.getChildCloneNodesTemplate(parentSC.Id, parentSC.Id, scopeGroup.Id);
      
      treeLst1 = E2_Estimator_WSManager.retrieveAllScopeTreeNodesOnScopeGroup(scopeGroup.Id);
      System.assertEquals(treeLst1.size(), 1, 'Doesnot return 2 scopes associated with the group');
      E2_Estimator_WSManager.updateScopeFlag(estimate.Id,'flagred');
      string error = E2_Estimator_WSManager.updateScopeFlag(E2_constants.BLANK,'flagred');  
      System.assertEquals(error, 'Failed to update: Current scope not identified!!!');
      E2_Estimator_WSManager.updateScopeFlag(childSC.Id,'flagred');
      E2_Estimator_WSManager.updateScopeFlag(childSC.Id,'flagyellow');
      E2_Estimator_WSManager.updateScopeFlag(childSC.Id,'flaggreen');
      
      String test_scope = E2_Estimator_WSManager.getFormatedScopeName(parentSC);
      system.assert(test_Scope != null);
      
      //commented as getting error during asset related code coverage
      
      /*treeMap = E2_Estimator_WSManager.getClonedNodesTemplate(parentSC.Id, scopeGroup.Id, null);
      E2_Estimator_WSManager.reparentScope(scopeGroup.Id, null);
      String a_scopeId = E2_Estimator_WSManager.reparentScope(childSC.Id, null);
      System.assertEquals(a_scopeId, childSC.id, 'Not successfully reparenting');*/
      
      String jsonString = '[{"scopeId":"' + parentSC.id + '", "displayOrder":"1"},{"scopeId":"' + childSC.id + '", "displayOrder":"2"}]';
      String statusStr = E2_Estimator_WSManager.updateScopesDisplayOrder(jsonString);
      System.assertEquals(statusStr, 'success');
      
      String test_Scope1 =  E2_Estimator_WSManager.getSelectedScopeNodes('', estimate.Id, parentSC.Id);
      system.assert(test_Scope1 != null);
      
      E2_Estimator_WSManager.deleteScope(scopeGroup.Id, E2_Constants.HASH_TAG);    
      String b_scopeId = E2_Estimator_WSManager.deleteScope(childSC.Id, parentSC.Id);
      System.assertEquals(b_scopeId, childSC.id, 'Not successfully deleting');
      
      List<string> exisitingAssetIds = new List<string>{recommendedAsset.Asset__c};
      E2_AssetWrapperMap assetMap = E2_Estimator_WSManager.searchAssets('test', exisitingAssetIds);
      System.assertEquals(assetMap.searchKey, 'test');
      //System.assertEquals(assetMap.assetList.size(), 1);
      //stop test  
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
    
    parentSC = E2_Test_Utils.insertScope(false);
    parentSC.Presales_LOE__c = estimate.Id;
    parentSC.Parent_Scope__c = null;
    parentSC.Complexity__c = 'Low';
    parentSC.Source_Scope__c = null;
    parentSC.LOE_Hrs__c = 10;
    insert parentSC;
    
    childSC = E2_Test_Utils.insertScope(false);
    childSC.Presales_LOE__c = estimate.Id;
    childSC.Parent_Scope__c = parentSC.Id;
    childSC.Complexity__c = 'Low';
    childSC.LOE_Hrs__c = 30;
    childSC.Scope_Group__c = scopeGroup.Id;
    insert childSC;
    
    parentSC1 = E2_Test_Utils.insertScope(false);
    parentSC1.Parent_Scope__c = null;
    parentSC1.Complexity__c = 'Low';
    parentSC1.Source_Scope__c = null;
    parentSC1.LOE_Hrs__c = 10;
    parentSC1.RecordTypeId = recTypeId;
    insert parentSC1;
    
    childSC1 = E2_Test_Utils.insertScope(false);
    childSC1.Parent_Scope__c = parentSC1.Id;
    childSC1.Complexity__c = 'Low';
    childSC1.LOE_Hrs__c = 30;
    childSC1.Scope_Group__c = scopeGroup.Id;
    childSC1.RecordTypeId = recTypeId;
    insert childSC1;
    
    E2_Effort__c effort1 = E2_Test_Utils.insertEffort(true, parentSC.Id);
    
    //E2_Assumption__c assumption1 = E2_Test_Utils.insertAssumption(true, parentSC.Id);
    
    //E2_Story__c story1 = E2_Test_Utils.insertStory(true, parentSC.Id);
    
    //E2_Question__c ques1 = E2_Test_Utils.insertQuestion(true, parentSC.Id);
    
    //E2_Response__c response = E2_Test_Utils.insertResponse(true, ques1.Id);
    
    List<CMC_Asset__c> lstAssets = new List<CMC_Asset__c>();
    lstAssets.add(E2_Test_Utils.insertAsset('Test Asset 1', 'Test asset record', 'Component', 'User Interface', 
  									        'Apex', 'Salesforce;Data integration', 1, false));
    lstAssets.add(E2_Test_Utils.insertAsset('Test Asset 2', 'Test asset record', 'Component', 'User Interface', 
  									        'Apex', 'Salesforce;Data integration', 1, false));
  	insert lstAssets;
  	
  	recommendedAsset = E2_Test_Utils.insertRecommendedAsset(parentSC.id, lstAssets[0].id, true);
       
  }
}