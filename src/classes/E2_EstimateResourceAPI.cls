// 
// (c) 2014 Appirio, Inc.
//
// Return Resources data for a given Presales Request
//
// 10/7/2014    Will Supinski 
// 09/12/2016   Rahul Jain: Updated below methods for E2 Implementation; E2 leverage same object for Timeline/Resource loading but 
//              with the introduction of Estimate Rate Cards object a junction between estimate and ratecards; (eliminating json creation on estimate records)
//              ; we can directly get ratecardid, practice id, region id 
public with sharing class E2_EstimateResourceAPI {
	
	public static Map<String, String> RegionIdByRole = new Map<String, String>();
	public static Map<String, String> PracticeIdByRole = new Map<String, String>();
	public static Map<String, String> RateCardIdByRole = new Map<String, String>();
	public static Map<String, String> PracticeNameByRole = new Map<String, String>();
		
	//  Return Resources data for a given Presales Request record.  Returns resource data only
	//  for the "default" estimate (there can only be one) under the Presales Request.
	//  @param psrId is the Id of the Presales Request record to search under.
	//	@return a list of E2_EstimateResource objects - one per Resource on an Estimate
	public static List<E2_EstimateResource> getResources(Id psrId){
		
		List<E2_EstimateResource> results = new List<E2_EstimateResource>();
		
		//query for all resources on the default estimate for a given PSR
		List<CMC_Estimate_Resource__c> resourceQuery = [SELECT Id, Name, E2_Role__c, Role__c, Skill__c, Estimate__c, Order__c, Rate__c, Cost__c, Total_Hours__c, 
                                                    		Estimate__r.Ratecard_JSON__c, CurrencyISOCode, Estimate__r.E2_SA__c,
                                                    		E2_Estimate_Rate_Card__r.Resource_Role__c,
                                                    		E2_Estimate_Rate_Card__r.Region__c,
                                                    		E2_Estimate_Rate_Card__r.Practice__c,
                                                    		E2_Estimate_Rate_Card__r.Rate_Card__c, 
                                                    		E2_Estimate_Rate_Card__r.Rate_Card__r.pse__Region__c,
                                                    		E2_Estimate_Rate_Card__r.Rate_Card__r.pse__Practice__c,
                                                        		(Select Id, Estimate_Week__r.Date__c, Hours__c 
                                                        		FROM Estimate_Resource_Weeks__r 
                                                        		ORDER BY Estimate_Week__r.Order__c) 
                                                    		FROM CMC_Estimate_Resource__c 
                                                    		where Estimate__r.Presales_Request__c = :psrId AND Estimate__r.default__c = true 
                                                    		ORDER BY Order__c];
		
		if(resourceQuery.size() > 0){
	
			CMC_Presales_LOE__c estimate = resourceQuery[0].Estimate__r;
			System.debug('<<<<<<<<< JSON ' + estimate.Ratecard_JSON__c);	//print the resource weeks please!\
			
			//parse the Ratecard for regionId, practiceId, RatecardId
			E2_EstimateResourceAPI.parseRatecardJSON(estimate.Ratecard_JSON__c);
			
			//generate a resource object for each resource
			for (CMC_Estimate_Resource__c resource : resourceQuery) 
			{
				E2_EstimateResource retResource = new E2_EstimateResource();
				
		  		retResource.rate = resource.Rate__c;
		  		retResource.cost = resource.Cost__c;
		  		retResource.hours = resource.Total_Hours__c;
		  		retResource.skill = resource.Skill__c;
		  		
		  		// 12/09/2016: RJ: Convert the below logic for two different applications; 
		  		// if condition is for existing application ie. E1 and else is for E2.
		  		if(resource.Estimate__r.E2_SA__c == NULL){
        		    String regionAndRole = resource.Role__c;
        		  	if(regionAndRole.indexOf('-') > 0){
        		  	    retResource.role = regionAndRole.substring(regionAndRole.lastIndexOf('-') + 2);
        		  		retResource.regionName = regionAndRole.substring(0, regionAndRole.lastIndexOf('-') - 1);
        		 	} else {
        		 		retResource.role = regionAndRole;
        		 	}
        		 	//grab Ids from Maps generated during the JSON parsing
    		  		retResource.regionId = RegionIdByRole.get(resource.Role__c);
    		  		retResource.practiceId = PracticeIdByRole.get(resource.Role__c);
    		  		retResource.rateCardId = RateCardIdByRole.get(resource.Role__c);
    		  		retResource.practiceName =  PracticeNameByRole.get(resource.Role__c);
		  		}else{
		  		    // especially for e2 because e2 stores the estimate rate cards and respective rate card info with it
		  		    retResource.role = resource.E2_Estimate_Rate_Card__r.Resource_Role__c;
		  		    retResource.regionName = resource.E2_Estimate_Rate_Card__r.Region__c;
		  		    retResource.practiceName =  resource.E2_Estimate_Rate_Card__r.Practice__c;
		  		    retResource.regionId = resource.E2_Estimate_Rate_Card__r.Rate_Card__r.pse__Region__c;
    		  		retResource.practiceId = resource.E2_Estimate_Rate_Card__r.Rate_Card__r.pse__Practice__c;
    		  		retResource.rateCardId = resource.E2_Estimate_Rate_Card__r.Rate_Card__c;
		  		}
		  		
		  		
		  		retResource.resourceId = resource.Id;
		  		
		  		retResource.curCode = resource.CurrencyISOCode;
		  		
		  		for (CMC_Estimate_Resource_Week__c detail : resource.Estimate_Resource_Weeks__r) {
		    		CMC_Estimate_Week__c ew = detail.Estimate_Week__r;
		    		
		    		//calculate the start date based on the first Resource Week that has hours
		    		if(retResource.startDate == null && detail.Hours__c != 0){
		    			retResource.startDate = ew.Date__c;
		    		}
		    		
		    		//calculate the end date based on the last Resource Week that has hours
		    		if(ew.Date__c != null && detail.Hours__c != 0){
		    			retResource.endDate = ew.Date__c.addDays(7); //add 7 because estimator only tracks start of week dates
		    		}
		 	 	}
		 	 	results.add(retResource);
			}
		}
		return results;
	}
	
	//  Parse ratecard JSON for Role, RegionName, regionId, practiceId, and RateCardId
	//  @param jsonStr A JSON string with Ratecard data from an Estimate
	static void parseRatecardJSON(String jsonStr){
		
		String role =  '';
		String regionName = '';  
		String regionId = '';
		String practiceId = '';
		String rateCardId = '';
		string practiceName = '';
        
        // For e2 there will cases when jsonStr will come empty or null
        if(jsonStr == NULL || String.isEmpty(jsonStr)) return;
        
        JSONParser parser = JSON.createParser(jsonStr);
        while (parser.nextToken() != null) {
        	
           	//START - start clean for this OBJ
            if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
            	role =  '';
				regionName = '';  
				regionId = '';
				practiceId = '';
				rateCardId = '';
				practiceName = '';
            }
            
            //END - store all the data collected for this OBJ
            if (parser.getCurrentToken() == JSONToken.END_OBJECT) {
           		 String roleKey = regionName + ' - ' + role; 

           		 E2_EstimateResourceAPI.RegionIdByRole.put(roleKey, regionId);
           		 E2_EstimateResourceAPI.PracticeIdByRole.put(roleKey, practiceId);
           		 E2_EstimateResourceAPI.RateCardIdByRole.put(roleKey, rateCardId);
           		 E2_EstimateResourceAPI.PracticeNameByRole.put(roleKey, practiceName);
            }
            
            //collect the data
            if( (parser.getCurrentToken() == JSONToken.FIELD_NAME) && parser.getText() == 'Id'){
            		parser.nextToken();
            		rateCardId = parser.getText();
            } else if ( (parser.getCurrentToken() == JSONToken.FIELD_NAME) && parser.getText() == 'Practice'){
            		parser.nextToken();
            		practiceId = parser.getText();
            } else if ( (parser.getCurrentToken() == JSONToken.FIELD_NAME) && parser.getText() == 'PracticeName'){
            		parser.nextToken();
            		practiceName = parser.getText();
            } else if ( (parser.getCurrentToken() == JSONToken.FIELD_NAME) && parser.getText() == 'RegionId'){
            		parser.nextToken();
            		regionId = parser.getText();
            } else if ( (parser.getCurrentToken() == JSONToken.FIELD_NAME) && parser.getText() == 'RegionName'){
            		parser.nextToken();
            		regionName = parser.getText();
            } else if ( (parser.getCurrentToken() == JSONToken.FIELD_NAME) && parser.getText() == 'Role'){
            		parser.nextToken();
            		role = parser.getText();
            } else{
            	parser.nextToken();	
            }
        }
	}
}