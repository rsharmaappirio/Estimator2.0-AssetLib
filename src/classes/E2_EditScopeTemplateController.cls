/**=====================================================================
 * Appirio, Inc
 * Name: E2_EditScopeTemplateController
 * Description: Controller class for E2_EditScopeTemplate page
 * Created Date: June 21, 2016
 * Created By:  Rohit Sharma
 * 
 * Date Modified      Modified By                  Description of the update
   October 19th,2016  Rohit Sharma                 I-241595 : Enhance the E2 code where algo has developed 
                                                    around "Scope Template manager" permission set
 * Jan 11, 2017       Vikash Goyal                 I-252391 : Delete exception on deleting efforts
*  =====================================================================*/

public with sharing class E2_EditScopeTemplateController {
    public E2_Scope__c scope{get;set;}
    public List<Scope> childScopes{get;set;}
    public Scope childScope{get;set;}
    public boolean is_View{get;set;}
    public string scopeGrpId{get;set;}
    public string dmlOperationMessage{get;set;}
    public Datetime lastModifiedDate{get;set;}
    public string assetsRecsJson {get;set;}
    public boolean showFavForSTMPermissionSet {get;set;}
    
    public E2_ScopeQuestionAnswerManager scopeQuestionManager{get;set;}
    
    public string effortsJson {get;set;}
    
    public E2_EditScopeTemplateController(ApexPages.StandardController std) {
       // constructor for the page tied to standard controller  
       this.scope = (E2_Scope__c)std.getRecord();
       this.childScopes = new List<Scope>();       
       this.is_View = false;       
       this.dmlOperationMessage = E2_Constants.DML_OPERATION_MESSAGE_FAIL;
       
       assetsRecsJson = '';
       showFavForSTMPermissionSet = true;
       scopeQuestionManager = new E2_ScopeQuestionAnswerManager();
       effortsJson = '';
    }

    public PageReference pageAction(){
        this.scopeGrpId = ApexPages.CurrentPage().getParameters().get(E2_Constants.URL_KEY_SCOPEGROUP_ID);
        // New
        if(this.scope.id == null){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'No scope defined to edit!!!');
            ApexPages.addMessage(msg); 
            return null;            
        }else{
            this.scope.LastModifiedBy = [SELECT Name,Id FROM User WHERE Id=:this.scope.LastModifiedById];
            scopeQuestionManager.scope = this.scope;
            this.lastModifiedDate = this.scope.lastModifiedDate;
            populateViewRecords();
        }
        return null;
    }
    
    // method to upsert or delete scope 
    public pagereference saveScope(){
        List<E2_Scope__c> scopeListToUpsert = new List<E2_Scope__c>();       
        List<E2_Effort__c> masterScope_Efforts = new List<E2_Effort__c>();        
        List<E2_Scope__c> scopeListToDelete = new List<E2_Scope__c>();       
        List<E2_Effort__c> effortsToDelete = new List<E2_Effort__c>();
        this.childScope.multiplierUpdated = false;        
        Scope masterScope;
        ApexPages.Message msg;        
        Id recTypeId = E2_RecordTypeClass.getId(E2_Constants.E2_SCOPE_API_NAME, E2_Constants.SCOPE_RT_TEMPLATE);
        
        List<E2_Recommended_Asset__c> assetsToInsert = new List<E2_Recommended_Asset__c>();
        List<E2_Recommended_Asset__c> assetsToDelete = new List<E2_Recommended_Asset__c>();
        //code to insert or delete assets 
        if(assetsRecsJson != '' && assetsRecsJson.length() > 0){
            Map<String, Object> assetsMap =  (Map<String, Object>) JSON.deserializeUntyped(assetsRecsJson);
            for(String assetId : assetsMap.keySet()){
              Map<String, Object> obj = (Map<String, Object>)assetsMap.get(assetId);
              if((String)obj.get('isExisting') == 'false' && (String)obj.get('isDeleted') == 'false'){
                  assetsToInsert.add(new E2_Recommended_Asset__c(Scope__c = this.scope.id, Asset__c = assetId));
              }
              else if((String)obj.get('isExisting') == 'true' && (String)obj.get('isDeleted') == 'true' && (String)obj.get('recommendedAssetRecId') != null){
                  string recId = (String)obj.get('recommendedAssetRecId');
                  assetsToDelete.add(new E2_Recommended_Asset__c(Id = recId));
              }
            }
        }
        
        // Create a savepoint 
        Savepoint sp = Database.setSavepoint();
        scopeListToUpsert.add(childScope.scope);
        this.scope = childScope.scope;
        
        try{ 
            if(!scopeListToUpsert.isEmpty()) upsert scopeListToUpsert;
            
            if(this.childScope.multiplier  != this.childScope.scope.Effort_Quantity__c) {
                this.childScope.multiplier = this.childScope.scope.Effort_Quantity__c;
                this.childScope.multiplierUpdated = true;
            }
        }catch(Exception ex){
            Database.rollback(sp);
            resetChildScopesOnException();            
            msg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
            ApexPages.addMessage(msg);            
            return null;
        }
        for(Effort ef : childScope.efforts) {
            if(ef.isDeleted == true){
                if(ef.effort.id <> NULL) effortsToDelete.add(ef.effort); 
                    continue;
            }
            if(ef.effort.scope__c == null) ef.effort.scope__c = childScope.scope.id;
                masterScope_Efforts.add(ef.effort);
        }
        try{
            if(!effortsToDelete.isEmpty()){
              delete effortsToDelete;            
            } 
 
            if(!masterScope_Efforts.isEmpty()){
                upsert masterScope_Efforts;
            }
            
            if(assetsToInsert.size() > 0){
                insert assetsToInsert;
            }
            
            if(assetsToDelete.size() > 0){
                delete assetsToDelete;
            }
        }catch(Exception ex){
            Database.rollback(sp);
            resetChildScopesOnException();            
            msg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
            ApexPages.addMessage(msg);
            return null;            
        }
        this.dmlOperationMessage = E2_Constants.DML_OPERATION_MESSAGE_SUCCESS;
        string errorMessage = E2_Constants.BLANK;
        scopeQuestionManager.saveQuestion(errorMessage, this.dmlOperationMessage);
        
        // Rohit - Set Current user details as last modified by user on scope 
        User modifiedBy = new User(Id = UserInfo.getUserId(),FirstName = UserInfo.getFirstName(),LastName = UserInfo.getLastName()); 
        this.scope.LastModifiedBy = modifiedBy;
        this.lastModifiedDate = System.now();
        // 01/11/2017 : VG : I-252391
        if(msg == null){
            // now since we got success from all the dml operations, lets remove the isDeleted efforts from the list
            for(integer indx = (this.childScope.efforts.size() - 1); indx > -1; indx--){
                Effort ef = this.childScope.efforts[indx];
                if(ef.isDeleted == true) this.childScope.efforts.remove(indx);
            }
        }
        
        return null;             
    }
    
    // method to reset child scopes 
    public void resetChildScopesOnException() {       
        string scope_id = childScope.scope.id;
        if(childScope.key <> scope_id){
            childScope.scope.id = null;
        }
        for(Effort ef : childScope.efforts){
            string ef_id = ef.effort.id;
            if(ef.key <> ef_id){
              ef.effort.id = null;
              ef.effort.scope__c = null;
            }
        }
    }
    
    //method to add new question 
    public pagereference addNewQuestion() {
        return scopeQuestionManager.addNewQuestion();
    }
    
    // method to populate records 
    public void populateViewRecords(){
        Id scopeId = this.scope.id;        
        for(E2_Scope__c scope : E2_DataUtil.getScopeAndChildrenOnScopeIdForEditScope(scopeId)){ 
               this.childScope = new Scope(scope, scope.Efforts__r);
        }
        scopeQuestionManager.retriveScopeQuestion();
    }
    
    public List<E2_Effort__c> getEffortsInstanceList(){
        List<E2_Effort__c> efforts = new List<E2_Effort__c>();        
        return efforts;
    }
    
    // method to add bulk efforts 
    public PageReference addBulkEfforts(){
        if(effortsJson != null && effortsJson.length() > 0){
            List<E2_EffortsWrapper> lstEffortsWrapper = (List<E2_EffortsWrapper>)JSON.deserialize(effortsJson, List<E2_EffortsWrapper>.class);
            for(E2_EffortsWrapper effortWrapper : lstEffortsWrapper){
                if(effortWrapper.hours > 0){
                    childScope.efforts.add(new Effort(new E2_Effort__c(Complexity_Factor_High__c = 0, 
                                                                           Complexity_Factor_Low__c = 0, 
                                                                           Effort_Hrs__c = effortWrapper.hours,
                                                                           Name = effortWrapper.phaseName + '-' + effortWrapper.roleName,
                                                                           Phase__c = effortWrapper.phaseName,
                                                                           Resource_Role__c = effortWrapper.roleName)));
                }    
            }
        }
        return null;
    }
    
    public Double offset{get{
        TimeZone tz = UserInfo.getTimeZone();
        //Milliseconds to Day
        return tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
    }}
    
    //wrapper class for Scope
    public class Scope{
        public string key{get;set;}
        public E2_Scope__c scope{get;set;}
        public boolean isCloned{get;set;}
        public boolean hasClonedEfforts{get;set;}
        public List<Effort> efforts{get;set;}
        //public string deletekey_effort{get;set;}

        public boolean isDeleted{get;set;}
        public string slider_state{get;set;}
        
        public decimal multiplier{get;set;}
        public boolean multiplierUpdated {get;set;}
        
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
            return hrs.round();
        }
        
        public Scope(E2_Scope__c scope, List<E2_Effort__c> efforts){            
            this.efforts = new List<Effort>();
            this.isDeleted = false;
            this.slider_state = '';
            this.isCloned = false;
            if(scope.Source_Scope__c != NULL){
                this.isCloned = true;               
            }
            this.key = scope.id;
            this.scope = scope;
            this.multiplier = scope.Effort_Quantity__c;
            this.multiplierUpdated = false;
            for(E2_Effort__c effort : efforts){
                if(effort.Source_Effort__c <> NULL) {
                    this.hasClonedEfforts = true;           
                }
                this.efforts.add(new Effort(effort));
            }           
        }
        //method to reload 
        public pagereference reload(){
            return null;            
        }
        //method to change complexity 
        public pagereference changeComplexity(){
            return null;
        }
        //method to remove scope 
        public pagereference remove(){
            this.isDeleted = true;
            return null;            
        }
        //method to add new effort 
        public pagereference addNewEffort(){
            this.efforts.add(new Effort(new E2_Effort__c(Complexity_Factor_High__c = 0, Complexity_Factor_Low__c = 0, Effort_Hrs__c = 0)));
            return null;
        }
    }
    
    // wrapper class for Effort
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
        //method to remove effort 
        public pagereference remove(){
            this.isDeleted = true;
            return null;            
        }
    }
}