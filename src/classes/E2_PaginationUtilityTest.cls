@isTest(seeAllData=false)
public class E2_PaginationUtilityTest {
  
  public static testmethod void testPagination(){
      
    User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
    
    Account acc = E2_Test_Utils.insertAccount(true);
    Opportunity opp = E2_Test_Utils.insertOpportunity(acc.Id, true);
    
    Presales_Request__c psr = E2_Test_Utils.insertPresalesReq(opp.Id, 'Demo', false);
    insert psr;
    Id recTypeId = E2_RecordTypeClass.getId(E2_Constants.E2_SCOPE_API_NAME, E2_Constants.SCOPE_RT_SCOPE);
    
    CMC_Presales_LOE__c estimate = E2_Test_Utils.insertEstimate(psr.id, false);  
    insert estimate;
    
    List<E2_Scope__c> customList = new List<E2_Scope__c>();
    
    for(Integer i=0; i<=50; i++){
      E2_Scope__c scope1 =  E2_Test_Utils.insertScope(false);
      scope1.recordTypeId = recTypeId;
      scope1.Presales_LOE__c = estimate.id;
      customList.add(scope1);
    }
    insert customList;
    
    List<Object> result = new List<Object> ();
    System.runAs(sysAdmin){
        Test.startTest();
          E2_PaginationUtility pageUtil = new E2_PaginationUtility();
          system.assertEquals(pageUtil.setPagination(new List<Object>()).size(),0);
          system.assertEquals(pageUtil.getPage(0), NULL);
          system.assertEquals(pageUtil.next(), NULL);
          system.assertEquals(pageUtil.previous(), NULL);
          system.assertEquals(pageUtil.first(), NULL);
          system.assertEquals(pageUtil.getShowingFrom(), 0);
          system.assertEquals(pageUtil.isMorePrevious, false);
          system.assertEquals(pageUtil.isMoreNext, false);
          pageUtil.setPagination(customList);  
          pageUtil.getPage(1);
          pageUtil.next();
          system.assertEquals(pageUtil.isMoreNext, false);
          pageUtil.previous();
          system.assertEquals(pageUtil.isMorePrevious, false);          
          pageUtil.first();
          pageUtil.last();
          system.assertEquals(pageUtil.totalPage, 3);
          pageUtil.getShowingFrom();
          pageUtil.getShowingTo();
          pageUtil.getRecordsList();
          system.assertEquals(pageUtil.listOfLinks.size(), 3);
        Test.stopTest();  
     }
  }
  
  public static testmethod void testPagination2(){
      
    User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
    
    List<Object> customList = new List<Object>();

    System.runAs(sysAdmin){
        Test.startTest();
          E2_PaginationUtility pageUtil = new E2_PaginationUtility();
          system.assertEquals(pageUtil.setPagination(customList), new List<Object>());  
          pageUtil.getPage(1);
          pageUtil.next();
          pageUtil.previous();
          system.assertEquals(pageUtil.first(), null);
          system.assertEquals(pageUtil.totalPage, 0);
          system.assertEquals(pageUtil.getShowingFrom(), 0);
          pageUtil.getShowingTo();
          pageUtil.getRecordsList();
          system.assertEquals(pageUtil.isMorePrevious, false);
          system.assertEquals(pageUtil.isMoreNext, false);
        Test.stopTest();  
     }
  }

}