/**=====================================================================
 * Appirio, Inc
 * Name: E2_Estimator_WSManagerTest
 * Description: Test class to E2_Estimator_WSManager web service manager 
 * Created Date: May 13, 2016
 * Created By: Rohit Sharma (Appirio)
 * 
 * Date Modified      Modified By                  Description of the update
 * Nov 07, 2016       Jitendra Jangid              S-448268: Cloned scope item on right click
 * Nov 22, 2016       Jitendra Jangid              I-244800: E2_Estimator_WSManagerTest test class got failed while running test in prod.
 * Nov 24, 2016       Jitendra Jangid              Placed all SOQL queries inside Start and Stop test block in all Test Methods.
*  =====================================================================*/
@isTest(seeAllData=false)
public class E2_Estimator_WSManagerTest {
  public static CMC_Presales_LOE__c estimate;
  public static E2_Scope__c parentSC, childSC, child_childSC, parentSC1, childSC1, child_childSC1,grpParentScope,grpChildScope;
  public static E2_Scope_Group__c scopeGroup;
  public static E2_Recommended_Asset__c recommendedAsset;
  public static Id recTypeId = E2_RecordTypeClass.getId(E2_Constants.E2_SCOPE_API_NAME, E2_Constants.SCOPE_RT_TEMPLATE); 
  public static CMC_Asset_Contributor__c asetContributor;
  public static E2_Question__c ques1;
  public static E2_Answer__c ans1;
  public static E2_Action_Scope__c actionScope;
  public static List<CMC_Asset__c> lstAssets;
  public static User sysAdmin;
  
  public static testmethod void testRetrieveAllScopeTreeNodesOnEstimateId(){
       sysAdmin = getSysAdminUser();
       
       System.runAs(sysAdmin){
           Test.startTest();
           
           estimate = [SELECT Id, Name FROM CMC_Presales_LOE__c];
           
           List<E2_TreeNode> treeLst = E2_Estimator_WSManager.retrieveAllScopeTreeNodesOnEstimateId(estimate.Id);
           System.assertEquals(6, treeLst.size(), 'Does not return 6 scopes associated with the estimate.');
           
           Test.stopTest();
        }
  }

  public static testmethod void testGetChildScopeDetailNodes(){
       sysAdmin = getSysAdminUser();
       
       System.runAs(sysAdmin){
           Test.startTest();
          
           parentSC = [SELECT Id, Name,Source_Scope__c, Complexity__c, Scope_Item_Type__c, Scope_Flag__c, LOE_Hrs__c, Is_Active__c
                      FROM E2_Scope__c WHERE Parent_Scope__c = null AND RecordTypeId != :recTypeId AND Name='Parent_Scope_001'];
           
           E2_TreeNodeMap treeMap = E2_Estimator_WSManager.getChildScopeDetailNodes(parentSC.Id);
           System.assertEquals(treeMap.nodeList.size(), 1, 'Doesnot return 1 scope child to parent scope');
           
           Test.stopTest();
       }
  }
  
  public static testmethod void testGetScopeDetailNodes(){
       sysAdmin = getSysAdminUser();
                  
       System.runAs(sysAdmin){
           Test.startTest();
           
           parentSC = [SELECT Id, Name,Source_Scope__c, Complexity__c, Scope_Item_Type__c, Scope_Flag__c, LOE_Hrs__c, Is_Active__c
                  FROM E2_Scope__c WHERE Parent_Scope__c = null AND RecordTypeId != :recTypeId AND Name='Parent_Scope_001'];
           childSC = [SELECT Id, Name, Source_Scope__c, Complexity__c, Scope_Item_Type__c, Scope_Flag__c, LOE_Hrs__c, Is_Active__c
                  FROM E2_Scope__c WHERE Parent_Scope__c = :parentSC.Id];
           
           E2_TreeNodeMap treeMap = E2_Estimator_WSManager.getScopeDetailNodes(parentSC.Id);
           System.assertEquals(parentSC.Id, treeMap.scope_id, 'returns same scope id');
           System.assertEquals(treeMap.nodeList.size(), 1, 'Does not return 1 scope related to scope id');
           
           Test.stopTest();
       }
  }
  
