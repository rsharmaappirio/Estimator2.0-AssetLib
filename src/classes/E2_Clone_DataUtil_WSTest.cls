/**=====================================================================
 * Appirio, Inc
 * Name: E2_Clone_DataUtil_WSTest
 * Description: Class include all test methods uses to perform unit test over E2_Clone_DataUtil_WS class.
 * Created Date: Nov 23rd, 2016
 * Created By: Jitendra Jangid (Appirio)
 * 
 * Date Modified      Modified By                  Description of the update
 * Nov 23, 2016       Jitendra Jangid              S-454105 : Utility class as Data Tier for E2_Clone_Estimate_WS (webservice)
 * Feb 27, 2017       Jitendra Jangid              S-404442: Create multiple timelines on an estimate.[Updated few mathods calling since method signature got changed.]
*  =====================================================================*/

@isTest
private class E2_Clone_DataUtil_WSTest {
    
private static CMC_Presales_LOE__c estimate;
private static User sysAdmin;

@isTest
public static void testGetEstimateFullDetailById(){
    sysAdmin=getSysAdminUser();
    
    system.runAs(sysAdmin){
        Test.startTest();
        estimate=[Select ID from CMC_Presales_LOE__c];
        
        List<CMC_Presales_LOE__c> lsEstimate= E2_Clone_DataUtil_WS.getEstimateFullDetailById(estimate.ID);
        System.assert(lsEstimate.size()==1, 'Unit test failed: unable to retrieve estimate details with '+estimate.ID +' estimate_id.');
        
        Test.stopTest();
    }
    
}

@isTest
public static void testGetFullScopesDetailsByEstimateId(){
    sysAdmin=getSysAdminUser();
    
    system.runAs(sysAdmin){
        Test.startTest();
        estimate=[Select ID from CMC_Presales_LOE__c];
        List<E2_scope__c> lsScope= E2_Clone_DataUtil_WS.getFullScopesDetailsByEstimateId(estimate.ID);
        System.assert(lsScope.size()==2, 'Unit test failed: unable to retrieve all scope associated with '+estimate.ID +' estimate_id.');
        
        Test.stopTest();
    }
}

@isTest
public static void testGetCapacityListByEstimateId(){
    sysAdmin=getSysAdminUser();
    
    system.runAs(sysAdmin){
        Test.startTest();
        estimate=[Select ID from CMC_Presales_LOE__c];
        List<E2_Capacity__c> lsCapacity= E2_Clone_DataUtil_WS.getCapacityListByEstimateId(estimate.ID);
        System.assert(lsCapacity.size()==2, 'Unit test failed: unable to retrieve all capacity associated with '+estimate.ID +' estimate_id.');
        
        Test.stopTest();
    }
}

@isTest
public static void testGetEstimateWeekMilestonesByEstimateId(){
    
    sysAdmin=getSysAdminUser();
    
    system.runAs(sysAdmin){
        Test.startTest();
        estimate=[Select ID from CMC_Presales_LOE__c];
        list<E2_Estimate_Week_Milestone__c> lsWeekMilestone= E2_Clone_DataUtil_WS.getEstimateWeekMilestonesByEstimateId(estimate.ID);
        System.assert(lsWeekMilestone.size()==1, 'Unit test failed: unable to retrieve all milestone week associated with '+estimate.ID +' estimate_id.');
        
        Test.stopTest();
    }
}

@isTest
public static void testGetEstimateMilestonesByEstimateId(){
    
    
    sysAdmin=getSysAdminUser();
    
    system.runAs(sysAdmin){
        Test.startTest();
        estimate=[Select ID from CMC_Presales_LOE__c];
        list<E2_Estimate_Milestone__c> lsEstimateMilestone= E2_Clone_DataUtil_WS.getEstimateMilestonesByEstimateId(estimate.ID);
        System.assert(lsEstimateMilestone.size()==1, 'Unit test failed: unable to retrieve all milestones associated with '+estimate.ID +' estimate_id.');
        
        Test.stopTest();
    }
}

@isTest
public static void testGetMilestonesWeeks(){
    
    sysAdmin=getSysAdminUser();
    
    system.runAs(sysAdmin){
        Test.startTest();
        E2_Estimate_Milestone__c milestone=[Select ID from E2_Estimate_Milestone__c];
        Set<String> setMilestoneID=new Set<String>();
        setMilestoneID.add(milestone.ID);
        
        E2_Estimate_Week_Milestone__c weekMilestone=[Select ID from E2_Estimate_Week_Milestone__c];
        Set<String> setWeekID=new Set<String>();
        setWeekID.add(weekMilestone.ID);
        list<E2_Estimate_Milestone_Week__c> lsMileStoneWeek= E2_Clone_DataUtil_WS.getMilestonesWeeks(setMilestoneID,setWeekID);
        System.assert(lsMileStoneWeek.size()==1, 'Unit test failed: unable to retrieve all milestone week associated with estimate_id.');
        
        Test.stopTest();
    }
}

@isTest
public static void testGetEstimateRateCardsByEstimateId(){
    
    sysAdmin=getSysAdminUser();
    
    system.runAs(sysAdmin){
        Test.startTest();
        Set<String> setEstimateID=getEstimateIDSet();
        
        list<E2_Estimate_Rate_Card__c> lsRateCard= E2_Clone_DataUtil_WS.getEstimateRateCardsByEstimateId(setEstimateID);
        System.assert(lsRateCard.size()==1, 'Unit test failed: unable to retrieve all rate cards associated with estimate.');
        
        Test.stopTest();
    }
}

@isTest
public static void testGetEstimateWeekMByEstimateId(){
    
    sysAdmin=getSysAdminUser();
    
    system.runAs(sysAdmin){
        Test.startTest();
        Set<String> setEstimateID=getEstimateIDSet();
        list<CMC_Estimate_Week__c> lsTimelineWeek= E2_Clone_DataUtil_WS.getEstimateWeekMByEstimateId(setEstimateID);
        System.assert(lsTimelineWeek.size()==1, 'Unit test failed: unable to retrieve all timeline week associated with estimate.');
        
        Test.stopTest();
    }
}

@isTest
public static void testGetResourceRequestByEstimateId(){
    
    sysAdmin=getSysAdminUser();
    
    system.runAs(sysAdmin){
        Test.startTest();
        Set<String> setEstimateID=getEstimateIDSet();
        list<CMC_Estimate_Resource__c> lsEstimateResource = E2_Clone_DataUtil_WS.getResourceRequestByEstimateId(setEstimateID);
        System.assert(lsEstimateResource.size()==1, 'Unit test failed: unable to retrieve all resources associated with estimate.');
        
        Test.stopTest();
    }
}

@isTest
public static void testGetResourceWeeks(){
    
    
    sysAdmin=getSysAdminUser();
    
    system.runAs(sysAdmin){
        Test.startTest();
        CMC_Estimate_Resource__c resource=[Select ID from CMC_Estimate_Resource__c];
        Set<String> setResourceID=new Set<String>();
        setResourceID.add(resource.ID);
        
        CMC_Estimate_Week__c week=[Select ID from CMC_Estimate_Week__c];
        Set<String> setWeekID=new Set<String>();
        setWeekID.add(week.ID);
        list<CMC_Estimate_Resource_Week__c> lsTimelineWeek = E2_Clone_DataUtil_WS.getResourceWeeks(setResourceID,setWeekID);
        System.assert(lsTimelineWeek.size()==1, 'Unit test failed: unable to retrieve all timeline weeks associated based on resources and weeks');
        
        Test.stopTest();
    }
}

private static Set<String> getEstimateIDSet(){
    Set<String> setEstimateID=new Set<String>();
    for(CMC_Presales_LOE__c est:[Select ID from CMC_Presales_LOE__c]){
       setEstimateID.add(est.ID);
    }
    
    return setEstimateID;
}
private static User getSysAdminUser(){
    sysAdmin=E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN,true);
    return sysAdmin;
} 

