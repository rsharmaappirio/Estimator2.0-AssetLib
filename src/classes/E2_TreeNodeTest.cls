/**=====================================================================
 * Appirio, Inc
 * Name: E2_TreeNodeTest
 * Description: Include all test nethod to perform unit test over E2_TreeNode class 
 * Created Date: July 7th, 2016
 * Created By: Rohit Sharma (Appirio)
 * 
 * Date Modified      Modified By                  Description of the update
 * Dec 08, 2016       Jitendra Jangid              S-449145 :Ability to find the Scope by type,Complexity ,Q&A and assets assigned. 
*  =====================================================================*/

@isTest(seeAllData=false)
public class E2_TreeNodeTest {
   static testmethod void testcase1(){
        User sysAdmin = E2_Test_Utils.insertSysAdminUser(false);    
        System.runAs(sysAdmin){
            E2_TreeNode node1 = new E2_TreeNode('title', false, false, 'key');
            System.assertEquals(node1.title, 'title');
            E2_TreeNode node2 = new E2_TreeNode('title', false, false, 'key', 'parent');
            System.assertEquals(node2.title, 'title');
            E2_TreeNode node3 = new E2_TreeNode('id', 'string text', 'string parent', false, 'string sourceId');
            System.assertEquals(node3.id, 'id');
            E2_TreeNode node4 = new E2_TreeNode('string id','string title', 'string text', 'string parent', false, 'string sourceId', 'string node_type');
            System.assertEquals(node4.id, 'string id');
            E2_TreeNode node5 = new E2_TreeNode('string id', 'string text', 'string parent', false, 'string sourceId', 'string node_type');            
            System.assertEquals(node5.id, 'string id');
            E2_TreeNode node6 = new E2_TreeNode('string id', 'string text', 'string parent', false, 'string sourceId', 'Medium', 40, 'string description');            
            System.assertEquals(node6.id, 'string id');
            E2_TreeNode node7 = new E2_TreeNode('string id','string title', 'string text', 'string parent', false, 'string sourceId', 'string node_type', 3);
            System.assertEquals(node7.display_order, 3);
        }    
    }
    
    //Start: S-449145(Ability to find the Scope by type,Complexity ,Q&A and assets assigned)
    @isTest
    public static void testOverloadedConstructor_6(){
        User sysAdmin = E2_Test_Utils.insertSysAdminUser(false);    
        System.runAs(sysAdmin){
            Test.startTest();
             E2_TreeNode parentNode = new E2_TreeNode('string id','string title', 'string text', 'string parent', false, 'string sourceId', 'string node_type', 3,'High','Epic',true,true);
             System.assertEquals(parentNode.complexity,'High');
             System.assertEquals(parentNode.scope_type,'Epic');
             System.assertEquals(parentNode.hasQuestion,true);
             System.assertEquals(parentNode.hasAsset,true);
            Test.stopTest();
            
        }
    }

    @isTest
    public static void testOverloadedConstructor_8(){
        User sysAdmin = E2_Test_Utils.insertSysAdminUser(false);    
        System.runAs(sysAdmin){
            Test.startTest();
             E2_TreeNode parentNode = new E2_TreeNode('string id', 'string text', 'string parent', false, 'string sourceId', 'string node_type',1);
             System.assertEquals(parentNode.display_order,1);
             
            Test.stopTest();
            
        }
    }
    //Stop: S-449145(Ability to find the Scope by type,Complexity ,Q&A and assets assigned)
}