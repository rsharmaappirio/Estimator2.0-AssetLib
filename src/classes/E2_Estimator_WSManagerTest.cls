@isTest(seeAllData=false)
public class E2_Estimator_WSManagerTest {
public static CMC_Presales_LOE__c estimate;
  public static E2_Scope__c parentSC, childSC;
  public static E2_Scope_Group__c scopeGroup;
  
  public static testmethod void testE2_TreeNode(){
    estimate = [SELECT Id, Name FROM CMC_Presales_LOE__c];
    parentSC = [SELECT Id, Name,Source_Scope__c FROM E2_Scope__c WHERE Parent_Scope__c = null];
    childSC = [SELECT Id, Name, Source_Scope__c FROM E2_Scope__c WHERE Parent_Scope__c = :parentSC.Id];
    scopeGroup = [SELECT Id, Name FROM E2_Scope_Group__c];
    
    User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
    
    System.runAs(sysAdmin){
  
    //start test
    Test.startTest();
      E2_TreeNode tree1 = new E2_TreeNode(parentSc.Name, false, false, parentSC.Id, '#');
      List<E2_TreeNode> treeLst = new List<E2_TreeNode>();
            
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
      
      treeMap = E2_Estimator_WSManager.getClonedNodes(childSC.Id, estimate.Id, parentSC.Id);
      System.assertEquals(childSC.Id, treeMap.scope_id, 'returns same scope id');
      System.assertEquals(treeMap.nodeList.size(), 1, 'Doesnot return 1 scope related to scope id');
      System.assertEquals(treeMap.nodeList[0].sourceId, childSC.id, 'source id is populated'); 
      System.assertNotEquals(treeMap.nodeList[0].id, childSC.id, 'source id <> scope id'); 
      
      treeMap = E2_Estimator_WSManager.getChildCloneNodes(parentSC.Id, parentSC.Id, estimate.Id);
      
      treeMap = E2_Estimator_WSManager.getClonedNodesTemplate(childSC.Id, scopeGroup.Id, parentSC.Id);
      System.assertEquals(childSC.Id, treeMap.scope_id, 'returns same scope id');
      System.assertEquals(treeMap.nodeList.size(), 1, 'Doesnot return 1 scope related to scope id');
      System.assertEquals(treeMap.nodeList[0].sourceId, childSC.id, 'source id is populated'); 
      System.assertNotEquals(treeMap.nodeList[0].id, childSC.id, 'source id <> scope id'); 
      
      treeMap = E2_Estimator_WSManager.getChildCloneNodesTemplate(parentSC.Id, parentSC.Id, scopeGroup.Id);
      
      treeLst = E2_Estimator_WSManager.retrieveAllScopeTreeNodesOnScopeGroup(scopeGroup.Id);
      System.assertEquals(treeLst.size(), 6, 'Doesnot return 2 scopes associated with the group');
      E2_Estimator_WSManager.updateScopeFlag(estimate.Id,'flagred');
      string error = E2_Estimator_WSManager.updateScopeFlag(E2_constants.BLANK,'flagred');  
      System.assertEquals(error, 'Failed to update: Current scope not identified!!!');
      E2_Estimator_WSManager.updateScopeFlag(childSC.Id,'flagred');
      E2_Estimator_WSManager.updateScopeFlag(childSC.Id,'flagyellow');
      E2_Estimator_WSManager.updateScopeFlag(childSC.Id,'flaggreen');
      
      treeMap = E2_Estimator_WSManager.getClonedNodesTemplate(parentSC.Id, scopeGroup.Id, null);
      E2_Estimator_WSManager.reparentScope(scopeGroup.Id, null);
      String a_scopeId = E2_Estimator_WSManager.reparentScope(childSC.Id, null);
      System.assertEquals(a_scopeId, childSC.id, 'Not successfully reparenting');
      E2_Estimator_WSManager.deleteScope(scopeGroup.Id, E2_Constants.HASH_TAG);    
      String b_scopeId = E2_Estimator_WSManager.deleteScope(childSC.Id, parentSC.Id);
      System.assertEquals(b_scopeId, childSC.id, 'Not successfully deleting');
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
    insert parentSC;
    
    childSC = E2_Test_Utils.insertScope(false);
    childSC.Presales_LOE__c = estimate.Id;
    childSC.Parent_Scope__c = parentSC.Id;
    childSC.Complexity__c = 'Low';
    insert childSC;
    
    E2_Effort__c effort1 = E2_Test_Utils.insertEffort(true, parentSC.Id);
    
    //E2_Assumption__c assumption1 = E2_Test_Utils.insertAssumption(true, parentSC.Id);
    
    //E2_Story__c story1 = E2_Test_Utils.insertStory(true, parentSC.Id);
    
    //E2_Question__c ques1 = E2_Test_Utils.insertQuestion(true, parentSC.Id);
    
    //E2_Response__c response = E2_Test_Utils.insertResponse(true, ques1.Id);
       
  }
}