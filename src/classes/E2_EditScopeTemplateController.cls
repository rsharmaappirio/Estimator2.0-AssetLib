/**=====================================================================
 * Appirio, Inc
 * Name: E2_EditScopeTemplateController
 * Description: Controller class for E2_EditScopeTemplate page
 * Created Date: 
 * Created By: 
 * 
 * Date Modified      Modified By                  Description of the update
   
*  =====================================================================*/

public with sharing class E2_EditScopeTemplateController {
    public E2_Scope__c scope{get;set;}
    public List<Scope> childScopes{get;set;}     
    public boolean is_View{get;set;}
    public string scopeGrpId{get;set;}
    public string dmlOperationMessage{get;set;}


    public E2_EditScopeTemplateController(ApexPages.StandardController std) {
       // constructor for the page tied to standard controller  
       this.scope = (E2_Scope__c)std.getRecord();
       this.childScopes = new List<Scope>();       
       this.is_View = false;       
       this.dmlOperationMessage = E2_Constants.DML_OPERATION_MESSAGE_FAIL;
    }

    public PageReference pageAction(){
        this.scopeGrpId = ApexPages.CurrentPage().getParameters().get(E2_Constants.URL_KEY_SCOPEGROUP_ID);
        // New
        if(this.scope.id == null){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'No scope defined to edit!!!');
            ApexPages.addMessage(msg); 
            return null;            
        }else{ 
            populateViewRecords();
        }
        return null;
    }
    
    public pagereference saveScope(){
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
            if(sc.isDeleted == false){                
                scopeListToUpsert.add(sc.scope);
            } else {
                scopeListToDelete.add(sc.scope);
            }
            this.scope = sc.scope;
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
    
    public void populateViewRecords(){
        Id scopeId = this.scope.id;        
        for(E2_Scope__c scope : E2_DataUtil.getScopeAndChildrenOnScopeIdForEditScope(scopeId)){                
               this.childScopes.add(new Scope(scope, scope.Efforts__r));
        } 
    }
    
    public List<E2_Effort__c> getEffortsInstanceList(){
        List<E2_Effort__c> efforts = new List<E2_Effort__c>();        
        return efforts;
    }
    
    public class Scope{
        public string key{get;set;}
        public E2_Scope__c scope{get;set;}
        public boolean isCloned{get;set;}
        public boolean hasClonedEfforts{get;set;}
        public List<Effort> efforts{get;set;}
        //public string deletekey_effort{get;set;}

        public boolean isDeleted{get;set;}
        public string slider_state{get;set;}
        
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
            if(scope.id == null){   
               Blob hash2 = Crypto.generateDigest(E2_Constants.MD5, Blob.valueOf(E2_Constants.STRING_1000 + String.valueOf(Datetime.now().formatGMT(E2_Constants.DATETIME_FORMAT_YYYYMMDD))));
               this.key = EncodingUtil.convertToHex(hash2);
            }else{
              this.key = scope.id;
            }
            this.scope = scope;
            for(E2_Effort__c effort : efforts){
                if(effort.Source_Effort__c <> NULL) {
                    this.hasClonedEfforts = true;           
                }
                this.efforts.add(new Effort(effort));
            }           
        }
        
        public pagereference reload(){
            return null;            
        }
        
        public pagereference changeComplexity(){
            return null;
        }
        
        public pagereference remove(){
            this.isDeleted = true;
            return null;            
        }
        
        public pagereference addNewEffort(){
            this.efforts.add(new Effort(new E2_Effort__c(Complexity_Factor_High__c = 0, Complexity_Factor_Low__c = 0, Effort_Hrs__c = 0)));
            return null;
        }
    }
    
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
        
        public pagereference remove(){
            this.isDeleted = true;
            return null;            
        }
    }
}