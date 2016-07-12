@isTest(seeAllData=false)
public class E2_AddEditDerivedEffortsControllerTest {

  public static testmethod void testAddEditDerivedEfforts() {
    CMC_Presales_LOE__c estimate = [SELECT Id, E2_Derived_Effort_Template__c, Name FROM CMC_Presales_LOE__c];
    string derivedEffortGroup = estimate.E2_Derived_Effort_Template__c;
    //create sys admin user
    User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
    System.runAs(sysAdmin){
      //start test
      Test.startTest();
          PageReference pageRef = Page.E2_AddEditDerivedEfforts;
          Test.setCurrentPage(pageRef);
          ApexPages.StandardController stdController = new ApexPages.StandardController(estimate);  
          E2_AddEditDerivedEffortsController controller = new E2_AddEditDerivedEffortsController(stdController);        
          controller.pageAction();
          system.assertEquals(controller.clonnedDerivedEffortList.size(), 4,'Doesnot return 4 derived efforts associated with estimate');
          controller.removeDerivedEffort();
          controller.deffortTemplateIds = derivedEffortGroup;
          controller.cloneDerivedEffort();
          controller.buildCapacity();
          controller.deffortTemplateIds = 'test';
          controller.save();
          controller.estimate = null;
          controller.removeDerivedEffort();
          Test.stopTest();  
    }   
  }
    
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
    derivedEfforts.add(dE);
    
    insert derivedEfforts;
    Account acc = E2_Test_Utils.insertAccount(true);
    Opportunity opp = E2_Test_Utils.insertOpportunity(acc.Id, true);    
    Presales_Request__c psr = E2_Test_Utils.insertPresalesReq(opp.Id, 'Demo', true);
    CMC_Presales_LOE__c estimate = E2_Test_Utils.insertEstimate(psr.Id, false); 
    estimate.E2_Derived_Effort_Template__c = derivedEffGrp.Id; 
    insert estimate;
  }
}