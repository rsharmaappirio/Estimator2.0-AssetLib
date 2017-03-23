// (c) Appirio
//
// Controller class for E2_RedirectToPrimaryTimeline Page
//
// 2016-12-19       Vikash Goyal     S-455024 : Primary Timeline link on PSR.

public with sharing class E2_RedirectToPrimaryTimelineController {
    
    public Presales_Request__c presalesReq {get;set;}
    public string primaryEstimateId {get;set;}
    public string primaryEstimateType {get;set;}
    public Boolean isE2Estimate {get;set;}
    
    public E2_RedirectToPrimaryTimelineController(ApexPages.StandardController std){
        presalesReq = (Presales_Request__c)std.getRecord();
        primaryEstimateId = '';
        isE2Estimate = true;
        primaryEstimateType = '';
    }
    
    public pageReference pageAction(){
        List<CMC_Presales_LOE__c> primaryEstimate = new List<CMC_Presales_LOE__c>([SELECT Id, Name, e2_estimate__c, Type__c 
                                                                        FROM CMC_Presales_LOE__c
                                                                        WHERE Default__c = true AND Presales_Request__c = :presalesReq.Id]);
        if(primaryEstimate.size() > 0){
            primaryEstimateId = primaryEstimate[0].Id;
            isE2Estimate = primaryEstimate[0].e2_estimate__c;
            primaryEstimateType = primaryEstimate[0].Type__c;
        }
        return null;
    }
}