  public static testmethod void testGetParentNodesWithEffortsOnEstimateId(){
       sysAdmin = getSysAdminUser();
       
       System.runAs(sysAdmin){
           Test.startTest();
           
           estimate = [SELECT Id, Name FROM CMC_Presales_LOE__c];
           
           List<E2_TreeNode> treeLst = E2_Estimator_WSManager.getParentNodesWithEffortsOnEstimateId(estimate.Id);
           System.assertEquals(2, treeLst.size() , 'Does not return 2 parent node attached with estimate.');   
           
           Test.stopTest();
       }
  }
  
  public static testmethod void testGetImmediateChildNodesWithEffortsOnScopeId(){
       sysAdmin = getSysAdminUser();
                      
       System.runAs(sysAdmin){
           Test.startTest();
           
           parentSC = [SELECT Id, Name,Source_Scope__c, Complexity__c, Scope_Item_Type__c, Scope_Flag__c, LOE_Hrs__c, Is_Active__c
                      FROM E2_Scope__c WHERE Parent_Scope__c = null AND RecordTypeId != :recTypeId AND Name='Parent_Scope_001'];
           
           List<E2_TreeNode> treeLst =  E2_Estimator_WSManager.getImmediateChildNodesWithEffortsOnScopeId(parentSC.Id);
           System.assertEquals(treeLst.size(), 1 + 1, 'Doesnot return the only immediate child scope and only effort to this scope');
           
           Test.stopTest();
       }
  }
  
  public static testmethod void testCloneScopeWithChild(){
       
       sysAdmin = getSysAdminUser();
       
       
       System.runAs(sysAdmin){
           Test.startTest();
           
           parentSC = [SELECT Id, Name,Source_Scope__c, Complexity__c, Scope_Item_Type__c, Scope_Flag__c, LOE_Hrs__c, Is_Active__c
                  FROM E2_Scope__c WHERE Parent_Scope__c = null AND RecordTypeId != :recTypeId AND Name='Parent_Scope_001'];
           childSC = [SELECT Id, Name, Source_Scope__c, Complexity__c, Scope_Item_Type__c, Scope_Flag__c, LOE_Hrs__c, Is_Active__c
                  FROM E2_Scope__c WHERE Parent_Scope__c = :parentSC.Id];
           String scopeToBeCloned= parentSC.Id +',' + childSC.Id;
           
           List<E2_TreeNode> resultedClonedNode=E2_Estimator_WSManager.cloneScopeWithChild(scopeToBeCloned);
           system.assert(resultedClonedNode != null && resultedClonedNode.size() == 2, 'Unit test failed: selected scope has not been successfully cloned.'+resultedClonedNode.size());
          
           Test.stopTest();
       }
   }
   
  public static testmethod void testGetClonedNodesTemplate(){
       
       sysAdmin = getSysAdminUser();
       
       System.runAs(sysAdmin){
           Test.startTest();
           
           List<E2_Scope__c> lsParentSC = [SELECT Id, Name,Source_Scope__c, Complexity__c, Scope_Item_Type__c, Scope_Flag__c, LOE_Hrs__c, Is_Active__c
                  FROM E2_Scope__c WHERE Parent_Scope__c = null AND RecordTypeId != :recTypeId];
           childSC = [SELECT Id, Name, Source_Scope__c, Complexity__c, Scope_Item_Type__c, Scope_Flag__c, LOE_Hrs__c, Is_Active__c
                  FROM E2_Scope__c WHERE Parent_Scope__c = :lsParentSC[0].Id];
           child_childSC = [SELECT Id, Name, Source_Scope__c, Complexity__c, Scope_Item_Type__c, Scope_Flag__c, LOE_Hrs__c, Is_Active__c
                       FROM E2_Scope__c WHERE Parent_Scope__c = :childSC.Id]; 
                       
           childSC1 = [SELECT Id, Name, Source_Scope__c, Complexity__c, Scope_Item_Type__c, Scope_Flag__c, LOE_Hrs__c, Is_Active__c
                  FROM E2_Scope__c WHERE Parent_Scope__c = :lsParentSC[1].Id];
           child_childSC1 = [SELECT Id, Name, Source_Scope__c, Complexity__c, Scope_Item_Type__c, Scope_Flag__c,LOE_Hrs__c, Is_Active__c
                         FROM E2_Scope__c WHERE Parent_Scope__c = :childSC1.Id];
           scopeGroup = [SELECT Id, Name FROM E2_Scope_Group__c];
       
           String scopeIds = lsParentSC[0].Id+ ','+ child_childSC.Id+ ',' + lsParentSC[1].Id+ ','+ child_childSC1.Id ; 
          
           List<E2_TreeNode> cloned_msg = E2_Estimator_WSManager.getClonedNodesTemplate(scopeIds, scopeGroup.Id, lsParentSC[0].Id);
           system.assertNotEquals(cloned_msg.size(), 0, 'Success message is returned');
          
           Test.stopTest();
       }
   }
  
