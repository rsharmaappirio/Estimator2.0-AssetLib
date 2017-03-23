/**=====================================================================
 * Appirio, Inc
 * Name: E2_Clone_Estimate_WSManagerTest
 * Description: Includes all test methods to perform unit test over E2_Clone_Estimate_WSManager class.
 * Created Date: Nov 22, 2016
 * Created By: Jitendra Jangid (Appirio)
 * 
 * Date Modified      Modified By                  Description of the update
 * Nov 22, 2016       Jitendra Jangid              S-454105 : Modal class to E2_Clone_Estimate_WS web service 
 * Nov 23, 2016       Jitendra Jangid              Updated testCloneEstimateMilestone() & testCloneEstimateTimeline() test methods to handle additional condition introduced due to change in corresponding methods of E2_Clone_Estimate_WSManager class 
 * Mar 02, 2017       Jitendra Jangid              S-404442: Create multiple timelines on an estimate.
 * Mar 07, 2017       Jitendra Jangid              S-404442: Create multiple timelines on an estimate[Updated few of test methods since signature of few methods got changed.]
*  =====================================================================*/

@isTest
private class E2_Clone_Estimate_WSManagerTest{
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
           string result = E2_Clone_Estimate_WSManager.cloneEstimate(wrapperJSON);
           System.assert(result.indexOf('Failed: ') == -1, 'An error encountered while cloning estimate.');
           
           // Invalid Estimate ID case
           result = E2_Clone_Estimate_WSManager.cloneEstimate(null);
           System.assert(result.containsIgnoreCase('Failed'), 'An error has to be reported since invalid JSON instance passed.');
          
