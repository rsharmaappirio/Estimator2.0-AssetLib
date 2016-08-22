public with sharing class E2_Estimator_Manager {
    
    public static void generateDerivedHours(Id estimateId,List<E2_Derived_Effort__c> e2DerivedEfforts) {    	
    	if(estimateId!=null){
       		Map<String, Decimal> idrolephaseToHoursMap = new Map<String, Decimal>();
	    	Set<Id> estimateIds = new Set<Id>();
	       	estimateIds.add(estimateId);
	       	loadEfforts(estimateIds, idrolephaseToHoursMap);
	        for(E2_Derived_Effort__c derivedEffort: e2DerivedEfforts){
	          decimal hrs = 0;
	          if(String.isBlank(derivedEffort.Of_Role__c) && !String.isBlank(derivedEffort.Of_Phase__c))
	          	hrs = derivedhrsWithoutOfRoleOrOfPhase(idrolephaseToHoursMap, 
	          								E2_Constants.SEPARATOR + derivedEffort.Of_Phase__c.toLowerCase());
	          else if(!String.isBlank(derivedEffort.Of_Role__c) && String.isBlank(derivedEffort.Of_Phase__c))
	          	hrs = derivedhrsWithoutOfRoleOrOfPhase(idrolephaseToHoursMap, 
	          											derivedEffort.Of_Role__c.toLowerCase() + E2_Constants.SEPARATOR);
	          else if(String.isBlank(derivedEffort.Of_Role__c) && String.isBlank(derivedEffort.Of_Phase__c))
	          	hrs = derivedhrsWithoutOfRoleAndOfPhase(idrolephaseToHoursMap);
	          else {
	          	string derivedKey = derivedEffort.Of_Role__c.toLowerCase() + 
	          					E2_Constants.SEPARATOR + derivedEffort.Of_Phase__c.toLowerCase();                 
	          	if(idrolephaseToHoursMap.containsKey(derivedKey))
	             hrs = idrolephaseToHoursMap.get(derivedKey);
	          }
	          hrs = hrs * (derivedEffort.Allocation__c/100);
	          derivedEffort.Derived_Hrs__c = hrs;       
	       	}  
    	}
    }
    
    private static Decimal derivedhrsWithoutOfRoleOrOfPhase(Map<String, Decimal> idrolephaseToHoursMap,string partialKey) {
    	decimal hrs = 0;
    	for(string idroleKey : idrolephaseToHoursMap.KeySet()) {
    		if(idroleKey.indexOf(partialKey) != -1)
    		hrs = hrs + idrolephaseToHoursMap.get(idroleKey);
    	}
    	return hrs;
    }
    
    private static Decimal derivedhrsWithoutOfRoleAndOfPhase(Map<String, Decimal> idrolephaseToHoursMap) {
    	decimal hrs = 0;
    	for(decimal idroleKey : idrolephaseToHoursMap.values()) {
    		hrs = hrs + idroleKey;
    	}
    	return hrs;
    }
    
    private static void loadEfforts(Set<Id> estimateIds, 
    								Map<String, Decimal> idrolephaseToHoursMap) {
          for(AggregateResult result : 
          					E2_DataUtil.getEffortsOnEstimateIds(estimateIds)){
              string role = ((string)result.get('Role')).toLowerCase();
              string phase = ((string)result.get('Phase')).toLowerCase();
              string rolePhaseKey = role + E2_Constants.SEPARATOR + phase;
              decimal hrs = 0;
              string complexity = ((string)result.get('Complexity')).toLowerCase();
              if(complexity == E2_Constants.LOW) hrs = (decimal)result.get('lowHrs');
              if(complexity == E2_Constants.MEDIUM) hrs = (decimal)result.get('midHrs');
              if(complexity == E2_Constants.HIGH) hrs = (decimal)result.get('highHrs');
              if(!idrolephaseToHoursMap.containsKey(rolePhaseKey)){
                 idrolephaseToHoursMap.put(rolePhaseKey, 0);
              }
              idrolephaseToHoursMap.put(rolePhaseKey, idrolephaseToHoursMap.get(rolePhaseKey) + hrs);
          }
    }
    
    
    
    public static Set<String> getAppirioWayPhases(){
	    Set<String> phases = new Set<String>();
	    for(Schema.PicklistEntry f :  E2_Capacity__c.Phase__c.getDescribe().getPicklistValues()) {
	    	phases.add(f.getLabel());
	    }
	    return phases;
	}
	
	// Method to check for existing rate cards on estimsate record and insert 
	//if no rate card found for estimate currency
	public static List<E2_Estimate_Rate_Card__c> getEstimateRateCards(Id estimateId, string currencyCode) {
	  List<E2_Estimate_Rate_Card__c> newEstimateRateCards = new List<E2_Estimate_Rate_Card__c>();
	  
	  List<E2_Estimate_Rate_Card__c> estimateRateCards = [SELECT Id, Resource_Role__c, Estimate__c, Region__c, 
															Practice__c, Code__c, Rate_Card__c, Resource_Cost__c,
															Bill_Rate__c,Discounted_Rate__c, Category__c 
															FROM E2_Estimate_Rate_Card__c 
															WHERE Estimate__c =: estimateId
															ORDER BY Region__c ASC, Resource_Role__c ASC];
															
		if(estimateRateCards.isEmpty() && !String.isBlank(currencyCode)) {			
			for(pse__Rate_Card__c rateCard : [SELECT Id, pse__Average_Cost_Rate__c, 
											  pse__Practice__r.Name, Code__c, Description__c,
		                                	  pse__Region__r.Name, pse__Role__c, pse__Suggested_Bill_Rate__c 
		                                	  FROM pse__Rate_Card__c 
		                                	  WHERE CurrencyISOCode =: currencyCode]) {
		                                	      
				E2_Estimate_Rate_Card__c estimateRC = new E2_Estimate_Rate_Card__c();
				estimateRC.Estimate__c = estimateId;
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
		    	newEstimateRateCards.add(estimateRC);		
			}
			if(!newEstimateRateCards.isEmpty()) {
			    // always use exception handling for any dml
			    try{
				   insert newEstimateRateCards;
			    }catch(Exception ex){
			       system.debug('Error in new estimate rate card creation:' + ex.getMessage()); 
			    }
			}
			return newEstimateRateCards;
		}
		return estimateRateCards;
		// No need to query again
		/*return [SELECT Id, Resource_Role__c, Estimate__c, Region__c, 
															Practice__c, Code__c, Rate_Card__c, Resource_Cost__c,
															Bill_Rate__c,Discounted_Rate__c, Category__c 
															FROM E2_Estimate_Rate_Card__c 
															WHERE Estimate__c =: estimateId
															// WHERE Id =: estimateId : this is Wrong
															ORDER BY Region__c ASC, Resource_Role__c ASC];*/
	}
	
}