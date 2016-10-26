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
    super.validateAccess(this.estimate);
    // Method to invoke on page load to get pre-calculated capacity
    this.storedCapacity = E2_DataUtil.getCapacityListByEstimateId(this.estimate.id);
    calculateHours();
    // RS: S-447214 : Method to generate epic level capacity
    generateScopeCapacity();
    return null;
  }
  
  // This method re-calculate Estimate capaicity from efforts and derived efforts
  public PageReference buildCapacity() {
    reBuildCapacity(this.estimate);
    PageReference pg = Page.E2_Capacity;
    pg.getParameters().put('id', this.estimate.id);
    pg.setRedirect(true);
    return pg; 
  }
  
  public static void reBuildCapacity(CMC_Presales_LOE__c estimate) {
    // Method invoke on Build Capacity command button
    List<E2_Capacity__c> oldCapacity = E2_DataUtil.getCapacityListByEstimateId(estimate.id);
    if(!oldCapacity.isEmpty()) {
        delete oldCapacity;
    }
    Map<String, E2_Capacity__c> rolePhaseCapacityMatrix = new Map<String, E2_Capacity__c>();
    calculateSpecifiedEfforts(estimate, rolePhaseCapacityMatrix);
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
  public static void calculateSpecifiedEfforts(CMC_Presales_LOE__c estimate,
                                        Map<String, E2_Capacity__c> rolePhaseCapacityMatrix){
    for(E2_Effort__c ef : E2_DataUtil.getEffortsListByEstimateId(estimate.id)){
        string phase = ef.Phase__c;
        string rolePhaseKey = phase + E2_Constants.SEPARATOR + ef.Resource_Role__c + 
                             (ef.Speciality__c != null ? E2_Constants.SEPARATOR + ef.Speciality__r.Name : E2_Constants.BLANK);
        if(!rolePhaseCapacityMatrix.containsKey(rolePhaseKey)){
           rolePhaseCapacityMatrix.put(rolePhaseKey, new E2_Capacity__c(Hours__c = 0, Estimator__c = estimate.id,
                                                                        Role__c = ef.Resource_Role__c, Phase__c = phase,
                                                                        Speciality__c = ef.Speciality__c));    
        }
        E2_Capacity__c capacity = rolePhaseCapacityMatrix.get(rolePhaseKey);
        decimal hrs = capacity.Hours__c;
        if(ef.Scope__r.Is_Active__c == true){
	        if(ef.Scope__r.Complexity__c == NULL || ef.Scope__r.Complexity__c.toLowerCase() == E2_Constants.MEDIUM){
	            hrs += ef.Effort_Hrs__c;
	        }else if(ef.Scope__r.Complexity__c.toLowerCase() == E2_Constants.HIGH){
	            hrs += ef.High_Effort_Hrs__c;
	        }else if(ef.Scope__r.Complexity__c.toLowerCase() == E2_Constants.LOW){
	            hrs += ef.Low_Effort_Hrs__c;
	        }
        }
        capacity.Hours__c = hrs;         
    }   
  }
  
  // Method summed up all derived efforts hours based on role, phase 
  // and store into Capacity record.
  public static void calculateDerivedEfforts(CMC_Presales_LOE__c estimate,
                                    Map<String, E2_Capacity__c> rolePhaseCapacityMatrix){
    if(estimate.E2_Derived_Effort_Template__c <> NULL) { 
    	Map<String, Decimal> roleToHrs = new Map<String, Decimal>();
        List<E2_Derived_Effort__c> derivedEffortsTemplate = 
                                    E2_DataUtil.getDerivedEffort(estimate.E2_Derived_Effort_Template__c);
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
                string rolePhaseKey = dE.To_Phase__c + E2_Constants.SEPARATOR + dE.Role__c;
                if(!rolePhaseCapacityMatrix.containsKey(rolePhaseKey)){
                   rolePhaseCapacityMatrix.put(rolePhaseKey, new E2_Capacity__c(Hours__c = 0, 
                                                                                Estimator__c = estimate.id,
                                                                                Role__c = dE.Role__c, 
                                                                                Phase__c = dE.To_Phase__c));    
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
  public void calculateHours(){
    for(E2_Capacity__c eC : this.storedCapacity) {
        string phase = eC.Phase__c;
        string role = eC.Role__c;
        If(eC.Hours__c <> NULL) {
            string rolePhaseKey = phase + E2_Constants.SEPARATOR + role;
            if(!rolesPhaseToHoursMap.containsKey(rolePhaseKey)){
               rolesPhaseToHoursMap.put(rolePhaseKey, 0);    
            }
            rolesPhaseToHoursMap.put(rolePhaseKey, (rolesPhaseToHoursMap.get(rolePhaseKey)+eC.Hours__c.round(System.RoundingMode.HALF_EVEN)));
            string phaseSumKey = phase + E2_Constants.SEPARATOR + TOTAL;
            if(!rolesPhaseToHoursMap.containsKey(phaseSumKey)){
               rolesPhaseToHoursMap.put(phaseSumKey, 0);    
            }
            rolesPhaseToHoursMap.put(phaseSumKey, (rolesPhaseToHoursMap.get(phaseSumKey)+eC.Hours__c.round(System.RoundingMode.HALF_EVEN)));
            if(!rolesToPhaseMap.containsKey(role)) rolesToPhaseMap.put(role, new Set<String>());
            
            if(eC.Speciality__c != null) {
                string roleskillPhaseKey = phase + E2_Constants.SEPARATOR + 
                                  role + E2_Constants.SPACE + E2_Constants.OPEN_BRACKET + 
                                  eC.Speciality__r.Name + E2_Constants.CLOSE_BRACKET;
                if(!rolesSkillPhaseToHoursMap.containsKey(roleskillPhaseKey)){
                    rolesSkillPhaseToHoursMap.put(roleskillPhaseKey, eC.Hours__c.round(System.RoundingMode.HALF_EVEN));    
                }
                if(!rolesSkillPhaseToHoursMap.containsKey(phaseSumKey)){
                   rolesSkillPhaseToHoursMap.put(phaseSumKey, 0);    
                }
                rolesSkillPhaseToHoursMap.put(phaseSumKey, (rolesSkillPhaseToHoursMap.get(phaseSumKey)+eC.Hours__c.round(System.RoundingMode.HALF_EVEN)));
                String roleSkillsKey = role + E2_Constants.SPACE + E2_Constants.OPEN_BRACKET + eC.Speciality__r.Name + E2_Constants.CLOSE_BRACKET;
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
               if(!scopeRolePhaseMap.containsKey(ultimateScopeId)) {
                scopeRolePhaseMap.put(ultimateScopeId, new map<string, set<string>>());
               }
               map<string, set<string>> rolePhaseMap = scopeRolePhaseMap.get(ultimateScopeId);
               if(!rolePhaseMap.containsKey(effort.Resource_Role__c)) rolePhaseMap.put(effort.Resource_Role__c, new set<string>());
               fillScopeRolePhaseHoursMap(ultimateScopeId, effort.Resource_Role__c, effort.Phase__c, loeHrs);
           }
      }
  }
  
  public void fillScopeRolePhaseHoursMap(id ultimateScopeId, string role, string phase, decimal loeHrs) {
      string scopeKey = ultimateScopeId + E2_Constants.SEPARATOR + role;
      loeHrs = loeHrs.round(System.RoundingMode.HALF_EVEN);
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
      List<E2_Derived_Effort__c> derivedEffortsTemplate = 
                                    E2_DataUtil.getDerivedEffort(estimate.E2_Derived_Effort_Template__c);
    for(string ultimateScopeId : scopeIdMap.keySet()) {
        for(E2_Derived_Effort__c derivedEffort : derivedEffortsTemplate) {
            String derivedKey = ultimateScopeId;
	        if(String.isBlank(derivedEffort.Of_Role__c) && !String.isBlank(derivedEffort.Of_Phase__c))
	            derivedKey += E2_Constants.SEPARATOR + derivedEffort.Of_Phase__c;
	        else if(!String.isBlank(derivedEffort.Of_Role__c) && String.isBlank(derivedEffort.Of_Phase__c))
	            derivedKey += E2_Constants.SEPARATOR + derivedEffort.Of_Role__c;
	        else if(String.isBlank(derivedEffort.Of_Role__c) && String.isBlank(derivedEffort.Of_Phase__c))
	            derivedKey += E2_Constants.SEPARATOR + TOTAL;
	        else 
    	        derivedKey += E2_Constants.SEPARATOR + derivedEffort.Of_Role__c + E2_Constants.SEPARATOR + derivedEffort.Of_Phase__c;
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
      map<string, decimal> scopeRolePhaseHourMaptemp = new map<string, decimal>();
      for(String uniqueKey : combinedderivedEfforts.KeySet()) {
        List<E2_Derived_Effort__c> derivedEfforts = combinedderivedEfforts.get(uniqueKey);
        decimal hrs = 0; 
        for(E2_Derived_Effort__c dE : derivedEfforts) {
            if(dE.Derived_Hrs__c <> NULL) hrs += dE.Derived_Hrs__c;
        }
        for(string ultimateScopeId : scopeIdMap.keySet()) {
            for(E2_Derived_Effort__c derivedEffort : derivedEfforts) {
                String derivedKey = ultimateScopeId;
            	if(String.isBlank(derivedEffort.Of_Role__c) && !String.isBlank(derivedEffort.Of_Phase__c))
            	    derivedKey += E2_Constants.SEPARATOR + derivedEffort.Of_Phase__c;
            	else if(!String.isBlank(derivedEffort.Of_Role__c) && String.isBlank(derivedEffort.Of_Phase__c))
    	            derivedKey += E2_Constants.SEPARATOR + derivedEffort.Of_Role__c;
    	        else if(String.isBlank(derivedEffort.Of_Role__c) && String.isBlank(derivedEffort.Of_Phase__c))
    	            derivedKey += E2_Constants.SEPARATOR + TOTAL;
    	        else 
        	       derivedKey += E2_Constants.SEPARATOR + derivedEffort.Of_Role__c + E2_Constants.SEPARATOR + derivedEffort.Of_Phase__c;
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
                        if(!rolePhaseMap.containsKey(derivedEffort.Role__c)) rolePhaseMap.put(derivedEffort.Role__c, new set<string>());
                        fillScopeRolePhaseHoursMapTemp(scopeRolePhaseHourMaptemp, ultimateScopeId, derivedEffort.Role__c, derivedEffort.To_Phase__c, dEhrs); 
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
            decimal loeHrs = scopeRolePhaseHourMaptemp.get(scopeKey);//.round(System.RoundingMode.HALF_EVEN);
            if(!scopeRolePhaseHourMap.containsKey(scopeKey)) scopeRolePhaseHourMap.put(scopeKey, loeHrs);
            else scopeRolePhaseHourMap.put(scopeKey, loeHrs + scopeRolePhaseHourMap.get(scopeKey));
        }
    }
  }
  
  public void fillScopeRolePhaseHoursMapTemp(map<string, decimal> scopeRolePhaseHourMaptemp,id ultimateScopeId, string role, string phase, decimal loeHrs) {
      string scopeKey = ultimateScopeId + E2_Constants.SEPARATOR + role;
      loeHrs = loeHrs;//.round(System.RoundingMode.HALF_DOWN);
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