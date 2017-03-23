/**=====================================================================
 * Appirio, Inc
 * Name: E2_AddNewScopeTemplateController
 * Description: Controller class for E2_AddNewScopeTemplate page
 * Created Date: 
 * Created By: Vikash Goyal (Appirio)
 * 
 * Date Modified      Modified By                  Description of the update
 * Dec, 12th, 2016    Rohit Sharma                 Modified the lines below in the processClipboardData method to suffice the feature for copy and paste - type/complexity/effort hrs
                                                   added a supporting overload method getEffortsInstanceList with effortsStr as argument string.
                                                   S-437670: Copy paste the Type and complexity field along with the Scope name ,description 
                                                   and assumptions while creating the scopes.
*  =====================================================================*/

public with sharing class E2_AddNewScopeTemplateController {
    public E2_Scope__c scope{get;set;}
    public List<Scope> childScopes{get;set;} 
    public boolean is_New{get;set;}
    public boolean is_View{get;set;}
    public boolean is_Edit{get;set;}
    public string scopeGrpId{get;set;}
    public string dmlOperationMessage{get;set;}
    public static boolean showNameError{get;set;}
    private static final string URL_VALUE_TRUE = 'true';
    private static final integer MAX_LENGTH_SCOPENAME = 80;
    private static final string DEFAULT_PHASE = 'Build';
    private static final string DEFAULT_ROLE = 'Developer';
    private static final integer DEFAULT_COMPLEXITY_ADDER = 0;
    private static final integer DEFAULT_COMPLEXITY_SUBTRACTOR = 0;
    private static final string SEPARATOR = ' - ';
    

    public transient string clipboardData{get;set;}
    
    // constructor 
    public E2_AddNewScopeTemplateController(ApexPages.StandardController std) {
       this.scope = (E2_Scope__c)std.getRecord();
       this.childScopes = new List<Scope>();
       this.is_New = false;
       this.is_View = false;
       this.is_Edit = false;
       this.dmlOperationMessage = E2_Constants.DML_OPERATION_MESSAGE_FAIL;
       this.clipboardData = E2_Constants.BLANK;
    }
    //wrapper class to define clipboard info
    public class ClipboardInfo{
        public string property1{get;set;} // scope name  
        public string property2{get;set;} // scope description  
        public string property3{get;set;} // scope assumption 
        
        public string property4{get;set;} // scope type
        public string property5{get;set;} // scope complexity
        public string property6{get;set;} // effort hours for default role and phase
    }
    
    public class ClipboardInfoList{
        public List<ClipboardInfo> list1{get;set;}      
    }
    
    //method to process clipboard data
    public pagereference processClipboardData(){
        try{
             showNameError = false;
             String StringIn = this.clipboardData;
             
             if(this.childScopes.size() > 0 && this.childScopes[this.childScopes.size() - 1].scope.name == null && this.childScopes[this.childScopes.size() - 1].scope.id == null){
                this.childScopes.remove(this.childScopes.size() - 1);
             }
             
             if(StringIn <> NULL && StringIn <> ''){
                 StringIn = '{"list1":' + StringIn + '}';
                 ClipboardInfoList infoList = (ClipboardInfoList)JSON.deserialize(StringIn, ClipboardInfoList.class);
                 integer scopeIndex = 0;
                 for(ClipboardInfo info : infoList.list1){
                    if(info.property1 <> NULL && string.isNotEmpty(info.property1) && string.isNotBlank(info.property1)) {
                        // RS: 12/12/2016: Modified below lines to support property4,5,6 inclusion in the save operation.
                        //                 Saving the life of users to a ton by allowing them to also copy and paste the type, complexity and default - developer hours.
                        Scope scopeInstance = new Scope(new E2_Scope__c(Description__c = info.property2, 
                                                                       E2_Assumption__c = info.property3 , 
                                                                       Is_Active__c = true, Name = info.property1, 
                                                                       Scope_Item_Type__c = ((info.property4 <> NULL && string.isNotEmpty(info.property4) 
                                                                                             && string.isNotBlank(info.property4)) && E2_Constants.SCOPE_TYPES.contains(info.property4.toLowerCase()) ? 
                                                                                                               info.property4 : 
                                                                                                               ''), // default empty
                                                                       Complexity__c = ((info.property5 <> NULL && string.isNotEmpty(info.property5) 
                                                                                        && string.isNotBlank(info.property5)) && E2_Constants.SCOPE_COMPLEXITIES.contains(info.property5.toLowerCase()) ? 
                                                                                                               info.property5 : 
                                                                                                               E2_Constants.MEDIUM) //default medium
                                                                       ),
                                                       getEffortsInstanceList(info.property6));
                        if(this.childScopes.size() > scopeIndex){
                            this.childScopes.add(scopeIndex, scopeInstance);
                        } else {
                            this.childScopes.add(scopeInstance);
                        }
                        if(info.property1.length() > MAX_LENGTH_SCOPENAME)  showNameError = true;
                        scopeIndex++;
                    }
                    
                 }      
             }
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
         
        this.clipboardData = E2_Constants.BLANK;
        return null;
    }
    
    // method for page action 
    public PageReference pageAction(){
        showNameError = false;
        this.scopeGrpId = ApexPages.CurrentPage().getParameters().get(E2_Constants.URL_KEY_SCOPEGROUP_ID);
        // New
        if(this.scope.id == null){
            this.is_New = true;                     
            this.childScopes.add(new Scope(new E2_Scope__c( Complexity__c = E2_Constants.MEDIUM), getEffortsInstanceList()));
            
        }else{
            if(ApexPages.CurrentPage().getParameters().get(E2_Constants.URL_KEY_IS_VIEW) == URL_VALUE_TRUE){
                this.is_View = true;                
            }else if(ApexPages.CurrentPage().getParameters().get(E2_Constants.URL_KEY_IS_EDIT) == URL_VALUE_TRUE){
                this.is_Edit = true;
            }   
            populateViewRecords();
        }
        return null;
    }
    
    // method to add new scope 
    public pagereference addNewScope(){
        showNameError = false;
        if(this.childScopes.size() > 0){
          this.childScopes.add(0, new Scope(new E2_Scope__c(Is_Active__c = true, Complexity__c = E2_Constants.MEDIUM), getEffortsInstanceList()));
        }else{
          this.childScopes.add(new Scope(new E2_Scope__c(Is_Active__c = true, Complexity__c = E2_Constants.MEDIUM), getEffortsInstanceList())); 
        }        
        return null;                
    }
    
    // method to save scope records 
    public pagereference saveScope(){
        showNameError = false;
        List<E2_Scope__c> scopeListToUpsert = new List<E2_Scope__c>();        
        List<E2_Effort__c> masterScope_Efforts = new List<E2_Effort__c>();        
        List<E2_Scope__c> scopeListToDelete = new List<E2_Scope__c>();
        List<E2_Effort__c> effortsToDelete = new List<E2_Effort__c>();
        
        Scope masterScope;
        ApexPages.Message msg;
        
        Id recTypeId = E2_RecordTypeClass.getId(E2_Constants.E2_SCOPE_API_NAME, E2_Constants.SCOPE_RT_TEMPLATE);
        
        // Create a savepoint 
        Savepoint sp = Database.setSavepoint();
        
        for(Scope sc : childScopes){
           if(sc.isDeleted == true){
             if(sc.scope.id <> NULL) scopeListToDelete.add(sc.scope); 
             continue;
           }
           
           if(sc.isDeleted == false){                
                sc.scope.recordTypeId = recTypeId;
                sc.scope.Scope_Group__c = scopeGrpId;
                if(this.scope.id <> NULL){
                    sc.scope.parent_scope__c = this.scope.id; 
                    this.is_Edit = true;                 
                }
                if(sc.scope.Id == null ){
                    sc.scope.Is_Active__c = true;
                    sc.scope.Effort_Quantity__c = this.scope.Effort_Quantity__c;
                }
                if(sc.scope.Name == null ){
                  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.E2_Scope_is_Required ));
                  return null;
                }
                
                System.debug('>>>>>>>>>>>1Id:' + sc.scope.id);  
                System.debug('>>>>>>>>>>>1Key:' + sc.key);                                                                                                             

                scopeListToUpsert.add(sc.scope);        
           }     
        }
        
        try{       
           system.debug('>>>>>SIZE>>>>' + scopeListToUpsert.size()); 
             
           if(!scopeListToUpsert.isEmpty()) upsert scopeListToUpsert;
        }catch(Exception ex){
            Database.rollback(sp);
            resetChildScopesOnException();            
            msg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
            ApexPages.addMessage(msg);            
            return null;
        }
        
        for(Scope sc : childScopes){        
            if(sc.isDeleted == false){
                    for(Effort ef : sc.efforts){
                        if(ef.isDeleted == true){
                           if(ef.effort.id <> NULL) effortsToDelete.add(ef.effort); 
                           continue;
                        }
                        system.debug('>>ef.effort.scope__c = sc.scope.id>>' + ef.effort.scope__c + '=' +  sc.scope.id);
                        if(ef.effort.scope__c == null) ef.effort.scope__c = sc.scope.id;
                        masterScope_Efforts.add(ef.effort);
                    }
               
            }           
        }
        
        try{
            if(!effortsToDelete.isEmpty()){
              delete effortsToDelete;            
            }         
                   
            if(!scopeListToDelete.isEmpty()){
              delete scopeListToDelete;
            }
 
            if(!masterScope_Efforts.isEmpty()){
                upsert masterScope_Efforts;
            }
            
        }catch(Exception ex){
            Database.rollback(sp);
            resetChildScopesOnException();
            msg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
            ApexPages.addMessage(msg);
            return null;            
        }
        this.dmlOperationMessage = E2_Constants.DML_OPERATION_MESSAGE_SUCCESS;   
        return null;                
    }
    
    // method to reset child scopes 
    public void resetChildScopesOnException(){
        for(Scope sc : childScopes){ 
               string scope_id = sc.scope.id;
               if(sc.key <> scope_id){
                  sc.scope.id = null;
               }
                for(Effort ef : sc.efforts){
                    string ef_id = ef.effort.id;
                    if(ef.key <> ef_id){
                      ef.effort.id = null;
                      ef.effort.scope__c = null;
                    }
                }
            }
    }
    
    // method to populate records 
    public void populateViewRecords(){
        Id scopeId = this.scope.id;
        Set<Id>  childScopeIds = new Set<Id>();                
        for(E2_Scope__c scope : E2_DataUtil.getScopeRecordsWithChildRecords(scopeId)){
                for(E2_Scope__c childScope : scope.Child_Scopes__r){
                     childScopeIds.add(childScope.id);
                }
        }
        // TBD: Might have to do this recursively when n child have to be retrieved.
        if(!childScopeIds.isEmpty()){
            for(E2_Scope__c scope : E2_DataUtil.getScopeRecordsWithChildForChildScopeIds(childScopeIds)){                
                
                    this.childScopes.add(new Scope(scope, scope.Efforts__r));
                    this.is_Edit = true;
            }
        }
    }
    //utility method to get efforts
    public List<E2_Effort__c> getEffortsInstanceList(){
        List<E2_Effort__c> efforts = new List<E2_Effort__c>();
        //efforts.add(new E2_Effort__c(Complexity_Factor_High__c = 0, Complexity_Factor_Low__c = 0, Effort_Hrs__c = 0));        
        return efforts;
    }
    
    public List<E2_Effort__c> getEffortsInstanceList(string effortsStr){
        // RS: 12/12/2016: Added this method; This is an overload of the default method
        //                 Allowing the users to add effort records too; if they have defined hours in the copy/paste in sheet.
        List<E2_Effort__c> efforts = getEffortsInstanceList();
        
        try{
            integer effortHours = integer.valueof(decimal.valueof(effortsStr));
            if(effortHours > 0) {
            efforts.add(new E2_Effort__c(Name = DEFAULT_ROLE + SEPARATOR + DEFAULT_PHASE,
                                     Is_Active__c = true, 
                                     Complexity_Factor_High__c = DEFAULT_COMPLEXITY_ADDER, 
                                     Complexity_Factor_Low__c = DEFAULT_COMPLEXITY_SUBTRACTOR, 
                                     Effort_Hrs__c = effortHours,
                                     Phase__c = DEFAULT_PHASE,
                                     Resource_Role__c = DEFAULT_ROLE));
            }
        }catch(Exception ex){
            system.debug('Error at the time of converting the string to integer - may be a null or a blank or non integral provided');
        }
        
                
        return efforts;
    }
    
    //wrapper class for Scope
    public class Scope{
        public string key{get;set;}
        public E2_Scope__c scope{get;set;}
        public boolean isCloned{get;set;}
        public List<Effort> efforts{get;set;}
        //public string deletekey_effort{get;set;}

        public boolean isDeleted{get;set;}
        public string slider_state{get;set;}
        public boolean hasNameError{get;set;}
        
        public decimal getEffortsSize(){
            decimal hrs = 0;
            string complexity = '';
            if(scope.Complexity__c <> NULL){
                complexity = scope.Complexity__c;
            }
            for(Effort effort : this.efforts){
                if(effort.isDeleted == false){ 
                     if(complexity.toLowerCase() == E2_Constants.MEDIUM && effort.effort.Effort_Hrs__c != null) hrs = hrs + effort.effort.Effort_Hrs__c;
                     if(complexity.toLowerCase() == E2_Constants.HIGH && effort.effort.Complexity_Factor_High__c != null && effort.effort.Effort_Hrs__c != null) hrs = hrs + (effort.effort.Effort_Hrs__c + (effort.effort.Effort_Hrs__c * (effort.effort.Complexity_Factor_High__c/100)));
                     if(complexity.toLowerCase() == E2_Constants.LOW && effort.effort.Complexity_Factor_Low__c != null && effort.effort.Effort_Hrs__c != null) hrs = hrs + (effort.effort.Effort_Hrs__c - (effort.effort.Effort_Hrs__c * (effort.effort.Complexity_Factor_Low__c/100)));
                }
            }
            return hrs;
        }
        
        
        public Scope(E2_Scope__c scope, List<E2_Effort__c> efforts){            
            this.efforts = new List<Effort>();
            this.isDeleted = false;
            this.slider_state = '';
            this.isCloned = false;
            this.hasNameError = false;
            if(scope.Name != NULL && scope.Name.length() > 80) {
                this.hasNameError = true;
            }
            if(scope.Source_Scope__c != NULL){
                this.isCloned = true;               
            }
            if(scope.id == null){   
               Blob hash2 = Crypto.generateDigest(E2_Constants.MD5, Blob.valueOf(E2_Constants.STRING_1000 + String.valueOf(Datetime.now().formatGMT(E2_Constants.DATETIME_FORMAT_YYYYMMDD))));
               this.key = EncodingUtil.convertToHex(hash2);
            }else{
              this.key = scope.id;
            }
            this.scope = scope;
            for(E2_Effort__c effort : efforts){
                this.efforts.add(new Effort(effort));
            }           
        }
        // method to reload
        public pagereference reload(){
            return null;            
        }
        // method to change complexity
        public pagereference changeComplexity(){
            return null;
        }
        // method to remove scope 
        public pagereference remove(){
            this.isDeleted = true;
            E2_AddNewScopeTemplateController.showNameError = false;
            return null;            
        }
        // method to add new effort 
        public pagereference addNewEffort(){
            this.efforts.add(new Effort(new E2_Effort__c(Complexity_Factor_High__c = 0, Complexity_Factor_Low__c = 0, Effort_Hrs__c = 0)));
            return null;
        }
    }
    
    //wrapper class for effort 
    public class Effort{
        public boolean isDeleted{get;set;}
        public string key{get;set;}
        public boolean isCloned{get;set;}
        public decimal oldHrs{get;set;}
        public E2_Effort__c effort{get;set;}
        public Effort(E2_Effort__c effort){
          this.isDeleted = false;   
          this.isCloned = false;
          this.oldHrs = 0;
          if(effort.Source_Effort__c <> NULL){
            this.isCloned = true;           
          }
          this.oldHrs = effort.Effort_Hrs__c;
          if(effort.id == null){    
            Blob hash2 = Crypto.generateDigest(E2_Constants.MD5, Blob.valueOf(E2_Constants.STRING_1000 + String.valueOf(Datetime.now().formatGMT(E2_Constants.DATETIME_FORMAT_YYYYMMDD))));            
            this.key = EncodingUtil.convertToHex(hash2);
          }else{
            this.key = effort.id;
          } 
          this.effort = effort;                     
        }
        // method to remove effort 
        public pagereference remove(){
            this.isDeleted = true;
            return null;            
        }
    }
    
}