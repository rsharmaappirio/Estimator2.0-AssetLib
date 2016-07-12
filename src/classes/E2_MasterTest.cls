@isTest(seeAllData=false)
public class E2_MasterTest {
    public static E2_Scope__c scope;
    public static CMC_Presales_LOE__c estimate;
    public static List<E2_Effort__c> effortLst;  
    public static Id recTypeId = E2_RecordTypeClass.getId('E2_Scope__c', E2_Constants.SCOPE_RT_SCOPE);
    
    static testmethod void testcase1(){
        Presales_Request__c psr;
        estimate = E2_DataUtil.getEstimateDetailOnId([SELECT Id FROM CMC_Presales_LOE__c][0].Id)[0]; 
        User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
        psr =  [SELECT Id, Description__c, Name,Account_Name__c, Opportunity__r.Account.Id,Opportunity__c FROM Presales_Request__c];
        System.runAs(sysAdmin){
            //start test
            Test.startTest();
            PageReference pageRef = Page.E2_AddEditEstimate;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('psr_id', psr.Id);          
            ApexPages.StandardController stdController = new ApexPages.StandardController(new CMC_Presales_LOE__c());
            E2_AddEditEstimateController controller = new E2_AddEditEstimateController(stdController);
            controller.pageAction();
            System.assertNotEquals(controller.psrId, null, 'psrid is not null');
            
            stdController = new ApexPages.StandardController(estimate);
            controller = new E2_AddEditEstimateController(stdController);
            controller.pageAction();
            System.assertNotEquals(controller.psrId, null, 'psrid is not null');
            
            //validateAccess
            
            Test.stopTest();
        }    
  }
    
    //create test data
  @testSetup static void createTestData(){      
    User solArchitect, accExecutive, delReviewer; 
    Account acc;
    Opportunity opp;
    Presales_Request__c psr;
    E2_Scope__c scope1; 
      
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
    Id recTypeId1 = E2_RecordTypeClass.getId(E2_Constants.E2_SCOPE_API_NAME, E2_Constants.SCOPE_RT_SCOPE);
    
    CMC_Presales_LOE__c estimate1 = E2_Test_Utils.insertEstimate(psr.id, false);  
    insert estimate1;
      
    scope1 =  E2_Test_Utils.insertScope(false);
    scope1.recordTypeId = recTypeId1;
    scope1.Presales_LOE__c = estimate1.id;  
    insert scope1;
  }
}