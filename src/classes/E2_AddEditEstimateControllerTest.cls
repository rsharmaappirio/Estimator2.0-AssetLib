@isTest(seeAllData=false)
public class E2_AddEditEstimateControllerTest {
    
  public static testmethod void  testAddEstimate(){     
    Presales_Request__c psr =  [SELECT Id, Description__c, Name,Account_Name__c, Opportunity__r.Account.Id,Opportunity__c FROM Presales_Request__c];
    User sysAdmin = E2_Test_Utils.insertSysAdminUser(false);    
    System.runAs(sysAdmin){
            PageReference pageRef = Page.E2_AddEditEstimate;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('psr_id', psr.Id);
            CMC_Presales_LOE__c estimate = new CMC_Presales_LOE__c();
            ApexPages.StandardController stdController = new ApexPages.StandardController(estimate);
            E2_AddEditEstimateController controller = new E2_AddEditEstimateController(stdController);
            //start test
            Test.startTest();
              
              controller.pageAction();
              System.assertEquals(controller.estimate.id, null, 'Error:Estimate should not exists in this case');
                          
              //call save method
              controller.save();
              
              //Assert to check estimate record is created
              List<CMC_Presales_LOE__c> result = [SELECT Id FROM CMC_Presales_LOE__c WHERE Id =: estimate.Id];
              system.assertEquals(result.size(), 1, 'Estimate record is created');
              
              controller.saveAndNext();
              
              PageReference pg = controller.cancel();
              System.assertNotEquals(null, pg, 'Should return a page reference than null');
              
              
            //stop test
            Test.stopTest();
    }
  }
  
  
  public static testmethod void  testEditEstimate(){
    User solArchitect, accExecutive, delReviewer; 
    Account acc;
    Opportunity opp;
    Presales_Request__c psr;
    
    psr = [SELECT Id FROM Presales_Request__c];
    solArchitect = [SELECT Id FROM User WHERE firstName = :'Test SA'];
    accExecutive = [SELECT Id FROM User WHERE firstName = :'Test AE'];
    delReviewer = [SELECT Id FROM User WHERE firstName = :'Test Reviewer'];
    
    User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
    
    System.runAs(sysAdmin){
        PageReference pageRef = Page.E2_AddEditEstimate;
        Test.setCurrentPage(pageRef);
        
        CMC_Presales_LOE__c estimate = E2_Test_Utils.insertEstimate(psr.Id, false);
        estimate.E2_SA__c = solArchitect.Id;
        estimate.Delivery_Reviewer__c = delReviewer.Id;
        estimate.Account_Executive__c = accExecutive.Id;
        estimate.E2_Is_Primary__c = true;
        estimate.E2_Date_Scoped__c = system.today();
        estimate.Description__c = 'This is test description';
        insert estimate;
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(estimate);
        E2_AddEditEstimateController controller = new E2_AddEditEstimateController(stdController);
        //start test
        Test.startTest();
          controller.pageAction();
          
          controller.estimate.Description__c = 'This is test description on update';
          controller.save();
          
          //Assert to check estimate record is created
          List<CMC_Presales_LOE__c> result = [SELECT Id, Description__c  FROM CMC_Presales_LOE__c WHERE Id =: estimate.Id];
          system.assertEquals(result[0].Description__c , 'This is test description on update', 'Estimate record is updated');
          
          
          Pagereference pg = controller.buildCapacity();
          System.assertEquals(pg.getUrl(), Page.E2_Capacity.getURL() + '?id=' + controller.estimate.id, 'build capacity button should redirect to capacity page');
          
          controller.saveAndNext();
          
          controller.cancel();
        //stop test
        Test.stopTest();
    }
    
  }
  
  
  //create test data
  @testSetup static void createTestData(){
    User solArchitect, accExecutive, delReviewer; 
    Account acc;
    Opportunity opp;
    Presales_Request__c psr;
    
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
  }
}