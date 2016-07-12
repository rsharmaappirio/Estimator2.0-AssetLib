@isTest(seeAllData=false)
public class E2_CapacityControllerTest {
    
  public static testmethod void testCapacity(){
      
    User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
    
    System.runAs(sysAdmin){
        Test.startTest();
            CMC_Presales_LOE__c estimate = [SELECT Id,E2_Last_Build_Datetime__c,E2_Derived_Effort_Template__c FROM CMC_Presales_LOE__c];
            PageReference pageRef = Page.E2_Capacity;
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController stdController = new ApexPages.StandardController(estimate);
            E2_CapacityController controller = new E2_CapacityController(stdController);
            controller.buildCapacity();
            controller.pageAction();
            system.assertEquals(controller.phases.size(), 1);
        system.assertEquals(controller.skillsPhases.size(), 1);
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
    insert derivedEfforts;
    Account acc = E2_Test_Utils.insertAccount(true);
    Opportunity opp = E2_Test_Utils.insertOpportunity(acc.Id, true);    
    Presales_Request__c psr = E2_Test_Utils.insertPresalesReq(opp.Id, 'Demo', true);
    CMC_Presales_LOE__c estimate = E2_Test_Utils.insertEstimate(psr.Id, false); 
    estimate.E2_Derived_Effort_Template__c = derivedEffGrp.Id; 
    insert estimate;
    E2_Scope__c scope = E2_Test_Utils.insertScope(false);
    List<E2_Scope__c> scopeLst = new List<E2_Scope__c>();
    scope.Presales_LOE__c = estimate.Id;
    scopeLst.add(scope);
    E2_Scope__c scope1 = E2_Test_Utils.insertScope(false);
    scope1.Presales_LOE__c = estimate.Id;
    scope1.Complexity__c = 'medium';  
    scopeLst.add(scope1);
    E2_Scope__c scope2 = E2_Test_Utils.insertScope(false);
    scope2.Presales_LOE__c = estimate.Id;
    scope2.Complexity__c = 'low';
    scopeLst.add(scope2);
    E2_Scope__c scope3 = E2_Test_Utils.insertScope(false);
    scope3.Presales_LOE__c = estimate.Id;
    scope3.Complexity__c = 'high';
    scopeLst.add(scope3);
    insert scopeLst;
    pse__Skill__c skill = new pse__Skill__c(Name = 'Javascript',pse__Type__c = 'Technologies',pse__Skill_Or_Certification__c = 'skill');
    insert skill; 
    E2_Effort__c effort1 = E2_Test_Utils.insertEffort(false, scopeLst[0].Id);
    effort1.Speciality__c = skill.Id;
    E2_Effort__c effort2 = E2_Test_Utils.insertEffort(false, scopeLst[1].Id);
    E2_Effort__c effort3 = E2_Test_Utils.insertEffort(false, scopeLst[2].Id);
    E2_Effort__c effort4 = E2_Test_Utils.insertEffort(false, scopeLst[3].Id);
    List<E2_Effort__c> effortLst = new List<E2_Effort__c>();
    effortLst.add(effort1);
    effortLst.add(effort2);
    effortLst.add(effort3);
    effortLst.add(effort4);
    insert effortLst;
      
    
    
  }

}