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
  public Decimal marginNum;
  public Map<Id, double> mapIdtoRCMargin {get;set;}
  public Map<Id, Double> mapIdToRateMargin {get;set;}
  
  public E2_TimelineController (ApexPages.StandardController std) {
    this.estimate = (CMC_Presales_LOE__c)std.getRecord();
    this.estimateRateCards = new List<E2_Estimate_Rate_Card__c>();
    marginNum = 0;
    mapIdtoRCMargin = new Map<Id, double>();
    mapIdToRateMargin = new Map<Id, double>();
  }
  
  public PageReference pageAction(){
    super.validateAccess(this.estimate);
    this.estimateRateCards = E2_Estimator_Manager.getEstimateRateCards(this.estimate.Id, this.estimate.CurrencyISOCode);
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
    return null;
  }
  
  public PageReference updateEstimateRateCards(){
      Map<String, E2_Estimate_Rate_Card__c> roleRateMap = new Map<String, E2_Estimate_Rate_Card__c>();
      
      if(!this.estimateRateCards.isEmpty()){
        // Create a savepoint 
        // we don't want to save/update estimate rate cards, when there is a failure in the update
        // of estimate resources later
        Savepoint sp = Database.setSavepoint();
        try{
            update this.estimateRateCards;
            //create map
            for(E2_Estimate_Rate_Card__c estimateRateCard : this.estimateRateCards){
                roleRateMap.put(estimateRateCard.Region__c + ' - ' +  estimateRateCard.Resource_Role__c, estimateRateCard);
            }
            // query existing estimate resource records and update the modified cost 
            List<CMC_Estimate_Resource__c> lstEstimateResourcesToUpdate = new List<CMC_Estimate_Resource__c>();
            // loop over the existing resources and set the new rate with it
            for(CMC_Estimate_Resource__c res : [SELECT Id, Rate__c, Role__c 
                                                 FROM CMC_Estimate_Resource__c
                                                 WHERE Estimate__c = : this.estimate.Id]){
                // check that estimate rate card has a record for resource role and rate has been updated through manage rate card.                                     
                if(roleRateMap.containsKey(res.Role__c) && roleRateMap.get(res.Role__c).Discounted_Rate__c != res.Rate__c){
                    res.Rate__c = roleRateMap.get(res.Role__c).Discounted_Rate__c;
                    lstEstimateResourcesToUpdate.add(res);
                }
            }
            update lstEstimateResourcesToUpdate;                                                     
        }catch(Exception ex){
            Database.rollback(sp);
            System.debug('Error in update of estimate rate cards:' + ex.getMessage());
        }
      }
      pageAction();
      return null;
  }
  
  
  public PageReference buildCapacity() {
    E2_CapacityController.reBuildCapacity(this.estimate);
    PageReference pg = Page.E2_Capacity;
    pg.getParameters().put('id', this.estimate.id);    
    return pg; 
  }
}