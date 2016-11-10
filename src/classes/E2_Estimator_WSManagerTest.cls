/**=====================================================================
 * Appirio, Inc
 * Name: E2_Estimator_WSManagerTest
 * Description: Test class to E2_Estimator_WSManager web service manager 
 * Created Date: May 13, 2016
 * Created By: Rohit Sharma (Appirio)
 * 
 * Date Modified      Modified By                  Description of the update
 * Nov 07, 2016       Jitendra Jangid              S-448268 : Cloned scope item on right click
*  =====================================================================*/
@isTest(seeAllData=false)
public class E2_Estimator_WSManagerTest {
  public static CMC_Presales_LOE__c estimate;
  public static E2_Scope__c parentSC, childSC, child_childSC, parentSC1, childSC1, child_childSC1;
  public static E2_Scope_Group__c scopeGroup;
  public static E2_Recommended_Asset__c recommendedAsset;
  public static Id recTypeId = E2_RecordTypeClass.getId(E2_Constants.E2_SCOPE_API_NAME, E2_Constants.SCOPE_RT_TEMPLATE); 
  public static CMC_Asset_Contributor__c asetContributor;
  public static E2_Question__c ques1;
  public static E2_Answer__c ans1;
  public static E2_Action_Scope__c actionScope;
  public static List<CMC_Asset__c> lstAssets;
  
