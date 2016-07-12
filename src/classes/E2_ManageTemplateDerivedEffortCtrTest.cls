@isTest(seeAllData=false)
public class E2_ManageTemplateDerivedEffortCtrTest {

    public static testmethod void testTemplates() {
     User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
     System.runAs(sysAdmin){
        Test.startTest();
            E2_Derived_Effort_Group__c derivedEffGrp = [SELECT Id,Name FROM E2_Derived_Effort_Group__c];
            ApexPages.StandardController stdController = new ApexPages.StandardController(derivedEffGrp);
            E2_ManageTemplateDerivedEffortController controller = new E2_ManageTemplateDerivedEffortController(stdController);
            controller.pageAction();
            system.assertEquals(controller.derivedEffortTemplates.size(), 4,'Doesnot return 4 derived efforts associated with estimate');
            controller.derivedEffortTemplates.get(2).toPhase.clear();
            controller.updateEfforts();
            system.assertEquals(controller.hasErrorEffort, true);         
            controller.derivedEffortTemplates.get(0).remove();
            controller.derivedEffortTemplates.get(2).toPhase.clear();
            controller.derivedEffortTemplates.get(2).toPhase.add('Architect');
            controller.derivedEffortTemplates.get(1).ofPhase.clear();
            controller.derivedEffortTemplates.get(1).toPhase.add('Strategy');
            controller.addNewEffort();
            system.assertEquals(controller.derivedEffortTemplates.size(), 5,'Doesnot return 5 new derived efforts.');
             for(E2_ManageTemplateDerivedEffortController.DerivedEffortTemplate dETemplate3 : controller.derivedEffortTemplates) {
                 if(dETemplate3.isNew) {
                    dETemplate3.name ='test';
                    dETemplate3.ofRole = 'Developer';
                    dETemplate3.toRole = 'Project Manager';
                    dETemplate3.toPhase.add('Build');
                    dETemplate3.toPhase.add('Architect');
                    dETemplate3.toPhase.add('Plan');
                    dETemplate3.ofPhase.clear();
                    dETemplate3.allocation = 30;
                    dETemplate3.includeWhen = 'hours exceed';
                    dETemplate3.includeWhenHrs = 20;
                 }
             }  
            controller.updateEfforts();
            system.assertEquals(controller.hasErrorEffort, true);
            system.assertEquals(controller.derivedEffortTemplates.size(), 5,'Doesnot return 4 derived efforts associated with estimate');
        Test.stopTest();  
     }
  }
  
  //create test data
  @testSetup
  private static void createTestData(){
    E2_Derived_Effort_Group__c derivedEffGrp  = E2_Test_Utils.insertDerivedEffort(false);
    derivedEffGrp.Description__c = 'Calculate Capacity';
    insert derivedEffGrp;
    List<E2_Derived_Effort__c> derivedEfforts = new List<E2_Derived_Effort__c>();
    Id devRecordTypeId = Schema.SObjectType.E2_Derived_Effort__c.getRecordTypeInfosByName().get('Template').getRecordTypeId();
    derivedEfforts.add(E2_Test_Utils.insertDerivedEffort('Project Manager', 'Build', 'Project Manager', 'Build', devRecordTypeId, derivedEffGrp.Id, false));
    derivedEfforts.add(E2_Test_Utils.insertDerivedEffort('Project Manager', 'Build', 'Project Manager', Null, devRecordTypeId, derivedEffGrp.Id, false));
    derivedEfforts.add(E2_Test_Utils.insertDerivedEffort('Project Manager', 'Build', Null, 'Build', devRecordTypeId, derivedEffGrp.Id, false));
    derivedEfforts.add(E2_Test_Utils.insertDerivedEffort('Project Manager', 'Build', Null, Null, devRecordTypeId, derivedEffGrp.Id, false));
    E2_Derived_Effort__c dE = E2_Test_Utils.insertDerivedEffort('Project Manager', 'Plan', 'Project Manager', 'Plan', devRecordTypeId, derivedEffGrp.Id, false);
    dE.Original_Allocation_Hours__c = 20;
    dE.UniqueKey__c = derivedEfforts.get(0).UniqueKey__c;
    derivedEfforts.get(1).UniqueKey__c = '';
    derivedEfforts.add(dE);
    insert derivedEfforts;
  }
}