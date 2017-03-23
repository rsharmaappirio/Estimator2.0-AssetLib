/**=====================================================================
 * Appirio, Inc
 * Name: E2_Clone_Estimate_WSTest
 * Description: Includes all test method to perform unit test over E2_Clone_Estimate_WS class.
 * Created Date: Nov 22, 2016
 * Created By: Jitendra Jangid (Appirio)
 * 
 * Date Modified      Modified By                  Description of the update
 * Nov 22, 2016       Jitendra Jangid              S-454105 :  Web service E2_Clone_Estimate_WS
 * Nov 24, 2016       Jitendra Jangid              Added new test methods[testCloneMilestoneWeeks()  and testcloneResourceWeeks()] and updated existing test methods[testCloneEstimateMilestone() and testCloneEstimateTimeline()] corresponding to changes noted in main class.
 * Feb 20, 2017       Jitendra Jangid              S-404442: Create multiple timelines on an estimate.
 * Feb 28, 2017       Jitendra Jangid              S-404442: Create multiple timelines on an estimate.[Changes all test methods since formal parameters of methods got changed.]    
*  =====================================================================*/

@isTest
private class E2_Clone_Estimate_WSTest{

  public static CMC_Presales_LOE__c estimate;
  public static E2_Scope__c parentSC, childSC, child_childSC, parentSC1, childSC1, child_childSC1;
  public static E2_Scope_Group__c scopeGroup;
  public static E2_Recommended_Asset__c recommendedAsset;
  public static Id recTypeId = E2_RecordTypeClass.getId(E2_Constants.E2_SCOPE_API_NAME, E2_Constants.SCOPE_RT_TEMPLATE); 
  public static CMC_Asset_Contributor__c asetContributor;
  public static E2_Question__c ques1;
  public static E2_Answer__c ans1;
  public static E2_Action_Scope__c actionScope;
  public static List<CMC_Asset__c> lstAssets;
  public static E2_Capacity__c capacity;
  public static User sysAdmin;
  
  public static testmethod void testCloneEstimate(){
       
       sysAdmin = getSysAdminUser();
       
       System.runAs(sysAdmin){
           Test.startTest();
           
            String wrapperJSON=getEstimateWrapper();
            string newEstimateId = E2_Clone_Estimate_WS.cloneEstimate(wrapperJSON);
            System.assert(newEstimateId.indexOf('Failed: ') == -1, 'Unit test failed: an error encountered while cloning estimate.');
          
           Test.stopTest();
       }
   }
   
   public static testmethod void testCloneEstimateScopes(){
       
       sysAdmin = getSysAdminUser();
       
       System.runAs(sysAdmin){
           Test.startTest();
           Presales_Request__c psr = [Select ID from Presales_Request__c];
          
           String wrapperJSON=getEstimateWrapper();
           
           wrapperJSON = E2_Clone_Estimate_WS.cloneEstimate(wrapperJSON);
           
           string scopeWrapperMapping = E2_Clone_Estimate_WS.cloneEstimateScopes(wrapperJSON);
           scopeWrapperMapping=scopeWrapperMapping.replaceFirst('ScopeMapping','');
           //System.assertEquals(returnMessage, 'success', 'Unit test failed: an error enclountered while cloning scopes.');
           //   returnMessage=E2_Clone_Estimate_WS.reParentClonedScopes(returnMessage, newEstimateId);
           String returnMessage=E2_Clone_Estimate_WS.reParentClonedScopes(scopeWrapperMapping);
           System.assert(!returnMessage.containsIgnoreCase('Failed'),'An error encountered while clonging milestone weeks.');
          
           Test.stopTest();
       }
   } 
   
   public static testmethod void testCloneEstimateCapacity(){
       
       sysAdmin = getSysAdminUser();
       
       System.runAs(sysAdmin){
           Test.startTest();
            String wrapperJSON=getEstimateWrapper();
            wrapperJSON = E2_Clone_Estimate_WS.cloneEstimate(wrapperJSON);
          
        //   String returnMessage = E2_Clone_Estimate_WS.cloneEstimateCapacity(estimate.Id , newEstimateId);
           String returnMessage = E2_Clone_Estimate_WS.cloneEstimateCapacity(wrapperJSON);
           System.assert(!returnMessage.containsIgnoreCase('Failed'), 'Unit test failed: an error encountered while cloning capacity.'+returnMessage);
           
           
           Test.stopTest();
       }
   } 
   
