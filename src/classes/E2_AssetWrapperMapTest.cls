/**=====================================================================
 * Appirio, Inc
 * Name                 : E2_AssetWrapperMapTest
 * Description  : Test class for E2_AssetWrapperMap
 * Created Date : July 28th, 2016
 * Created By       : Vikash Goyal (Appirio)
 * 
 * Date Modified      Modified By                  Description of the update

*  =====================================================================*/
@isTest
private class E2_AssetWrapperMapTest {

    static testMethod void testAssetWrapperMap() {
        User sysAdmin = E2_Test_Utils.insertSysAdminUser(false);
        CMC_Asset__c assetRec = [SELECT Name, Short_Description__c, Technologies__c, Asset_Type__c, 
                                 Asset_SubType__c, Appirio_Services_Practice__c, Total_Hours__c, Reuse_LOE__c,
                                                         Number_of_Uses__c, Is_Recommended__c, Release_Stage__c
                                                         FROM CMC_Asset__c limit 1];    
      System.runAs(sysAdmin){
        Test.startTest();
        E2_AssetWrapper assetRec1 = new E2_AssetWrapper(assetRec.Id, assetRec.Name, assetRec.Short_Description__c, 'primaryContributors', 
                                assetRec.Technologies__c,   assetRec.Release_Stage__c, assetRec.Asset_Type__c, assetRec.Asset_SubType__c, assetRec.Appirio_Services_Practice__c, 
                                assetRec.Number_of_Uses__c, false, 10, assetRec.Reuse_LOE__c);
        System.assertEquals(assetRec1.assetName, 'Test Asset');
        
        E2_AssetWrapperMap assetWrapperMap = new E2_AssetWrapperMap('tes', new List<E2_AssetWrapper>{assetRec1});
        System.assertEquals(assetWrapperMap.searchKey, 'tes');
        Test.stopTest();
      }
    }
    
    //create test data
    @testSetup 
    static void createTestData(){
        CMC_Asset__c assetRec = E2_Test_Utils.insertAsset('Test Asset', 'Test asset record', 'Component', 'User Interface', 
                                                                            'Apex', 'Salesforce', 1, 'Active', true); 
    }
}