  public static testmethod void testE2_TreeNode(){
    estimate = [SELECT Id, Name FROM CMC_Presales_LOE__c];
    parentSC = [SELECT Id, Name,Source_Scope__c, Complexity__c, Scope_Item_Type__c, Scope_Flag__c, LOE_Hrs__c, Is_Active__c
                  FROM E2_Scope__c WHERE Parent_Scope__c = null AND RecordTypeId != :recTypeId];
    childSC = [SELECT Id, Name, Source_Scope__c, Complexity__c, Scope_Item_Type__c, Scope_Flag__c, LOE_Hrs__c, Is_Active__c
                  FROM E2_Scope__c WHERE Parent_Scope__c = :parentSC.Id];
    child_childSC = [SELECT Id, Name, Source_Scope__c, Complexity__c, Scope_Item_Type__c, Scope_Flag__c, LOE_Hrs__c, Is_Active__c
                       FROM E2_Scope__c WHERE Parent_Scope__c = :childSC.Id];              
    scopeGroup = [SELECT Id, Name FROM E2_Scope_Group__c];
    recommendedAsset = [SELECT Scope__c, Asset__c FROM E2_Recommended_Asset__c];
    ques1 = [SELECT Id, Name, Scope__c FROM E2_Question__c];
    ans1 = [SELECT Id, Name FROM E2_Answer__c WHERE Question__c =: ques1.Id];
    
    parentSC1 = [SELECT Id, Name,Source_Scope__c, Complexity__c, Scope_Item_Type__c, Scope_Flag__c, LOE_Hrs__c, Is_Active__c
                    FROM E2_Scope__c WHERE Parent_Scope__c = null AND RecordTypeId = :recTypeId];
    childSC1 = [SELECT Id, Name, Source_Scope__c, Complexity__c, Scope_Item_Type__c, Scope_Flag__c, LOE_Hrs__c, Is_Active__c
                  FROM E2_Scope__c WHERE Parent_Scope__c = :parentSC1.Id];
    child_childSC1 = [SELECT Id, Name, Source_Scope__c, Complexity__c, Scope_Item_Type__c, Scope_Flag__c,LOE_Hrs__c, Is_Active__c
                         FROM E2_Scope__c WHERE Parent_Scope__c = :childSC1.Id];              
    
    asetContributor = [Select c.Primary_Contact__c, c.Hours_Contributed__c, c.Contact__c, c.Asset__c 
                         From CMC_Asset_Contributor__c c];  
    actionScope = [SELECT Id FROM E2_Action_Scope__c];
    lstAssets = [SELECT Id, Short_Description__c, Technologies__c, Release_Stage__c, Asset_Type__c, Asset_SubType__c, Appirio_Services_Practice__c,
                   Number_of_Uses__c, Is_Recommended__c, Total_Hours__c, Reuse_LOE__c 
                   FROM CMC_Asset__c];
    
    User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
    
    System.runAs(sysAdmin){
  
    //start test
    Test.startTest();
      
      E2_TreeNode tree1 = new E2_TreeNode(parentSc.Name, false, false, parentSC.Id, '#');
      List<E2_TreeNode> treeLst = new List<E2_TreeNode>();
      
      E2_TreeNode tree2 = new E2_TreeNode(parentSc.Name, false, false, parentSC1.Id, '#');
      List<E2_TreeNode> treeLst1 = new List<E2_TreeNode>();
            
      treeLst = E2_Estimator_WSManager.retrieveAllScopeTreeNodesOnEstimateId(estimate.Id);
      System.assertEquals(treeLst.size(), 4, 'Doesnot return 2 scopes associated with the estimate');

      E2_TreeNodeMap treeMap = E2_Estimator_WSManager.getChildScopeDetailNodes(parentSC.Id);
      System.assertEquals(treeMap.nodeList.size(), 1, 'Doesnot return 1 scope child to parent scope');

      treeMap = E2_Estimator_WSManager.getScopeDetailNodes(childSC.Id);
      System.assertEquals(childSC.Id, treeMap.scope_id, 'returns same scope id');
      System.assertEquals(treeMap.nodeList.size(), 1, 'Doesnot return 1 scope related to scope id');
      
      treeLst = E2_Estimator_WSManager.getParentNodesWithEffortsOnEstimateId(estimate.Id);
      System.assertEquals(treeLst.size(), 1, 'Doesnot return the only 1 parent scope associated with the estimate');      
      
      treeLst = E2_Estimator_WSManager.getImmediateChildNodesWithEffortsOnScopeId(parentSC.Id);
      System.assertEquals(treeLst.size(), 1 + 1, 'Doesnot return the only immediate child scope and only effort to this scope');      

      // S-448268 : Cloned scope item on right click
      String scopeToBeCloned= parentSC.Id +',' + childSC.Id;
      List<E2_TreeNode> resultedClonedNode=E2_Estimator_WSManager.cloneScopeWithChild(scopeToBeCloned);
      system.assert(resultedClonedNode != null && resultedClonedNode.size() == 2, 'Unit test failed: selected scope has not successfully cloned.'+resultedClonedNode.size());
      // S-448268 :End
      
      String scopeIds = parentSC.Id+ ','+ child_childSC.Id+ ',' + parentSC1.Id+ ','+ child_childSC1.Id ; 
      List<E2_TreeNode> cloned_msg = E2_Estimator_WSManager.getClonedNodesTemplate(scopeIds, scopeGroup.Id, parentSC.Id);
      system.assertNotEquals(cloned_msg.size(), 0, 'Success message is returned');
      
      treeLst1 = E2_Estimator_WSManager.retrieveAllScopeTreeNodesOnScopeGroup(scopeGroup.Id);
      System.assertEquals(treeLst1.size(), 5, 'Does not return 2 scopes associated with the group');
      
      E2_Estimator_WSManager.updateScopeFlag(estimate.Id,'flagred');
      string error = E2_Estimator_WSManager.updateScopeFlag(E2_constants.BLANK,'flagred');  
      System.assertEquals(error, 'Failed to update: Current scope not identified!!!');
      
      E2_Estimator_WSManager.updateScopeFlag(childSC.Id,'flagred');
      E2_Estimator_WSManager.updateScopeFlag(childSC.Id,'flagyellow');
      E2_Estimator_WSManager.updateScopeFlag(childSC.Id,'flaggreen');
      
      String test_scopeName = E2_Estimator_WSManager.getFormatedScopeName(parentSC);
      system.assert(test_scopeName != null);
      
      String test_scopeName1 = E2_Estimator_WSManager.getFormatedScopeName(childSC);
      system.assert(test_scopeName1 != null);

      E2_Estimator_WSManager.reparentScope(scopeGroup.Id, null);
      String a_scopeId = E2_Estimator_WSManager.reparentScope(childSC.Id, null);
      System.assertEquals(a_scopeId, childSC.id, 'Not successfully reparenting');
      
      String jsonString = '[{"scopeId":"' + parentSC.id + '", "displayOrder":"1", "sequence":"1"},{"scopeId":"' + childSC.id + '", "displayOrder":"2", "sequence":"2"}]';
      String statusStr = E2_Estimator_WSManager.updateScopesDisplayOrder(jsonString);
      System.assertEquals(statusStr, 'success');
       
      List<E2_TreeNode> test_Scope1 =  E2_Estimator_WSManager.getSelectedScopeNodes(scopeIds, estimate.Id, null);
      system.assert(test_Scope1 != null);
      
      string allscopesIds = parentSC.Id +',' + childSC.Id + ',' + childSC1.Id;
      String scopestatus = E2_Estimator_WSManager.updateScopesStatus('Low', null, childSC1.Id, allscopesIds);
      System.assertEquals(scopestatus, 'Success', 'Success message is returned');
      
      scopestatus = E2_Estimator_WSManager.updateScopesStatus(null, childSC.Id, null, allscopesIds);
      System.assertEquals(scopestatus, 'Success', 'Success message is returned');
       System.assertEquals(childSC.Is_Active__c, true);
      
      E2_Estimator_WSManager.deleteScope(scopeGroup.Id, E2_Constants.HASH_TAG);    
      String b_scopeId = E2_Estimator_WSManager.deleteScope(childSC.Id, parentSC.Id);
      System.assertEquals(b_scopeId, childSC.id, 'Not successfully deleting');
      
      String existing_assets = E2_Estimator_WSManager.getExistingAssetsForScope(parentSC.Id);
      system.assert(existing_assets != null);
      system.debug('lstAssets=='+ lstAssets);
      
      List<string> exisitingAssetIds = new List<string>{recommendedAsset.Asset__c};
      system.debug('exisitingAssetIds=='+ exisitingAssetIds);
      Id [] fixedSearchResults = new Id[1];
      fixedSearchResults[0] = lstAssets[1].Id;
      Test.setFixedSearchResults(fixedSearchResults);
    
      E2_AssetWrapperMap assetMap = E2_Estimator_WSManager.searchAssets('Test', exisitingAssetIds);
      System.assertEquals(assetMap.searchKey, 'Test');
      System.assertEquals(assetMap.assetList.size(), 1);
     
      
     
      //stop test  
    Test.stopTest();
    }
  }
 