  public static testmethod void testRetrieveAllScopeTreeNodesOnScopeGroup(){
       
       sysAdmin = getSysAdminUser();
       
       System.runAs(sysAdmin){
           Test.startTest();
       
           scopeGroup = [SELECT Id, Name FROM E2_Scope_Group__c];
               
           List<E2_TreeNode> treeLst1 = E2_Estimator_WSManager.retrieveAllScopeTreeNodesOnScopeGroup(scopeGroup.Id);
           System.assertEquals(2,treeLst1.size(), 'Does not return 2 scopes associated with the group.');
          
           Test.stopTest();
       }
   }
  
  public static testmethod void testUpdateScopeFlag(){
       
       sysAdmin = getSysAdminUser();
       
       System.runAs(sysAdmin){
           Test.startTest();
       
           estimate = [SELECT Id, Name FROM CMC_Presales_LOE__c];
           parentSC = [SELECT Id, Name,Source_Scope__c, Complexity__c, Scope_Item_Type__c, Scope_Flag__c, LOE_Hrs__c, Is_Active__c
                      FROM E2_Scope__c WHERE Parent_Scope__c = null AND RecordTypeId != :recTypeId AND name='Parent_Scope_001'];
           
           string error=E2_Estimator_WSManager.updateScopeFlag(estimate.Id,'flagred');
           System.assert(error.startsWith('Failed:'), 'Unit Test failed: An error should be generated since estimate id has passed instead of scope id.');
           
           
           error = E2_Estimator_WSManager.updateScopeFlag(E2_constants.BLANK,'flagred');  
           System.assertEquals(error, 'Failed to update: Current scope not identified!!!');
           
           string result=E2_Estimator_WSManager.updateScopeFlag(parentSC.Id,'flagred');
           System.assertEquals(result,parentSC.Id);
           result=E2_Estimator_WSManager.updateScopeFlag(parentSC.Id,'flagyellow');
           System.assertEquals(result,parentSC.Id);
           result=E2_Estimator_WSManager.updateScopeFlag(parentSC.Id,'flaggreen');
           System.assertEquals(result,parentSC.Id);
           
           Test.stopTest();
       }
   }
  
  public static testmethod void testGetFormatedScopeName(){
       
       sysAdmin = getSysAdminUser();
       
       System.runAs(sysAdmin){
           Test.startTest();
           
           parentSC = [SELECT Id, Name,Source_Scope__c, Complexity__c, Scope_Item_Type__c, Scope_Flag__c, LOE_Hrs__c, Is_Active__c
                      FROM E2_Scope__c WHERE Parent_Scope__c = null AND RecordTypeId != :recTypeId AND Name='Parent_Scope_001'];
           childSC = [SELECT Id, Name, Source_Scope__c, Complexity__c, Scope_Item_Type__c, Scope_Flag__c, LOE_Hrs__c, Is_Active__c
                      FROM E2_Scope__c WHERE Parent_Scope__c = :parentSC.Id];
       
           
          String test_scopeName = E2_Estimator_WSManager.getFormatedScopeName(parentSC);
          system.assert(test_scopeName != null);
      
          test_scopeName = E2_Estimator_WSManager.getFormatedScopeName(childSC);
          system.assert(test_scopeName != null);
          
           Test.stopTest();
       }
   }
  
