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
        }    
    }
}