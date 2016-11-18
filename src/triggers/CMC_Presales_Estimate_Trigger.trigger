// 
// (c) 2015 Appirio, Inc.
//
// This class serves as a handler for Presales Estimate Trigger
//
// 9/21/2015    Saurabh Gupta      Original
// 9/21/2015    Saurabh Gupta      For S-353499 : Add Product on creation of Presales Estimate record
// 10/27/2016   Vikash Goyal       For I-241434 : Added function to delete child scope records before deleting estimate record
// 11/11/2016   Rohit Sharma       For S-447474 : Fixed fee calculation support

trigger CMC_Presales_Estimate_Trigger on CMC_Presales_LOE__c (before insert, before delete, before update) {
    //CMC_Presales_Trigger_Handler presalesHandler = new CMC_Presales_Trigger_Handler();
    E2_CMC_Presales_Trigger_Handler presalesHandler = new E2_CMC_Presales_Trigger_Handler();
    
    if (Trigger.isBefore && Trigger.isInsert) {
        List <PermissionSetAssignment> permissionSetAssigneeList = [SELECT Id From PermissionSetAssignment Where PermissionSet.Name = 'CMC_Presales_Beta' AND AssigneeId =: UserInfo.getUserId() LIMIT 1];

        if (!permissionSetAssigneeList.isEmpty()) {
            presalesHandler.onBeforeInsert(Trigger.new);
        }
    }
    
    // RS (S-447474) : trigger before estimate update action 
    if (Trigger.isBefore && Trigger.isUpdate) {
        presalesHandler.onBeforeUpdate(Trigger.new);
    } 
    
    if (Trigger.isBefore && Trigger.isDelete) {
        presalesHandler.onBeforeDelete(Trigger.old);
    }
}