  public static testmethod void testReparentScope(){
       
       sysAdmin = getSysAdminUser();
       
       System.runAs(sysAdmin){
           Test.startTest();
       
           scopeGroup = [SELECT Id, Name FROM E2_Scope_Group__c];
           parentSC = [SELECT Id, Name,Source_Scope__c, Complexity__c, Scope_Item_Type__c, Scope_Flag__c, LOE_Hrs__c, Is_Active__c
                      FROM E2_Scope__c WHERE Parent_Scope__c = null AND RecordTypeId != :recTypeId AND Name='Parent_Scope_001'];
           childSC = [SELECT Id, Name, Source_Scope__c, Complexity__c, Scope_Item_Type__c, Scope_Flag__c, LOE_Hrs__c, Is_Active__c
                      FROM E2_Scope__c WHERE Parent_Scope__c = :parentSC.Id];
           
           String result=E2_Estimator_WSManager.reparentScope(scopeGroup.Id, null);
           system.assert(result.startsWith('Failed:'), 'Unit test failed: An error should be thrown when invalid scope id passed.');
           
           result=E2_Estimator_WSManager.reparentScope(E2_constants.BLANK, null);
           system.assertEquals(result, 'Failed to move: Current scope not identified!!!');
           
           result = E2_Estimator_WSManager.reparentScope(childSC.Id, null);
           System.assertEquals(result, childSC.id, 'Unit test failed: Reparenting unsuccessful.');
          
           Test.stopTest();
       }
   }
  
  public static testmethod void testUpdateScopesDisplayOrder(){
       
       sysAdmin = getSysAdminUser();
       
       
       System.runAs(sysAdmin){
           Test.startTest();
           
           parentSC = [SELECT Id, Name,Source_Scope__c, Complexity__c, Scope_Item_Type__c, Scope_Flag__c, LOE_Hrs__c, Is_Active__c
                  FROM E2_Scope__c WHERE Parent_Scope__c = null AND RecordTypeId != :recTypeId AND Name='Parent_Scope_001'];
           childSC = [SELECT Id, Name, Source_Scope__c, Complexity__c, Scope_Item_Type__c, Scope_Flag__c, LOE_Hrs__c, Is_Active__c
                      FROM E2_Scope__c WHERE Parent_Scope__c = :parentSC.Id];
           String jsonString = '[{"scopeId":"' + parentSC.id + '", "displayOrder":"1", "sequence":"1"},{"scopeId":"' + childSC.id + '", "displayOrder":"2", "sequence":"2"}]';
           
           String statusStr = E2_Estimator_WSManager.updateScopesDisplayOrder(jsonString);
           System.assertEquals(statusStr, 'success');
       
           Test.stopTest();
       }
   }
   
   public static testmethod void testGetSelectedScopeNodes(){
       
       sysAdmin = getSysAdminUser();
       
       System.runAs(sysAdmin){
           Test.startTest();
           
           estimate = [SELECT Id, Name FROM CMC_Presales_LOE__c];
           List<E2_Scope__c> lsParentSC = [SELECT Id, Name,Source_Scope__c, Complexity__c, Scope_Item_Type__c, Scope_Flag__c, LOE_Hrs__c, Is_Active__c
                      FROM E2_Scope__c WHERE Parent_Scope__c = null AND RecordTypeId != :recTypeId];
           childSC = [SELECT Id, Name, Source_Scope__c, Complexity__c, Scope_Item_Type__c, Scope_Flag__c, LOE_Hrs__c, Is_Active__c
                      FROM E2_Scope__c WHERE Parent_Scope__c = :lsParentSC[0].Id];
           child_childSC = [SELECT Id, Name, Source_Scope__c, Complexity__c, Scope_Item_Type__c, Scope_Flag__c, LOE_Hrs__c, Is_Active__c
                           FROM E2_Scope__c WHERE Parent_Scope__c = :childSC.Id];
           
           childSC1 = [SELECT Id, Name, Source_Scope__c, Complexity__c, Scope_Item_Type__c, Scope_Flag__c, LOE_Hrs__c, Is_Active__c
                      FROM E2_Scope__c WHERE Parent_Scope__c = :lsParentSC[1].Id];
           child_childSC1 = [SELECT Id, Name, Source_Scope__c, Complexity__c, Scope_Item_Type__c, Scope_Flag__c,LOE_Hrs__c, Is_Active__c
                             FROM E2_Scope__c WHERE Parent_Scope__c = :childSC1.Id];        
                      
           String scopeIds = lsParentSC[0].Id+ ','+ child_childSC.Id+ ',' + lsParentSC[1].Id+ ','+ child_childSC1.Id ; 
           
           
           List<E2_TreeNode> test_Scope1 =  E2_Estimator_WSManager.getSelectedScopeNodes(scopeIds, estimate.Id, null);
           system.assert(test_Scope1 != null);
          
           Test.stopTest();
       }
   }
  
