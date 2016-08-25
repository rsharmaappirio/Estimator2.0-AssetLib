/**=====================================================================
 * Appirio, Inc
 * Name: E2_TimelineController
 * Description: Controller class for E2_Timeline page
 * Created Date: Aug 12th, 2016
 * Created By: Rahul Jain (Appirio)
 * 
 * Date Modified      Modified By                  Description of the update
      
*  =====================================================================*/
public with sharing class E2_TimelineController extends E2_Master {
  public CMC_Presales_LOE__c estimate {get;set;}
  public List<E2_Estimate_Rate_Card__c> estimateRateCards{get;set;}
  public Decimal marginNum; // TODO: REMOVE NOT NEEDED NOW
  public Map<Id, double> mapIdtoRCMargin {get;set;}// TODO: REMOVE NOT NEEDED NOW
  public Map<Id, Double> mapIdToRateMargin {get;set;}// TODO: REMOVE NOT NEEDED NOW
  
  public E2_TimelineController (ApexPages.StandardController std) {
    this.estimate = (CMC_Presales_LOE__c)std.getRecord();
    this.estimateRateCards = new List<E2_Estimate_Rate_Card__c>();
    marginNum = 0;// TODO: REMOVE NOT NEEDED NOW
    mapIdtoRCMargin = new Map<Id, double>();// TODO: REMOVE NOT NEEDED NOW
    mapIdToRateMargin = new Map<Id, double>();// TODO: REMOVE NOT NEEDED NOW
  }
  
  public PageReference pageAction(){
    super.validateAccess(this.estimate);
    this.estimateRateCards = E2_Estimator_Manager.getEstimateRateCards(this.estimate.Id, this.estimate.CurrencyISOCode);
    populateMarginMap();// TODO: REMOVE NOT NEEDED NOW
    return null;
  }
  
  public void populateMarginMap(){
      // TODO: REMOVE NOT NEEDED NOW
    //code for rc margin and rate margin
    if(!estimateRateCards.isEmpty()){
      for(E2_Estimate_Rate_Card__c rc : estimateRateCards){
        if(rc.Resource_Cost__c != null && rc.Bill_Rate__c != null){
            marginNum = 1 - (Double.valueOf(rc.Resource_Cost__c)/Double.valueOf(rc.Bill_Rate__c));
            Decimal roundedrcMargin  = marginNum.setScale(2);
            mapIdtoRCMargin.put(rc.Id, roundedrcMargin);
        }
        if(rc.Resource_Cost__c != null && rc.Discounted_Rate__c!= null){
            marginNum = 1 - (Double.valueOf(rc.Resource_Cost__c)/Double.valueOf(rc.Discounted_Rate__c));
            Decimal roundedrcMargin  = marginNum.setScale(2);
            mapIdToRateMargin.put(rc.Id, roundedrcMargin);
        }
      }  
    }
  }
  
  public E2_Estimate_Rate_Card__c getEstimateRateCard(pse__Rate_Card__c rateCard, String currencyCode){
      	E2_Estimate_Rate_Card__c estimateRC = new E2_Estimate_Rate_Card__c();
		estimateRC.Estimate__c = estimate.id;
		estimateRC.Resource_Role__c = rateCard.pse__Role__c;
    	estimateRC.Region__c = rateCard.pse__Region__r.Name;
    	estimateRC.Practice__c = rateCard.pse__Practice__r.Name;
		estimateRC.Code__c = rateCard.Code__c;
		estimateRC.Rate_Card__c = rateCard.Id;
		estimateRC.CurrencyISOCode = currencyCode;
		estimateRC.Resource_Cost__c = rateCard.pse__Average_Cost_Rate__c;
		estimateRC.Bill_Rate__c = rateCard.pse__Suggested_Bill_Rate__c;
		estimateRC.Discounted_Rate__c = rateCard.pse__Suggested_Bill_Rate__c;
    	estimateRC.Category__c = rateCard.pse__Region__r.Name;
        return estimateRC;
  }
  
  public PageReference refreshRateCardRatesAndCost(){
      
       if(estimate.CurrencyISOCode <> NULL){
           Set<Id> rateCardIds = new Set<Id>();
           string currencyCode = estimate.CurrencyISOCode;
           List<E2_Estimate_Rate_Card__c> newRateCardsToInsert = new List<E2_Estimate_Rate_Card__c>();
           List<E2_Estimate_Rate_Card__c> rateCardsToUpdate = new List<E2_Estimate_Rate_Card__c>();
           
           List<E2_Estimate_Rate_Card__c> estimateRateCards = [SELECT Id, Resource_Role__c, Estimate__c, Region__c, 
    															Practice__c, Code__c, Rate_Card__c, Resource_Cost__c,
    															Bill_Rate__c, Discounted_Rate__c, Category__c,
    															Rate_Card__r.pse__Average_Cost_Rate__c, Rate_Card__r.pse__Suggested_Bill_Rate__c 
    															FROM E2_Estimate_Rate_Card__c 
    															WHERE Estimate__c =: estimate.id
    															ORDER BY Region__c ASC, Resource_Role__c ASC];
    		
    		// create a set of existing rate card ids													
    	    for(E2_Estimate_Rate_Card__c erateCard : estimateRateCards){
    	        rateCardIds.add(erateCard.Rate_Card__c);
    	    }													
    		
    		
    		// check that no new rate card entries exist in the system for this selected currency.	
			for(pse__Rate_Card__c rateCard : [SELECT Id, pse__Average_Cost_Rate__c, 
											  pse__Practice__r.Name, Code__c, 
		                                	  pse__Region__r.Name, pse__Role__c, pse__Suggested_Bill_Rate__c 
		                                	  FROM pse__Rate_Card__c 
		                                	  WHERE CurrencyISOCode =: currencyCode 
		                                	  AND ID NOT IN : rateCardIds]) {
		    	newRateCardsToInsert.add(getEstimateRateCard(rateCard, currencyCode));
			}
			
			//update the estimate rate card values 
    	    for(E2_Estimate_Rate_Card__c erateCard : estimateRateCards){
    	        boolean hasChanged = false;
    	        // when original rate does not match bill rate 
    	        if(erateCard.Bill_Rate__c <> erateCard.Rate_Card__r.pse__Suggested_Bill_Rate__c){
    	            if(erateCard.Bill_Rate__c == erateCard.Discounted_Rate__c){
    	                erateCard.Discounted_Rate__c = erateCard.Rate_Card__r.pse__Suggested_Bill_Rate__c;
    	            }
    	            erateCard.Bill_Rate__c = erateCard.Rate_Card__r.pse__Suggested_Bill_Rate__c;
    	            hasChanged = true;
    	        }
    	        // when original cost doesn't match the resource cost
    	        if(erateCard.Resource_Cost__c <> erateCard.Rate_Card__r.pse__Average_Cost_Rate__c){
    	            erateCard.Resource_Cost__c = erateCard.Rate_Card__r.pse__Average_Cost_Rate__c;
    	            hasChanged = true;
    	        }
    	        if(hasChanged){
    	            rateCardsToUpdate.add(erateCard);
    	        }
    	    }
    	    
    	    
    	    if(!rateCardsToUpdate.isEmpty()){
    	        update rateCardsToUpdate;
    	    }
    	    
    	    if(!newRateCardsToInsert.isEmpty()){
    	        insert newRateCardsToInsert;
    	    }
    	    
    	    this.estimateRateCards = [SELECT Id, Resource_Role__c, Estimate__c, Region__c, 
    									Practice__c, Code__c, Rate_Card__c, Resource_Cost__c,
    									Bill_Rate__c, Discounted_Rate__c, Category__c,
    									Rate_Card__r.pse__Average_Cost_Rate__c, Rate_Card__r.pse__Suggested_Bill_Rate__c 
    									FROM E2_Estimate_Rate_Card__c 
    									WHERE Estimate__c =: estimate.id
    									ORDER BY Region__c ASC, Resource_Role__c ASC];
    									
    		updateEstimateResources();
    		populateMarginMap();
    	
       }
      return null;
  }
  
  public PageReference updateEstimateRateCards(){
     
      if(!this.estimateRateCards.isEmpty()){
        // Create a savepoint 
        // we don't want to save/update estimate rate cards, when there is a failure in the update
        // of estimate resources later
        Savepoint sp = Database.setSavepoint();
        try{
            update this.estimateRateCards;
            // update the rates and cost on the related estimate resources records
            updateEstimateResources();                                                    
        }catch(Exception ex){
            Database.rollback(sp);
            System.debug('Error in update of estimate rate cards:' + ex.getMessage());
        }
      }
      pageAction();
      return null;
  }
  
  public void updateEstimateResources(){
    Map<String, E2_Estimate_Rate_Card__c> roleRateMap = new Map<String, E2_Estimate_Rate_Card__c>();
    List<CMC_Estimate_Resource__c> lstEstimateResourcesToUpdate = new List<CMC_Estimate_Resource__c>();
    
    //create map
    for(E2_Estimate_Rate_Card__c estimateRateCard : this.estimateRateCards){
        roleRateMap.put(estimateRateCard.Region__c + ' - ' +  estimateRateCard.Resource_Role__c, estimateRateCard);
        
    }
    // query existing estimate resource records and update the modified rate 
    // loop over the existing resources and set the new rate with it
    for(CMC_Estimate_Resource__c res : [SELECT Id, Rate__c, Role__c, Cost__c 
                                         FROM CMC_Estimate_Resource__c
                                         WHERE Estimate__c = : this.estimate.Id]){
        boolean hasChanged = false;                                     
        // check that estimate rate card has a record for resource role and rate has been updated through manage rate card.                                     
        if(roleRateMap.containsKey(res.Role__c) && roleRateMap.get(res.Role__c).Discounted_Rate__c != res.Rate__c){
            res.Rate__c = roleRateMap.get(res.Role__c).Discounted_Rate__c;
            hasChanged = true;
        }
        
        // check that estimate rate card has a record for resource role and cost has been updated through manage rate card.                                     
        if(roleRateMap.containsKey(res.Role__c) && roleRateMap.get(res.Role__c).Resource_Cost__c != res.Cost__c){
            res.Cost__c = roleRateMap.get(res.Role__c).Resource_Cost__c;
            hasChanged = true;
        }
        
        if(hasChanged) lstEstimateResourcesToUpdate.add(res);
    }
    
    if(!lstEstimateResourcesToUpdate.isEmpty())   update lstEstimateResourcesToUpdate; 
    
  }
  
  public PageReference buildCapacity() {
    E2_CapacityController.reBuildCapacity(this.estimate);
    PageReference pg = Page.E2_Capacity;
    pg.getParameters().put('id', this.estimate.id);    
    return pg; 
  }
}