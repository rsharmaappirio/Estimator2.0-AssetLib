/**=====================================================================
 * Appirio, Inc
 * Name: E2_AddEditScopeController
 * Description: Controller class for AddEditScope page
 * Created Date: Apr 8th, 2016
 * Created By: Arpita Bose (Appirio)
 * 
 * Date Modified      Modified By           Description of the update
   Dec 8th, 2016      Rohit Sharma          S-449145 :Ability to find the Scope by type, 
                                            Complexity ,Q&A and assets assigned.
   Feb 1st, 2017      Rohit Sharma          S-456643 :Condition added on page re-direct to add 
                                            customerMode parameter in request.
   Feb 08, 2017       Rohit Sharma          S-447325 : Add multiplier on Scope: Added new JSON string 
                                            to get effort multiplier picklist values.
*  =====================================================================*/
public with sharing class E2_AddEditScopeController extends E2_Master {
  public CMC_Presales_LOE__c estimate {get;set;}
  public list<string> scopeTypelist{get;set;}
  public list<string> complexitylist{get;set;}
  public static final string X = 'x';

  //constructor
  public E2_AddEditScopeController (ApexPages.StandardController std) {
    this.estimate = (CMC_Presales_LOE__c)std.getRecord();
    this.complexitylist = new list<string>();
    this.scopeTypelist = new list<string>();
  }
  //page action method on the page load
  public PageReference pageAction(){
    PageReference page = super.validateForTimelineEstimate(this.estimate);
    if(page <> NULL) return page;
    super.validateAccess(this.estimate);
    for(Schema.PicklistEntry ple : E2_Scope__c.Scope_Item_Type__c.getDescribe().getPicklistValues()) {
        this.scopeTypelist.add(ple.getValue());
    }
    for(Schema.PicklistEntry ple : E2_Scope__c.Complexity__c.getDescribe().getPicklistValues()) {
        this.complexitylist.add(ple.getValue());
    }
    return null;
  }
  //method to call build capacity
  public PageReference buildCapacity() {
  	E2_CapacityController.reBuildCapacity(this.estimate);
    PageReference pg = Page.E2_Capacity;
    pg.getParameters().put('id', this.estimate.id); 
    if(ApexPages.currentPage().getParameters().get(E2_Constants.PAGE_PARAMETER_CUSTOMERMODE) != null)  
        pg.getParameters().put(E2_Constants.PAGE_PARAMETER_CUSTOMERMODE,ApexPages.currentPage().getParameters().get(E2_Constants.PAGE_PARAMETER_CUSTOMERMODE));
    return pg; 
  }
}