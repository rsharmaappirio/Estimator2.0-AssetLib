public with sharing class E2_ManageTemplateDerivedEffortController {
	
	public E2_Derived_Effort_Group__c selectedGroup{get;set;}
	public List<DerivedEffortTemplate> derivedEffortTemplates{get;set;}
	public boolean hasNewEffort{get;set;}
	public boolean hasErrorEffort{get;set;}
	public List<SelectOption> phasePicklist{get;set;}
	public List<SelectOption> rolePicklist{get;set;}
	public List<SelectOption> includeWhenPicklist{get;set;}
	public string errorString{get;set;}
		
	public E2_ManageTemplateDerivedEffortController(ApexPages.StandardController std) {
    	this.selectedGroup = (E2_Derived_Effort_Group__c)std.getRecord();
		hasNewEffort = false;
		hasErrorEffort = false;
		this.derivedEffortTemplates = new List<DerivedEffortTemplate>();
	}

	public PageReference pageAction() {
		loadTemplates();
		this.phasePicklist = populatePhasePicklistValues();
		this.rolePicklist = populateRolePicklistValues();
		this.includeWhenPicklist = populateIncludePicklistValues();
		return null;
	}
	
	public void loadTemplates() {
		this.derivedEffortTemplates.clear();
		map<string,DerivedEffortTemplate> uniqueKeyDerivedEfforts = new map<string,DerivedEffortTemplate>();
		for(E2_Derived_Effort__c derivedEffort : E2_DataUtil.getAllDerivedEffort(this.selectedGroup.Id)) {
			if(uniqueKeyDerivedEfforts.containsKey(derivedEffort.UniqueKey__c)) 
				uniqueKeyDerivedEfforts.get(derivedEffort.UniqueKey__c).addDerivedEffort(derivedEffort);
			else {
				DerivedEffortTemplate dE = new DerivedEffortTemplate(derivedEffort);
				uniqueKeyDerivedEfforts.put(dE.uniqueKey, dE);
				this.derivedEffortTemplates.add(dE);
			}	
		}
	}
	
	private List<SelectOption> populatePhasePicklistValues() {
	    List<SelectOption> options = new List<SelectOption>();               
	    for( Schema.PicklistEntry f : E2_Derived_Effort__c.Of_Phase__c.getDescribe().getPicklistValues()){
	    	options.add(new SelectOption(f.getLabel(), f.getValue()));
	    }      
	    return options;  
  	}
  	
  	private List<SelectOption> populateRolePicklistValues(){
	    List<SelectOption> options = new List<SelectOption>();
	    for( Schema.PicklistEntry f : E2_Derived_Effort__c.Role__c.getDescribe().getPicklistValues()){
	    	options.add(new SelectOption(f.getLabel(), f.getValue()));
	    }       
	    return options;  
  	}
  	
  	private List<SelectOption> populateIncludePicklistValues(){
	    List<SelectOption> options = new List<SelectOption>();
	    for( Schema.PicklistEntry f : E2_Derived_Effort__c.Include_When__c.getDescribe().getPicklistValues()){
	    	options.add(new SelectOption(f.getLabel(), f.getValue()));
	    }       
	    return options;  
  	}
	
	
	public PageReference addNewEffort() {
		E2_Derived_Effort__c derivedEffort = new E2_Derived_Effort__c(Is_Active__c = true,Derived_Effort_Group__c = this.selectedGroup.Id);
		if(!this.derivedEffortTemplates.isEmpty())
			this.derivedEffortTemplates.add(0,new DerivedEffortTemplate(derivedEffort));
		else
			this.derivedEffortTemplates.add(new DerivedEffortTemplate(derivedEffort));
		hasNewEffort = true;
		return null;
	}
	
	public PageReference updateEfforts() {
		hasErrorEffort = false;
		hasNewEffort = false;
		errorString = 'Required values are missing.';
		Id devRecordTypeId = Schema.getGlobalDescribe().get('E2_Derived_Effort__c').getDescribe()
							.getRecordTypeInfosByName().get('Template').getRecordTypeId();
		List<E2_Derived_Effort__c> templatetoDelete = new List<E2_Derived_Effort__c>();
		List<E2_Derived_Effort__c> templatetoUpsert = new List<E2_Derived_Effort__c>();
		for(DerivedEffortTemplate template : this.derivedEffortTemplates) {
			if(template.isDelete) {
				for(E2_Derived_Effort__c dE : template.derivedEfforts) {
					if(dE.Id <> NULL) 
						templatetoDelete.add(dE);
				}				
			} else {
				if(template.name == NULL || template.name == '' || template.allocation == null || 
				   template.allocation <= 0 || template.toRole == NULL || template.toRole == '' || 
				   template.toPhase.isEmpty() || template.includeWhen == NULL || template.includeWhen == '' || 
					(template.includeWhen != 'always' && template.includeWhenHrs <= 0)) {
					template.hasError = true;
					hasErrorEffort = true;
				} else if(template.uniqueKey != template.generateUniqueKey()) {
					if(template.isNew) {
						createDerivedEffort( template, templatetoUpsert, devRecordTypeId);
					} else {
						for(E2_Derived_Effort__c dE : template.derivedEfforts) {
							if(dE.Id <> NULL) 
								templatetoDelete.add(dE);
						}
						createDerivedEffort( template, templatetoUpsert, devRecordTypeId);
					}
				}
			}
		}
		try{
			if(!this.hasErrorEffort) {				
				if(!templatetoDelete.isEmpty())
					delete templatetoDelete;
				if(!templatetoUpsert.isEmpty())
					insert templatetoUpsert;
				this.loadTemplates();
			}
		}catch(DMLException ex){
		   hasErrorEffort = true;
		   errorString = ex.getMessage().contains(E2_constants.INSUFFICIENT_ACCESS_OR_READONLY) ? 
                                    E2_constants.INSUFFICIENT_ERROR_MSSG: 
                                    ex.getMessage();  
		}
		return null;
	}
	
	private void createDerivedEffort(DerivedEffortTemplate template, List<E2_Derived_Effort__c> templatetoUpsert, Id devRecordTypeId) {
		String generatedUniqueKey = template.generateUniqueKey();
		decimal allocation = template.allocation/template.toPhase.size();
		for(String toPhase : template.toPhase) {
			if(template.ofPhase.isEmpty()) {
				E2_Derived_Effort__c newDE = new E2_Derived_Effort__c(Name = template.Name, Of_Role__c = template.ofRole,
											 Role__c = template.toRole, Original_Allocation_Hours__c = template.allocation,
											 Allocation__c = allocation, 
											 Include_When__c = template.includeWhen, 
											 Include_When_Hours__c = (template.includeWhen != 'always' ? template.includeWhenHrs : 0),
											 Is_Active__c = template.isActive, UniqueKey__c = generatedUniqueKey,
											 To_Phase__c = toPhase, RecordTypeId = devRecordTypeId,
											 Derived_Effort_Group__c = this.selectedGroup.Id,
											 Allocation_Min__c = template.allocationMin);
				templatetoUpsert.add(newDE);
			} else {
				for(String ofPhase : template.ofPhase) {
					E2_Derived_Effort__c newDE = new E2_Derived_Effort__c(Name = template.Name, Of_Role__c = template.ofRole,
												 Role__c = template.toRole,Original_Allocation_Hours__c = template.allocation,
												 Allocation__c = allocation, 
												 Include_When__c = template.includeWhen, 
												 Include_When_Hours__c = (template.includeWhen != 'always' ? template.includeWhenHrs : 0),
												 Is_Active__c = template.isActive, UniqueKey__c = generatedUniqueKey,
												 Of_Phase__c = ofPhase, To_Phase__c = toPhase, RecordTypeId = devRecordTypeId,
												 Derived_Effort_Group__c = this.selectedGroup.Id,
											 	 Allocation_Min__c = template.allocationMin);
					templatetoUpsert.add(newDE);
				}
			}	
		}
	}
    
    public class DerivedEffortTemplate {
    	public List<E2_Derived_Effort__c> derivedEfforts{get;set;}
    	public String name{get;set;}
    	public String ofRole{get;set;}
    	public String toRole{get;set;}
    	public list<string> ofPhase{get;set;}
    	public list<string> toPhase{get;set;}
    	public Decimal allocation{get;set;}
    	public String includeWhen{get;set;}
    	public Decimal includeWhenHrs{get;set;}
    	public Decimal allocationMin{get;set;}
    	public String uniqueKey{get;set;}
    	public boolean isNew{get;set;}
    	public boolean isDelete{get;set;}
    	public boolean hasError{get;set;}
    	public boolean isActive{get;set;}    	
    	
    	public DerivedEffortTemplate(E2_Derived_Effort__c derivedEffort) {
    		derivedEfforts = new List<E2_Derived_Effort__c>();
    		ofPhase = new list<String>();
    		toPhase = new list<String>();
    		isNew = false;
    		if(derivedEffort.Id == NULL) {
    			isNew = true;
    			this.isActive = derivedEffort.Is_Active__c;
    		} else {
    			this.name = derivedEffort.Name;
    			this.ofRole = derivedEffort.Of_Role__c;
    			this.toRole = derivedEffort.Role__c;
    			this.allocation = derivedEffort.Original_Allocation_Hours__c != NULL && derivedEffort.Original_Allocation_Hours__c > 0 ?
    							  derivedEffort.Original_Allocation_Hours__c : derivedEffort.Allocation__c;
    			this.includeWhen = derivedEffort.Include_When__c;
    			this.includeWhenHrs = derivedEffort.Include_When_Hours__c;  
    			this.isActive = derivedEffort.Is_Active__c;
    			this.allocationMin = derivedEffort.Allocation_Min__c;	
    			this.uniqueKey = !String.isBlank(derivedEffort.UniqueKey__c) ? derivedEffort.UniqueKey__c :
    						derivedEffort.Name + E2_Constants.SEPARATOR + (!String.isBlank(this.ofRole) ? this.ofRole : '') +
    						E2_Constants.SEPARATOR + (!String.isBlank(derivedEffort.Of_Phase__c) ? derivedEffort.Of_Phase__c : '') +
    						E2_Constants.SEPARATOR + this.toRole + E2_Constants.SEPARATOR + this.allocation + E2_Constants.SEPARATOR + 
    						derivedEffort.To_Phase__c + E2_Constants.SEPARATOR + (!String.isBlank(this.includeWhen) ? this.includeWhen : '') +
    						E2_Constants.SEPARATOR + this.includeWhenHrs + E2_Constants.SEPARATOR + derivedEffort.Is_Active__c
    						+ E2_Constants.SEPARATOR + this.allocationMin;
    		}
    		isDelete = false;
    		addDerivedEffort(derivedEffort);
    	}
    	
    	public void addDerivedEffort(E2_Derived_Effort__c derivedEffort) {
    		this.derivedEfforts.add(derivedEffort);
    		this.ofPhase.add(derivedEffort.Of_Phase__c);
    		this.toPhase.add(derivedEffort.To_Phase__c);
    	}
    	
    	public string generateUniqueKey() {
    		return this.name + E2_Constants.SEPARATOR + (!String.isBlank(this.ofRole) ? this.ofRole : '') +
    			   E2_Constants.SEPARATOR + this.ofPhase + E2_Constants.SEPARATOR + 
    			   this.toRole + E2_Constants.SEPARATOR + this.allocation + E2_Constants.SEPARATOR + 
    			   this.toPhase + E2_Constants.SEPARATOR + (!String.isBlank(this.includeWhen) ? this.includeWhen : '') +
    			   E2_Constants.SEPARATOR + this.includeWhenHrs + E2_Constants.SEPARATOR + this.isActive
    			   + E2_Constants.SEPARATOR + this.allocationMin;
    	}
    	
    	public PageReference remove() {
    		this.isDelete = true;
    		//system.assert(false,this.isDelete);
    		return null;
    	}
    }
}