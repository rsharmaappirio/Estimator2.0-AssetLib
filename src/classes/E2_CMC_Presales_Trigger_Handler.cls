// 
// (c) 2015 Appirio, Inc.
//
// This class serves as a handler for Presales Estimate Trigger
//
// 9/21/2015    Saurabh Gupta      Original
// 9/21/2015    Saurabh Gupta      For S-353499 : Add Product on creation of Presales Estimate record
// 10/21/2015   Saurabh Gupta      For S-360957 : Changes to handle Is_Created_From_Custom_UI__c
// 11/07/2015   Saurabh Gupta	   For S-365752 : Populated RateCard_JSON__c when an Estimate is created
// 11/17/2015   Saurabh Gupta      For I-191220 : Added condition to handle NullPointer exception
// 11/20/2015   Saurabh Gupta	   For S-368002 : Added Component on creation of Presales Estimate record
// 10/27/2016   Vikash Goyal       For I-241434 : Added function to delete child scope records before deleting estimate record
// 11/11/2016   Rohit Sharma       For S-447474 : Fixed fee calculation support

public with sharing class E2_CMC_Presales_Trigger_Handler {
	// variables
    public static final String APPIRIO = 'Appirio';

    // called on before insert
    public void onBeforeInsert(List <CMC_Presales_LOE__c> newPresalesList) {
    	createProduct(newPresalesList);
    	createRateCardEntry(newPresalesList); //Changes S-365752
	}
	
	// called on before delete
    public void onBeforeDelete(List <CMC_Presales_LOE__c> oldPresalesList) {
    	deleteChildScopes(oldPresalesList);
	}
	
	// RS (S-447474) : 11/11 Method to call on estimate before update
	public void onBeforeUpdate(List <CMC_Presales_LOE__c> newPresalesList) {
	    updateDiscountPercentage(newPresalesList);
	}

    // create product record based on CMC_Presales_LOE__c.Name
    private void createProduct(List<CMC_Presales_LOE__c> presalesList) {

        // fetch account name with Appirio
        Id accountId;
        for (Account acct : [SELECT Id FROM Account WHERE Name =: APPIRIO Limit 1]) {
        	accountId = acct.Id;
        }

        // proceed only if there is valid account
        if(accountId != null) {
        	// iterate and insert the product records
	        List <CMC_Product__c> productList = new List <CMC_Product__c>();
	        List <CMC_Presales_LOE__c> updatePresalesList = new List <CMC_Presales_LOE__c>();
	        for(CMC_Presales_LOE__c presalesObj : presalesList) {
	        	if (!presalesObj.Is_Created_From_Custom_UI__c) {//Changes S-360957
		            // populate Product with Account and Active field
		            CMC_Product__c product = new CMC_Product__c();
		            product.Name = presalesObj.Name;
		            product.IS_Active__c = true;
		            product.Account__c = accountId;
		            productList.add(product);
		            updatePresalesList.add(presalesObj);
	        	}
	        }
	
	        // insert Products
	        if(!productList.isEmpty()) {
	            insert productList;
	        }
			
			List <CMC_Component__c> componentList = new List <CMC_Component__c>(); //Changes for S-368002
			
			//Changes for S-360957 Starts
	        // Assign appropriate lookup fields
	        for(Integer counter = 0; counter < updatePresalesList.size(); counter++) {
	            updatePresalesList[counter].Product__c = productList[counter].Id;
	            
	            //Changes For S-368002 Starts
            	CMC_Component__c comp = new CMC_Component__c();
            	comp.Name = 'Default Component';
            	comp.Product__c = productList[counter].Id;
            	comp.Is_Active__c = true;
            	componentList.add(comp);
            	//Changes for S-368002 Ends
	        }
	        //Changes for S-360957 Ends
	        
	        //Changes for S-368002 Starts
	        if (!componentList.isEmpty()) {
	        	insert componentList;
	        }
	        //Changes for S-368002 Ends
        }
    }
    
    //Changes for S-365752 Starts
    //Method to populate Rate Card Entry on given Presales Estimate
    public void createRateCardEntry(List<CMC_Presales_LOE__c> presalesList) {
    	Set <String> currencySet = new Set <String>();
    	Map <String, List <RateCard>> currencyRateCardMap = new Map <String, List <RateCard>>();
    	for (CMC_Presales_LOE__c presales : presalesList) {
    		if (!presales.Is_Created_From_Custom_UI__c) {
    			currencySet.add(presales.CurrencyIsoCode);
    		}
    	}
    	
    	//Fetch list of RateCards associated with given currencies
    	if (!currencySet.isEmpty()) {
	    	for (pse__Rate_Card__c rateCard : [SELECT Id, pse__Average_Cost_Rate__c, Code__c, pse__Practice__c, pse__Practice__r.Name, pse__Region__c, 
	    									   pse__Region__r.Name, pse__Role__c, pse__Suggested_Bill_Rate__c, CurrencyIsoCode FROM pse__Rate_Card__c 
	    									   WHERE CurrencyIsoCode IN: currencySet AND pse__Practice__r.Name IN ('SFDC - Technical', 'Community') 
	    									   ORDER BY pse__Average_Cost_Rate__c DESC]) {
	    		RateCard obj = new RateCard();
    			obj.Id = rateCard.Id;
    			obj.Resource_Cost = (rateCard.pse__Average_Cost_Rate__c).intValue();
    			obj.Suggested_Cost = (rateCard.pse__Average_Cost_Rate__c).intValue();
    			obj.Practice = rateCard.pse__Practice__c;
		        obj.PracticeName = rateCard.pse__Practice__r.Name;
		        obj.RegionId = rateCard.pse__Region__c;
		        obj.RegionName = rateCard.pse__Region__r.Name;
		        obj.Role = rateCard.pse__Role__c;
		        obj.Rate_Card = (rateCard.pse__Suggested_Bill_Rate__c).intValue();
		        obj.Rate = (rateCard.pse__Suggested_Bill_Rate__c).intValue();
		        obj.CurrencyIsoCode = rateCard.CurrencyIsoCode;
		        obj.Code = rateCard.Code__c;
		        obj.Category = rateCard.pse__Region__r.Name;
	    		if (!currencyRateCardMap.containsKey(rateCard.CurrencyIsoCode)) {
	    			currencyRateCardMap.put(rateCard.CurrencyIsoCode, new List <RateCard>());
	    		}
	    		currencyRateCardMap.get(rateCard.CurrencyIsoCode).add(obj);								   	
	    	}
	    	
	    	//Prepare list of RateCard records
	    	Map <String, String> currencyRateCardJSONMap = populateRateCardJSONObject(currencyRateCardMap);
	    	for (CMC_Presales_LOE__c presales : presalesList) {
	    		if (currencyRateCardJSONMap.size() > 0) {
		    		String rateCardJSON = currencyRateCardJSONMap.get(presales.currencyIsoCode);
		    		rateCardJSON = rateCardJSON != null ? rateCardJSON.replaceAll('Resource_Cost', 'Resource Cost') : rateCardJSON;
		    		rateCardJSON = rateCardJSON != null ? rateCardJSON.replaceAll('Suggested_Cost', 'Suggested Cost') : rateCardJSON;
		    		rateCardJSON = rateCardJSON != null ?rateCardJSON.replaceAll('Rate_Card', 'Rate Card') : rateCardJSON;
		    		
		    		presales.Ratecard_JSON__c = rateCardJSON;
	    		}
	    	}
    	}
    }
    
    //Method to populate RateCard JSON for given currency
    public Map <String, String> populateRateCardJSONObject(Map <String, List <RateCard>> currencyRateCardMap) {
    	Map <String, String> currencyRateCardJSONMap = new Map <String, String>();
    	
    	for (String currencyCode : currencyRateCardMap.keySet()) {
    		currencyRateCardJSONMap.put(currencyCode, JSON.serialize(currencyRateCardMap.get(currencyCode)));
    	}
    	return currencyRateCardJSONMap;
    }
    
    //Wrapper Class
    public class RateCard {
    	Id Id;
    	Decimal Resource_Cost;
    	Decimal Suggested_Cost;
    	String Practice;
    	String PracticeName;
    	String RegionId;
    	String RegionName;
    	String Role;
    	Decimal Rate_Card;
    	Decimal Rate;
    	String CurrencyIsoCode;
    	String Code;
    	String Category;
    }
    //Changes for S-365752 Ends
    
    //Method to delete all child scopes related to estimates
    private void deleteChildScopes(List<CMC_Presales_LOE__c> presalesList){
        List<E2_Scope__c> lstScopesToDelete = new List<E2_Scope__c>(E2_DataUtil.getChildScopesOfEstimate(presalesList));
        try{
            if(lstScopesToDelete.size() > 0){
                delete lstScopesToDelete;
            }
        }
        catch(DmlException ex){
            presalesList[0].addError(ex.getMessage());
        }
    }
    
    // RS (S-447474) : 11/11 Method to keep discount amount as entered by user previously for E2 estimates 
	private void updateDiscountPercentage(List <CMC_Presales_LOE__c> newPresalesList) {
	    for(CMC_Presales_LOE__c estimate : newPresalesList) {
	        if(estimate.E2_SA__c <> NULL && !string.isBlank(estimate.Discount__c) && 
	            estimate.Discount__c <> string.valueOf(estimate.Discount_Amount__c) && 
	            estimate.Service_Fees__c <> 0) {
	            decimal discount = Decimal.valueOf(estimate.Discount__c);
	            estimate.Discount_Percent__c = (discount * 100) / estimate.Service_Fees__c;
	        }
	    }
	}
}