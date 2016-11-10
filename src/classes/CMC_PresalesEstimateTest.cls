/**=====================================================================
 * Appirio, Inc
 * Name: CMC_PresalesEstimateTest
 * Description: This class includes test method to run unit test over CMC_PresalesEstimate class.
 * Created Date: 
 * Created By: 
 * 
 * Date Modified      Modified By                  Description of the update
 * Nov 07, 2016       Jitendra Jangid              S-452048: Display a meaningful error message when inadvertently setting the Primary Estimate as the Primary
 * 
 * *  =====================================================================*/
@isTest(seeAllData=false)
public class CMC_PresalesEstimateTest {

// (c) Appirio
//
// Testing CMC_PresalesEstimate.cls
//
// 2014-10-13		Will Supinski	created

//NOTE - most of this test is commented out because it hits a soql limit just creating records... completely 
// irrelevant to the code to be tested. 
//  the test currently meets the code coverage requirements as it stands
    public static testMethod void testSwitchDefault() {
      //create 2 estimates under the same PSR
      Opportunity opp = [SELECT Id FROM Opportunity];
      Presales_Request__c psr = [SELECT Id FROM Presales_Request__c];
      list<CMC_Presales_LOE__c> estimates = [SELECT Id, Product__c, Default__c FROM CMC_Presales_LOE__c];
      CMC_Presales_LOE__c estimate = null;
      CMC_Presales_LOE__c estimate1 = null;
      for(CMC_Presales_LOE__c persalesLOE : estimates) {
          if(persalesLOE.Default__c == false)
            estimate = persalesLOE;
          else
            estimate1 = persalesLOE;
      }
        User sysAdmin = E2_Test_Utils.insertSysAdminUser(true);    
        System.runAs(sysAdmin){
             //start test
            Test.startTest();  
            
            CMC_Epic__c epic = new CMC_Epic__c();
            epic.Epic_Name__c = 'testingEpic1';
            epic.Product__c = estimate1.Product__c;
            insert epic;
            
            CMC_Component__c comp = new CMC_Component__c();
            comp.Name = 'Default Component';
            comp.Product__c = estimate1.Product__c;
            insert comp;
            
            CMC_Story__c story = new CMC_Story__c();
            story.Component__c = comp.Id;
            story.Epic__c = epic.Id;
            story.Story_Name__c = 'Testing Story';
            insert story;
            
            CMC_Asset_Usage__c au = new CMC_Asset_Usage__c();
            au.Story__c = story.Id;
            au.Opportunity__c = opp.Id; //this is set because it is on the default estimate
            insert au;
            
            CMC_PresalesEstimate.setPrimary(estimate.Id, psr.Id);
            
            List<CMC_Presales_LOE__c> est2list = [SELECT Id, Default__c FROM CMC_Presales_LOE__c WHERE Id = :estimate.Id];
            CMC_Presales_LOE__c est2 = est2list[0];
            //make sure the default flags are set properly
            System.AssertEquals(est2.Default__c, true);
            //S-452048: Display a meaningful error message when inadvertently setting the Primary Estimate as the Primary
            String resultMessage=CMC_PresalesEstimate.setPrimary(estimate.Id, psr.Id);
            system.assertEquals('The Presales Estimate you have selected is already marked as the Primary.', resultMessage);
            //S-452048: End
            //stop test
            Test.stopTest();
        }
    }
    
    @testSetup 
  public static void createTestData(){
    Account acc = E2_Test_Utils.insertAccount(true);
    Opportunity opp = E2_Test_Utils.insertOpportunity(acc.Id, true);
    Presales_Request__c psr = E2_Test_Utils.insertPresalesReq(opp.Id, 'Demo', true);
    
        CMC_Product__c prod = new CMC_Product__c();
        prod.Name = 'Testing oldDefault';
        prod.Account__c = acc.Id;
        insert prod;
        
        list<CMC_Presales_LOE__c> estimates = new list<CMC_Presales_LOE__c>();
        CMC_Presales_LOE__c estimate1 = E2_Test_Utils.insertEstimate(psr.id, false);
        estimate1.Default__c = true;
        estimate1.Name = 'Testing oldDefault';
        estimate1.Product__c = prod.Id;
        estimates.add(estimate1);

        CMC_Presales_LOE__c estimate2 = new CMC_Presales_LOE__c();
        estimate2.Default__c = false;
        estimate2.Presales_Request__c = psr.Id;
        estimate2.Name = 'Testing newDefault';
        estimates.add(estimate2);
        
        insert estimates; 
  }
}