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
}