   public static testmethod void testCloneEstimateMilestone(){
       
       sysAdmin = getSysAdminUser();
       
       System.runAs(sysAdmin){
           Test.startTest();
           String wrapperJSON=getEstimateWrapper();
           wrapperJSON= E2_Clone_Estimate_WS.cloneEstimate(wrapperJSON);
           
           //String returnMessage = E2_Clone_Estimate_WS.cloneEstimateMilestone(estimate.Id , newEstimateId);
           String returnMessage = E2_Clone_Estimate_WS.cloneEstimateMilestone(wrapperJSON);
           System.assert(!returnMessage.equalsIgnoreCase('success') && !returnMessage.startsWith('Failed'), 'An error encountered while cloning estimate milestone.');
          
           Test.stopTest();
       }
    } 
    
    public static testmethod void testCloneMilestoneWeeks(){
       
       sysAdmin = getSysAdminUser();
       
       System.runAs(sysAdmin){
           Test.startTest();
          
           String wrapperJSON=getEstimateWrapper();
           wrapperJSON = E2_Clone_Estimate_WS.cloneEstimate(wrapperJSON);
           E2_Clone_Estimate_WSManager.EstimateWrapper wrapper=(E2_Clone_Estimate_WSManager.EstimateWrapper)JSON.deserialize(wrapperJSON,E2_Clone_Estimate_WSManager.EstimateWrapper.class);
           wrapper.partialClone=true;
           wrapper.estimateIsActive=true;
           wrapperJSON=JSON.serialize(wrapper);
         
           //String milestoneWeekJSON = E2_Clone_Estimate_WSManager.cloneEstimateMilestone(estimate.Id , newEstimateId);
           String milestoneWeekJSON = E2_Clone_Estimate_WSManager.cloneEstimateMilestone(wrapperJSON);
           milestoneWeekJSON=milestoneWeekJSON.replaceFirst('milestonemapping','');
            //System.assert(true == false, 'JSON: '+milestoneWeekJSON);
           
           //String returnMessage = E2_Clone_Estimate_WS.cloneMilestoneWeeks(milestoneWeekJSON , newEstimateId);
           String returnMessage = E2_Clone_Estimate_WS.cloneMilestoneWeeks(milestoneWeekJSON);
           System.assert(!returnMessage.containsIgnoreCase('Failed'), 'An error encountered while cloning milestone weeks.');
          
           Test.stopTest();
       }
    }
    
    
    
    public static testmethod void testCloneEstimateTimeline(){
       
       sysAdmin = getSysAdminUser();
       
       System.runAs(sysAdmin){
           Test.startTest();
           String wrapperJSON=getEstimateWrapper();
           wrapperJSON = E2_Clone_Estimate_WS.cloneEstimate(wrapperJSON);
          
           E2_Clone_Estimate_WSManager.EstimateWrapper wrapper=(E2_Clone_Estimate_WSManager.EstimateWrapper)JSON.deserialize(wrapperJSON,E2_Clone_Estimate_WSManager.EstimateWrapper.class);
           wrapper.partialClone=true;
           wrapper.estimateIsActive=true;
           wrapperJSON=JSON.serialize(wrapper);
           //String returnMessage = E2_Clone_Estimate_WS.cloneEstimateTimeline(estimate.Id , newEstimateId);
           String returnMessage = E2_Clone_Estimate_WS.cloneEstimateTimeline(wrapperJSON);
           System.assert(!returnMessage.equalsIgnoreCase('success') && !returnMessage.startsWith('Failed'), 'An error encountered while cloning timeline.'+returnMessage);
           
           Test.stopTest();
       }
   } 
   