   public static testmethod void testUpdateScopesStatus(){
       
       sysAdmin = getSysAdminUser();
       
       
       System.runAs(sysAdmin){
           Test.startTest();
           
           parentSC = [SELECT Id, Name,Source_Scope__c, Complexity__c, Scope_Item_Type__c, Scope_Flag__c, LOE_Hrs__c, Is_Active__c
                      FROM E2_Scope__c WHERE Parent_Scope__c = null AND RecordTypeId != :recTypeId AND Name='Parent_Scope_001'];
           childSC = [SELECT Id, Name, Source_Scope__c, Complexity__c, Scope_Item_Type__c, Scope_Flag__c, LOE_Hrs__c, Is_Active__c
                      FROM E2_Scope__c WHERE Parent_Scope__c = :parentSC.Id];
           child_childSC = [SELECT Id, Name, Source_Scope__c, Complexity__c, Scope_Item_Type__c, Scope_Flag__c, LOE_Hrs__c, Is_Active__c
                           FROM E2_Scope__c WHERE Parent_Scope__c = :childSC.Id];
                           
           string allscopesIds = parentSC.Id +',' + childSC.Id + ',' + child_childSC.Id;
           
           
           String scopestatus = E2_Estimator_WSManager.updateScopesStatus('Low', null, child_childSC.Id, allscopesIds);
           System.assertEquals(scopestatus, 'Success', 'Success message is returned');
      
           scopestatus = E2_Estimator_WSManager.updateScopesStatus(null, childSC.Id, null, allscopesIds);
           System.assertEquals(scopestatus, 'Success', 'Success message is returned');
           System.assertEquals(childSC.Is_Active__c, true);
          
           Test.stopTest();
       }
   }
  
    public static testmethod void testDeleteScopeWithUnauthorizedUser(){
       
       User noSysAdminUser=E2_Test_Utils.insertUser('Appirio SFDC Training Only', true);
       
       
       System.runAs(noSysAdminUser){
           Test.startTest();
           
           scopeGroup = [SELECT Id, Name FROM E2_Scope_Group__c];
           parentSC = [SELECT Id, Name,Source_Scope__c, Complexity__c, Scope_Item_Type__c, Scope_Flag__c, LOE_Hrs__c, Is_Active__c
                      FROM E2_Scope__c WHERE Parent_Scope__c = null AND RecordTypeId != :recTypeId AND Name='Parent_Scope_001'];
           childSC = [SELECT Id, Name, Source_Scope__c, Complexity__c, Scope_Item_Type__c, Scope_Flag__c, LOE_Hrs__c, Is_Active__c
                      FROM E2_Scope__c WHERE Parent_Scope__c = :parentSC.Id];
               
           String result = E2_Estimator_WSManager.deleteScope(childSC.Id, parentSC.Id);
           System.assert(result.startsWith('Failed'), 'Unit test failed: An error should be generated in order to insufficient privilege over Scope object.');
          
           Test.stopTest();
       }
    }
    
    
    public static testmethod void testDeleteScope(){
       
       sysAdmin = getSysAdminUser();
       
       
       System.runAs(sysAdmin){
           Test.startTest();
           
           scopeGroup = [SELECT Id, Name FROM E2_Scope_Group__c];
           parentSC = [SELECT Id, Name,Source_Scope__c, Complexity__c, Scope_Item_Type__c, Scope_Flag__c, LOE_Hrs__c, Is_Active__c
                      FROM E2_Scope__c WHERE Parent_Scope__c = null AND RecordTypeId != :recTypeId AND Name='Parent_Scope_001'];
           childSC = [SELECT Id, Name, Source_Scope__c, Complexity__c, Scope_Item_Type__c, Scope_Flag__c, LOE_Hrs__c, Is_Active__c
                      FROM E2_Scope__c WHERE Parent_Scope__c = :parentSC.Id];
           
           String result= E2_Estimator_WSManager.deleteScope(scopeGroup.Id, E2_Constants.HASH_TAG);    
           System.assert(result.startsWith('Failed:'), 'Unit test failed: An error should be generated when invalid scope id has passed.');
           
           String b_scopeId = E2_Estimator_WSManager.deleteScope(childSC.Id, parentSC.Id);
           System.assertEquals(b_scopeId, childSC.id, 'Not successfully deleting');
          
           Test.stopTest();
       }
    }
    
