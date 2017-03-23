/**=====================================================================
 * Appirio, Inc
 * Name: E2_TimelineController
 * Description: Controller class for E2_ResourceTimeline page
 * Created Date: Feb 13th, 2017
 * Created By: Rohit Sharma (Appirio)
 * 
 * Date Modified      Modified By         Description of the update
 * Oct 26th, 2016     Rohit Sharma        S-447680 : Round off the hours to nearest figure on capacity tab.
 * Nov 11th, 2016     Rohit Sharma        S-447474 : Fixed fee calculation support
 * Nov 23th, 2016     Rohit Sharma        S-455804 : Default fixed fee uplift cost and buffer
 * Dec 26, 2016       Rahul Jain          S-459273 : Added Resource Level field in getEstimateRateCards method
 * Dec 27, 2016       Rahul Jain          S-459273 : Updated populateCapacityNeeds method to add resource level logic
*  =====================================================================*/
public with sharing class E2_ResourceTimelineController extends E2_Master {
    
  public CMC_Presales_LOE__c estimate {get;set;}
  public List<E2_Estimate_Rate_Card__c> estimateRateCards{get;set;}
  public string renderOptions_PhasesJSON{get;set;}
  public string capacityNeeds_JSON{get;set;}
  public static final string SEPARATOR = ' - ';
  public string estimate_Mode{get;set;}
  public decimal discountAmount{get;set;}
  public E2_System_setting__c e2SystemSetting{get;set;}
  private string primaryTimelineId;

  public E2_ResourceTimelineController (ApexPages.StandardController std) {
    // constructor : use to initiate the variable
    this.estimate = (CMC_Presales_LOE__c)std.getRecord();
    this.estimateRateCards = new List<E2_Estimate_Rate_Card__c>();
    this.estimate.Discount_Percent__c = (this.estimate.Discount_Percent__c == NULL ? 0 : this.estimate.Discount_Percent__c);
    primaryTimelineId = this.estimate.E2_Parent_Estimate__c <> NULL ? this.estimate.E2_Parent_Estimate__c : this.estimate.Id;
    e2SystemSetting = E2_System_setting__c.getInstance();
    // populate renderOptions_PhasesJSON field
    populateRenderOptions();
  }
  
  
  public void populateRenderOptions(){
     // method to populate the renderOptions_PhasesJSON variable with phases 
     // and color code utilize in the phase column/row of the grid
     
     this.discountAmount = this.estimate.Discount_Amount__c;
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
      if(estimate.Id != null) 
     // method to refresh overview panel - Estimate Summary Section above the grid
     this.estimate = [SELECT id, Name, Service_Fees__c,
                        Service_Costs__c,
                        Service_Margin__c,                
                        Calculated_Fees__c,
                        Calculated_Costs__c,
                        Calculated_Margin__c,
                        Discount_Percent__c,
                        Discount_Amount__c,
                        Discount__c,
                        Total_Fees__c,
                        As_Sold_Margin__c,
                        Final_Total__c,
                        Blended_Rate_Number__c,
                        Offshore_Blend__c,
                        Ratecard_JSON__c,
                        Mode__c,
                        Services_Uplifted_Costs__c,
                        Fixed_Fee_Cost_Uplift__c,
                        Fixed_Fee_Cost_Uplift_Percent__c,
                        Fixed_Fee_Buffer__c,
                        Fixed_Fee_Blended__c,
                        Fixed_Fee_Buffer_Amount__c,
                        Topcoder_Challenge_Fees__c,
                        Asset_Fees__c,
                        Total_Resource_Hours__c,
                        E2_Estimate_Total_Weeks__c 
                       FROM CMC_Presales_LOE__c 
                       WHERE Id = :estimate.id];
      
      this.estimate.Discount_Percent__c = (this.estimate.Discount_Percent__c == NULL ? 0 : this.estimate.Discount_Percent__c);
      this.estimate.Fixed_Fee_Buffer__c = (this.estimate.Fixed_Fee_Buffer__c == NULL ? 0 : this.estimate.Fixed_Fee_Buffer__c);
      this.discountAmount = this.estimate.Discount_Amount__c;
      return null;
  }
  
  
  public void changeDiscount(){
      // this method gets invoked when user changes or update the discount input in Estimate 
      // Summary above the grid. 
      try{
        this.estimate.Discount__c = NULL;  
        update this.estimate;
      }catch(Exception ex){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));  
      }
      refreshOverviewPanel(); 
  }
  
  public void changeFixedFee(){
      // this method gets invoked when user changes or update the fixed fee buffer input in Estimate 
      // Summary above the grid. 
      try{
        update this.estimate;
      }catch(Exception ex){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));  
      }
      refreshOverviewPanel(); 
  }
  
  public void changeDiscountAmount() {
      // this method gets invoked when user changes or update the discount input in Estimate 
      // Summary above the grid. 
      try{
        decimal discountPct = (this.discountAmount * 100) / this.estimate.Service_Fees__c;
        this.estimate.Discount_Percent__c = discountPct;
        this.estimate.Discount__c = string.valueOf(this.discountAmount);
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
    this.capacityNeeds_JSON = E2_Estimator_Manager.populateCapacityNeeds(primaryTimelineId);
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
            // add resource role also
            estimateRC.Resource_Level__c = rateCard.E2_Resource_Level__c;
            // S-469552 : VG : March 2, 2017
            estimateRC.Practice_Id__c = rateCard.pse__Practice__c;
            estimateRC.Region_Id__c = rateCard.pse__Region__c;
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
                if(erateCard.Rate_Card__c <> NULL) rateCardIds.add(erateCard.Rate_Card__c);
            }                                                   
            
            
            // check that no new rate card entries exist in the system for this selected currency.  
            for(pse__Rate_Card__c rateCard : E2_DataUtil.getpseRateCardRecs(rateCardIds, currencyCode)) {
                newRateCardsToInsert.add(getEstimateRateCard(rateCard, currencyCode));
            }
            system.debug('estimateRateCards>>' +estimateRateCards);
            //update the estimate rate card values 
            for(E2_Estimate_Rate_Card__c erateCard : estimateRateCards){
                boolean hasChanged = false;
                if(erateCard.Rate_Card__c <> NULL){
                    // when original rate does not match bill rate 
                    if(erateCard.Bill_Rate__c <> erateCard.Rate_Card__r.pse__Suggested_Bill_Rate__c){
                        system.debug('erateCard>>' +erateCard);
                        if(erateCard.Bill_Rate__c == erateCard.Discounted_Rate__c) erateCard.Discounted_Rate__c = erateCard.Rate_Card__r.pse__Suggested_Bill_Rate__c;
                        erateCard.Bill_Rate__c = erateCard.Rate_Card__r.pse__Suggested_Bill_Rate__c;
                        hasChanged = true;
                    }
                    // when original cost doesn't match the resource cost
                    if(erateCard.Resource_Cost__c <> erateCard.Rate_Card__r.pse__Average_Cost_Rate__c){
                        system.debug('erateCard==>>' +erateCard);
                        erateCard.Resource_Cost__c = erateCard.Rate_Card__r.pse__Average_Cost_Rate__c;
                        hasChanged = true;
                    }
                    // when original resource level doesn't match the existing record.
                    if(erateCard.Resource_Level__c <> erateCard.Rate_Card__r.E2_Resource_Level__c) {
                        system.debug('erateCard==>>' +erateCard);
                        erateCard.Resource_Level__c = erateCard.Rate_Card__r.E2_Resource_Level__c;
                        hasChanged = true;
                    }
                    // S-469552 : VG : March 2, 2017
                    // when original resource role doesn't match the existing record.
                    if(erateCard.Resource_Role__c <> erateCard.Rate_Card__r.pse__Role__c) {
                        erateCard.Resource_Role__c = erateCard.Rate_Card__r.pse__Role__c;
                        hasChanged = true;
                    }
                     // when original region doesn't match the existing record.
                    if(erateCard.Region__c <> erateCard.Rate_Card__r.pse__Region__r.Name) {
                        erateCard.Region__c = erateCard.Rate_Card__r.pse__Region__r.Name;
                        hasChanged = true;
                    }
                     // when original practice doesn't match the existing record.
                    if(erateCard.Practice__c <> erateCard.Rate_Card__r.pse__Practice__r.Name) {
                        erateCard.Practice__c = erateCard.Rate_Card__r.pse__Practice__r.Name;
                        hasChanged = true;
                    }
                     // when original practice lookup doesn't match the existing record.
                    if(erateCard.Practice_Id__c <> erateCard.Rate_Card__r.pse__Practice__c) {
                        erateCard.Practice_Id__c = erateCard.Rate_Card__r.pse__Practice__c;
                        hasChanged = true;
                    }
                     // when original region lookup doesn't match the existing record.
                    if(erateCard.Region_Id__c <> erateCard.Rate_Card__r.pse__Region__c) {
                        erateCard.Region_Id__c = erateCard.Rate_Card__r.pse__Region__c;
                        hasChanged = true;
                    }
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
                
                this.estimateRateCards = E2_DataUtil.getEstimateRateCards(estimate.Id);
                //12/26: no need to update the estimate ratecard json now; e2 doesn't need this
                //E2_Estimator_Manager.updateEstimeRateCardJSON(this.estimateRateCards, this.estimate.Id);
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
             //12/26: no need to update the estimate ratecard json now; e2 doesn't need this
            //E2_Estimator_Manager.updateEstimeRateCardJSON(this.estimateRateCards, this.estimate.Id);
        }catch(Exception ex){
            Database.rollback(sp);
            System.debug('Error in update of estimate rate cards:' + ex.getMessage());
        }
      }
      return null;
  }
  
  public void updateEstimateResources(){
      //TODO: RJ Change the below logic later on estimate rate card id stored in CMC Estimate Resource object.
      //WE DID THE BELOW LOGIC BECAUSE WE WANT APPLICATION TO WORK FOR E1 Estimates too.
    // method that helps in updating the existing estimate resources related to current estimate
    // with the updated/new billing rate and the cost rate.
    Map<String, E2_Estimate_Rate_Card__c> roleRateMap = new Map<String, E2_Estimate_Rate_Card__c>();
    List<CMC_Estimate_Resource__c> lstEstimateResourcesToUpdate = new List<CMC_Estimate_Resource__c>();
    //create map
    /** S-469552 : 2nd March 2017 : commented this one and added new logic below
    for(E2_Estimate_Rate_Card__c estimateRateCard : this.estimateRateCards){
        roleRateMap.put(estimateRateCard.Practice__c + SEPARATOR + estimateRateCard.Region__c + 
             SEPARATOR +  estimateRateCard.Resource_Role__c + 
             // 01/11/17: RJ: Added this logic to work with save operations after new Resource Level field added
             (String.isBlank(estimateRateCard.Resource_Level__c) ? E2_Constants.BLANK : SEPARATOR + estimateRateCard.Resource_Level__c), estimateRateCard);
        
    }**/
    
    for(E2_Estimate_Rate_Card__c estimateRateCard : this.estimateRateCards){
        roleRateMap.put(estimateRateCard.Id, estimateRateCard);
        
    }
    // query existing estimate resource records and update the modified rate 
    // loop over the existing resources and set the new rate with it
    for(CMC_Estimate_Resource__c res : [SELECT Id, Rate__c, E2_Role__c, Role__c, Cost__c, E2_Estimate_Rate_Card__c
                                         FROM CMC_Estimate_Resource__c
                                         WHERE Estimate__c = : this.estimate.Id]){
        boolean hasChanged = false;   
        //string e2Role = res.E2_Role__c;
        string e2Role = res.E2_Estimate_Rate_Card__c;
        
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
        
        if(roleRateMap.containsKey(e2Role)){
            String resource = roleRateMap.get(e2Role).Practice__c + SEPARATOR + 
                                roleRateMap.get(e2Role).Region__c + SEPARATOR + 
                                roleRateMap.get(e2Role).Resource_Role__c;
                    
            if(roleRateMap.get(e2Role).Resource_Level__c != null && roleRateMap.get(e2Role).Resource_Level__c != ''){ 
                        resource += SEPARATOR + roleRateMap.get(e2Role).Resource_Level__c;
            }
            
            if(res.E2_Role__c != resource){
                res.E2_Role__c = resource;
                hasChanged = true;
            }
        }
                
        
        if(hasChanged) lstEstimateResourcesToUpdate.add(res);
    }
    
    try{
       if(!lstEstimateResourcesToUpdate.isEmpty())   update lstEstimateResourcesToUpdate; 
    }catch(Exception ex){
       System.debug(ex.getMessage()); 
    }
    
  }
  
  public void changeEstimateMode() {
      //RS: 11/11 this method gets invoked when user chnages estimate mode to either T & M or Fixed Fee
      // above summary section
      if(!string.isBlank(this.estimate_Mode)) {
          this.estimate.Mode__c = this.estimate_Mode;
          if(estimate_Mode == E2_Constants.ESTIMATE_MODE_FIXED_FEE) {
              // RS: 11/23 : Default fixed fee uplift cost and buffer from custom setting.
              this.estimate.Fixed_Fee_Cost_Uplift_Percent__c = e2SystemSetting.Fixed_Fee_Cost_Uplift__c;
              if(this.estimate.Fixed_Fee_Buffer__c == NULL ||
                 this.estimate.Fixed_Fee_Buffer__c == 0) {
                  this.estimate.Fixed_Fee_Buffer__c = e2SystemSetting.Fixed_Fee_Buffer__c;
              }
          }
          try{
            update this.estimate;
          }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));  
          }
          refreshOverviewPanel();
      }
  }
}