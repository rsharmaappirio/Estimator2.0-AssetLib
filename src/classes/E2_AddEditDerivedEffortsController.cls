/**=====================================================================
 * Appirio, Inc
 * Name: E2_AddEditDerivedEffortsController
 * Description: Controller class to add/update derived efforts on estimate
 * Created Date: 
 * Created By: Rahul Jain (Appirio)
 * 
 * Date Modified      Modified By                  Description of the update
 * May 18, 2016       Rohit Sharma                
 * Dec 27, 2016       Rohit Sharma                 Updated DerivedEffort inner class: add variable for Of Level and To Level
 * Feb 1st, 2017      Rohit Sharma                 S-456643 :Condition added on page re-direct to add 
                                                   customerMode parameter in request.
*  =====================================================================*/
public with sharing class E2_AddEditDerivedEffortsController extends E2_Master {
  public CMC_Presales_LOE__c estimate {get;set;}
  public List<DerivedEffort> clonnedDerivedEffortList{get;set;}
  public String deffortTemplateIds{get;set;}
  public String deffortGroupName{get;set;}
  //constructor
  public E2_AddEditDerivedEffortsController(ApexPages.StandardController std) {
    this.estimate = (CMC_Presales_LOE__c)std.getRecord();
    this.clonnedDerivedEffortList = new List<DerivedEffort>();
  }
  //page action method on loading of page
  public PageReference pageAction(){
    PageReference page = super.validateForTimelineEstimate(this.estimate);
    if(page <> NULL) return page;
    super.validateAccess(this.estimate);
    //if estimate id is null then return, else display derived effort 
    if(this.estimate.id == NULL){
        return null;        
    }else{
        if(this.estimate.E2_Derived_Effort_Template__c != null) {
            getDerivedEffortTemplates(this.estimate.E2_Derived_Effort_Template__c);
        }
    }
    return null;    
  }
  //save method
  public PageReference save(){
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
    if(ApexPages.currentPage().getParameters().get(E2_Constants.PAGE_PARAMETER_CUSTOMERMODE) != null)  
        pg.getParameters().put(E2_Constants.PAGE_PARAMETER_CUSTOMERMODE,ApexPages.currentPage().getParameters().get(E2_Constants.PAGE_PARAMETER_CUSTOMERMODE));
    pg.setRedirect(true);
    return pg;      
  }
  //method to remove derived efforts
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
  //method to clone derived efforts
  public PageReference cloneDerivedEffort() {
    if(!String.isBlank(deffortTemplateIds)) {
        save();
        getDerivedEffortTemplates(deffortTemplateIds);
    }
    return null;
  }
  //call build capacity 
  public PageReference buildCapacity() {
    E2_CapacityController.reBuildCapacity(this.estimate);
    PageReference pg = Page.E2_Capacity;
    pg.getParameters().put('id', this.estimate.id);
    if(ApexPages.currentPage().getParameters().get(E2_Constants.PAGE_PARAMETER_CUSTOMERMODE) != null)  
        pg.getParameters().put(E2_Constants.PAGE_PARAMETER_CUSTOMERMODE,ApexPages.currentPage().getParameters().get(E2_Constants.PAGE_PARAMETER_CUSTOMERMODE));
    return pg; 
  }
  //utility method to get derived Efforts Template for a group Id
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
  //wrapper class for derived effort
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
    // 12/27 : Resource level
    public String ofLevel{get;set;}
    public String toLevel{get;set;}
    //constructor
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
        // 12/27 : Define resource level
        this.ofLevel = derivedEffort.Of_level__c;
        this.toLevel = derivedEffort.Level__c;
    }
    //method to add Phase
    public void addPhase(E2_Derived_Effort__c derivedEffort) {
        if(this.toPhase.indexOf(derivedEffort.To_Phase__c) == -1)
        this.toPhase += E2_Constants.COMMA + E2_Constants.SPACE + derivedEffort.To_Phase__c;
        if(!String.isBlank(derivedEffort.Of_Phase__c) && this.ofPhase.indexOf(derivedEffort.Of_Phase__c) == -1)
            this.ofPhase += E2_Constants.COMMA + E2_Constants.SPACE + derivedEffort.Of_Phase__c;
        this.derivedHrs += derivedEffort.Derived_Hrs__c;
    }
        
  }
}