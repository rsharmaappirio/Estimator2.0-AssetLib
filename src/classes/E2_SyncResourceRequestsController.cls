// 
// (c) 2014 Appirio, Inc.
//
//  Sync Resource Requests allows the user to access resource data from the 
//  E2_EstimateResourceAPI to form Resource Requests from CMC Estimates.  This
//  tool "syncs" the resource request records to align with the data in the 
//  default estimated under the selected Presales Request.  The "sync" is limited
//  to "Create" and "Update" operations.
//
// 10/7/2014    Will Supinski 

public with sharing class E2_SyncResourceRequestsController {

	public Opportunity opp;
	public String selectedPSR {get;set;}
	public List<E2_EstimateResource> resources {get;set;}
	public List<pse__Resource_Request__c> resourceRequests {get;set;}
	public Map<Id, pse__Resource_Request__c> existingRRs {get;set;}
	public List<pse__Resource_Request__c> endResults {get;set;}
	public List<pse__Resource_Request__c> upsertList {get;set;}
	
	public Map<String, String> actions {get;set;} 
	public Map<String, pse__Resource_Request__c> rrAlreadyExistsMap;
	public boolean workDone {get;set;}
	
	public String dynamicButtonName {get;set;}
	private boolean isCreate;
	private boolean isUpdate;
	
	
	private String defaultSkill;
	private map<string,string> practiceSkillMap;
	private Set<String> roleValues = new Set<String>(); 
	
    public E2_SyncResourceRequestsController(ApexPages.StandardController stdController) {
        this.opp = (Opportunity)stdController.getRecord();
        setDefaults();
    }
    
    //setup some default values at page-load
    private void setDefaults(){
    	workDone = false;
    	actions = new Map<String, String>();  //key is the resourceId, value is the action operation ie 'Update' or 'Create'
    	practiceSkillMap = new map<String, String>();
    	if(E2_Practice_Skills_Mappings__c.getall() != NULL && !E2_Practice_Skills_Mappings__c.getall().isEmpty()) {
        	for(E2_Practice_Skills_Mappings__c psMap : E2_Practice_Skills_Mappings__c.getall().values()) {
        	    practiceSkillMap.put( psMap.Name, psMap.Skill_Id__c );
        	}
    	}
    	
    	//default skill
    	List<pse__Skill__c> dSkills = [SELECT Id FROM pse__Skill__c WHERE Name= 'Salesforce.com' AND pse__Type__c = 'Vendor Experience' ];
        if(dSkills.size() > 0){
         	defaultSkill = dSkills[0].Id;
        }
        
        //possible role values
		Schema.DescribeFieldResult fieldResult = pse__Resource_Request__c.pse__Resource_Role__c.getDescribe();
  		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
  		for(Schema.PicklistEntry pe: ple){
  			roleValues.add(pe.getValue());
  		}
    }
    
    //return picklist of PSRs
    public List<SelectOption> getPresalesRequests() {
      List<SelectOption> options = new List<SelectOption>();
      List<Presales_Request__c> psrs = [SELECT Id, Name FROM Presales_Request__c WHERE Opportunity__c = :opp.Id AND Id IN (SELECT Presales_Request__c FROM CMC_Presales_LOE__c WHERE Presales_Request__r.Opportunity__c=:opp.Id) ORDER BY LastModifiedDate DESC];
   	  for (Presales_Request__c psr : psrs) {
        options.add(new SelectOption(psr.Id, psr.Name));
      }
     
      return options;
	}
	
	//Upon selecting a PSR generate the Sync preview
	public PageReference selectPSR() {
		dynamicButtonName = '';
    	isCreate = false;
    	isUpdate = false;
    	
		if(selectedPSR != null){
			queryExistingRRs();
			
			//API call for resource data - pull data from "default" Presales Estimate under the PSR
			resources = E2_EstimateResourceAPI.getResources(selectedPSR);
			System.debug('<<< RESOURCES ' + resources);
			generateResourceRequestPreview();
		}
		
        return null;
    }
    
    //  Query the Opportunity for existing Resource Requests, map them by Estimate_Resource_Id__c for lookup
    private void queryExistingRRs(){
    	existingRRs =  new Map<ID, pse__Resource_Request__c>([SELECT Id, Name, pse__Requested_Bill_Rate__c, pse__SOW_Hours__c, Estimate_Resource_Id__c, pse__Resource_Role__c, CurrencyISOCode, pse__Primary_Skill_Certification__c, pse__Region__c, pse__Practice__c, pse__End_Date__c, pse__Start_Date__c, pse__Rate_Card__c, pse__Status__c, pse__Notes__c 
					   FROM pse__Resource_Request__c 
					   WHERE pse__Opportunity__c = :opp.Id ORDER BY pse__Status__c]);
        
        //populate map with records by Estimate_Resource_Id__c for lookup later to determine if an Update action 
        rrAlreadyExistsMap = new Map<String, pse__Resource_Request__c>();
        for(pse__Resource_Request__c err: existingRRs.values()){
        	if(err.Estimate_Resource_Id__c != null){
        		rrAlreadyExistsMap.put(err.Estimate_Resource_Id__c, err);
        	}
        }
    }
    
    //  Generate Preview by taking the resources returned by the E2_EstimateResourceAPI
    //  and converting them to Resource Requests.  Check each for validity and then identify
    //  if any of these records exist.  If they exist then mark for "Update" otherwise "Create"
    private void generateResourceRequestPreview(){
    	upsertList = new  List<pse__Resource_Request__c>();
    	resourceRequests = new List<pse__Resource_Request__c>();
    	for(E2_EstimateResource er: resources){
    		
    		pse__Resource_Request__c rr = mapEstimateResourceToRR(er);
    		
    		if(isValidResourceRequest(rr)){
    			
    			//check if the Resource Request exists and matches - Update
    			pse__Resource_Request__c existingRR = rrAlreadyExistsMap.get(er.resourceId);
    			
    			if(existingRR != null){
    				
    				if(existingRR.pse__Status__c == 'Planning'){
    					actions.put(existingRR.Estimate_Resource_Id__c, 'No Action - RR is Planned - Contact Consulting Ops');
    					rr.pse__Status__c = 'Planning';
    				}
    				else{
    					rr.Id = existingRR.Id;
	    				actions.put(er.resourceId, 'Update');
	    				isUpdate = true;
	    				upsertList.add(rr);
	    				existingRRs.remove(existingRR.Id);		//remove from existing list for later
    				}  				
	    		} else{
	    			actions.put(er.resourceId, 'Create');
	    			isCreate = true;
	    			upsertList.add(rr);
	    		}
    		}
    		
    		//list all records to show the Action to the user
    		resourceRequests.add(rr);
    	}
    	
    	//go through all that is left of the existingRRs and zero out their Hours since they didnt match any Estimate Resources
    	for(pse__Resource_Request__c err: existingRRs.values()){
    		//err.pse__SOW_Hours__c = 0;
    		
    		if(err.pse__Status__c == 'Planning'){
    					actions.put(err.Estimate_Resource_Id__c, 'No Action - RR is Planned - Contact Consulting Ops');
    					err.pse__Status__c = 'Planning';
    		}
    		else{
    			err.pse__Status__c = 'Cancelled';
				resourceRequests.add(err);
				upsertList.add(err);
				actions.put(err.Estimate_Resource_Id__c, 'Update - Cancelled');
				isUpdate = true;	
    		}
		}
    	
    	setDynamicButton();
    }
    
    //set the dynamic button text of the Action button to "Update" and/or "Create" Resource Requests
    private void setDynamicButton(){
    	if(isCreate){
    		dynamicButtonName = 'Create ';
    		if(isUpdate){
    			dynamicButtonName +=  'And ';
    		}
    	}
    	
    	if(isUpdate){
    		dynamicButtonName +=  'Update ';	
    	}
    	dynamicButtonName +=  'Resource Requests';
    	if(!isUpdate && !isCreate){
    		dynamicButtonName = 'No Action';
    	}
    }
    
    //  Convert an EstimateResource into a Resource Request
	//  @param er An EstimateResource object generated via E2_EstimateResourceAPI
	//  @return a new Resource Request SObject
    private pse__Resource_Request__c mapEstimateResourceToRR(E2_EstimateResource er){
    	pse__Resource_Request__c rr = new pse__Resource_Request__c();
    	
    	//map variables
    	rr.pse__Resource_Role__c = er.role;
		rr.pse__Requested_Bill_Rate__c = er.rate;
		rr.pse__SOW_Hours__c = er.hours;
		rr.pse__Region__c = er.regionId;
		rr.pse__Practice__c = er.practiceId;
		rr.pse__Start_Date__c = er.startDate;
		rr.pse__End_Date__c = er.endDate;
		
		rr.CurrencyISOCode = er.curCode;
		rr.Estimate_Resource_Id__c = er.resourceId;
		rr.pse__Opportunity__c = opp.Id;
		rr.pse__Status__c = 'Submitted';
		// RS : map skills from custom setting  
		if(practiceSkillMap.containsKey(er.practiceName)) {
		    rr.pse__Primary_Skill_Certification__c = practiceSkillMap.get(er.practiceName);
		} else {
		//set default skill
		    rr.pse__Primary_Skill_Certification__c = defaultSkill;
		}
		//put the skill text in the notes field.
		rr.pse__Notes__c = er.skill;
		
		return rr;
    }
    
    public boolean checkExistingRR(pse__Resource_Request__c rr){
    	
    	//no updates to RRs in Planning status
    	if(rr.pse__Status__c == 'Planning'){
    		actions.put(rr.Estimate_Resource_Id__c, 'No Action - RR is Planned - Contact Consulting Ops');
			return false;
    	}
    	return true;
    	
    }
    
    //  Check if a given Resource Request is valid by checking required fields.  
	//  @param rr a Resource Request
	//  @return true if valid, false if not.  If not valid, set action with reason not valid.
    public boolean isValidResourceRequest(pse__Resource_Request__c rr){
    	
    	
    	
    	//check role value to make sure it is an available picklist option
    	if(!roleValues.contains(rr.pse__Resource_Role__c)){
    		actions.put(rr.Estimate_Resource_Id__c, 'None - Invalid Role');
    		return false;
    	}
    	//check regionId
    	if(rr.pse__Region__c == null){
    		actions.put(rr.Estimate_Resource_Id__c, 'None - Invalid Region');
    		return false;
    	}
    	
    	//check practiceId
    	if(rr.pse__Practice__c == null){
    		actions.put(rr.Estimate_Resource_Id__c, 'None - Invalid Practice');
    		return false;
    	}
    	
    	//check start and end dates
    	if(rr.pse__Start_Date__c == null){
    		actions.put(rr.Estimate_Resource_Id__c, 'None - Invalid Start Date');
    		return false;
    	}
    	if(rr.pse__End_Date__c == null){
    		actions.put(rr.Estimate_Resource_Id__c, 'None - Invalid End Date');
    		return false;
    	}
    	
    	//check requested hours
    	if(rr.pse__SOW_Hours__c == null || rr.pse__SOW_Hours__c <= 0){
    		actions.put(rr.Estimate_Resource_Id__c, 'None - Invalid Hours');
    		return false;
    	}
    	
    	//check skill
    	if(rr.pse__Primary_Skill_Certification__c == null){
    		actions.put(rr.Estimate_Resource_Id__c, 'None - Invalid Skill');
    		return false;
    	}
    	
    	//check Rate
    	if(rr.pse__Requested_Bill_Rate__c == null){
    		actions.put(rr.Estimate_Resource_Id__c, 'None - Invalid Rate');
    		return false;
    	}
    	
    	return true;
    }
    
    //perform the sync
    public PageReference syncData(){
    	if(upsertList.size() ==  0){
    		return cancel();
    	}
    	
    	upsert upsertList;
    	workDone = true;
    	endResults =  [SELECT Id, Name, pse__Requested_Bill_Rate__c, pse__SOW_Hours__c, Estimate_Resource_Id__c, pse__Resource_Role__c, CurrencyISOCode, pse__Primary_Skill_Certification__c, pse__Region__c, pse__Practice__c, pse__End_Date__c, pse__Start_Date__c, pse__Rate_Card__c, pse__Status__c 
					   FROM pse__Resource_Request__c 
					   WHERE pse__Opportunity__c = :opp.Id ORDER BY pse__Status__c];
    
   
    	return null; // new PageReference('/' + opp.Id);
    }
    
    public PageReference cancel(){
    	return new PageReference('/' + opp.Id);
    }
    
}