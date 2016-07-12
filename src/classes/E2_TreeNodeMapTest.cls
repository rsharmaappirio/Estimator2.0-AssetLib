@isTest(seeAllData=false)
public class E2_TreeNodeMapTest {
    static testmethod void testcase1(){
        User sysAdmin = E2_Test_Utils.insertSysAdminUser(false);    
        System.runAs(sysAdmin){
             Test.startTest();
             E2_Scope__c scope = [SELECT ID FROM E2_Scope__c];
             E2_TreeNode node1 = new E2_TreeNode('title', false, false, 'key');
             System.assertEquals(node1.title, 'title', 'title should match');
             List<E2_TreeNode> nodeList = new List<E2_TreeNode>();
             nodeList.add(node1);
             E2_TreeNodeMap nodeMap = new E2_TreeNodeMap(scope.id, nodeList);
             System.assertEquals(nodeMap.scope_id, scope.id, 'Id should match');
             Test.stopTest();
        }    
    }
    
  //create test data
  @testSetup static void createTestData(){
    User solArchitect, accExecutive, delReviewer; 
    Account acc;
    Opportunity opp;
    Presales_Request__c psr;
    E2_Scope__c scope; 
      
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
    Id recTypeId = E2_RecordTypeClass.getId(E2_Constants.E2_SCOPE_API_NAME, E2_Constants.SCOPE_RT_SCOPE);
    
    CMC_Presales_LOE__c estimate = E2_Test_Utils.insertEstimate(psr.id, false);  
    insert estimate;
      
    scope =  E2_Test_Utils.insertScope(false);
    scope.recordTypeId = recTypeId;
    scope.Presales_LOE__c = estimate.id;  
    insert scope;  
  }
}