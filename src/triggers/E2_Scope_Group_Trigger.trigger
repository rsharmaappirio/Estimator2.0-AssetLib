/**=====================================================================
 * Appirio, Inc
 * Name: E2_Scope_Group_Trigger
 * Description: Trigger on Scoope library object
 * Created Date: Oct 27, 2016
 * Created By:  Vikash Goyal
 * 
 * Date Modified      Modified By                  Description of the update
   
*  =====================================================================*/
trigger E2_Scope_Group_Trigger on E2_Scope_Group__c (before delete) {
    
    if (Trigger.isBefore && Trigger.isDelete) {
        E2_Scope_Group_Trigger_Handler.onBeforeDelete(Trigger.old);
    }
}