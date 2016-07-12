/**=====================================================================
 * Appirio, Inc
 * Name: E2_CapacityController
 * Description: Controller class to build & display estimate capacity
 * Created Date: 
 * Created By: Rahul Jain (Appirio)
 * 
 * Date Modified      Modified By                  Description of the update
 * May 17, 2016       Rohit Sharma                 Code added to build capaicty from Efforts and derived efforts and 
 *                                                 save into E2_capicty.     
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
  private static string TOTAL = 'total';
    
  public E2_CapacityController(ApexPages.StandardController std) {
    this.estimate = (CMC_Presales_LOE__c)std.getRecord();
    phases = new Set<String>();
    skillsPhases = new Set<String>();
    rolesToPhaseMap = new Map<String, Set<String>>();
    rolesSkillToPhaseMap = new Map<String, Set<String>>();
    rolesPhaseToHoursMap = new Map<String, Decimal>();
    rolesSkillPhaseToHoursMap = new Map<String, Decimal>();   
  }
  
  
  
  public PageReference pageAction(){
    super.validateAccess(this.estimate);
    // Method to invoke on page load to get pre-calculated capacity
    this.storedCapacity = E2_DataUtil.getCapacityListByEstimateId(this.estimate.id);
    calculateHours();
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
        insert rolePhaseCapacityMatrix.values();
    }
    estimate.E2_Last_Build_Datetime__c = System.now();
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
                derivedEfforts.get(0).Include_When_Hours__c < hrs) || 
              (derivedEfforts.get(0).Include_When__c == E2_Constants.IF_HOURS_ARE_LESS_THAN && 
                derivedEfforts.get(0).Include_When_Hours__c > hrs)) {
              for(E2_Derived_Effort__c dE : derivedEfforts) {
                string rolePhaseKey = dE.To_Phase__c + E2_Constants.SEPARATOR + dE.Role__c;
                if(!rolePhaseCapacityMatrix.containsKey(rolePhaseKey)){
                   rolePhaseCapacityMatrix.put(rolePhaseKey, new E2_Capacity__c(Hours__c = 0, 
                                                                                Estimator__c = estimate.id,
                                                                                Role__c = dE.Role__c, 
                                                                                Phase__c = dE.To_Phase__c));    
                }
                E2_Capacity__c capacity = rolePhaseCapacityMatrix.get(rolePhaseKey);
                capacity.Hours__c +=  dE.Derived_Hrs__c;
              }
            }   
        }   
        }
    }
  
  // Method to create Capacity matrix from E2 Capacity record
  public void calculateHours(){
    for(E2_Capacity__c eC : this.storedCapacity) {
        string phase = eC.Phase__c;
        string role = eC.Role__c;
        string rolePhaseKey = phase + E2_Constants.SEPARATOR + role;
        if(!rolesPhaseToHoursMap.containsKey(rolePhaseKey)){
           rolesPhaseToHoursMap.put(rolePhaseKey, 0);    
        }
        rolesPhaseToHoursMap.put(rolePhaseKey, rolesPhaseToHoursMap.get(rolePhaseKey)+eC.Hours__c);
        string phaseSumKey = phase + E2_Constants.SEPARATOR + TOTAL;
        if(!rolesPhaseToHoursMap.containsKey(phaseSumKey)){
           rolesPhaseToHoursMap.put(phaseSumKey, 0);    
        }
        rolesPhaseToHoursMap.put(phaseSumKey, rolesPhaseToHoursMap.get(phaseSumKey)+eC.Hours__c);
        if(!rolesToPhaseMap.containsKey(role)) rolesToPhaseMap.put(role, new Set<String>());
        
        if(eC.Speciality__c != null) {
            string roleskillPhaseKey = phase + E2_Constants.SEPARATOR + 
                              role + E2_Constants.SPACE + E2_Constants.OPEN_BRACKET + 
                              eC.Speciality__r.Name + E2_Constants.CLOSE_BRACKET;
            if(!rolesSkillPhaseToHoursMap.containsKey(roleskillPhaseKey)){
                rolesSkillPhaseToHoursMap.put(roleskillPhaseKey, eC.Hours__c);    
            }
            if(!rolesSkillPhaseToHoursMap.containsKey(phaseSumKey)){
               rolesSkillPhaseToHoursMap.put(phaseSumKey, 0);    
            }
            rolesSkillPhaseToHoursMap.put(phaseSumKey, rolesSkillPhaseToHoursMap.get(phaseSumKey)+eC.Hours__c);
            String roleSkillsKey = role + E2_Constants.SPACE + E2_Constants.OPEN_BRACKET + eC.Speciality__r.Name + E2_Constants.CLOSE_BRACKET;
            if(!rolesSkillToPhaseMap.containsKey(roleSkillsKey)) rolesSkillToPhaseMap.put(roleSkillsKey, new Set<String>());
        }        
    }
    updateZeroHoursInMaps();
  }
  
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
  
}