   public static testmethod void testcloneResourceWeeks(){
       
       sysAdmin = getSysAdminUser();
       
       System.runAs(sysAdmin){
           Test.startTest();
           String wrapperJSON=getEstimateWrapper();
           List<CMC_Estimate_Resource_Week__c> lsResourceWeek=[Select Estimate_Resource__r.ID,Estimate_Resource__r.Estimate__c,
                                                               Estimate_Week__r.ID,Estimate_Week__r.Estimate__c 
                                                               FROM CMC_Estimate_Resource_Week__c];
           List<E2_Clone_Estimate_WSManager.EstimateWrapper> lsTimelineWrapper=new List<E2_Clone_Estimate_WSManager.EstimateWrapper>();
           
           wrapperJSON = E2_Clone_Estimate_WS.cloneEstimate(wrapperJSON);
           
           E2_Clone_Estimate_WSManager.EstimateWrapper wrapper=(E2_Clone_Estimate_WSManager.EstimateWrapper)JSON.deserialize(wrapperJSON,E2_Clone_Estimate_WSManager.EstimateWrapper.class);
        //   String newEstimateId=wrapper.newEstimateId;
           
           for(CMC_Estimate_Resource_Week__c rWeek: lsResourceWeek){
                CMC_Estimate_Resource__c estimateResource=rWeek.Estimate_Resource__r;
                CMC_Estimate_Resource__c clonedEstimateResource=estimateResource.clone(false, true, false, false);
                clonedEstimateResource.Estimate__c=wrapper.newEstimateId;
                insert clonedEstimateResource;
                CMC_Estimate_Week__c estimateWeek=rWeek.Estimate_Week__r;
                CMC_Estimate_Week__c clonedEstimateWeek=estimateWeek.clone(false, true, false, false);
                clonedEstimateWeek.Estimate__c=wrapper.newEstimateId;
                insert clonedEstimateWeek;
                E2_Clone_Estimate_WSManager.EstimateWrapper resource=new E2_Clone_Estimate_WSManager.EstimateWrapper();
                resource.key=rWeek.Estimate_Resource__r.ID;
                resource.value=clonedEstimateResource.id;
                resource.isWeek=false;
                resource.cloneFrom=wrapper.cloneFrom;
                E2_Clone_Estimate_WSManager.EstimateWrapper week=new E2_Clone_Estimate_WSManager.EstimateWrapper();
                week.key=rWeek.Estimate_Week__r.ID;
                week.value=clonedEstimateWeek.id;
                week.isWeek=true;
                week.cloneFrom=wrapper.cloneFrom;
                lsTimelineWrapper.add(resource);
                lsTimelineWrapper.add(week);
          }
          String jsonResourceWeek=JSON.serialize(lsTimelineWrapper);
           
           
           //String returnMessage = E2_Clone_Estimate_WS.cloneResourceWeeks(jsonResourceWeek, newEstimateId);
           String returnMessage = E2_Clone_Estimate_WS.cloneResourceWeeks(jsonResourceWeek);
           System.assert(!returnMessage.containsIgnoreCase('Failed'), 'An error encountered while cloning resource weeks.');
           
           Test.stopTest();
       }
   } 
   
   
   
   public static testmethod void testDeleteEstimate(){
       
       sysAdmin = getSysAdminUser();
       
       System.runAs(sysAdmin){
           Test.startTest();
           String wrapperJSON=getEstimateWrapper();
           wrapperJSON = E2_Clone_Estimate_WS.cloneEstimate(wrapperJSON);
           E2_Clone_Estimate_WSManager.EstimateWrapper wrapper=(E2_Clone_Estimate_WSManager.EstimateWrapper)JSON.deserialize(wrapperJSON,E2_Clone_Estimate_WSManager.EstimateWrapper.class);
           String newEstimateId=wrapper.newEstimateId;
           String returnMessage = E2_Clone_Estimate_WS.deleteEstimate(newEstimateId);
           System.assertEquals(returnMessage, 'success', 'An error encountered while deleting estimate.');
          
           Test.stopTest();
       }
    }
    