    public static testmethod void testGetExistingAssetsForScope(){
       
       sysAdmin = getSysAdminUser();
       
       System.runAs(sysAdmin){
           Test.startTest();
       
           parentSC = [SELECT Id, Name,Source_Scope__c, Complexity__c, Scope_Item_Type__c, Scope_Flag__c, LOE_Hrs__c, Is_Active__c
                  FROM E2_Scope__c WHERE Parent_Scope__c = null AND RecordTypeId != :recTypeId AND Name='Parent_Scope_001'];
           
           String existing_assets = E2_Estimator_WSManager.getExistingAssetsForScope(parentSC.Id);
           system.assert(existing_assets != null);
          
           Test.stopTest();
       }
    }
    
    
     public static testmethod void testSearchAssets(){
       
       sysAdmin = getSysAdminUser();
       
       System.runAs(sysAdmin){
           Test.startTest();
           
           parentSC = [SELECT Id, Name,Source_Scope__c, Complexity__c, Scope_Item_Type__c, Scope_Flag__c, LOE_Hrs__c, Is_Active__c
                  FROM E2_Scope__c WHERE Parent_Scope__c = null AND RecordTypeId != :recTypeId AND Name='Parent_Scope_001'];
           recommendedAsset = [SELECT Scope__c, Asset__c FROM E2_Recommended_Asset__c];
           
           lstAssets=[Select id from CMC_Asset__c];
           Id [] fixedSearchResults= new Id[lstAssets.size()];
           Integer idx=0;
           for(CMC_Asset__c objAsset:lstAssets){
              fixedSearchResults[idx]= objAsset.id;
              idx++;
           }
           
           Test.setFixedSearchResults(fixedSearchResults);

           String existing_assets = E2_Estimator_WSManager.getExistingAssetsForScope(parentSC.Id);
           List<string> exisitingAssetIds = new List<string>{recommendedAsset.Asset__c};
           
           E2_AssetWrapperMap assetMap = E2_Estimator_WSManager.searchAssets('Test', exisitingAssetIds);
           System.assertEquals('Test',assetMap.searchKey);
           System.assertEquals(3,assetMap.assetList.size());
          
           Test.stopTest();
       }
    }
    
