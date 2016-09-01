/**=====================================================================
 * Appirio, Inc
 * Name: E2_EditScopeController
 * Description: Controller class for editscope page
 * Created Date: MAY 11th, 2016
 * Created By: Rohit Sharma (Appirio)
 * 
 * Date Modified      Modified By                  Description of the update
   May 17, 2016       Rahul Jain                   Removed hardcoding, added constants & comments. 
*  =====================================================================*/

public with sharing class E2_EditScopeController {
    public E2_Scope__c scope{get;set;}
    public Scope childScope{get;set;}
    public boolean is_View{get;set;}
    public string estimateId{get;set;}
    public string dmlOperationMessage{get;set;}
    public string errorMessage{get;set;}
    public boolean is_Dirty{get;set;}
    public string assetsRecsJson {get;set;}
    public string effortsJson {get;set;}
    
    public E2_ScopeQuestionAnswerManager scopeQuestionManager{get;set;}

    public E2_EditScopeController(ApexPages.StandardController std) {
       // constructor for the page tied to standard controller	
       this.scope = (E2_Scope__c)std.getRecord();
       this.childScope = new Scope();
       this.is_View = false;       
       this.dmlOperationMessage = E2_Constants.DML_OPERATION_MESSAGE_FAIL;
       this.errorMessage = E2_constants.BLANK;
       this.is_Dirty = false;
       assetsRecsJson = '';
       effortsJson = '';
       scopeQuestionManager = new E2_ScopeQuestionAnswerManager();
    }

    public PageReference pageAction(){
        this.estimateId = ApexPages.CurrentPage().getParameters().get(E2_Constants.URL_KEY_ESTIMATE_ID);
        // New
        if(this.scope.id == null){
        	this.errorMessage = 'No scope defined to edit!!!';
            return null;            
        }else{
        	scopeQuestionManager.scope = this.scope;
            populateViewRecords();            
        }
        return null;
    }
    
    public E2_Favourite_Scope__c getE2FavoriteScopeInstance(Id scopeId, Id userId, string uniqueKey){
          E2_Favourite_Scope__c favSC = new E2_Favourite_Scope__c();
	      favSC.Scope__c = scopeId;
	      favSC.User__c = userId;
	      favSC.Unique_Scope_User_Id__c = uniqueKey;
		  return favSc;	      
        
    }
    
    
    public pagereference saveScope(){
        List<E2_Scope__c> scopeListToUpsert = new List<E2_Scope__c>();       
        List<E2_Effort__c> masterScope_Efforts = new List<E2_Effort__c>();        
        List<E2_Scope__c> scopeListToDelete = new List<E2_Scope__c>();       
        List<E2_Effort__c> effortsToDelete = new List<E2_Effort__c>();
        List<E2_Favourite_Scope__c> fscLstToInsert = new List<E2_Favourite_Scope__c>();
        List<E2_Favourite_Scope__c> fscLstToDelete = new List<E2_Favourite_Scope__c>();  
        Map<String,E2_Favourite_Scope__c> favScopes = new Map<String,E2_Favourite_Scope__c>();
        List<E2_Recommended_Asset__c> assetsToInsert = new List<E2_Recommended_Asset__c>();
        List<E2_Recommended_Asset__c> assetsToDelete = new List<E2_Recommended_Asset__c>();
        this.errorMessage = E2_Constants.BLANK;  
        Scope masterScope;
        Id recTypeId = E2_RecordTypeClass.getId(E2_Constants.E2_SCOPE_API_NAME, E2_Constants.SCOPE_RT_SCOPE);
        
        
        // TODO - Rohit Sharma/Arpita - please move this query to datautil class
        for(E2_Favourite_Scope__c favSC : [SELECT Id,Unique_Scope_User_Id__c 
                                          FROM E2_Favourite_Scope__c 
                                          WHERE User__c =: UserInfo.getUserId()]) {
            favScopes.put(favSC.Unique_Scope_User_Id__c, favSC);
        }
        
       
        
        if(!String.isBlank(assetsRecsJson) && assetsRecsJson.length() > 0){
            Map<String, Object> assetsMap =  (Map<String, Object>) JSON.deserializeUntyped(assetsRecsJson);
            for(String assetId : assetsMap.keySet()){
              Map<String, Object> obj = (Map<String, Object>)assetsMap.get(assetId);
              if(((String)obj.get('isExisting')) == 'false' && ((String)obj.get('isDeleted')) == 'false'){
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
        
    	if(this.childScope.isDeleted == false){                
            // scope to insert/update (Upsert)
            scopeListToUpsert.add(this.childScope.scope);
        
            String uniqueKey = this.childScope.scope.Id + '-' + UserInfo.getUserId();
            if(this.childScope.scope.Is_Favourite__c == true && !favScopes.containsKey(uniqueKey)){
		      fscLstToInsert.add(getE2FavoriteScopeInstance(this.childScope.scope.Id, UserInfo.getUserId(), uniqueKey));
		    }else if(this.childScope.scope.Is_Favourite__c == false && favScopes.containsKey(uniqueKey)){
			  fscLstToDelete.add(favScopes.get(uniqueKey));
			}
				
        } else {
        	scopeListToDelete.add(this.childScope.scope);
        }
        this.scope = this.childScope.scope;
        
        try{       
           system.debug('>>>>>SIZE>>>>' + scopeListToUpsert.size()); 
           if(!fscLstToInsert.isEmpty()) upsert fscLstToInsert;
           
           if(!fscLstToDelete.isEmpty()) delete fscLstToDelete;
           
           if(!scopeListToUpsert.isEmpty()) upsert scopeListToUpsert;
           
		        
		       
        }catch(Exception ex){
            Database.rollback(sp);
            resetChildScopesOnException();
            this.errorMessage = ex.getMessage().contains(E2_constants.INSUFFICIENT_ACCESS_OR_READONLY) ? 
                                    E2_Constants.INSUFFICIENT_ERROR_MSSG: 
                                    ex.getMessage();
            return null;
        }
        
        if(this.childScope.isDeleted == false){             
                    
            for(Effort ef : this.childScope.efforts){
                if(ef.isDeleted == true){
                    if(ef.effort.id <> NULL) effortsToDelete.add(ef.effort); 
                        continue;
                }
                system.debug('>>ef.effort.scope__c = sc.scope.id>>' + ef.effort.scope__c + '=' +  this.childScope.scope.id);
                if(ef.effort.scope__c == null) ef.effort.scope__c = this.childScope.scope.id;
                    masterScope_Efforts.add(ef.effort);
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
            
            if(assetsToInsert.size() > 0){
            	insert assetsToInsert;
            }
            
            if(assetsToDelete.size() > 0){
            	delete assetsToDelete;
            }
            assetsRecsJson = '';
            this.is_Dirty = false;
        }catch(Exception ex){
            Database.rollback(sp);
            resetChildScopesOnException(); 
            this.errorMessage = ex.getMessage().contains(E2_constants.INSUFFICIENT_ACCESS_OR_READONLY) ? 
                                    E2_Constants.INSUFFICIENT_ERROR_MSSG : 
                                    ex.getMessage();
            return null;            
        }
        this.dmlOperationMessage = E2_Constants.DML_OPERATION_MESSAGE_SUCCESS;
        scopeQuestionManager.saveQuestion(this.errorMessage, this.dmlOperationMessage);
        return null;             
    }
    
    public void resetChildScopesOnException(){       
        string scope_id = this.childScope.scope.id;
        if(this.childScope.key <> scope_id){
            this.childScope.scope.id = null;
        }
        for(Effort ef : this.childScope.efforts){
            string ef_id = ef.effort.id;
            if(ef.key <> ef_id){
                ef.effort.id = null;
                ef.effort.scope__c = null;
            }
        }
    }
    
    public pagereference addNewQuestion() {
    	return scopeQuestionManager.addNewQuestion();
    }
    
    public void populateViewRecords(){
        Id scopeId = this.scope.id;   
        Id currentUserId = UserInfo.getUserId();     
        for(E2_Scope__c scope : E2_DataUtil.getScopeAndChildrenOnScopeIdForEditScope(scopeId)){
               this.childScope = new Scope(scope, scope.Efforts__r);
        }
        scopeQuestionManager.retriveScopeQuestion();
    }
    
    
    public pagereference updateFormStatus() {
        is_Dirty = true;
        return null;
    }
    
    public List<E2_Effort__c> getEffortsInstanceList(){
        List<E2_Effort__c> efforts = new List<E2_Effort__c>();        
        return efforts;
    }
    
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
            this.is_Dirty = true;
        }
        return null;
    }
    
    public class Scope{
        public string key{get;set;}
        public E2_Scope__c scope{get;set;}
        public boolean isCloned{get;set;}
        public boolean hasClonedEfforts{get;set;}
        public List<Effort> efforts{get;set;}

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
        
        public Scope() {
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