  @testSetup
  private static void createTestData(){
    Account acc = E2_Test_Utils.insertAccount(false);
    acc.Name= 'Appirio';
    insert acc;
    
    Opportunity opp = E2_Test_Utils.insertOpportunity(acc.Id, true);
    
    Presales_Request__c psr = E2_Test_Utils.insertPresalesReq(opp.Id, 'Demo', true);
    estimate = E2_Test_Utils.insertEstimate(psr.Id, true);
    scopeGroup = E2_Test_Utils.insertScopeGroup(true);
    
    parentSC = E2_Test_Utils.insertScope(false);
    parentSC.Presales_LOE__c = estimate.Id;
    parentSC.Parent_Scope__c = null;
    parentSC.Complexity__c = 'Low';
    parentSC.Source_Scope__c = null;
    parentSC.LOE_Hrs__c = 0;
    insert parentSC;
    
    childSC = E2_Test_Utils.insertScope(false);
    childSC.Presales_LOE__c = estimate.Id;
    childSC.Parent_Scope__c = parentSC.Id;
    childSC.Complexity__c = 'Low';
    childSC.LOE_Hrs__c = 30;
    childSC.Scope_Group__c = scopeGroup.Id;
    insert childSC;
    
    child_childSC = E2_Test_Utils.insertScope(false);
    child_childSC.Presales_LOE__c = estimate.Id;
    child_childSC.Parent_Scope__c = childSC.Id;
    child_childSC.Complexity__c = 'Low';
    child_childSC.LOE_Hrs__c = 30;
    child_childSC.Scope_Group__c = scopeGroup.Id;
    insert child_childSC;
    
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
    
    child_childSC1 = E2_Test_Utils.insertScope(false);
    child_childSC1.Presales_LOE__c = estimate.Id;
    child_childSC1.Parent_Scope__c = childSC1.Id;
    child_childSC1.Complexity__c = 'Low';
    child_childSC1.LOE_Hrs__c = 30;
    child_childSC1.Scope_Group__c = scopeGroup.Id;
    insert child_childSC1;
    
    E2_Effort__c effort1 = E2_Test_Utils.insertEffort(true, parentSC.Id);

    lstAssets = new List<CMC_Asset__c>();
    lstAssets.add(E2_Test_Utils.insertAsset('Test Asset 1', 'Test asset record', 'Component', 'User Interface', 
  									        'Apex', 'Salesforce;Data integration', 1, 'Active', false));
    lstAssets.add(E2_Test_Utils.insertAsset('Test Asset 2', 'Test asset record', 'Component', 'User Interface', 
  									        'Apex', 'Salesforce;Data integration', 1, 'Active', false));
  	lstAssets.add(E2_Test_Utils.insertAsset('Test Asset 3', 'Test asset record', 'Component', 'User Interface', 
  									        'Apex', 'Salesforce;Data integration', 1, 'Active', false));
  	insert lstAssets;								        

  	recommendedAsset = E2_Test_Utils.insertRecommendedAsset(parentSC.id, lstAssets[0].id, true);
  	
  	Contact con  = E2_Test_Utils.insertContact(acc.Id, true);
  	
  	asetContributor = new CMC_Asset_Contributor__c();
  	asetContributor.Contact__c = con.Id;
  	asetContributor.Asset__c = lstAssets[0].Id;
  	asetContributor.Hours_Contributed__c = 4;
  	asetContributor.Primary_Contact__c = true;
  	insert asetContributor;
  	
  	ques1 = E2_Test_Utils.insertQuestions(parentSC.Id, true);
  	ans1 = E2_Test_Utils.insertAnswer(ques1.Id, true);
  	
  	actionScope = new E2_Action_Scope__c(Answer__c = ans1.Id, Scope__c = parentSC.Id);
    insert actionScope;
  	
       
  }
}