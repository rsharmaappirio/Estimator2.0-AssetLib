/**=====================================================================
 * Appirio, Inc
 * Name: E2_CapacityController
 * Description: Controller class to build & display estimate capacity
 * Created Date: June 15, 2016
 * Created By: Rahul Jain (Appirio)
 * 
 * Date Modified      Modified By                  Description of the update
 * May 17, 2016       Rohit Sharma                 Code added to build capaicty from Efforts and derived efforts and 
 *                                                 save into E2_capicty.
 * Oct 14, 2016       Rohit Sharma                 S-447214 : Show capacity distribution by Epics.
 * Oct 18, 2016       Rohit Sharma                 I-240559 : Runtime error has appeared on clicking on Capacity tab
 * Oct 19, 2016       Rohit Sharma                 I-240619 : Total of Capacity needs by Phase/Role and by Epic 
 * Dec 19, 2016       Rohit Sharma                 S-449155 : Define risk factor on capacity
 * Dec 26, 2016       Rahul Jain                   S-459273 : Updated calculateSpecifiedEfforts for resource level consideration
 * Feb 1st, 2017      Rohit Sharma                 S-456643 :Condition added on page re-direct to add customerMode parameter in request.
 * Feb 08, 2017       Rohit Sharma                 S-447325 : Add multiplier on Scope : code updated to add Effort multiplier on effort
 *                                                 hours for epic level capacity calculation.
*  =====================================================================*/
public with sharing class E2_CapacityController extends E2_Master{
    
  public CMC_Presales_LOE__c estimate {get;set;}
  public Set<String> phases {get;set;}
  public Set<String> skillsPhases {get;set;}
  public List<E2_Capacity__c> storedCapacity {get;set;}
  public Map<String, Set<String>> rolesToPhaseMap {get;set;}
  public Map<String, Decimal> rolesPhaseToHoursMap {get;set;}
  public Map<String, Set<String>> rolesSkillToPhaseMap {get;set;}
  public Map<String, Decimal> rolesSkillPhaseToHoursMap {get;set;}
  // RS: S-447214 : map for Epic level capacity distribution
  public map<string, decimal> scopeRolePhaseHourMap {get;set;}
  public map<string, map<string, set<string>>> scopeRolePhaseMap {get;set;}
  public map<string, string> scopeIdMap {get;set;}
  public set<string> scopePhases {get;set;}
  private static string TOTAL = 'total';
  public List<string> riskList {get;set;}
  public string riskPrecent {get;set;}
  
  //constructor  
  public E2_CapacityController(ApexPages.StandardController std) {
    this.estimate = (CMC_Presales_LOE__c)std.getRecord();
    phases = new Set<String>();
    skillsPhases = new Set<String>();
    rolesToPhaseMap = new Map<String, Set<String>>();
    rolesSkillToPhaseMap = new Map<String, Set<String>>();
    rolesPhaseToHoursMap = new Map<String, Decimal>();
    rolesSkillPhaseToHoursMap = new Map<String, Decimal>();
    scopeRolePhaseHourMap = new map<string, decimal>();
    scopeRolePhaseMap = new map<string, map<string, set<string>>>();
    scopeIdMap = new map<string, string>();
    scopePhases = new set<string>();
  }
  
  
  //page action method on load of page
  public PageReference pageAction(){
    PageReference page = super.validateForTimelineEstimate(this.estimate);
    if(page <> NULL) return page;
    super.validateAccess(this.estimate);
    // Method to invoke on page load to get pre-calculated capacity
    this.storedCapacity = E2_DataUtil.getCapacityListByEstimateId(this.estimate.id);
    calculateHours();
    // RS: S-447214 : Method to generate epic level capacity
    generateScopeCapacity();
    riskList = populateRiskPicklistValues();
    return null;
  }
  
  // Method to display Risk % without 'None' option
  private List<string> populateRiskPicklistValues() {
      List<string> options = new List<string>();               
      for( Schema.PicklistEntry f : CMC_Presales_LOE__c.E2_Risk__c.getDescribe().getPicklistValues()){
        options.add(f.getValue());
      }      
      return options;  
    }
    
    // method to update risk % on estimate and re-build Capacity
    public PageReference updateRisk() {
        if(!string.isBlank(this.riskPrecent)) {
            this.estimate.E2_Risk__c = this.riskPrecent;
            return buildCapacity();
        }
        return null;
    }
    
  
  // This method re-calculate Estimate capaicity from efforts and derived efforts
  public PageReference buildCapacity() {
    reBuildCapacity(this.estimate);
    PageReference pg = Page.E2_Capacity;
    pg.getParameters().put('id', this.estimate.id);
    if(ApexPages.currentPage().getParameters().get(E2_Constants.PAGE_PARAMETER_CUSTOMERMODE) != null)  
        pg.getParameters().put(E2_Constants.PAGE_PARAMETER_CUSTOMERMODE,ApexPages.currentPage().getParameters().get(E2_Constants.PAGE_PARAMETER_CUSTOMERMODE));
    pg.setRedirect(true);
    return pg; 
  }
  
  public static void reBuildCapacity(CMC_Presales_LOE__c estimate) {
    for(CMC_Presales_LOE__c estimateTemp : E2_DataUtil.getEstimateDerivedEffortId( estimate.Id )) {
        estimate.E2_Derived_Effort_Template__c = estimateTemp.E2_Derived_Effort_Template__c;
    }
    // Method invoke on Build Capacity command button
    List<E2_Capacity__c> oldCapacity = E2_DataUtil.getCapacityListByEstimateId(estimate.id);
    if(!oldCapacity.isEmpty()) {
        delete oldCapacity;
    }
    Map<String, E2_Capacity__c> rolePhaseCapacityMatrix = new Map<String, E2_Capacity__c>();
    // pass by reference: rolePhaseCapacityMatrix and get the hours filled in for specified efforts.
    calculateSpecifiedEfforts(estimate, rolePhaseCapacityMatrix);
    // Now again pass by reference: rolePhaseCapacityMatrix and get the hours filled in for derived efforts.
    calculateDerivedEfforts(estimate, rolePhaseCapacityMatrix);
    
    if(!rolePhaseCapacityMatrix.isEmpty()) {
    	// T-522009 : Method to add Risk Factor in total capacity
    	addRiskFactor(estimate, rolePhaseCapacityMatrix);
    	// T-522009 : End
        insert rolePhaseCapacityMatrix.values();
    }
    estimate.E2_Last_Build_Datetime__c = System.now();
    estimate.E2_Risk_percentage__c = estimate.E2_Risk__c;
    update estimate;
  }
  
  // Method summed up all efforts hours based on role, phase and skills 
  // and store into Capacity record.
  // 12/26 : RJ : Method updated to include resource level in capacity needs calculation
  public static void calculateSpecifiedEfforts(CMC_Presales_LOE__c estimate,
                                        Map<String, E2_Capacity__c> rolePhaseCapacityMatrix){
    for(E2_Effort__c ef : E2_DataUtil.getEffortsListByEstimateId(estimate.id)){
        string phase = ef.Phase__c;
        //string rolePhaseKey = phase + E2_Constants.SEPARATOR + ef.Resource_Role__c + 
        //                     (ef.Speciality__c != null ? E2_Constants.SEPARATOR + ef.Speciality__r.Name : E2_Constants.BLANK);
        string rolePhaseKey = phase + E2_Constants.SEPARATOR + ef.Resource_Role__c 
                             + (ef.Resource_Level__c <> NULL ? E2_Constants.SEPARATOR + ef.Resource_Level__c : E2_Constants.BLANK) 
                             + (ef.Speciality__c != null ? E2_Constants.SEPARATOR + ef.Speciality__r.Name : E2_Constants.BLANK);
                             
        if(!rolePhaseCapacityMatrix.containsKey(rolePhaseKey)){
           //rolePhaseCapacityMatrix.put(rolePhaseKey, new E2_Capacity__c(Hours__c = 0, Estimator__c = estimate.id,
           //                                                                Role__c = ef.Resource_Role__c, Phase__c = phase,
           //                                                                Speciality__c = ef.Speciality__c));    
           rolePhaseCapacityMatrix.put(rolePhaseKey, new E2_Capacity__c(Hours__c = 0, Estimator__c = estimate.id,
                                                                           Role__c = ef.Resource_Role__c, Phase__c = phase,
                                                                           Level__c = ef.Resource_Level__c,
                                                                           Speciality__c = ef.Speciality__c));    
        }
        decimal effortHrs = 0;
        if(ef.Scope__r.Is_Active__c == true){
	        if(ef.Scope__r.Complexity__c == NULL || ef.Scope__r.Complexity__c.toLowerCase() == E2_Constants.MEDIUM){
	            effortHrs = ef.Effort_Hrs__c;
	        }else if(ef.Scope__r.Complexity__c.toLowerCase() == E2_Constants.HIGH){
	            effortHrs = ef.High_Effort_Hrs__c;
	        }else if(ef.Scope__r.Complexity__c.toLowerCase() == E2_Constants.LOW){
	            effortHrs = ef.Low_Effort_Hrs__c;
	        }
	        // RS : S-447325 : apply effort multiplier on effort hours.
	        if(ef.Scope__r.Effort_Quantity__c > 0) effortHrs = effortHrs * ef.Scope__r.Effort_Quantity__c;
        }
        E2_Capacity__c capacity = rolePhaseCapacityMatrix.get(rolePhaseKey);
        decimal hrs = capacity.Hours__c + effortHrs;
        capacity.Hours__c = hrs;         
    }   
  }
  
  // Method summed up all derived efforts hours based on role, phase 
  // and store into Capacity record.
  public static void calculateDerivedEfforts(CMC_Presales_LOE__c estimate,
                                    Map<String, E2_Capacity__c> rolePhaseCapacityMatrix){
    
    // we only have run through when estimate is associated with any derived effort template
    if(estimate.E2_Derived_Effort_Template__c <> NULL) { 
    	Map<String, Decimal> roleToHrs = new Map<String, Decimal>();
    	
    	// get the derived effort template linked to the current estimate.
        List<E2_Derived_Effort__c> derivedEffortsTemplate = 
                                    E2_DataUtil.getDerivedEffort(estimate.E2_Derived_Effort_Template__c);
        // pass by reference: derivedEffortsTemplate and load with the derived hours in.                            
        E2_Estimator_Manager.generateDerivedHours(estimate.Id, derivedEffortsTemplate);
        
        Map<String, List<E2_Derived_Effort__c>> combinedderivedEfforts = new Map<String, List<E2_Derived_Effort__c>>();
        
        for(E2_Derived_Effort__c ef : derivedEffortsTemplate){
            if(!combinedderivedEfforts.containsKey(ef.UniqueKey__c)) 
                combinedderivedEfforts.put(ef.UniqueKey__c, new List<E2_Derived_Effort__c>());
            combinedderivedEfforts.get(ef.UniqueKey__c).add(ef);    
        }
        for(String uniqueKey : combinedderivedEfforts.KeySet()) {
            List<E2_Derived_Effort__c> derivedEfforts = combinedderivedEfforts.get(uniqueKey);
            decimal hrs = 0; 
            for(E2_Derived_Effort__c dE : derivedEfforts) {
                hrs += dE.Derived_Hrs__c;
            }
            if(String.isBlank(derivedEfforts.get(0).Include_When__c) || 
               derivedEfforts.get(0).Include_When__c == E2_Constants.ALWAYS || 
              (derivedEfforts.get(0).Include_When__c == E2_Constants.WHEN_HOURS_EXCEED && 
                derivedEfforts.get(0).Include_When_Hours__c <= hrs) || 
              (derivedEfforts.get(0).Include_When__c == E2_Constants.IF_HOURS_ARE_LESS_THAN && 
                derivedEfforts.get(0).Include_When_Hours__c > hrs)) {
                    
              for(E2_Derived_Effort__c dE : derivedEfforts) {
                string rolePhaseKey = dE.To_Phase__c + E2_Constants.SEPARATOR + dE.Role__c 
                                + (dE.Level__c <> NULL ? E2_Constants.SEPARATOR + dE.Level__c : E2_Constants.BLANK);
                if(!rolePhaseCapacityMatrix.containsKey(rolePhaseKey)){
                   // 12/26 : RJ : added level in capacity needs instance
                   rolePhaseCapacityMatrix.put(rolePhaseKey, new E2_Capacity__c(Hours__c = 0, 
                                                                                Estimator__c = estimate.id,
                                                                                Role__c = dE.Role__c, 
                                                                                Phase__c = dE.To_Phase__c,
                                                                                Level__c = dE.Level__c)); 
                   system.debug('derivedEfforts.get(0).Include_When__c==' + derivedEfforts.get(0).Include_When__c);
                    system.debug('derivedEfforts.get(0).Include_When_Hours__c==' + derivedEfforts.get(0).Include_When_Hours__c + ' hrs '+hrs);
                   system.debug('==rolePhaseCapacityMatrix>>'+rolePhaseCapacityMatrix.values());                                                             
                }
                E2_Capacity__c capacity = rolePhaseCapacityMatrix.get(rolePhaseKey);
                capacity.Hours__c +=  dE.Derived_Hrs__c;  
              }
            }   
        }   
  	}
  }
    
  // T-522009 : Method to add Risk Factor in total capacity
  public static void addRiskFactor(CMC_Presales_LOE__c estimate,
                                    Map<String, E2_Capacity__c> rolePhaseCapacityMatrix) {
  	if(!String.isBlank(estimate.E2_Risk__c)) {
    	string estimaterisk = estimate.E2_Risk__c;
        estimaterisk = estimaterisk.replace(E2_Constants.PERCENTAGE, E2_Constants.BLANK);
        Decimal risk_percent = Decimal.valueOf(estimaterisk);
        for(E2_Capacity__c capacity : rolePhaseCapacityMatrix.values()) {
        	Decimal hours = capacity.Hours__c + (risk_percent/100 * capacity.Hours__c);
            capacity.Hours__c =  hours;	
       	}            
   	}
  }
  
  // Method to create Capacity matrix from E2 Capacity record
  // 12/26 : RJ : Method updated to include resource level in capacity needs calculation
  public void calculateHours(){
    for(E2_Capacity__c eC : this.storedCapacity) {
        string phase = eC.Phase__c;
        string role = eC.Role__c;
        If(eC.Hours__c <> NULL) {
            // 12/26 : RJ : added level in rolephaseKey if exists in capacity needs
            string rolePhaseKey = phase + E2_Constants.SEPARATOR + role
                                  + (eC.Level__c <> NULL ? ' - ' + eC.Level__c : E2_Constants.BLANK);
            if(!rolesPhaseToHoursMap.containsKey(rolePhaseKey)){
               rolesPhaseToHoursMap.put(rolePhaseKey, 0);    
            }
            rolesPhaseToHoursMap.put(rolePhaseKey, (rolesPhaseToHoursMap.get(rolePhaseKey)+eC.Hours__c));
            string phaseSumKey = phase + E2_Constants.SEPARATOR + TOTAL;
            if(!rolesPhaseToHoursMap.containsKey(phaseSumKey)){
               rolesPhaseToHoursMap.put(phaseSumKey, 0);    
            }
            rolesPhaseToHoursMap.put(phaseSumKey, (rolesPhaseToHoursMap.get(phaseSumKey)+eC.Hours__c));
            
            if(!rolesToPhaseMap.containsKey(role + (eC.Level__c <> NULL ? ' - ' + eC.Level__c : E2_Constants.BLANK))) rolesToPhaseMap.put(role + (eC.Level__c <> NULL ? ' - ' + eC.Level__c : E2_Constants.BLANK), new Set<String>());
            
            if(eC.Speciality__c != null) {
                // 12/26 : RJ : added level in roleskillPhaseKey if exists in capacity needs
                string roleskillPhaseKey = phase + E2_Constants.SEPARATOR + 
                                  role + (eC.Level__c <> NULL ? ' - ' + eC.Level__c : E2_Constants.BLANK) 
                                  + E2_Constants.SPACE + E2_Constants.OPEN_BRACKET + 
                                  eC.Speciality__r.Name + E2_Constants.CLOSE_BRACKET;
                if(!rolesSkillPhaseToHoursMap.containsKey(roleskillPhaseKey)){
                    rolesSkillPhaseToHoursMap.put(roleskillPhaseKey, eC.Hours__c);    
                }
                if(!rolesSkillPhaseToHoursMap.containsKey(phaseSumKey)){
                   rolesSkillPhaseToHoursMap.put(phaseSumKey, 0);    
                }
                rolesSkillPhaseToHoursMap.put(phaseSumKey, (rolesSkillPhaseToHoursMap.get(phaseSumKey)+eC.Hours__c));
                // 12/26 : RJ : added level in roleSkillsKey if exists in capacity needs
                String roleSkillsKey = role + (eC.Level__c <> NULL ? ' - ' + eC.Level__c : E2_Constants.BLANK)
                                        + E2_Constants.SPACE + E2_Constants.OPEN_BRACKET + eC.Speciality__r.Name + E2_Constants.CLOSE_BRACKET;
                if(!rolesSkillToPhaseMap.containsKey(roleSkillsKey)) rolesSkillToPhaseMap.put(roleSkillsKey, new Set<String>());
            }
        }
    }
    updateZeroHoursInMaps();
  }
  //utility method to update zero hours 
  private void updateZeroHoursInMaps() {
    Set<string> updatedPhases = new set<string>();
    Set<string> updatedskillPhases = new set<string>();
    for(string phase : E2_Estimator_Manager.getAppirioWayPhases()){
        string phaseSumKey = phase + E2_Constants.SEPARATOR + TOTAL;
        if(rolesPhaseToHoursMap.containsKey(phaseSumKey) && 
            rolesPhaseToHoursMap.get(phaseSumKey) <> 0){
          updatedPhases.add(phase);    
        }
        if(rolesSkillPhaseToHoursMap.containsKey(phaseSumKey) && 
            rolesSkillPhaseToHoursMap.get(phaseSumKey) <> 0){
          updatedskillPhases.add(phase);    
        }                     
    }  
    
    this.phases.clear();
    this.phases.addAll(updatedPhases);
    this.skillsPhases.clear();
    this.skillsPhases.addAll(updatedskillPhases);
    
    for(String role : rolesToPhaseMap.keyset()){
        rolesToPhaseMap.put(role, phases);
        for(string phase : phases){
            string rolePhaseKey = phase + E2_Constants.SEPARATOR + role;            
            if(!rolesPhaseToHoursMap.containsKey(rolePhaseKey)) rolesPhaseToHoursMap.put(rolePhaseKey, 0);            
        }
    }  
    
    for(String role : rolesSkillToPhaseMap.keyset()){
        rolesSkillToPhaseMap.put(role, skillsPhases);
        for(string phase : skillsPhases){
            string rolePhaseKey = phase + E2_Constants.SEPARATOR + role;            
            if(!rolesSkillPhaseToHoursMap.containsKey(rolePhaseKey)) rolesSkillPhaseToHoursMap.put(rolePhaseKey, 0);            
        }
    }
  }
  
  private map<id, id> getScopeEpicMapping() {
      // Method generate scope and epic mapping based on top most parent epic in hierarchy
      // and update scopeIdMap for epic Name
      map<id,set<id>> epicmap = new map<id,set<id>>();
      map<id,id> scopeEpicmap = new map<id,id>();
      for(E2_Scope__c scope : E2_DataUtil.getEstimateScopeParentMapping(estimate.Id)) {
          id parentEpic = NULL;
          if(epicmap.containsKey(scope.Parent_Scope__c)) {
              parentEpic = scope.Parent_Scope__c;
          } else {
              for(id epic : epicmap.keySet()) {
                  if(epicmap.get(epic).contains(scope.Parent_Scope__c)) {
                      parentEpic = epic;
                      break;
                  }
              }
          }
          if(scope.Scope_Item_Type__c == 'Epic' && parentEpic == NULL) {
              epicmap.put(scope.Id, new set<id>());
              scopeIdMap.put(scope.Id, scope.Name);
          }else if(parentEpic <> NULL) {
              epicmap.get(parentEpic).add(scope.Id);
          }
      }
      for(id epic : epicmap.keySet()) {
          for(id childScope : epicmap.get(epic)) {
              scopeEpicmap.put(childScope, epic);
          }
          scopeEpicmap.put(epic, epic);
     }
     return scopeEpicmap;
     
  }
  
  public void generateEpicSpecifiedCapacity() {
      // RS: S-447214 : Method to generate epic level specified capacity needs
      map<id,id> scopeEpicmap = getScopeEpicMapping();
      for(E2_Effort__c effort : E2_DataUtil.getAllActiveScopeEffortsByEstimateId(estimate.Id)) {
           if(scopeEpicmap.containsKey(effort.Scope__c)) {
               string ultimateScopeId = scopeEpicmap.get(effort.Scope__c);
               decimal loeHrs = effort.Effort_Hrs__c;
               if(effort.Scope__r.Complexity__c == E2_Constants.LOW) {
                   loeHrs = effort.Low_Effort_Hrs__c;
               }else if(effort.Scope__r.Complexity__c == E2_Constants.HIGH) {
                   loeHrs = effort.High_Effort_Hrs__c;
               }
               // RS : S-447325 : apply effort multiplier on effort hours.
               if(effort.Scope__r.Effort_Quantity__c > 0) loeHrs = loeHrs * effort.Scope__r.Effort_Quantity__c;
               if(!scopeRolePhaseMap.containsKey(ultimateScopeId)) {
                scopeRolePhaseMap.put(ultimateScopeId, new map<string, set<string>>());
               }
               map<string, set<string>> rolePhaseMap = scopeRolePhaseMap.get(ultimateScopeId);
               if(!rolePhaseMap.containsKey(effort.Resource_Role__c + (effort.Resource_Level__c <> NULL ? ' - ' + effort.Resource_Level__c : E2_Constants.BLANK))) rolePhaseMap.put(effort.Resource_Role__c  + (effort.Resource_Level__c <> NULL ? ' - ' + effort.Resource_Level__c : E2_Constants.BLANK), new set<string>());
               fillScopeRolePhaseHoursMap(ultimateScopeId, effort.Resource_Role__c, effort.Phase__c, effort.Resource_Level__c, loeHrs);
           }
      }
  }
  
  // Method used to fill scopeRolePhaseHourMap based on role, phase defined in specified/derived efforts
  // 12/26 : RJ : Method updated to include resource level defined in specified/derived efforts
  public void fillScopeRolePhaseHoursMap(id ultimateScopeId, string role, string phase, string level, decimal loeHrs) {
      string scopeKey = ultimateScopeId + E2_Constants.SEPARATOR + role + 
                        (level <> NULL ? ' - ' + level : E2_Constants.BLANK);
      loeHrs = loeHrs;
      if(!scopeRolePhaseHourMap.containsKey(scopeKey)) scopeRolePhaseHourMap.put(scopeKey, loeHrs);
      else scopeRolePhaseHourMap.put(scopeKey, loeHrs + scopeRolePhaseHourMap.get(scopeKey));
               
      string scopePhaseKey = scopeKey + E2_Constants.SEPARATOR + phase;
      if(!scopeRolePhaseHourMap.containsKey(scopePhaseKey)) scopeRolePhaseHourMap.put(scopePhaseKey, loeHrs);
      else scopeRolePhaseHourMap.put(scopePhaseKey, loeHrs + scopeRolePhaseHourMap.get(scopePhaseKey));
               
      string scopeRoleKey = scopeKey + E2_Constants.SEPARATOR + TOTAL;
      if(!scopeRolePhaseHourMap.containsKey(scopeRoleKey)) scopeRolePhaseHourMap.put(scopeRoleKey, loeHrs);
      else scopeRolePhaseHourMap.put(scopeRoleKey, loeHrs + scopeRolePhaseHourMap.get(scopeRoleKey));
               
      string phaseScopeTotal = ultimateScopeId + E2_Constants.SEPARATOR + phase;
      if(!scopeRolePhaseHourMap.containsKey(phaseScopeTotal)) scopeRolePhaseHourMap.put(phaseScopeTotal, loeHrs);
      else scopeRolePhaseHourMap.put(phaseScopeTotal, loeHrs + scopeRolePhaseHourMap.get(phaseScopeTotal));
               
      string scopeTotal = ultimateScopeId + E2_Constants.SEPARATOR + TOTAL;
      if(!scopeRolePhaseHourMap.containsKey(scopeTotal)) scopeRolePhaseHourMap.put(scopeTotal, loeHrs);
      else scopeRolePhaseHourMap.put(scopeTotal, loeHrs + scopeRolePhaseHourMap.get(scopeTotal));
               
      string phaseTotal = phase + E2_Constants.SEPARATOR + TOTAL;
      if(!scopeRolePhaseHourMap.containsKey(phaseTotal)) scopeRolePhaseHourMap.put(phaseTotal, loeHrs);
      else scopeRolePhaseHourMap.put(phaseTotal, loeHrs + scopeRolePhaseHourMap.get(phaseTotal));
  }
  
  public Map<String, List<E2_Derived_Effort__c>> calculateDerivedhours() {
      // RS: S-447214 : Method calculate scope wise derived efforts and generate derivedefforts map by 
      // efforts uniqueKey
      // 12/26 : RS : Method re-evaluated and updated to remove unnecessary if-else logic 
      List<E2_Derived_Effort__c> derivedEffortsTemplate = 
                                    E2_DataUtil.getDerivedEffort(estimate.E2_Derived_Effort_Template__c);
    for(string ultimateScopeId : scopeIdMap.keySet()) {
        for(E2_Derived_Effort__c derivedEffort : derivedEffortsTemplate) {
            String derivedKey = ultimateScopeId;
            
            string keys = (String.isBlank(derivedEffort.Of_Role__c) ? E2_Constants.BLANK : 
	                (derivedEffort.Of_Role__c + (String.isBlank(derivedEffort.Of_level__c) ? 
	                    E2_Constants.BLANK : ' - ' + derivedEffort.Of_level__c)));
	                
	          keys += (String.isBlank(derivedEffort.Of_Phase__c) ? E2_Constants.BLANK : 
	                 (!string.isBlank(keys) ? E2_Constants.SEPARATOR : E2_Constants.BLANK) + derivedEffort.Of_Phase__c);
	         
	         if(String.isBlank( keys )) {
	             derivedKey += E2_Constants.SEPARATOR + TOTAL;
	         } else {
	             derivedKey += E2_Constants.SEPARATOR + keys;
	         }
    	    if(scopeRolePhaseHourMap.containsKey(derivedKey)) {
    	        decimal hrs = scopeRolePhaseHourMap.get(derivedKey);
    	        hrs = hrs * (derivedEffort.Allocation__c/100);
    	        if(derivedEffort.Derived_Hrs__c <> NULL) derivedEffort.Derived_Hrs__c += hrs;
    	        else derivedEffort.Derived_Hrs__c = hrs;
            }
        }
    }
        
    Map<String, List<E2_Derived_Effort__c>> combinedderivedEfforts = new Map<String, List<E2_Derived_Effort__c>>();
    for(E2_Derived_Effort__c ef : derivedEffortsTemplate){
        if(!combinedderivedEfforts.containsKey(ef.UniqueKey__c)) 
            combinedderivedEfforts.put(ef.UniqueKey__c, new List<E2_Derived_Effort__c>());
        combinedderivedEfforts.get(ef.UniqueKey__c).add(ef);    
    }
    return combinedderivedEfforts;
  }
  
  public map<string, decimal> generateDerivedHoursMap(Map<String, List<E2_Derived_Effort__c>> combinedderivedEfforts) {
      // RS: S-447214 : Method generate scopeRolePhaseHourMaptemp for derived hours.
      // 12/26 : RS : Method re-evaluated and updated to remove unnecessary if-else logic
      map<string, decimal> scopeRolePhaseHourMaptemp = new map<string, decimal>();
      for(String uniqueKey : combinedderivedEfforts.KeySet()) {
        List<E2_Derived_Effort__c> derivedEfforts = combinedderivedEfforts.get(uniqueKey);
        decimal hrs = 0; 
        for(E2_Derived_Effort__c dE : derivedEfforts) {
            if(dE.Derived_Hrs__c <> NULL) hrs += dE.Derived_Hrs__c;
        }
        for(string ultimateScopeId : scopeIdMap.keySet()) {
            for(E2_Derived_Effort__c derivedEffort : derivedEfforts) {
                // 12/27 : get unique key for epic based hours for derived efforts
                String derivedKey = ultimateScopeId;
                string keys = (String.isBlank(derivedEffort.Of_Role__c) ? E2_Constants.BLANK : 
	                (derivedEffort.Of_Role__c + (String.isBlank(derivedEffort.Of_level__c) ? 
	                    E2_Constants.BLANK : ' - ' + derivedEffort.Of_level__c)));
	                
	            keys += (String.isBlank(derivedEffort.Of_Phase__c) ? E2_Constants.BLANK : 
	                 (!string.isBlank(keys) ? E2_Constants.SEPARATOR : E2_Constants.BLANK) + derivedEffort.Of_Phase__c);
	         
	            if(String.isBlank( keys )) {
	                derivedKey += E2_Constants.SEPARATOR + TOTAL;
	            } else {
	                derivedKey += E2_Constants.SEPARATOR + keys;
	            }
        	    if(scopeRolePhaseHourMap.containsKey(derivedKey)) {
        	        decimal dEhrs = scopeRolePhaseHourMap.get(derivedKey);
        	        dEhrs = dEhrs * (derivedEffort.Allocation__c/100);
        	        if(String.isBlank(derivedEffort.Include_When__c) || 
                       derivedEffort.Include_When__c == E2_Constants.ALWAYS || 
                       (derivedEffort.Include_When__c == E2_Constants.WHEN_HOURS_EXCEED && 
                       derivedEffort.Include_When_Hours__c <= hrs) || 
                       (derivedEffort.Include_When__c == E2_Constants.IF_HOURS_ARE_LESS_THAN && 
                       derivedEffort.Include_When_Hours__c > hrs)) {
                        map<string, set<string>> rolePhaseMap = scopeRolePhaseMap.get(ultimateScopeId);
                        if(!rolePhaseMap.containsKey(derivedEffort.Role__c + (String.isBlank(derivedEffort.Level__c) ? E2_Constants.BLANK : ' - ' + derivedEffort.Level__c))) rolePhaseMap.put(derivedEffort.Role__c + (String.isBlank(derivedEffort.Level__c) ? E2_Constants.BLANK : ' - ' + derivedEffort.Level__c), new set<string>());
                        fillScopeRolePhaseHoursMapTemp(scopeRolePhaseHourMaptemp, ultimateScopeId, derivedEffort.Role__c, derivedEffort.To_Phase__c, derivedEffort.Level__c, dEhrs); 
                     }
        	    }
            }
        }
    }
    return scopeRolePhaseHourMaptemp;
  }
  
  public void generateEpicDerivedCapacity() {
    // RS: S-447214 : Method to generate epic level detived capacity needs
    Map<String, List<E2_Derived_Effort__c>> combinedderivedEfforts = calculateDerivedhours();
    map<string, decimal> scopeRolePhaseHourMaptemp = generateDerivedHoursMap(combinedderivedEfforts);
    if(!scopeRolePhaseHourMaptemp.isEmpty()) {
        for(string scopeKey : scopeRolePhaseHourMaptemp.keySet()) {
            decimal loeHrs = scopeRolePhaseHourMaptemp.get(scopeKey);
            if(!scopeRolePhaseHourMap.containsKey(scopeKey)) scopeRolePhaseHourMap.put(scopeKey, loeHrs);
            else scopeRolePhaseHourMap.put(scopeKey, loeHrs + scopeRolePhaseHourMap.get(scopeKey));
        }
    }
  }
  
  // Method used to fill scopeRolePhaseHourMap based on role, phase defined in specified/derived efforts
  // 12/26 : RJ : Method updated to include resource level defined in specified/derived efforts
  public void fillScopeRolePhaseHoursMapTemp(map<string, decimal> scopeRolePhaseHourMaptemp,id ultimateScopeId, string role, string phase, string level, decimal loeHrs) {
      string scopeKey = ultimateScopeId + E2_Constants.SEPARATOR + role +
                        (level <> NULL ? ' - ' + level : E2_Constants.BLANK);
      loeHrs = loeHrs;
      if(!scopeRolePhaseHourMaptemp.containsKey(scopeKey)) scopeRolePhaseHourMaptemp.put(scopeKey, loeHrs);
      else scopeRolePhaseHourMaptemp.put(scopeKey, loeHrs + scopeRolePhaseHourMaptemp.get(scopeKey));
               
      string scopePhaseKey = scopeKey + E2_Constants.SEPARATOR + phase;
      if(!scopeRolePhaseHourMaptemp.containsKey(scopePhaseKey)) scopeRolePhaseHourMaptemp.put(scopePhaseKey, loeHrs);
      else scopeRolePhaseHourMaptemp.put(scopePhaseKey, loeHrs + scopeRolePhaseHourMaptemp.get(scopePhaseKey));
               
      string scopeRoleKey = scopeKey + E2_Constants.SEPARATOR + TOTAL;
      if(!scopeRolePhaseHourMaptemp.containsKey(scopeRoleKey)) scopeRolePhaseHourMaptemp.put(scopeRoleKey, loeHrs);
      else scopeRolePhaseHourMaptemp.put(scopeRoleKey, loeHrs + scopeRolePhaseHourMaptemp.get(scopeRoleKey));
               
      string phaseScopeTotal = ultimateScopeId + E2_Constants.SEPARATOR + phase;
      if(!scopeRolePhaseHourMaptemp.containsKey(phaseScopeTotal)) scopeRolePhaseHourMaptemp.put(phaseScopeTotal, loeHrs);
      else scopeRolePhaseHourMaptemp.put(phaseScopeTotal, loeHrs + scopeRolePhaseHourMaptemp.get(phaseScopeTotal));
               
      string scopeTotal = ultimateScopeId + E2_Constants.SEPARATOR + TOTAL;
      if(!scopeRolePhaseHourMaptemp.containsKey(scopeTotal)) scopeRolePhaseHourMaptemp.put(scopeTotal, loeHrs);
      else scopeRolePhaseHourMaptemp.put(scopeTotal, loeHrs + scopeRolePhaseHourMaptemp.get(scopeTotal));
               
      string phaseTotal = phase + E2_Constants.SEPARATOR + TOTAL;
      if(!scopeRolePhaseHourMaptemp.containsKey(phaseTotal)) scopeRolePhaseHourMaptemp.put(phaseTotal, loeHrs);
      else scopeRolePhaseHourMaptemp.put(phaseTotal, loeHrs + scopeRolePhaseHourMaptemp.get(phaseTotal));
  }
  
   public void generateScopeCapacity() {
    // RS: S-447214 : Method to generate epic level capacity with detived effort and % risk factor
    generateEpicSpecifiedCapacity();
    if(estimate.E2_Derived_Effort_Template__c <> NULL) generateEpicDerivedCapacity();
      
    if(!String.isBlank(estimate.E2_Risk__c)) {
        string estimaterisk = estimate.E2_Risk__c;
        estimaterisk = estimaterisk.replace(E2_Constants.PERCENTAGE, E2_Constants.BLANK);
        Decimal risk_percent = Decimal.valueOf(estimaterisk);
        for(string mapkey : scopeRolePhaseHourMap.keySet()) {
        	Decimal hours = scopeRolePhaseHourMap.get(mapkey) + (risk_percent/100 * scopeRolePhaseHourMap.get(mapkey));
            scopeRolePhaseHourMap.put(mapkey, hours);
       	}            
   	 }
   	
     Set<string> updatedPhases = new set<string>();
     for(string phase : E2_Estimator_Manager.getAppirioWayPhases()){
        string phaseSumKey = phase + E2_Constants.SEPARATOR + TOTAL;
        if(scopeRolePhaseHourMap.containsKey(phaseSumKey) && 
            scopeRolePhaseHourMap.get(phaseSumKey) <> 0){
            updatedPhases.add(phase);    
        }                   
    }  
    
    scopePhases.clear();
    scopePhases.addAll(updatedPhases);
    
    for(String ultimateScopeId : scopeRolePhaseMap.keyset()){
        map<string, set<string>> rolePhaseMap = scopeRolePhaseMap.get(ultimateScopeId);
        for(string role : rolePhaseMap.keyset()) {
            rolePhaseMap.put(role, scopePhases);
            for(string phase : scopePhases){
                string scopeKey = ultimateScopeId + E2_Constants.SEPARATOR + role + E2_Constants.SEPARATOR + phase;
                if(!scopeRolePhaseHourMap.containsKey(scopeKey)) scopeRolePhaseHourMap.put(scopeKey, 0);
                string scopePhaseKey = ultimateScopeId + E2_Constants.SEPARATOR + phase;
                if(!scopeRolePhaseHourMap.containsKey(scopePhaseKey)) scopeRolePhaseHourMap.put(scopePhaseKey, 0);
            }
        }
    }
  }
  
}