@testSetup
private static void createTestData(){
    
    // sysAdmin=E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN,true);
    Account acc = E2_Test_Utils.insertAccount(true);
    Opportunity opp = E2_Test_Utils.insertOpportunity(acc.Id, true);        
    Presales_Request__c psr = E2_Test_Utils.insertPresalesReq(opp.Id, 'Demo', true);
    estimate = E2_Test_Utils.insertEstimate(psr.Id, true);
    
    //Create Scopes and associate them with estimate.
    E2_Scope__c parentScope=E2_Test_Utils.insertScope(false);
    parentScope.Presales_LOE__c=estimate.ID;
    insert parentScope;
    
    E2_Scope__c childScope=E2_Test_Utils.insertScope(false);
    childScope.Presales_LOE__c=estimate.ID;
    childScope.Parent_Scope__c=parentScope.ID;
    childScope.Ultimate_Parent_Scope__c=parentScope.ID;
    insert childScope;
    
    //insert effort and associate it with child scope
    E2_Effort__c childEffort=E2_Test_Utils.insertEffort(true,childScope.ID);
    
    //insert capacity and associate them with estimate
    E2_Capacity__c capacity=new E2_Capacity__c();
    capacity.Estimator__c=estimate.ID;
    capacity.Role__c='Developer';
    capacity.Phase__c='Build';
    capacity.Hours__c=40;
    insert capacity;
    
    capacity=new E2_Capacity__c();
    capacity.Estimator__c=estimate.ID;
    capacity.Role__c='QA Tester';
    capacity.Phase__c='Test';
    capacity.Hours__c=40;
    insert capacity;
    
    
    //insert weeks over milestone and associate them with estimate
    E2_Estimate_Week_Milestone__c weekMilestones = new E2_Estimate_Week_Milestone__c(Name = 'Week1',Estimate__c = estimate.Id, Order__c = 1,Date__c = system.today());
    insert weekMilestones;
    E2_Estimate_Milestone__c milestone = E2_Test_Utils.insertEstimateMilestone(estimate.Id, true);
    E2_Estimate_Milestone_Week__c milestoneWk = new E2_Estimate_Milestone_Week__c(Estimate_Milestone__c = milestone.Id, Estimate_Week_Milestone__c = weekMilestones.Id,TextColorCode__c = 'Red'); 
    insert milestoneWk;
    
    //Insert Ratecard
    E2_Estimate_Rate_Card__c estimateRC = E2_Test_Utils.insertEstimateRateCard(estimate.Id, true);
    
    
    CMC_Estimate_Resource__c resource = E2_Test_Utils.insertCMCEstimateRes(estimate.Id, true);
    CMC_Estimate_Week__c week = E2_Test_Utils.insertEstimateWeek(estimate.Id, true);
    CMC_Estimate_Resource_Week__c resWeek = E2_Test_Utils.insertCMCEstimateResWeek(resource.Id, week.Id, true);
    
    
    
}
	
	

}