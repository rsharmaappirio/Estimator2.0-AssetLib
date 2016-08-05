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
    
    public string assetsRecsJson {get;set;}
	public boolean showFavForSTMPermissionSet {get;set;}
	// Question wrapper list for question and answer 
	public List<Question> listQuestions {get;set;}

    public E2_EditScopeTemplateController(ApexPages.StandardController std) {
       // constructor for the page tied to standard controller  
       this.scope = (E2_Scope__c)std.getRecord();
       this.childScopes = new List<Scope>();       
       this.is_View = false;       
       this.dmlOperationMessage = E2_Constants.DML_OPERATION_MESSAGE_FAIL;
       
       assetsRecsJson = '';
       showFavForSTMPermissionSet = true;
       listQuestions = new List<Question>();
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
        
        //I-227260 : code to hide Favourite for Scope Template Manager
        List<PermissionSet> permissionSetsAllowed = [SELECT Id, Name
			                                                 FROM PermissionSet
			                                                 WHERE Name =: E2_Constants.STM_PERMISSION_SET];
        
		    User currentUser = [SELECT Id, Profile.Name,
		                          (SELECT Id FROM PermissionSetAssignments WHERE PermissionSetId IN: permissionSetsAllowed)
		                          FROM User
		                          WHERE Id = :userinfo.getUserId()];
		      if (currentUser.PermissionSetAssignments.size() > 0) {
		        showFavForSTMPermissionSet = false;
		      }
		      else {
		        showFavForSTMPermissionSet = true;
		      }
        return null;
    }
    
    public pagereference saveScope(){
        List<E2_Scope__c> scopeListToUpsert = new List<E2_Scope__c>();       
        List<E2_Effort__c> masterScope_Efforts = new List<E2_Effort__c>();        
        List<E2_Scope__c> scopeListToDelete = new List<E2_Scope__c>();       
        List<E2_Effort__c> effortsToDelete = new List<E2_Effort__c>();
        // Question and Answer collections to upsert and delete
        map<string,E2_Question__c> questionToUpsert = new map<string,E2_Question__c>();
        List<E2_Question__c> questionToDelete = new List<E2_Question__c>();
        map<string,List<E2_Answer__c>> answerToUpsert = new map<string,List<E2_Answer__c>>();
        List<E2_Answer__c> answerToDelete = new List<E2_Answer__c>();
        map<E2_Answer__c, string> answerScopeMap = new map<E2_Answer__c, string>();
                
        Scope masterScope;
        ApexPages.Message msg;        
        Id recTypeId = E2_RecordTypeClass.getId(E2_Constants.E2_SCOPE_API_NAME, E2_Constants.SCOPE_RT_TEMPLATE);
        
        List<E2_Recommended_Asset__c> assetsToInsert = new List<E2_Recommended_Asset__c>();
        List<E2_Recommended_Asset__c> assetsToDelete = new List<E2_Recommended_Asset__c>();
        
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
        
        integer questionindex = 1;
        for(Question question : listQuestions) {
            if(question.isDeleted) {
                if(question.e2question.Id != NULL) {
                    for(Answer answer : question.e2answers) {
                        if(answer.e2answer.Id != NULL) 
                            answerToDelete.add(answer.e2answer);
                    }
                    questionToDelete.add(question.e2question);
                }
            } else {
                if(question.e2question.Id == NULL) {
                    string mapKey = questionindex+question.e2question.Question_Text__c;
                    updateQuestionUpsertList(questionToUpsert, answerToUpsert, answerToDelete,
                                             answerScopeMap, question, mapKey);
                    questionindex++;
                } else {
                    string mapKey = question.e2question.Id;
                    updateQuestionUpsertList(questionToUpsert, answerToUpsert, answerToDelete,
                                             answerScopeMap, question, mapKey);
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
            
            if(assetsToInsert.size() > 0){
            	insert assetsToInsert;
            }
            
            if(assetsToDelete.size() > 0){
            	delete assetsToDelete;
            }
            if(answerToDelete.size() > 0) {
                delete answerToDelete;
            }
            
            if(questionToDelete.size() > 0) {
                delete questionToDelete;
            }
                        
            if(questionToUpsert.size() > 0) {
                upsert questionToUpsert.values();

            }
            
            if(answerToUpsert.size() > 0) {
                List<E2_Answer__c> e2Answers = new List<E2_Answer__c>();
                for(string mapKey : questionToUpsert.KeySet()) {
                    E2_question__c question = questionToUpsert.get(mapKey);
                    for(E2_Answer__c e2Answer : answerToUpsert.get(mapKey)) {
                        if(e2Answer.Id == NULL) {
                            e2Answer.Question__c = question.Id; 
                        }                       
                        e2Answers.add(e2Answer);
                    }
                }
                upsert e2Answers;
                set<Id> answersId = new set<Id>();
                list<E2_Action_Scope__c> answerScopes = new List<E2_Action_Scope__c>();
                for(E2_Answer__c answer : e2Answers) {
                	answersId.add(answer.Id);
                	if(answerScopeMap.containsKey(answer)) {
                		for(String scopeId : answerScopeMap.get(answer).split(E2_Constants.COMMA)) {
                			answerScopes.add(new E2_Action_Scope__c(Answer__c = answer.Id,
                									Scope__c = scopeId,
                									Unique_Key__c = answer.Id+scopeId));
                		}
                	}
                }
                delete E2_DataUtil.getRelatedScopes(answersId);
                insert answerScopes;
            }
        }catch(Exception ex){
            Database.rollback(sp);
            resetChildScopesOnException();            
            msg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
            ApexPages.addMessage(msg);
            return null;            
        }
        this.dmlOperationMessage = E2_Constants.DML_OPERATION_MESSAGE_SUCCESS;
        retriveScopeQuestion();        
        return null;             
    }
    
    /**
     * Method to get answer and question to insert, update and delete
     */
    public void updateQuestionUpsertList(map<string,E2_Question__c> questionToUpsert,
                                            map<string,List<E2_Answer__c>> answerToUpsert,
                                            List<E2_Answer__c> answerToDelete,
                                            map<E2_Answer__c,string> answerScopeMap,
                                            Question question, string mapKey) {
        questionToUpsert.put(mapKey, question.e2question);
        for(Answer answer : question.e2answers) {                       
            if(!answer.isDeleted) {
                if(question.selectedAnswer != NULL && answer.e2answer.id != NULL) {
                    if(question.selectedAnswer.indexOf(answer.e2answer.id) != -1) {
                        answer.e2answer.Is_Selected__c = true;
                    } else {
                        answer.e2answer.Is_Selected__c = false;
                    }
                }
                if(!string.isBlank(answer.bindedScopes)) {
                	answerScopeMap.put(answer.e2answer, answer.bindedScopes);
                }                
                if(!answerToUpsert.containsKey(mapKey))
                    answerToUpsert.put(mapKey, new List<E2_Answer__c>());
                answerToUpsert.get(mapKey).add(answer.e2answer);
            }else if(answer.e2answer.Id != NULL) {
                answerToDelete.add(answer.e2answer);
            }
        }
        if(question.e2question.Id == NULL && question.e2answers.isEmpty()) {
            answerToUpsert.put(mapKey, new List<E2_Answer__c>());
            answerToUpsert.get(mapKey).add(new E2_Answer__c(Is_Active__c = true));
        }
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
        retriveScopeQuestion();
    }
    
    public void retriveScopeQuestion() {
        this.listQuestions.clear();
        map<Id,Answer> answermap = new map<Id,Answer>();
        List<E2_Question__c> questions =  E2_DataUtil.getScopeQuestions(this.scope.id);
        if(questions.size() > 0) {
            for(E2_Question__c question : questions) {
            	Question questionWrapper = new Question(question);
                this.listQuestions.add(questionWrapper);
                for(Answer answer : questionWrapper.e2answers) {
                	answermap.put(answer.e2answer.Id, answer);
                }
            }           
        }
        if(!answermap.isEmpty()) {
        	for(E2_Action_Scope__c actionScopes : E2_DataUtil.getRelatedScopes(answermap.KeySet())) {
        		Answer answer = answermap.get(actionScopes.Answer__c);
        		if(answer.bindedScopes.length() >=15) {
        			answer.bindedScopes = answer.bindedScopes+E2_Constants.COMMA+actionScopes.Scope__c;
        		}else {
        			answer.bindedScopes = actionScopes.Scope__c;
        		}
        	}
        }        
    }
    
    public pagereference addNewQuestion() {
        this.listQuestions.add(new Question(new E2_Question__c(Scope__c = scope.Id, Is_Active__c = true)));
        return null;
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
    
    public class Question {
        public boolean isDeleted{get;set;}
        public boolean isCloned{get;set;}
        public boolean isEdit{get;set;}
        public String key{get;set;}
        public E2_Question__c e2question{get;set;}
        public list<Answer> e2answers{get;set;}
        public string selectedAnswer{get;set;}
        public integer sequence{get;set;}
        public Question (E2_Question__c e2question) {
            this.isDeleted = false;   
            this.isCloned = false;
            this.isEdit = false;
            this.sequence = 0;
            this.selectedAnswer = E2_Constants.BLANK;
            if(e2question.Source_Question__c <> NULL){
                this.isCloned = true;           
            }
            if(e2question.id == null){    
                Blob hash2 = Crypto.generateDigest(E2_Constants.MD5, Blob.valueOf(E2_Constants.STRING_1000 + String.valueOf(Datetime.now().formatGMT(E2_Constants.DATETIME_FORMAT_YYYYMMDD))));            
                this.key = EncodingUtil.convertToHex(hash2);
            }else{
                this.key = e2question.id;
          } 
            this.e2question = e2question;  
            this.e2answers = new list<Answer>();
            if(e2question.Answers__r != NULL && !e2question.Answers__r.isEmpty()) {
                for(E2_Answer__c answer : e2question.Answers__r) {
                    this.e2answers.add(new Answer(answer));
                    this.sequence = Integer.valueOf(answer.Sequence__c);
                    if(answer.Is_Selected__c) {
                        selectedAnswer += answer.id+E2_Constants.COMMA;
                    }
                }
                if(!string.isblank(selectedAnswer)) {
                    selectedAnswer = selectedAnswer.removeEnd(E2_Constants.COMMA);
                }
            }                
        }
        
        public pagereference addAnswer() {
            for(Answer ans : this.e2answers) {
                if(ans.e2answer.Id == Null)
                    ans.isDeleted = true;
            }            
            if(e2question.Type__c == 'Yes/No') {
                E2_Answer__c answer1 = new E2_Answer__c(Answer_Text__c = 'Yes',Is_Active__c = true,Sequence__c = 1);
                this.e2answers.add(new Answer(answer1));
                E2_Answer__c answer2 = new E2_Answer__c(Answer_Text__c = 'No',Is_Active__c = true,Sequence__c = 2);
                this.e2answers.add(new Answer(answer2));
                this.sequence = 2;
            } else if(e2question.Type__c != 'Summary') {
                for(integer index = 1;index <= 5;index++) {
                    E2_Answer__c answer = new E2_Answer__c(Is_Active__c = true,Sequence__c = index);
                    this.e2answers.add(new Answer(answer));
                }
                this.sequence = 5;
            }
            return null;
        }
        
        public pagereference addNewAnswerInstance() {
        	this.sequence = this.sequence + 1;
        	E2_Answer__c answer = new E2_Answer__c(Is_Active__c = true,Sequence__c = this.sequence);
            this.e2answers.add(new Answer(answer));
            this.isEdit = true;
        	return null;
        } 
        
        public pagereference remove(){
            this.isDeleted = true;
            return null;            
        }        
    }
    
    public class Answer {
        public boolean isDeleted{get;set;}
        public boolean isCloned{get;set;}
        public boolean isEdit{get;set;}
        public String key{get;set;}
        public string bindedScopes{get;set;}
        public E2_Answer__c e2answer{get;set;}
        
        public Answer (E2_Answer__c e2answer) {
            this.isDeleted = false;   
            this.isCloned = false;
            this.isEdit = false;
            this.bindedScopes = E2_constants.BLANK;
            if(e2answer.Source_Answer__c <> NULL){
                this.isCloned = true;           
            }
            if(e2answer.id == null){    
                Blob hash2 = Crypto.generateDigest(E2_Constants.MD5, Blob.valueOf(E2_Constants.STRING_1000 + String.valueOf(Datetime.now().formatGMT(E2_Constants.DATETIME_FORMAT_YYYYMMDD))));            
                this.key = EncodingUtil.convertToHex(hash2);
            }else{
                this.key = e2answer.id;
          } 
            this.e2answer = e2answer;  
        }
        
        public pagereference remove(){
            this.isDeleted = true;
            return null;            
        }
    }
}