  private static User getSysAdminUser(){
      User admin=[Select Id from user where firstName='test user' AND lastname='Testing'];
      return admin;
  }
  @testSetup
  private static void createTestData(){
    sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
    
    Account acc = E2_Test_Utils.insertAccount(false);
    acc.Name= 'Appirio';
    insert acc;
    
    Opportunity opp = E2_Test_Utils.insertOpportunity(acc.Id, true);
    
    Presales_Request__c psr = E2_Test_Utils.insertPresalesReq(opp.Id, 'Demo', true);
    estimate = E2_Test_Utils.insertEstimate(psr.Id, true);
    
    // Scope items related to the Scope Group
    scopeGroup = E2_Test_Utils.insertScopeGroup(true);
    grpParentScope=E2_Test_Utils.insertScope(false);
    grpParentScope.Parent_Scope__c = null;
    grpParentScope.name='Scope_Group_Parent_Scope_001';
    grpParentScope.Complexity__c = 'Low';
    grpParentScope.Source_Scope__c = null;
    grpParentScope.Scope_Group__c=scopeGroup.Id;
    grpParentScope.LOE_Hrs__c = 0;
    grpParentScope.RecordTypeId = recTypeId;
    insert grpParentScope;
    
    grpChildScope=E2_Test_Utils.insertScope(false);
    grpChildScope.Parent_Scope__c = grpParentScope.Id;
    grpChildScope.name='Scope_Group_Child_Scope_001';
    grpChildScope.Complexity__c = 'Low';
    grpChildScope.Source_Scope__c = null;
    grpChildScope.Scope_Group__c=scopeGroup.Id;
    grpChildScope.LOE_Hrs__c = 0;
    grpChildScope.RecordTypeId = recTypeId;
    insert grpChildScope;
    
    //Scope items related to the Pre-sales estimate
    parentSC = E2_Test_Utils.insertScope(false);
    parentSC.Presales_LOE__c = estimate.Id;
    parentSC.Parent_Scope__c = null;
    parentSC.name='Parent_Scope_001';
    parentSC.Complexity__c = 'Low';
    parentSC.Source_Scope__c = null;
    parentSC.LOE_Hrs__c = 0;
    insert parentSC;
    
    childSC = E2_Test_Utils.insertScope(false);
    childSC.Presales_LOE__c = estimate.Id;
    childSC.Parent_Scope__c = parentSC.Id;
    childSC.Complexity__c = 'Low';
    childSC.LOE_Hrs__c = 30;
    insert childSC;
    
    child_childSC = E2_Test_Utils.insertScope(false);
    child_childSC.Presales_LOE__c = estimate.Id;
    child_childSC.Parent_Scope__c = childSC.Id;
    child_childSC.Complexity__c = 'Low';
    child_childSC.LOE_Hrs__c = 30;
    insert child_childSC;
    
    parentSC1 = E2_Test_Utils.insertScope(false);
    parentSC1.Parent_Scope__c = null;
    parentSC1.Complexity__c = 'Low';
    parentSC1.name='Parent_Scope_002';
    parentSC1.Source_Scope__c = null;
    parentSC1.LOE_Hrs__c = 10;
    parentSC1.Presales_LOE__c=estimate.Id;
    insert parentSC1;
    
    childSC1 = E2_Test_Utils.insertScope(false);
    childSC1.Parent_Scope__c = parentSC1.Id;
    childSC1.Complexity__c = 'Low';
    childSC1.LOE_Hrs__c = 30;
    childSC1.Presales_LOE__c = estimate.Id;
    insert childSC1;
    
    child_childSC1 = E2_Test_Utils.insertScope(false);
    child_childSC1.Presales_LOE__c = estimate.Id;
    child_childSC1.Parent_Scope__c = childSC1.Id;
    child_childSC1.Complexity__c = 'Low';
    child_childSC1.LOE_Hrs__c = 30;
    insert child_childSC1;
    
    E2_Effort__c effort1 = E2_Test_Utils.insertEffort(true, parentSC.Id);
    effort1 = E2_Test_Utils.insertEffort(true, child_childSC.Id);

    lstAssets = new List<CMC_Asset__c>();
    lstAssets.add(E2_Test_Utils.insertAsset('Test Asset 1', 'Test asset record', 'Component', 'User Interface', 
  									        'Apex', 'Salesforce;Data integration', 1, 'Active', false));
    lstAssets.add(E2_Test_Utils.insertAsset('Test Asset 2', 'Test asset record', 'Component', 'User Interface', 
  									        'Apex', 'Salesforce;Data integration', 1, 'Active', false));
  	lstAssets.add(E2_Test_Utils.insertAsset('Test Asset 3', 'Test asset record', 'Component', 'User Interface', 
  									        'Apex', 'Salesforce;Data integration', 1, 'Active', false));
    lstAssets.add(E2_Test_Utils.insertAsset('Test Asset 4', 'Test asset record-1', 'Component', 'User Interface', 
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