    // Added new test method to cover all methods releated to the timeline[Jitendra Jangid: 20th Feb, 2017]
    public static testmethod void testMultiTimelineMethods(){
       
       sysAdmin = getSysAdminUser();
       
       System.runAs(sysAdmin){
           Test.startTest();
           estimate = [SELECT Id, Name,CurrencyIsoCode FROM CMC_Presales_LOE__c];
           String timelineJSON='[{"cloneFrom":"'+estimate.ID+'","currencyISOCode":"'+estimate.CurrencyIsoCode+'","isWeek":true,"isNewTimeline":false}]';
           timelineJSON=E2_Clone_Estimate_WS.createNewTimeline(timelineJSON);
           timelineJSON=E2_Clone_Estimate_WS.cloneTimelineRateCards(timelineJSON);
           list<E2_Clone_Estimate_WSManager.EstimateWrapper> mappingList = (list<E2_Clone_Estimate_WSManager.EstimateWrapper>)JSON.deserialize(timelineJSON, list<E2_Clone_Estimate_WSManager.EstimateWrapper>.class);
           system.assert(mappingList.get(0).newTimelineId != null, 'Assert Failed: New estimate has not been created.');  
           
           String result=E2_Clone_Estimate_WS.cloneTimelineVersion(timelineJSON);
           system.assert(!result.contains('failed'), 'Assert Failed: an error received in response of cloneTimelineVersion method calling.');  
           
           result=E2_Clone_Estimate_WS.cloneResourceWeeksTimelineVersion(timelineJSON);
           system.assert(!result.contains('failed'), 'Assert Failed: an error received in response of cloneResourceWeeksTimelineVersion method calling.');  
           
           Test.stopTest();
       }
   } 
	
	
  private static String getEstimateWrapper(){
      estimate = [SELECT Id, Name FROM CMC_Presales_LOE__c];
      E2_Clone_Estimate_WSManager.EstimateWrapper wrapper=new E2_Clone_Estimate_WSManager.EstimateWrapper();
      wrapper.cloneFrom=estimate.Id;
      
      return JSON.serialize(wrapper);
      
  }	
  private static User getSysAdminUser(){
      User admin=[Select Id from user where firstName='test user' AND lastname='Testing'];
      return admin;
  }
  @testSetup
  private static void createTestData(){
      sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
    
    Account acc = E2_Test_Utils.insertAccount(false);
    acc.Name= 'Appirio';
    insert acc;
    
    Opportunity opp = E2_Test_Utils.insertOpportunity(acc.Id, true);
    
    Presales_Request__c psr = E2_Test_Utils.insertPresalesReq(opp.Id, 'Demo', true);
    estimate = E2_Test_Utils.insertEstimate(psr.Id, true);
    
    //Scope items related to the Pre-sales estimate
    parentSC = E2_Test_Utils.insertScope(false);
    parentSC.Presales_LOE__c = estimate.Id;
    parentSC.Parent_Scope__c = null;
    parentSC.name='Parent_Scope_001';
    parentSC.Complexity__c = 'Low';
    parentSC.Source_Scope__c = null;
    parentSC.LOE_Hrs__c = 0;
    insert parentSC;
    
    childSC = E2_Test_Utils.insertScope(false);
    childSC.Presales_LOE__c = estimate.Id;
    childSC.Parent_Scope__c = parentSC.Id;
    childSC.Complexity__c = 'Low';
    childSC.LOE_Hrs__c = 30;
    insert childSC;
    
    child_childSC = E2_Test_Utils.insertScope(false);
    child_childSC.Presales_LOE__c = estimate.Id;
    child_childSC.Parent_Scope__c = childSC.Id;
    child_childSC.Complexity__c = 'Low';
    child_childSC.LOE_Hrs__c = 30;
    insert child_childSC;
    
    parentSC1 = E2_Test_Utils.insertScope(false);
    parentSC1.Parent_Scope__c = null;
    parentSC1.Complexity__c = 'Low';
    parentSC1.name='Parent_Scope_002';
    parentSC1.Source_Scope__c = null;
    parentSC1.LOE_Hrs__c = 10;
    parentSC1.Presales_LOE__c=estimate.Id;
    insert parentSC1;
    
    childSC1 = E2_Test_Utils.insertScope(false);
    childSC1.Parent_Scope__c = parentSC1.Id;
    childSC1.Complexity__c = 'Low';
    childSC1.LOE_Hrs__c = 30;
    childSC1.Presales_LOE__c = estimate.Id;
    insert childSC1;
    
    child_childSC1 = E2_Test_Utils.insertScope(false);
    child_childSC1.Presales_LOE__c = estimate.Id;
    child_childSC1.Parent_Scope__c = childSC1.Id;
    child_childSC1.Complexity__c = 'Low';
    child_childSC1.LOE_Hrs__c = 30;
    insert child_childSC1;
    
    E2_Effort__c effort1 = E2_Test_Utils.insertEffort(true, parentSC.Id);
    effort1 = E2_Test_Utils.insertEffort(true, child_childSC.Id);

    capacity=new E2_Capacity__c();
    capacity.Estimator__c=estimate.Id;
    insert capacity;
    

    lstAssets = new List<CMC_Asset__c>();
    lstAssets.add(E2_Test_Utils.insertAsset('Test Asset 1', 'Test asset record', 'Component', 'User Interface', 
  									        'Apex', 'Salesforce;Data integration', 1, 'Active', false));
    lstAssets.add(E2_Test_Utils.insertAsset('Test Asset 2', 'Test asset record', 'Component', 'User Interface', 
  									        'Apex', 'Salesforce;Data integration', 1, 'Active', false));
  	lstAssets.add(E2_Test_Utils.insertAsset('Test Asset 3', 'Test asset record', 'Component', 'User Interface', 
  									        'Apex', 'Salesforce;Data integration', 1, 'Active', false));
    lstAssets.add(E2_Test_Utils.insertAsset('Test Asset 4', 'Test asset record-1', 'Component', 'User Interface', 
  									        'Apex', 'Salesforce;Data integration', 1, 'Active', false));
  	insert lstAssets;								        

  	recommendedAsset = E2_Test_Utils.insertRecommendedAsset(parentSC.id, lstAssets[0].id, true);
  	
  	Contact con  = E2_Test_Utils.insertContact(acc.Id, true);
  	
  	asetContributor = new CMC_Asset_Contributor__c();
  	asetContributor.Contact__c = con.Id;
  	asetContributor.Asset__c = lstAssets[0].Id;
  	asetContributor.Hours_Contributed__c = 4;
  	asetContributor.Primary_Contact__c = true;
  	insert asetContributor;
  	
  	ques1 = E2_Test_Utils.insertQuestions(parentSC.Id, true);
  	ans1 = E2_Test_Utils.insertAnswer(ques1.Id, true);
  	
  	actionScope = new E2_Action_Scope__c(Answer__c = ans1.Id, Scope__c = parentSC.Id);
    insert actionScope;
    
    //Insert Capacity Records
    
    
      	
  	pse__Region__c region = E2_Test_Utils.insertRegion(true);
    pse__Practice__c practice = E2_Test_Utils.insertPractice(true);
    
    pse__Rate_Card__c rateCard = E2_Test_Utils.insertRateCard(acc.Id, region.Id, practice.Id, true);
    
    E2_Estimate_Rate_Card__c estimateRC = E2_Test_Utils.insertEstimateRateCard(estimate.Id, true);
    
    CMC_Estimate_Resource__c resource = E2_Test_Utils.insertCMCEstimateRes(estimate.Id, true);
    
    CMC_Estimate_Week__c week = E2_Test_Utils.insertEstimateWeek(estimate.Id, true);
    CMC_Estimate_Resource_Week__c resWeek = E2_Test_Utils.insertCMCEstimateResWeek(resource.Id, week.Id, true);
    E2_Estimate_Week_Milestone__c weekMilestones = new E2_Estimate_Week_Milestone__c(Name = 'Week1',Estimate__c = estimate.Id, Order__c = 2,
                                                         Date__c = system.today());
    insert weekMilestones;
    E2_Estimate_Milestone__c milestone = E2_Test_Utils.insertEstimateMilestone(estimate.Id, true);
    E2_Estimate_Milestone_Week__c milestoneWk = new E2_Estimate_Milestone_Week__c(Estimate_Milestone__c = milestone.Id, Estimate_Week_Milestone__c = weekMilestones.Id, 
                                                         TextColorCode__c = 'Red'); 
    insert milestoneWk;
  }

}