/**=====================================================================
 * Appirio, Inc
 * Name: E2_AddEditScopeController
 * Description: Controller class for AddEditScope page
 * Created Date: Apr 8th, 2016
 * Created By: Arpita Bose (Appirio)
 * 
 * Date Modified      Modified By                  Description of the update
      
*  =====================================================================*/
public with sharing class E2_AddEditScopeController extends E2_Master {
  public CMC_Presales_LOE__c estimate {get;set;}

  
  public E2_AddEditScopeController (ApexPages.StandardController std) {
    this.estimate = (CMC_Presales_LOE__c)std.getRecord();
    
  }
  
  public PageReference pageAction(){
    super.validateAccess(this.estimate);
    return null;
  }
  
  public PageReference buildCapacity() {
  	E2_CapacityController.reBuildCapacity(this.estimate);
    PageReference pg = Page.E2_Capacity;
    pg.getParameters().put('id', this.estimate.id);    
    return pg; 
  }
}