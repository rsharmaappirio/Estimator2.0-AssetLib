/**=====================================================================
 * Appirio, Inc
 * Name			: E2_AddBulkEffortsController
 * Description	: Controller class for E2_AddBulkEfforts Page
 * Created Date	: Aug 8th, 2016
 * Created By	: Vikash Goyal (Appirio)
 * 
 * Date Modified      Modified By                  Description of the update

*  =====================================================================*/
public class E2_AddBulkEffortsController {

    public List<E2_EffortsWrapper> lstEfforts {get;set;}
    public List<SelectOption> roles {get;set;}
    public List<SelectOption> phases {get;set;}
    
    public String effortsJson {get;set;}
    
    // constructor 
    public E2_AddBulkEffortsController(){
        lstEfforts = new List<E2_EffortsWrapper>();
        roles = getPicklistValues(new E2_Effort__c(), E2_Constants.EFFORT_ROLE_FIELD_API_NAME);
        phases = getPicklistValues(new E2_Effort__c(), E2_Constants.EFFORT_PHASE_FIELD_API_NAME);
        effortsJson = '';
        addEfforts();
    }
    
    // method to add efforts 
    public PageReference addEfforts(){
        for(Integer index = 0; index < E2_Constants.DEFAULT_BULK_EFFORTS_TO_ADD; index++){
            lstEfforts.add(new E2_EffortsWrapper());
        }
        return null;
    }
    
    // utility method to display field values as picklist 
    private static List<SelectOption> getPicklistValues(SObject obj, String fld){
        List<SelectOption> options = new List<SelectOption>();
        Schema.sObjectType objType = obj.getSObjectType(); 
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();       
        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap(); 
        list<Schema.PicklistEntry> values = fieldMap.get(fld).getDescribe().getPickListValues();
        
        for (Schema.PicklistEntry entry : values){ 
            options.add(new SelectOption(entry.getLabel(), entry.getValue())); 
        }
        
        return options;
    }
    
    // method to create JSON for list of efforts 
    public PageReference prepareEffortsJson(){
        effortsJson = JSON.serialize(lstEfforts, true);
        return null;   
    }
}