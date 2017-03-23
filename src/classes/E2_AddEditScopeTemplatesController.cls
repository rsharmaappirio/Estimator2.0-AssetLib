/**=====================================================================
 * Appirio, Inc
 * Name: E2_AddEditScopeTemplatesController 
 * Description: Controller class for E2_AddEditScopeTemplates page
 * Created Date: 
 * Created By: 
 * 
 * Date Modified      Modified By                  Description of the update
   Feb 08, 2017       Rohit Sharma          S-447325 : Add multiplier on Scope: Added new JSON string 
                                            to get effort multiplier picklist values.      
*  =====================================================================*/

public with sharing class E2_AddEditScopeTemplatesController {
  public E2_Scope_Group__c scopeGroup {get;set;}
  
  public E2_AddEditScopeTemplatesController (ApexPages.StandardController std) {
    this.scopeGroup = (E2_Scope_Group__c)std.getRecord();   
  }
}