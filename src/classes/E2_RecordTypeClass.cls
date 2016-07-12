/**=====================================================================
 * Appirio, Inc
 * Name: E2_RecordTypeClass
 * Description: Utility Class to get Record Types Id, Record types name
 * Created Date: Apr 15th, 2016
 * Created By: Arpita Bose
 * 
 * Date Modified      Modified By                  Description of the update
 * 
*  =====================================================================*/
public abstract class E2_RecordTypeClass {

    public static Map<String , Schema.SObjectType> globalDescription = Schema.getGlobalDescribe();
    public static sObject sObjectToBind;
    
    public static Id getId(String objectName, String recordTypeName) {     
            return globalDescription.get(objectName).getDescribe().getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        
    }

}