// (c) Appirio
//
// Set a new primary Estimate - called from button "Set Primary" 
//
// 2014-10-13       Will Supinski     added "default" flag change S-264267
// 2016-09-28       Rohit Sharma      added the checks for null and empty list to resolve issue I-237464
// 2016-11-02       Rohit Sharma      modified code below for S-452048: Display a meaningful error message when inadvertently setting the Primary Estimate as the Primary
global class CMC_PresalesEstimate {
    
    public static Set<Id> nonDefaultProductIds = new Set<Id>();
    
    // RS 11/02: Added constants for duplicate error message and success msg
    public static final string DUPLICATE_MSG = 'The Presales Estimate you have selected is already marked as the Primary.';
    public static final string SUCCESS_MSG = 'Success';
    
    // RS 11/02: Added return type string to setPrimary Method 
    webservice static string setPrimary(String newPrimaryId, String psrId){
        
        List<CMC_Presales_LOE__c> newRecords = new List<CMC_Presales_LOE__c>();
        // RS 11/02: setup & initiate collection of set type; will be used to validate existing with new default
        Set<String> existingDefaultEstimates = new Set<String>();
        
        //find the old default record(s) 
        List<CMC_Presales_LOE__c> estimates = [SELECT id, Default__c, Product__c FROM CMC_Presales_LOE__c WHERE Default__c = true AND Presales_Request__c=:psrId ];
        
        for(CMC_Presales_LOE__c est: estimates) 
        {
            est.Default__c = false;
            newRecords.add(est);
            // RS 11/02: Added existing default estimate id in collection of set type. 
            existingDefaultEstimates.add(est.id);
            // RS 09/28: only fill this list when estimate product is not null
            if(est.Product__c <> NULL) nonDefaultProductIds.add(est.Product__c);
        } 
        
        
        
        //mark the new record as default 
        List<CMC_Presales_LOE__c> newdefaultQuery = [SELECT Id, Default__c, Product__c, Presales_Request__r.Opportunity__c
                FROM CMC_Presales_LOE__c 
                WHERE Id =: newPrimaryId];
        CMC_Presales_LOE__c newDefaultLOE = newdefaultQuery[0];
        newDefaultLOE.Default__c = true; 
        newRecords.add(newDefaultLOE); 
        
        // RS 11/02: Check if the new primary is same as old; if yes throw the exception
        if(existingDefaultEstimates.contains(newDefaultLOE.id)){
          return DUPLICATE_MSG;          
        }
        
        update newRecords;
        // RS 09/28: run only when the previous default estimate have the product assigned
        if(!nonDefaultProductIds.isEmpty()) CMC_PresalesEstimate.updateAssetUsages(newDefaultLOE);
        
        // when everything being process send a success message to invoker.
        return SUCCESS_MSG;
    }
    
    //after updating estimates - update child Asset Reuses
    public static void updateAssetUsages(CMC_Presales_LOE__c newDefaultLOE){
        
        //remove Opportunity relation to non default estimates
        List<CMC_Asset_Usage__c> assetUsages = [SELECT Opportunity__c, Story__c FROM CMC_Asset_Usage__c 
                                            WHERE Story__r.Epic__r.Product__c IN :nonDefaultProductIds];
        for(CMC_Asset_Usage__c au: assetUsages){
            au.Opportunity__c = null;
        }
        
        // RS 09/28: run only when current estimate has a product assigned
        if(newDefaultLOE.Product__c <> NULL) {
            //add Opportunity relation to default estimate
            List<CMC_Asset_Usage__c> primaryAssetUsages = [SELECT Opportunity__c, Story__c FROM CMC_Asset_Usage__c 
                                WHERE Story__r.Epic__r.Product__c = :newDefaultLOE.Product__c];
            for(CMC_Asset_Usage__c au: primaryAssetUsages){
                au.Opportunity__c = newDefaultLOE.Presales_Request__r.Opportunity__c;
                assetUsages.add(au);
            }
        }
        
        if(!assetUsages.isEmpty()) update assetUsages;
    }
    
}