           Test.stopTest();
       }
   }
   
  public static testmethod void testCloneEstimateScopes(){
       
       sysAdmin = getSysAdminUser();
       
       System.runAs(sysAdmin){
           Test.startTest();
           Presales_Request__c psr = [Select ID from Presales_Request__c];
           String wrapperJSON=getEstimateWrapper();
           
           wrapperJSON = E2_Clone_Estimate_WSManager.cloneEstimate(wrapperJSON);
           
           string scopeWrapperMapping = E2_Clone_Estimate_WSManager.cloneEstimateScopes(wrapperJSON);
           scopeWrapperMapping=scopeWrapperMapping.replaceFirst('ScopeMapping','');
           
           String returnMessage=E2_Clone_Estimate_WSManager.reParentClonedScopes(scopeWrapperMapping);
           System.assert(!returnMessage.containsIgnoreCase('Failed'),'An error encountered while reparenting cloned scopes.');
           
           // Invalid JSON for reParentClonedScopes
           returnMessage=E2_Clone_Estimate_WSManager.reParentClonedScopes(null);
           System.assert(returnMessage.containsIgnoreCase('Failed'),'An error has to be received since invalid JSON passed.');
           
        //   Estimate without scope
           CMC_Presales_LOE__c estimateWithoutScope = E2_Test_Utils.insertEstimate(psr.Id, true);
           E2_Clone_Estimate_WSManager.EstimateWrapper wrapper=(E2_Clone_Estimate_WSManager.EstimateWrapper)JSON.deserialize(wrapperJSON,E2_Clone_Estimate_WSManager.EstimateWrapper.class);
           wrapper.cloneFrom=estimateWithoutScope.Id;
           wrapper.newEstimateId=null;
           
           wrapperJSON = E2_Clone_Estimate_WSManager.cloneEstimate(JSON.serialize(wrapper));
           returnMessage = E2_Clone_Estimate_WSManager.cloneEstimateScopes(wrapperJSON);
           System.assert(!returnMessage.containsIgnoreCase('Failed'),'An error encountered while cloning estimate scopes.');
           
           // Invalid JSON
           returnMessage = E2_Clone_Estimate_WSManager.cloneEstimateScopes(null);
           System.assert(returnMessage.containsIgnoreCase('Failed'),'An error has to be receieved since invalid JSON passed.');
           
           Test.stopTest();
       }
   } 
   
  public static testmethod void testCloneEstimateCapacity(){
       
       sysAdmin = getSysAdminUser();
       
       System.runAs(sysAdmin){
           Test.startTest();
           String wrapperJSON=getEstimateWrapper();
           
           wrapperJSON = E2_Clone_Estimate_WSManager.cloneEstimate(wrapperJSON);
           
           String returnMessage = E2_Clone_Estimate_WSManager.cloneEstimateCapacity(wrapperJSON);
           System.assert(!returnMessage.containsIgnoreCase('Failed'), 'An error encountered while cloning capacity.');
           
           
           // Cover Catch block
           E2_Clone_Estimate_WSManager.EstimateWrapper wrapper=(E2_Clone_Estimate_WSManager.EstimateWrapper)JSON.deserialize(wrapperJSON,E2_Clone_Estimate_WSManager.EstimateWrapper.class);
           wrapper.newEstimateId=wrapper.newEstimateId+'1';
           returnMessage = E2_Clone_Estimate_WSManager.cloneEstimateCapacity(JSON.serialize(wrapper));
           System.assert(returnMessage.startsWith('Failed'), 'An error should be appared since invalid estimate ref has passed.');
           
           returnMessage = E2_Clone_Estimate_WSManager.cloneEstimateCapacity(null);
           System.assert(returnMessage.startsWith('Failed'), 'An error should be appared since invalid JSON passed.');
          
           Test.stopTest();
       }
   } 
   
  public static testmethod void testCloneEstimateMilestone(){
       
       sysAdmin = getSysAdminUser();
       
       System.runAs(sysAdmin){
           Test.startTest();
           String wrapperJSON=getEstimateWrapper();
       
           // Addiitonal Test Data for testCloneEstimateMilestone for special where cloneEstimateMilestone expects estimate without milestone.
           Presales_Request__c psr = [Select ID from Presales_Request__c];
           CMC_Presales_LOE__c estimateWithoutMilestone = E2_Test_Utils.insertEstimate(psr.Id, true);
           String wrapperJSONWithoutMilestone=getEstimateWrapper(estimateWithoutMilestone.ID,estimateWithoutMilestone.CurrencyIsoCode);
           
           wrapperJSON = E2_Clone_Estimate_WSManager.cloneEstimate(wrapperJSON);
           wrapperJSONWithoutMilestone=E2_Clone_Estimate_WSManager.cloneEstimate(wrapperJSONWithoutMilestone);
           
           //Result: JSON containing milestone week
           String returnMessage = E2_Clone_Estimate_WSManager.cloneEstimateMilestone(wrapperJSON);
           System.assert(!returnMessage.startsWith('Failed'),'An error encountered while clonging milestone.');
          
          //Result: Success message since estimate does not have milestone attached
           returnMessage = E2_Clone_Estimate_WSManager.cloneEstimateMilestone(wrapperJSONWithoutMilestone);
           System.assert(!returnMessage.startsWith('Failed'),'An error encountered while clonging milestone.');
          
           //Result: Failure since invalid new estimate ID passed       
           E2_Clone_Estimate_WSManager.EstimateWrapper wrapper=(E2_Clone_Estimate_WSManager.EstimateWrapper)JSON.deserialize(wrapperJSON,E2_Clone_Estimate_WSManager.EstimateWrapper.class);
           wrapper.newEstimateId=wrapper.newEstimateId+'1';
           returnMessage = E2_Clone_Estimate_WSManager.cloneEstimateMilestone(JSON.serialize(wrapper));
           System.assert(returnMessage.startsWith('Failed'), 'An error should be received since invalid estimate ref has passed.');
           
           // Invalid JSON
           returnMessage = E2_Clone_Estimate_WSManager.cloneEstimateMilestone(null);
           System.assert(returnMessage.startsWith('Failed'), 'An error should be received since invalid JSON passed.');
          
           Test.stopTest();
       }
    }
    
  @isTest
  public static void testCloneMilestoneWeeks(){
      
      sysAdmin = getSysAdminUser();
       
      System.runAs(sysAdmin){
           Test.startTest();
           String wrapperJSON=getEstimateWrapper();
           wrapperJSON = E2_Clone_Estimate_WSManager.cloneEstimate(wrapperJSON);
           E2_Clone_Estimate_WSManager.EstimateWrapper wrapper=(E2_Clone_Estimate_WSManager.EstimateWrapper)JSON.deserialize(wrapperJSON,E2_Clone_Estimate_WSManager.EstimateWrapper.class);
           wrapper.partialClone=true;
           wrapper.estimateIsActive=true;
           wrapperJSON=JSON.serialize(wrapper);
           
           String milestoneWeekJSON = E2_Clone_Estimate_WSManager.cloneEstimateMilestone(wrapperJSON);
           milestoneWeekJSON=milestoneWeekJSON.replaceFirst('milestonemapping','');
           
           String returnMessage=E2_Clone_Estimate_WSManager.cloneMilestoneWeeks(milestoneWeekJSON);
           System.assert(!returnMessage.containsIgnoreCase('Failed'),'An error encountered while clonging milestone weeks. ');
          
           //Result: Failure since invalid new estimate ID passed   
          list<E2_Clone_Estimate_WSManager.EstimateWrapper> lsWrapper=(list<E2_Clone_Estimate_WSManager.EstimateWrapper>)JSON.deserialize(milestoneWeekJSON,list<E2_Clone_Estimate_WSManager.EstimateWrapper>.class);
          lsWrapper.get(0).isWeek=null;
          returnMessage = E2_Clone_Estimate_WSManager.cloneMilestoneWeeks(JSON.serialize(lsWrapper));
          System.assert(returnMessage.startsWith('Failed'), 'An error should be appeared since invalid estimate ref has passed.');
          
          //Invalid JSON
          returnMessage = E2_Clone_Estimate_WSManager.cloneMilestoneWeeks(null);
          System.assert(returnMessage.startsWith('Failed'), 'An error should be received since invalid JSON passed.');
          
          Test.stopTest();
       }
      
      
  }
    
  public static testmethod void testCloneEstimateTimeline(){
       
       sysAdmin = getSysAdminUser();
       
       System.runAs(sysAdmin){
           Test.startTest();
           String wrapperJSON=getListEstimateWrapper();
       
           // Additional Test Data for testCloneEstimateTimeline for special scenario where cloneEstimateTimeline expects estimate without timeline(Ratecard).
           Presales_Request__c psr = [Select ID from Presales_Request__c];
           CMC_Presales_LOE__c estimateWithoutMilestone = E2_Test_Utils.insertEstimate(psr.Id, true);
           String wrapperJSONWithoutMilestone=getListEstimateWrapper(estimateWithoutMilestone.ID,estimateWithoutMilestone.currencyISOCode);
           
           // Clone Estimate for multi timeline
           wrapperJSON = E2_Clone_Estimate_WSManager.createNewTimeline(wrapperJSON);
           wrapperJSONWithoutMilestone=E2_Clone_Estimate_WSManager.createNewTimeline(wrapperJSONWithoutMilestone);
            
           List<E2_Clone_Estimate_WSManager.EstimateWrapper> lsWrapper=(List<E2_Clone_Estimate_WSManager.EstimateWrapper>)JSON.deserialize(wrapperJSON,List<E2_Clone_Estimate_WSManager.EstimateWrapper>.class);
           lsWrapper.get(0).partialClone=true;
           lsWrapper.get(0).estimateIsActive=true;
           lsWrapper.get(0).newEstimateId=lsWrapper.get(0).newTimelineId;
           wrapperJSON=JSON.serialize(lsWrapper.get(0));
        //   CMC_Presales_LOE__c estimeates=[Select ID,E2_Parent_Estimate__c,E2_Is_Active__c FROM CMC_Presales_LOE__c WHERE id =: lsWrapper.get(0).newTimelineId];
        //   System.assert(true==false, '==> '+estimeates.E2_Is_Active__c);
           String returnMessage = E2_Clone_Estimate_WSManager.cloneEstimateTimeline(wrapperJSON);
           System.assert(!returnMessage.startsWith('Failed'), 'An error encountered while cloning timeline.');
           
           
        // Branch coverage
           E2_Clone_Estimate_WSManager.EstimateWrapper wrapper=(E2_Clone_Estimate_WSManager.EstimateWrapper)JSON.deserialize(wrapperJSON,E2_Clone_Estimate_WSManager.EstimateWrapper.class);
           wrapper.estimateIsActive=false;
           wrapperJSON=JSON.serialize(wrapper);
           returnMessage = E2_Clone_Estimate_WSManager.cloneEstimateTimeline(wrapperJSON);
           System.assert(!returnMessage.startsWith('Failed'), 'An error encountered while cloning timeline.==>'+returnMessage);
        
           wrapper=(E2_Clone_Estimate_WSManager.EstimateWrapper)JSON.deserialize(wrapperJSON,E2_Clone_Estimate_WSManager.EstimateWrapper.class);
           wrapper.estimateIsActive=false;
           wrapper.partialClone=false;
           wrapperJSON=JSON.serialize(wrapper);
           returnMessage = E2_Clone_Estimate_WSManager.cloneEstimateTimeline(wrapperJSON);
           System.assert(!returnMessage.startsWith('Failed'), 'An error encountered while cloning timeline.==>');
        
        
        
           lsWrapper=(List<E2_Clone_Estimate_WSManager.EstimateWrapper>)JSON.deserialize(wrapperJSONWithoutMilestone,List<E2_Clone_Estimate_WSManager.EstimateWrapper>.class);
           lsWrapper.get(0).partialClone=true;
           lsWrapper.get(0).estimateIsActive=true;
           wrapperJSONWithoutMilestone=JSON.serialize(lsWrapper.get(0));
           
           returnMessage = E2_Clone_Estimate_WSManager.cloneEstimateTimeline(wrapperJSONWithoutMilestone);
           System.assert(!returnMessage.startsWith('Failed'), 'An error encountered while cloning timeline.');
           
           
           
           
           
           wrapper=(E2_Clone_Estimate_WSManager.EstimateWrapper)JSON.deserialize(wrapperJSON,E2_Clone_Estimate_WSManager.EstimateWrapper.class);
           wrapper.newEstimateId=wrapper.newEstimateId+'1';
           wrapperJSON=JSON.serialize(wrapper);
           returnMessage = E2_Clone_Estimate_WSManager.cloneEstimateTimeline(wrapperJSON);
           System.assert(returnMessage.startsWith('Failed'),'An error should be generated in order to invalid estimate id passed.');
           
           // Invalid JSON
           returnMessage = E2_Clone_Estimate_WSManager.cloneEstimateTimeline(null);
           System.assert(returnMessage.startsWith('Failed'),'An error should be generated since invalid JSON passed.');
          
           Test.stopTest();
       }
   } 
   
   @isTest
   public static void testCloneResourceWeeks(){
       sysAdmin = getSysAdminUser();
       
       System.runAs(sysAdmin){
           Test.startTest();
           String wrapperJSON=getEstimateWrapper();
           List<CMC_Estimate_Resource_Week__c> lsResourceWeek=[Select Estimate_Resource__r.ID,Estimate_Resource__r.Estimate__c,
                                                           Estimate_Week__r.ID,Estimate_Week__r.Estimate__c 
                                                           FROM CMC_Estimate_Resource_Week__c];
           List<E2_Clone_Estimate_WSManager.EstimateWrapper> lsTimelineWrapper=new List<E2_Clone_Estimate_WSManager.EstimateWrapper>();
           wrapperJSON = E2_Clone_Estimate_WSManager.cloneEstimate(wrapperJSON);
           
           E2_Clone_Estimate_WSManager.EstimateWrapper wrapper=(E2_Clone_Estimate_WSManager.EstimateWrapper)JSON.deserialize(wrapperJSON,E2_Clone_Estimate_WSManager.EstimateWrapper.class);
           
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
         
          String returnMessage = E2_Clone_Estimate_WSManager.cloneResourceWeeks(jsonResourceWeek);
          System.assert(!returnMessage.containsIgnoreCase('Failed'), 'An error encountered while cloning resource weeks.');
          
          
          lsTimelineWrapper.get(0).isWeek=null;
          
          returnMessage = E2_Clone_Estimate_WSManager.cloneResourceWeeks(JSON.serialize(lsTimelineWrapper));
          System.assert(returnMessage.startsWith('Failed'),'An error should be generated in order to invalid isWeek passed.');
          
          // Invalid JSON
          returnMessage = E2_Clone_Estimate_WSManager.cloneResourceWeeks(null);
          System.assert(returnMessage.startsWith('success'),'An error should be generated since invalid JSON passed.');
          
          Test.stopTest();
       }
   }
   
   
   public static testmethod void testDeleteEstimate(){
       
       sysAdmin = getSysAdminUser();
       
       System.runAs(sysAdmin){
           Test.startTest();
           String wrapperJSON=getEstimateWrapper();
           wrapperJSON = E2_Clone_Estimate_WSManager.cloneEstimate(wrapperJSON);
           E2_Clone_Estimate_WSManager.EstimateWrapper wrapper=(E2_Clone_Estimate_WSManager.EstimateWrapper)JSON.deserialize(wrapperJSON,E2_Clone_Estimate_WSManager.EstimateWrapper.class);
           String newEstimateId=wrapper.newEstimateId;
           
           String returnMessage = E2_Clone_Estimate_WSManager.deleteEstimate(newEstimateId);
           System.assertEquals(returnMessage, 'success', 'Unit test failed: an error encountered while deleting estimate.');
          
           returnMessage = E2_Clone_Estimate_WSManager.deleteEstimate('#');
           System.assert(returnMessage.startsWith('Failed'),'Unit test failed: An error should be generated in order to invalild estimate id.');
           
           Test.stopTest();
       }
    }
    
    public static testmethod void testMultiTimelineMethods(){
       
       sysAdmin = getSysAdminUser();
       
       System.runAs(sysAdmin){
           Test.startTest();
           estimate = [SELECT Id, Name,CurrencyIsoCode FROM CMC_Presales_LOE__c];
           CMC_Estimate_Resource__c eResource=[Select ID FROM CMC_Estimate_Resource__c WHERE Estimate__c=:estimate.ID];
           CMC_Estimate_Week__c eWeek=[Select ID FROM CMC_Estimate_Week__c WHERE Estimate__c=:estimate.ID];
        
           String timelineJSON='[{"key":"'+eWeek.ID+'","cloneFrom":"'+estimate.ID+'","currencyISOCode":"'+estimate.CurrencyIsoCode+'","isWeek":true,"isNewTimeline":false},{"key":"'+eResource.ID+'","cloneFrom":"'+estimate.ID+'","currencyISOCode":"'+estimate.CurrencyIsoCode+'","isWeek":false,"isNewTimeline":false}]';
           timelineJSON=E2_Clone_Estimate_WSManager.createNewTimeline(timelineJSON);
           list<E2_Clone_Estimate_WSManager.EstimateWrapper> mappingList = (list<E2_Clone_Estimate_WSManager.EstimateWrapper>)JSON.deserialize(timelineJSON, list<E2_Clone_Estimate_WSManager.EstimateWrapper>.class);
           system.assert(mappingList.get(0).newTimelineId != null, 'The new estimate has not been created.');  
           
           
           
           
           String result=E2_Clone_Estimate_WSManager.cloneTimelineVersion(timelineJSON);
           system.assert(!result.contains('Failed'), 'Assert Failed: an error received in response of cloneTimelineVersion method calling.');  
          
           result=E2_Clone_Estimate_WSManager.cloneTimelineRateCards(timelineJSON);
           system.assert(!result.contains('Failed'), 'Assert Failed: cloneTimelineRateCards method should return failure.');  
          
          
           eResource=[Select ID FROM CMC_Estimate_Resource__c WHERE Estimate__c=:mappingList.get(0).newTimelineId];
           eWeek=[Select ID FROM CMC_Estimate_Week__c WHERE Estimate__c=:mappingList.get(0).newTimelineId];
        //   system.assert(true==false, 'Key: '+eResource.ID+'|| Key: '+eWeek.ID);  
          
           mappingList.get(0).value=eWeek.ID;
           mappingList.get(1).value=eResource.ID;
           timelineJSON=JSON.serialize(mappingList);
           result=E2_Clone_Estimate_WSManager.cloneResourceWeeksTimelineVersion(timelineJSON);
           system.assert(!result.contains('Failed'), 'An error received in response of cloneResourceWeeksTimelineVersion method calling.=>'+result);  
    
           //Handle isNewTimeline case
           timelineJSON='[{"key":"'+eWeek.ID+'","cloneFrom":"'+mappingList.get(0).newTimelineId+'","currencyISOCode":"'+estimate.CurrencyIsoCode+'","isWeek":true,"isNewTimeline":true},{"key":"'+eResource.ID+'","cloneFrom":"'+mappingList.get(0).newTimelineId+'","currencyISOCode":"'+estimate.CurrencyIsoCode+'","isWeek":false,"isNewTimeline":true}]';
           timelineJSON=E2_Clone_Estimate_WSManager.createNewTimeline(timelineJSON);
           system.assert(!timelineJSON.toLowerCase().contains('failed'), 'The new estimate has not been created.');
    
        //   Exception cases
           timelineJSON='[{"cloneFrom":"'+estimate.ID+'","currencyISOCode":""}]';
           result=E2_Clone_Estimate_WSManager.createNewTimeline(timelineJSON);
           system.assert(result.contains('Failed'), 'Assert Failed: createNewTimeline method should return failure.');  
           
           timelineJSON='[{"cloneFrom":"","currencyISOCode":""}]';
           result=E2_Clone_Estimate_WSManager.cloneTimelineRateCards(timelineJSON);
           system.assert(result.contains('Failed'), 'Assert Failed: cloneTimelineRateCards method should return failure.');  
           
           result=E2_Clone_Estimate_WSManager.cloneTimelineVersion(timelineJSON);
           system.assert(result.contains('Failed'), 'Assert Failed: cloneTimelineVersion method should return failure.');  
           
          result=E2_Clone_Estimate_WSManager.cloneResourceWeeksTimelineVersion('');
          system.assert(result.contains('Failed'), 'Assert Failed: cloneResourceWeeksTimelineVersion method should return failure.'); 
          
          
          // Handle Catch Block
          eResource=[Select ID FROM CMC_Estimate_Resource__c WHERE Estimate__c=:estimate.ID];
          eWeek=[Select ID FROM CMC_Estimate_Week__c WHERE Estimate__c=:estimate.ID];
          timelineJSON='[{"key":"'+eWeek.ID+'","cloneFrom":"'+estimate.ID+'","currencyISOCode":"'+estimate.CurrencyIsoCode+'","isWeek":true,"isNewTimeline":false},{"key":"'+eResource.ID+'","cloneFrom":"'+estimate.ID+'","currencyISOCode":"'+estimate.CurrencyIsoCode+'","isWeek":false,"isNewTimeline":false}]';
          timelineJSON=E2_Clone_Estimate_WSManager.createNewTimeline(timelineJSON);
          result=E2_Clone_Estimate_WSManager.cloneTimelineVersion(timelineJSON);
          result=E2_Clone_Estimate_WSManager.cloneResourceWeeksTimelineVersion(timelineJSON);
          system.assert(result.contains('Failed'), 'Assert Failed: cloneResourceWeeksTimelineVersion method should return failure.'); 
          
        
        // Estimate is not attached with any of resource OR Empty Timeline
           Presales_Request__c psr = [SELECT ID FROM Presales_Request__c];
           estimate = E2_Test_Utils.insertEstimate(psr.Id, true);
           E2_Estimate_Rate_Card__c estimateRC = E2_Test_Utils.insertEstimateRateCard(estimate.Id, true);
           timelineJSON='[{"cloneFrom":"'+estimate.ID+'","currencyISOCode":"'+estimate.CurrencyIsoCode+'","isWeek":true,"isNewTimeline":false}]';
           timelineJSON=E2_Clone_Estimate_WSManager.createNewTimeline(timelineJSON);
           result=E2_Clone_Estimate_WSManager.cloneTimelineVersion(timelineJSON);
           system.assert(!result.contains('Failed'), 'An error received in response of cloneTimelineVersion method calling.');  
           
           
           Test.stopTest();
       }
    }
	
  private static String getEstimateWrapper(){
      estimate = [SELECT Id,currencyISOCode, Name FROM CMC_Presales_LOE__c];
      E2_Clone_Estimate_WSManager.EstimateWrapper wrapper=new E2_Clone_Estimate_WSManager.EstimateWrapper();
      wrapper.cloneFrom=estimate.Id;
      wrapper.currencyISOCode=estimate.currencyISOCode;
      wrapper.isNewTimeline=false;
      
      return JSON.serialize(wrapper);
      
  }
  private static String getEstimateWrapper(String estimateID,String currencyISOCode){
      E2_Clone_Estimate_WSManager.EstimateWrapper wrapper=new E2_Clone_Estimate_WSManager.EstimateWrapper();
      wrapper.cloneFrom=estimateID;
      wrapper.currencyISOCode=estimate.currencyISOCode;
      wrapper.isNewTimeline=false;
      
      return JSON.serialize(wrapper);
      
  }
  
  private static String getListEstimateWrapper(){
      estimate = [SELECT Id,currencyISOCode, Name FROM CMC_Presales_LOE__c];
      E2_Clone_Estimate_WSManager.EstimateWrapper wrapper=new E2_Clone_Estimate_WSManager.EstimateWrapper();
      wrapper.cloneFrom=estimate.Id;
      wrapper.currencyISOCode=estimate.currencyISOCode;
      wrapper.isNewTimeline=false;
      
      List<E2_Clone_Estimate_WSManager.EstimateWrapper> lsWrapper=new List<E2_Clone_Estimate_WSManager.EstimateWrapper>();
      lsWrapper.add(wrapper);
      
      return JSON.serialize(lsWrapper);
      
  }
  private static String getListEstimateWrapper(String estimateID,String currencyISOCode){
      E2_Clone_Estimate_WSManager.EstimateWrapper wrapper=new E2_Clone_Estimate_WSManager.EstimateWrapper();
      wrapper.cloneFrom=estimateID;
      wrapper.currencyISOCode=estimate.currencyISOCode;
      wrapper.isNewTimeline=false;
      
      List<E2_Clone_Estimate_WSManager.EstimateWrapper> lsWrapper=new List<E2_Clone_Estimate_WSManager.EstimateWrapper>();
      lsWrapper.add(wrapper);
      
      return JSON.serialize(lsWrapper);
      
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