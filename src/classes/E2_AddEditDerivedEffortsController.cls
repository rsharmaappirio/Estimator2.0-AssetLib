/**=====================================================================
 * Appirio, Inc
 * Name: E2_AddEditDerivedEffortsController
 * Description: Controller class to add/update derived efforts on estimate
 * Created Date: 
 * Created By: Rahul Jain (Appirio)
 * 
 * Date Modified      Modified By                  Description of the update
 * May 18, 2016       Rohit Sharma                      
*  =====================================================================*/
public with sharing class E2_AddEditDerivedEffortsController extends E2_Master {
  public CMC_Presales_LOE__c estimate {get;set;}
  public List<DerivedEffort> clonnedDerivedEffortList{get;set;}
  public String deffortTemplateIds{get;set;}
  public String deffortGroupName{get;set;}
  
  public E2_AddEditDerivedEffortsController(ApexPages.StandardController std) {
    this.estimate = (CMC_Presales_LOE__c)std.getRecord();
    this.clonnedDerivedEffortList = new List<DerivedEffort>();
  }
  
  public PageReference pageAction(){
    super.validateAccess(this.estimate);
    if(this.estimate.id == NULL){
        return null;        
    }else{
        if(this.estimate.E2_Derived_Effort_Template__c != null) {
            getDerivedEffortTemplates(this.estimate.E2_Derived_Effort_Template__c);
        }
    }
    return null;    
  }
  
  public PageReference save(){
    system.debug('in save method');
    Savepoint sp = Database.setSavepoint();        
    try{
        estimate.E2_Derived_Effort_Template__c = deffortTemplateIds;
        update estimate;       
    }catch(Exception ex){
        Database.rollback(sp);
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        return null;
    }
    PageReference pg = Page.E2_AddEditDerivedEfforts;
    pg.getParameters().put('id', this.estimate.id);
    pg.setRedirect(true);
    return pg;      
  }
  
  public PageReference removeDerivedEffort(){
    Savepoint sp = Database.setSavepoint();        
    try{
        estimate.E2_Derived_Effort_Template__c = null;
        update estimate;  
        clonnedDerivedEffortList.clear();  
        deffortGroupName = null; 
        deffortTemplateIds = null;  
    }catch(Exception ex){
        Database.rollback(sp);
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        return null;
    }
    return null;
  }

  public PageReference cloneDerivedEffort() {
    if(!String.isBlank(deffortTemplateIds)) {
        save();
        getDerivedEffortTemplates(deffortTemplateIds);
    }
    return null;
  }
  
  public PageReference buildCapacity() {
    E2_CapacityController.reBuildCapacity(this.estimate);
    PageReference pg = Page.E2_Capacity;
    pg.getParameters().put('id', this.estimate.id);    
    return pg; 
  }
  
  private void getDerivedEffortTemplates(string groupId) {
    clonnedDerivedEffortList.clear();
    for(E2_Derived_Effort_Group__c dG : E2_DataUtil.getDerivedEffortGroupById(groupId)) {
        deffortGroupName = dG.Name;
    }
    map<string, DerivedEffort> combinedderivedEfforts = new map<string, DerivedEffort>();
    List<E2_Derived_Effort__c> derivedEffortsTemplate = E2_DataUtil.getDerivedEffort(groupId);
    E2_Estimator_Manager.generateDerivedHours(estimate.Id, derivedEffortsTemplate);
    for(E2_Derived_Effort__c dE : derivedEffortsTemplate) {
        if(combinedderivedEfforts.containsKey(dE.UniqueKey__c)) 
            combinedderivedEfforts.get(dE.UniqueKey__c).addPhase(dE);
        else 
            combinedderivedEfforts.put(dE.UniqueKey__c, new DerivedEffort(dE));
    }
    clonnedDerivedEffortList.addAll(combinedderivedEfforts.values());
  }
  
  public class DerivedEffort{
    
    public E2_Derived_Effort__c derivedEffort{get;set;}
    public String name{get;set;}
    public String ofRole{get;set;}
    public String toRole{get;set;}
    public String ofPhase{get;set;}
    public String toPhase{get;set;}
    public Decimal allocation{get;set;}
    public String includeWhen{get;set;}
    public Decimal includeWhenHrs{get;set;}
    public Decimal allocationMin{get;set;}
    public decimal derivedHrs{get;set;}
    
    public DerivedEffort(E2_Derived_Effort__c derivedEffort){
        this.derivedEffort = derivedEffort;
        this.name = derivedEffort.Name;
        this.ofRole = derivedEffort.Of_Role__c;
        this.toRole = derivedEffort.Role__c;
        this.ofPhase = String.isBlank(derivedEffort.Of_Phase__c) ? E2_constants.BLANK : derivedEffort.Of_Phase__c;
        this.toPhase = derivedEffort.To_Phase__c;
        this.allocation = derivedEffort.Original_Allocation_Hours__c == NULL ? derivedEffort.Allocation__c : derivedEffort.Original_Allocation_Hours__c;
        this.includeWhen = derivedEffort.Include_When__c;
        this.includeWhenHrs = derivedEffort.Include_When_Hours__c;    
        this.derivedHrs = derivedEffort.Derived_Hrs__c;
        this.allocationMin = derivedEffort.Allocation_Min__c;
    }
    
    public void addPhase(E2_Derived_Effort__c derivedEffort) {
        if(this.toPhase.indexOf(derivedEffort.To_Phase__c) == -1)
        this.toPhase += E2_Constants.COMMA + E2_Constants.SPACE + derivedEffort.To_Phase__c;
        if(!String.isBlank(derivedEffort.Of_Phase__c) && this.ofPhase.indexOf(derivedEffort.Of_Phase__c) == -1)
            this.ofPhase += E2_Constants.COMMA + E2_Constants.SPACE + derivedEffort.Of_Phase__c;
        this.derivedHrs += derivedEffort.Derived_Hrs__c;
    }
        
  }
}