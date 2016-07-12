@isTest(seeAllData=false)
public class E2_SelectDerEffortTemplateControllerTest {
  public static List<E2_Derived_Effort_Group__c> derEffList;
  
  public static testmethod void testSelectDerivedEffort(){
    User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
    derEffList = [SELECT Id, Name FROM E2_Derived_Effort_Group__c ];
    
    System.runAs(sysAdmin){
      //start test
        Test.startTest();
        
            PageReference pageRef = Page.E2_SelectDerivedEffortTemplate;
            Test.setCurrentPage(pageRef);
            E2_SelectDerivedEffortTemplateController controller = new E2_SelectDerivedEffortTemplateController();
            controller.pageAction();
            system.assertEquals(controller.derivedGroups.size(), 3, '3 Derived Effort Group records are loaded');
            
            controller.searchGroup = 'SFDC Test';
            controller.getList();
            controller.selectTemplateEfforts();
            system.assertEquals(controller.derivedGroups.size(), 1, '1 Derived Effort Group record loaded for searchGroup- SFDC Test');
            
            controller.clearTemplateSearch();
        Test.stopTest();  
     }
  }
  
  @testsetup public static void createTestData(){
    E2_Derived_Effort_Group__c derivedEffGrp1 =  E2_Test_Utils.insertDerivedEffort(false);
    derivedEffGrp1.Description__c = 'Calculate Capacity';
    
    E2_Derived_Effort_Group__c derivedEffGrp2 =  E2_Test_Utils.insertDerivedEffort(false);
    derivedEffGrp2.Description__c = 'Calculate Capacity';
    
    E2_Derived_Effort_Group__c derivedEffGrp3 =  E2_Test_Utils.insertDerivedEffort(false);
    derivedEffGrp3.Name = 'SFDC Test';
    derivedEffGrp3.Description__c = 'Calculate Capacity';
    
    derEffList = new List<E2_Derived_Effort_Group__c>();
    derEffList.add(derivedEffGrp1);
    derEffList.add(derivedEffGrp2);
    derEffList.add(derivedEffGrp3);
    insert derEffList;
    
   
  }

}