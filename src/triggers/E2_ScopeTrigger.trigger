trigger E2_ScopeTrigger on E2_Scope__c (after insert, after update) {
  //methods to execute on after trigger
  if (trigger.isAfter) {
    if(Trigger.isInsert){
       E2_ScopeTriggerHandler.afterInsert (Trigger.new);     
    }else if(Trigger.isUpdate){
       E2_ScopeTriggerHandler.afterUpdate( Trigger.new, Trigger.oldMap); 
    }
  }

}