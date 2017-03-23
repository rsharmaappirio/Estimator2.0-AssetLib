/**=====================================================================
 * Appirio, Inc
 * Name: E2_Estimator_Manager
 * Description: 
 * Created Date: July 7th, 2016
 * Created By: 
 * 
 * Date Modified      Modified By                  Description of the update
 * Dec 8th, 2016      Rohit Sharma                 S-449145 :Ability to find the Scope by type, 
                                                   Complexity ,Q&A and assets assigned.      
 * Dec 26, 2016       Rahul Jain                   S-459273 : Added Resource Level field in getEstimateRateCards, generateDerivedHours, loadEfforts method
 * Feb 08, 2017       Rohit Sharma                 S-447325 : Add multiplier on Scope : code updated to add Effort multiplier on effort
 *                                                 hours for epic level capacity calculation.
*  =====================================================================*/
public with sharing class E2_Estimator_Manager {
    
    private final static integer PERCENT_DENOMINATOR = 100;
    private final static string TOTAL_CONSTANTS = 'total';
    
    //method to generate Derived Hours based on estimate Id and E2_Derived_Effort__c
    public static void generateDerivedHours(Id estimateId,List<E2_Derived_Effort__c> e2DerivedEfforts) {
        // validate that this is for any valid estimate id
    	if(estimateId <> NULL){
       		Map<String, Decimal> idrolephaseToHoursMap = new Map<String, Decimal>();
	    	Set<Id> estimateIds = new Set<Id>();
	       	estimateIds.add(estimateId);
	       	// load the efforts in the map 
	       	loadEfforts(estimateIds, idrolephaseToHoursMap);
	       	
	       	// traverse through all the e2 drived efforts (template) records associated with this estimate.
	       	// 12/26 : RS : Method re-evaluated and updated to remove unnecessary if-else logic
	        for(E2_Derived_Effort__c derivedEffort: e2DerivedEfforts){
	          decimal hrs = 0;
	          string keys = (String.isBlank(derivedEffort.Of_Role__c) ? E2_Constants.BLANK : 
	                (derivedEffort.Of_Role__c.toLowerCase() + (String.isBlank(derivedEffort.Of_level__c) ? 
	                    E2_Constants.BLANK : E2_Constants.SEPARATOR + derivedEffort.Of_level__c.toLowerCase())));
	                
	          keys += (String.isBlank(derivedEffort.Of_Phase__c) ? E2_Constants.BLANK : 
	                 (!string.isBlank(keys) ? E2_Constants.SEPARATOR : E2_Constants.BLANK) + derivedEffort.Of_Phase__c.toLowerCase());
	                 
	                 
	         if(String.isBlank( keys )) {
	             hrs = idrolephaseToHoursMap.get( TOTAL_CONSTANTS );
	         } else if(idrolephaseToHoursMap.containsKey( keys )) {
	             hrs = idrolephaseToHoursMap.get( keys );
	         }
	          hrs = hrs * (derivedEffort.Allocation__c/PERCENT_DENOMINATOR);
	          derivedEffort.Derived_Hrs__c = hrs;       
	       	}  
    	}
    }
    //method to get derived hours if Role or Phase does not exist
    // VG : 01/10/2017 : Commented as NOT IN USE
    /*private static Decimal derivedhrsWithoutOfRoleOrOfPhase(Map<String, Decimal> idrolephaseToHoursMap,string partialKey) {
    	decimal hrs = 0;
    	for(string idroleKey : idrolephaseToHoursMap.KeySet()) {
    		if(idroleKey.indexOf(partialKey) != -1)
    		hrs = hrs + idrolephaseToHoursMap.get(idroleKey);
    	}
    	return hrs;
    }*/
    //method to get derived hours if Role and Phase does not exist
    // VG : 01/10/2017 : Commented as NOT IN USE
    /*private static Decimal derivedhrsWithoutOfRoleAndOfPhase(Map<String, Decimal> idrolephaseToHoursMap) {
    	decimal hrs = 0;
    	for(decimal idroleKey : idrolephaseToHoursMap.values()) {
    		hrs = hrs + idroleKey;
    	}
    	return hrs;
    }*/
    //method to load efforts based on complexity 
    private static void loadEfforts(Set<Id> estimateIds, 
    								Map<String, Decimal> idrolephaseToHoursMap) {
    	   // 12/26: Updated the code below to add level field based calculations.
    	  // for total sum of effort hours 
          if(!idrolephaseToHoursMap.containsKey(TOTAL_CONSTANTS)){
            idrolephaseToHoursMap.put(TOTAL_CONSTANTS, 0);
          }
          // RS :S-447325: Effort_Quantity__c custom field added in SOQL
          for(E2_Effort__c result : [Select  e.Low_Effort_Hrs__c, e.High_Effort_Hrs__c,
                                            e.Effort_Hrs__c, e.Resource_Role__c , e.Phase__c ,
                                            e.Scope__r.Presales_LOE__c , e.Scope__r.Complexity__c 
                                            ,e.Resource_Level__c, e.Scope__r.Effort_Quantity__c 
                                            From E2_Effort__c e
                                            where e.Scope__r.Presales_LOE__c in : estimateIds AND e.Scope__r.Is_Active__c = true]){
                                                
              string role = result.Resource_Role__c.toLowerCase();
              string level = string.isBlank(result.Resource_Level__c) ? E2_Constants.BLANK : result.Resource_Level__c.toLowerCase();
              string phase = result.Phase__c.toLowerCase();
              
              string rolePhaseKey = role + ((String.isEmpty(level)) ? E2_Constants.BLANK : E2_Constants.SEPARATOR + level) + E2_Constants.SEPARATOR + phase;
              
              decimal hrs = 0;
              string complexity = ((string)result.Scope__r.Complexity__c.toLowerCase());
              if(complexity == E2_Constants.LOW) hrs = (decimal)result.get('Low_Effort_Hrs__c');
              if(complexity == E2_Constants.MEDIUM) hrs = (decimal)result.get('Effort_Hrs__c');
              if(complexity == E2_Constants.HIGH) hrs = (decimal)result.get('High_Effort_Hrs__c');
              // RS :S-447325: add Effort Multiplier into effort hours
              if(result.Scope__r.Effort_Quantity__c > 0) hrs = hrs * result.Scope__r.Effort_Quantity__c;
              // for total sum of effort hours 
              idrolephaseToHoursMap.put(TOTAL_CONSTANTS, idrolephaseToHoursMap.get(TOTAL_CONSTANTS) + hrs);
              
              //for role + level + phase || role + phase
              if(!idrolephaseToHoursMap.containsKey(rolePhaseKey)){
                 idrolephaseToHoursMap.put(rolePhaseKey, 0);
              }
              idrolephaseToHoursMap.put(rolePhaseKey, idrolephaseToHoursMap.get(rolePhaseKey) + hrs);
              
              //for role
              if(!idrolephaseToHoursMap.containsKey(role)){
                 idrolephaseToHoursMap.put(role, 0);
              }
              
              if(String.isEmpty(level)) idrolephaseToHoursMap.put(role, idrolephaseToHoursMap.get(role) + hrs);
              
              //for role + level
              string rolePlusLevel = role + E2_Constants.SEPARATOR + level;
              if(!String.isEmpty(level) && !idrolephaseToHoursMap.containsKey(rolePlusLevel)){
                 idrolephaseToHoursMap.put(rolePlusLevel, 0);
              }
              if(!String.isEmpty(level)) idrolephaseToHoursMap.put(rolePlusLevel, idrolephaseToHoursMap.get(rolePlusLevel) + hrs);
              
              
              //for phase
              if(!idrolephaseToHoursMap.containsKey(phase)){
                 idrolephaseToHoursMap.put(phase, 0);
              }
              idrolephaseToHoursMap.put(phase, idrolephaseToHoursMap.get(phase) + hrs);
              //system.debug('idrolephaseToHoursMap'+idrolephaseToHoursMap);
          }
    }
    
    
    //method to get Appirio Way Phase 
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
	  
	  List<E2_Estimate_Rate_Card__c> estimateRateCards = E2_DataUtil.getEstimateRateCards(estimateId);
															
		if(estimateRateCards.isEmpty() && !String.isBlank(currencyCode)) {			
			for(pse__Rate_Card__c rateCard : E2_DataUtil.getPSERateCardRecords(currencyCode)) {
		                                	      
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
		    	//need resource level to be queried and updated now
		    	estimateRC.Resource_Level__c = rateCard.E2_Resource_Level__c;
		    	// S-469552 : VG : March 2, 2017
                estimateRC.Practice_Id__c = rateCard.pse__Practice__c;
                estimateRC.Region_Id__c = rateCard.pse__Region__c;
		    	newEstimateRateCards.add(estimateRC);		
			}
			if(!newEstimateRateCards.isEmpty()) {
			    try{
				   insert newEstimateRateCards;
				   // QUERYING AGAIN FOR RETURNING THE ORDERED LIST BY REGION & ROLE
        		   estimateRateCards = E2_DataUtil.getEstimateRateCards(estimateId);
        		   //no need to updated ratecard json now; do not need in e2
        		   //updateEstimeRateCardJSON(estimateRateCards, estimateId);
			    }catch(Exception ex){
			       system.debug('Error in new estimate rate card creation:' + ex.getMessage()); 
			    }
			}
		}
		return estimateRateCards;
	
	}
	
	//no need to updated ratecard json now; do not need in e2
	/*public static void updateEstimeRateCardJSON(List<E2_Estimate_Rate_Card__c> estimateRateCards,Id estimateId) {
      List<RateCardJSONWrapper> ratecards = new List<RateCardJSONWrapper>();
      for(E2_Estimate_Rate_Card__c estimateRateCard : estimateRateCards) {
       ratecards.add(populateRateCard(estimateRateCard));   
      }
      if(!ratecards.isEmpty()) {
          string rt_JSON = JSON.serialize(ratecards);
          rt_JSON = rt_JSON != null ? rt_JSON.replaceAll('Resource_Cost', 'Resource Cost') : rt_JSON;
		  rt_JSON = rt_JSON != null ? rt_JSON.replaceAll('Suggested_Cost', 'Suggested Cost') : rt_JSON;
		  rt_JSON = rt_JSON != null ?rt_JSON.replaceAll('Rate_Card', 'Rate Card') : rt_JSON;
		  update (new CMC_Presales_LOE__c(Id = estimateId, Ratecard_JSON__c = rt_JSON));
      }
     }*/
  
      public static RateCardJSONWrapper populateRateCard(E2_Estimate_Rate_Card__c erc) {
        RateCardJSONWrapper rateCard = new RateCardJSONWrapper();
        rateCard.Id = erc.Rate_Card__c;
        rateCard.Resource_Cost = (erc.Resource_Cost__c).intValue();
        rateCard.Suggested_Cost = (erc.Resource_Cost__c).intValue();
        rateCard.Practice = erc.Rate_Card__r.pse__Practice__c;
        rateCard.PracticeName = erc.Practice__c;
        rateCard.RegionId = erc.Rate_Card__r.pse__Region__c;
        rateCard.RegionName = erc.Region__c;
        rateCard.Role = erc.Resource_Role__c;
        rateCard.Rate_Card = (erc.Bill_Rate__c).intValue();
        rateCard.Rate = (erc.Discounted_Rate__c).intValue();
        rateCard.CurrencyIsoCode = erc.CurrencyIsoCode;
        rateCard.Code = erc.Code__c;
        rateCard.Category = erc.Category__c;
        return rateCard;
  }
  
  public static string populateCapacityNeeds(string estimateId) {
      // method to populate the capacityNeeds_JSON variable with Phase hours
      // Role hours and total capacity needs from Capicity needs calculated 
      // from Scopes
      // RS : S-447680 : Round off the hours to nearest figure on capacity tab
      
      // RS : get estimate capacity needs from primary timeline
      
    string capacityNeeds_JSON = '{';
    
    string phaseHours_JSON = '{';
    for(AggregateResult groupedResults : [SELECT SUM(Hours__c) Hours, Phase__c  
                                          FROM E2_Capacity__c WHERE Estimator__c =: estimateId  
                                          GROUP BY Phase__c]) {
        string phaseHour = '"' + string.valueOf(groupedResults.get('Phase__c')).toLowerCase() + '" : "' + ((Decimal)groupedResults.get('Hours')).round() + '"';
        phaseHours_JSON += (phaseHours_JSON == '{' ? '' : ',') + phaseHour;
    }
    phaseHours_JSON += '},';
    capacityNeeds_JSON += '"PhaseHours" : '+ phaseHours_JSON;
    
    // 12/27: Added resource level related changes in the query and json formation
    string roleHours_JSON = '{';
    for(AggregateResult groupedResults : [SELECT SUM(Hours__c) Hours, Role__c, Level__c  
                                          FROM E2_Capacity__c WHERE Estimator__c =: estimateId  
                                          GROUP BY Role__c, Level__c]) {
        string roleHour = '"' + string.valueOf(groupedResults.get('Role__c')).toLowerCase() 
        + (groupedResults.get('Level__c') == NULL || string.valueOf(groupedResults.get('Level__c')) == '' ? 
                                    E2_Constants.BLANK : 
                                    E2_Constants.HYPHEN_SEPARATOR + string.valueOf(groupedResults.get('Level__c')).toLowerCase()) 
        + '" : "' + ((Decimal)groupedResults.get('Hours')).round() + '"';
        roleHours_JSON += (roleHours_JSON == '{' ? '' : ',') + roleHour;
    }
    
    roleHours_JSON += '},';
    capacityNeeds_JSON += '"RoleHours" : '+ roleHours_JSON;
    AggregateResult[] totalHours = [SELECT SUM(Hours__c) Hours 
                                    FROM E2_Capacity__c 
                                    WHERE Estimator__c =: estimateId];
    capacityNeeds_JSON += '"TotalHours" : "' + (totalHours[0].get('Hours') == NULL ? '' : ''+ ((Decimal)totalHours[0].get('Hours')).round()) + '"';
    capacityNeeds_JSON += '}';
    return capacityNeeds_JSON;
  }
  
  //
  public class RateCardJSONWrapper {
        Id Id;
        Decimal Resource_Cost;//Cost
        Decimal Suggested_Cost;//cost
        String Practice;
        String PracticeName;
        String RegionId;
        String RegionName;
        String Role;
        Decimal Rate_Card;//Bill_Rate__c
        Decimal Rate;//Discounted_Rate__c
        String CurrencyIsoCode;
        String Code;
        String Category;
    }
	
}