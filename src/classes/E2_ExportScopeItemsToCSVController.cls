public with sharing class E2_ExportScopeItemsToCSVController {
  public string header{get;set;}
  public string headerXLS{get;set;}
  public List<ScopeWrapper> lstScopeWrapper {get; set;}
  public CMC_Presales_LOE__c estimate {get;set;}
  
  public E2_ExportScopeItemsToCSVController(ApexPages.StandardController std){
  	this.estimate = (CMC_Presales_LOE__c)std.getRecord();
  	lstScopeWrapper = new List<ScopeWrapper>();
  	header = E2_Constants.SCOPE_CSV_HEADER;
  	headerXLS = E2_Constants.SCOPE_XLS_HEADER;
  }
  
  public void pageAction(){
  	List<E2_Scope__c> lstScopeItems = E2_DataUtil.getActiveChildScopesOfEstimate(String.valueOf(estimate.Id));
    for(E2_Scope__c scope : lstScopeItems){
    	ScopeWrapper wrapper = new ScopeWrapper();
    	wrapper.parentScope = scope.Parent_Scope__c == null ? '' : scope.Parent_Scope__r.name;
    	wrapper.scopeName = scope.Name;
    	wrapper.complexity = scope.Complexity__c;
    	wrapper.scopeItemtype = scope.Scope_Item_Type__c;    	
    	wrapper.description = scope.Description__c;
    	wrapper.assumption = scope.E2_Assumption__c;
    	wrapper.loeHrs = (scope.LOE_Hrs__c != null) ? String.valueOf(scope.LOE_Hrs__c) : '0';    	 	
    	lstScopeWrapper.add(wrapper);
    }
  }  
  
  public class ScopeWrapper{
  	public string parentScope {get; set;}
  	public string scopeName {get; set;}
    public string complexity{get; set;}
    public string scopeItemtype{get; set;}    
    public string description{get; set;}
    public string assumption{get; set;}
    public string loeHrs{get; set;}    
  }
}