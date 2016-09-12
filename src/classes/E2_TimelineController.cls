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
  public string renderOptions_PhasesJSON{get;set;}
  public string capacityNeeds_JSON{get;set;}
  public String ratecard_JSON {get;set;}
  public static final string SEPARATOR = ' - ';
  public List<RateCardJSONWrapper> rcList;
  
  public E2_TimelineController (ApexPages.StandardController std) {
    // constructor : use to initiate the variable
    this.estimate = (CMC_Presales_LOE__c)std.getRecord();
    this.estimateRateCards = new List<E2_Estimate_Rate_Card__c>();
    this.estimate.Discount_Percent__c = (this.estimate.Discount_Percent__c == NULL ? 0 : this.estimate.Discount_Percent__c);
    // populate renderOptions_PhasesJSON field
    populateRenderOptions();
    rcList = new List<RateCardJSONWrapper>();
  }
  
  
  public void populateRenderOptions(){
     // method to populate the renderOptions_PhasesJSON variable with phases 
     // and color code utilize in the phase column/row of the grid
     
     
     Schema.DescribeFieldResult fieldResult = E2_Effort__c.Phase__c.getDescribe();
     List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
     Map<String, String> phaseColorCodeMap = E2_Constants.PHASE_COLORCODE_MAP;
     
     // TODO: For first instance we are not moving these wild characters in constants; as these characters defines the 
     // logic behind what is happening...
     this.renderOptions_PhasesJSON = '{';
     for( Schema.PicklistEntry f : ple){
      string lineitem = '"' + f.getLabel() + '" : "' + (phaseColorCodeMap.containsKey(f.getLabel()) ? phaseColorCodeMap.get(f.getLabel()) : '') + '"';
      this.renderOptions_PhasesJSON += (this.renderOptions_PhasesJSON == '{' ? '' : ',') + lineitem;
     }
     this.renderOptions_PhasesJSON += '}';
  }
  
  
  public pagereference refreshOverviewPanel(){
     // method to refresh overview panel - Estimate Summary Section above the grid
     this.estimate = [SELECT id, Name, Service_Fees__c,
                        Service_Costs__c,
                        Service_Margin__c,                
                        Calculated_Fees__c,
                        Calculated_Costs__c,
                        Calculated_Margin__c,
                        Discount_Percent__c,
                        Discount_Amount__c,
                        Total_Fees__c,
                        As_Sold_Margin__c,
                        Final_Total__c,
                        Blended_Rate_Number__c,
                        Offshore_Blend__c,
                        Ratecard_JSON__c
                       FROM CMC_Presales_LOE__c 
                       WHERE Id = :estimate.id];
      
      this.estimate.Discount_Percent__c = (this.estimate.Discount_Percent__c == NULL ? 0 : this.estimate.Discount_Percent__c);
      
      return null;
  }
  
  
  public void changeDiscount(){
      // this method gets invoked when user changes or update the discount input in Estimate 
      // Summary above the grid. 
      try{
        update this.estimate;
      }catch(Exception ex){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));  
      }
      refreshOverviewPanel(); 
  }
  
  
  public PageReference pageAction(){
    // method for page action 
    super.validateAccess(this.estimate);
    populateCapacityNeeds();
    this.estimateRateCards = E2_Estimator_Manager.getEstimateRateCards(this.estimate.Id, this.estimate.CurrencyISOCode);
    return null;
  }
  
  public void populateCapacityNeeds() {
      // method to populate the capacityNeeds_JSON variable with Phase hours
      // Role hours and total capacity needs from Capicity needs calculated 
      // from Scopes
    this.capacityNeeds_JSON = '{';
    
    string phaseHours_JSON = '{';
    for(AggregateResult groupedResults : [SELECT SUM(Hours__c) Hours, Phase__c  FROM E2_Capacity__c WHERE Estimator__c =: this.estimate.Id  GROUP BY Phase__c]) {
        string phaseHour = '"' + string.valueOf(groupedResults.get('Phase__c')).toLowerCase() + '" : "' + Integer.valueOf(groupedResults.get('Hours')) + '"';
        phaseHours_JSON += (phaseHours_JSON == '{' ? '' : ',') + phaseHour;
    }
    phaseHours_JSON += '},';
    this.capacityNeeds_JSON += '"PhaseHours" : '+ phaseHours_JSON;
    string roleHours_JSON = '{';
    for(AggregateResult groupedResults : [SELECT SUM(Hours__c) Hours, Role__c  FROM E2_Capacity__c WHERE Estimator__c =: this.estimate.Id  GROUP BY Role__c]) {
        string roleHour = '"' + string.valueOf(groupedResults.get('Role__c')).toLowerCase() + '" : "' + Integer.valueOf(groupedResults.get('Hours')) + '"';
        roleHours_JSON += (roleHours_JSON == '{' ? '' : ',') + roleHour;
    }
    roleHours_JSON += '},';
    this.capacityNeeds_JSON += '"RoleHours" : '+ roleHours_JSON;
    AggregateResult[] totalHours = [SELECT SUM(Hours__c) Hours FROM E2_Capacity__c WHERE Estimator__c =: this.estimate.Id];
    this.capacityNeeds_JSON += '"TotalHours" : "' + (totalHours[0].get('Hours') == NULL ? '' : ''+Integer.valueOf(totalHours[0].get('Hours'))) + '"';
    this.capacityNeeds_JSON += '}';
  }
  
   
  public E2_Estimate_Rate_Card__c getEstimateRateCard(pse__Rate_Card__c rateCard, String currencyCode){
       // method to get instance of estimate rate card object with the ratecard record association.
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
      // this method is invoked by clicking on set cost & rates button
      // this method readjust the billing rate and the cost rate on estimate resources; estimate rate card records
      // associated to current estimate. 
      // TODO: Do we need to record the changes in the practice or region etc
       if(estimate.CurrencyISOCode <> NULL){
           Set<Id> rateCardIds = new Set<Id>();
           string currencyCode = estimate.CurrencyISOCode;
           List<E2_Estimate_Rate_Card__c> newRateCardsToInsert = new List<E2_Estimate_Rate_Card__c>();
           List<E2_Estimate_Rate_Card__c> rateCardsToUpdate = new List<E2_Estimate_Rate_Card__c>();
           
           List<E2_Estimate_Rate_Card__c> estimateRateCards = E2_DataUtil.getEstimateRateCardRecs(estimate.Id);
            
            // create a set of existing rate card ids                                                   
            for(E2_Estimate_Rate_Card__c erateCard : estimateRateCards){
                rateCardIds.add(erateCard.Rate_Card__c);
            }                                                   
            
            
            // check that no new rate card entries exist in the system for this selected currency.  
            for(pse__Rate_Card__c rateCard : E2_DataUtil.getpseRateCardRecs(rateCardIds, currencyCode)) {
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
            
            
            try{
                if(!rateCardsToUpdate.isEmpty()){
                    update rateCardsToUpdate;
                }
                
                if(!newRateCardsToInsert.isEmpty()){
                    insert newRateCardsToInsert;
                }
                
                this.estimateRateCards = E2_DataUtil.getEstimateRateCardRecs(estimate.Id);
                
                updateEstimateResources();
            }catch(Exception ex){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));  
            }
        
       }
      return null;
  }
  
  
  public PageReference updateEstimateRateCards(){
      // When save button is clicked 
      
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
      
      //pageAction();
      // TODO: Check whey are are setting back the estimate rate card records.
      //this.estimateRateCards = E2_Estimator_Manager.getEstimateRateCards(this.estimate.Id, this.estimate.CurrencyISOCode);
      
      return null;
  }
  
  public void updateEstimateResources(){
    // method that helps in updating the existing estimate resources related to current estimate
    // with the updated/new billing rate and the cost rate.
    Map<String, E2_Estimate_Rate_Card__c> roleRateMap = new Map<String, E2_Estimate_Rate_Card__c>();
    List<CMC_Estimate_Resource__c> lstEstimateResourcesToUpdate = new List<CMC_Estimate_Resource__c>();
    
    //create map
    for(E2_Estimate_Rate_Card__c estimateRateCard : this.estimateRateCards){
        roleRateMap.put(estimateRateCard.Practice__c + SEPARATOR + estimateRateCard.Region__c + SEPARATOR +  estimateRateCard.Resource_Role__c, estimateRateCard);
        
    }
    // query existing estimate resource records and update the modified rate 
    // loop over the existing resources and set the new rate with it
    for(CMC_Estimate_Resource__c res : [SELECT Id, Rate__c, E2_Role__c, Role__c, Cost__c 
                                         FROM CMC_Estimate_Resource__c
                                         WHERE Estimate__c = : this.estimate.Id]){
        boolean hasChanged = false;   
        string e2Role = res.E2_Role__c;
        // check that estimate rate card has a record for resource role and rate has been updated through manage rate card.                                     
        if(roleRateMap.containsKey(e2Role) && roleRateMap.get(e2Role).Discounted_Rate__c != res.Rate__c){
            res.Rate__c = roleRateMap.get(e2Role).Discounted_Rate__c;
            hasChanged = true;
        }
        
        // check that estimate rate card has a record for resource role and cost has been updated through manage rate card.                                     
        if(roleRateMap.containsKey(e2Role) && roleRateMap.get(e2Role).Resource_Cost__c != res.Cost__c){
            res.Cost__c = roleRateMap.get(e2Role).Resource_Cost__c;
            hasChanged = true;
        }
        
        if(hasChanged) lstEstimateResourcesToUpdate.add(res);
    }
    
    try{
       if(!lstEstimateResourcesToUpdate.isEmpty())   update lstEstimateResourcesToUpdate; 
    }catch(Exception ex){
       System.debug(ex.getMessage()); 
    }
    
  }
  
  private RateCardJSONWrapper populateRateCard(E2_Estimate_Rate_Card__c erc) {
        RateCardJSONWrapper rateCard = new RateCardJSONWrapper();
        rateCard.Id = erc.Rate_Card__c;
        rateCard.Resource_Cost = (erc.Resource_Cost__c).intValue();
        rateCard.Suggested_Cost = (erc.Resource_Cost__c).intValue();
        rateCard.Practice = erc.Rate_Card__r.pse__Practice__c;
        rateCard.PracticeName = erc.Practice__c;
        rateCard.RegionId = erc.Rate_Card__r.pse__Practice__c;
        rateCard.RegionName = erc.Region__c;
        rateCard.Role = erc.Resource_Role__c;
        rateCard.Rate_Card = (erc.Bill_Rate__c).intValue();
        rateCard.Rate = (erc.Discounted_Rate__c).intValue();
        rateCard.CurrencyIsoCode = erc.CurrencyIsoCode;
        rateCard.Code = erc.Code__c;
        rateCard.Category = erc.Category__c;
        return rateCard;
  }
  
  public void populateRateCardJSON(pse__Rate_Card__c rateCard, E2_Estimate_Rate_Card__c erc, String currencyCode){
     /*   this.ratecard_JSON = '{';
        this.ratecard_JSON += '"Id":"'+ erc.Id + '","Resource Cost":' + erc.Resource_Cost__c + ',"Suggested Cost":' + erc.Resource_Cost__c + ',"Practice":"' + rateCard.pse__Practice__c +'",';
        this.ratecard_JSON += '"PracticeName":"' + erc.Practice__c + '","RegionId": "' + rateCard.pse__Region__c + '","RegionName":"' +  erc.Region__c + '","Role":"' + erc.Resource_Role__c + '",';
        this.ratecard_JSON += '"Rate Card":' + erc.Rate_Card__c + ',"Rate":' + erc.Rate_Card__c + ',"CurrencyIsoCode":"' + currencyCode + '", "Code":"' + erc.Code__c + '",';
        this.ratecard_JSON += '"Category":"' + erc.Category__c + '"';
        this.ratecard_JSON += '}'; */
     
    //rcList =      List<RateCardJSONWrapper>   
        
  }
  
  //
  class RateCardJSONWrapper {
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