/**=====================================================================
 * Appirio, Inc
 * Name: E2_ScopeQuestionAnswerManager
 * Description: Controller class for addedit question answer on page
 * Created Date: August 05, 2016
 * Created By: Rohit Sharma (Appirio)
 * 
 * Date Modified      Modified By                  Description of the update
*  =====================================================================*/
public with sharing class E2_ScopeQuestionAnswerManager {
    public E2_Scope__c scope{get;set;}
    // Question wrapper list for question and answer 
	public List<Question> listQuestions {get;set;}
	
	public E2_ScopeQuestionAnswerManager() {
		listQuestions = new List<Question>();
	}
	
	public pagereference saveQuestion(String errorMessage, string dmlOperationMessage) {
        // Question and Answer collections to upsert and delete
        map<string,E2_Question__c> questionToUpsert = new map<string,E2_Question__c>();
        List<E2_Question__c> questionToDelete = new List<E2_Question__c>();
        map<string,List<E2_Answer__c>> answerToUpsert = new map<string,List<E2_Answer__c>>();
        List<E2_Answer__c> answerToDelete = new List<E2_Answer__c>();
        map<E2_Answer__c, string> answerScopeMap = new map<E2_Answer__c, string>();
        set<string> scopeIdsToDeactivate = new set<string>();
        set<string> scopeIdsToActivate = new set<string>();
        Savepoint sp = Database.setSavepoint();
        
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
                                             answerScopeMap, question, scopeIdsToDeactivate,
                                             scopeIdsToActivate, mapKey);
                    questionindex++;
                } else {
                    string mapKey = question.e2question.Id;
                    updateQuestionUpsertList(questionToUpsert, answerToUpsert, answerToDelete,
                                             answerScopeMap, question, scopeIdsToDeactivate,
                                             scopeIdsToActivate, mapKey);
                }
            }
        }
        
        try{
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
                list<E2_Action_Scope__c> answerScopes = new list<E2_Action_Scope__c>();
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
            errorMessage = ex.getMessage().contains(E2_constants.INSUFFICIENT_ACCESS_OR_READONLY) ? 
                                    E2_Constants.INSUFFICIENT_ERROR_MSSG : 
                                    ex.getMessage();
            return null;            
        }
        dmlOperationMessage = E2_Constants.DML_OPERATION_MESSAGE_SUCCESS;
        retriveScopeQuestion();
        return null;             
    }
    
    /**
     * Method to Acitvate/De-activate child scopes template
     */
     private void updateScopeStatus(set<string> scopeIdsToDeactivate,
                                    set<string> scopeIdsToActivate) {
     	
     }
     
    
    /**
     * Method to get answer and question to insert, update and delete
     */
    public void updateQuestionUpsertList(map<string,E2_Question__c> questionToUpsert,
                                            map<string,List<E2_Answer__c>> answerToUpsert,
                                            List<E2_Answer__c> answerToDelete,
                                            map<E2_Answer__c,string> answerScopeMap,
                                            Question question, set<string> scopeIdsToDeactivate,
                                            set<string> scopeIdsToActivate, string mapKey) {
        questionToUpsert.put(mapKey, question.e2question);
        for(Answer answer : question.e2answers) {                       
            if(!answer.isDeleted) {
                if(question.selectedAnswer != NULL && answer.e2answer.id != NULL) {
                    if(question.selectedAnswer.indexOf(answer.e2answer.id) != -1) {
                        answer.e2answer.Is_Selected__c = true;
                    } else {
                        answer.e2answer.Is_Selected__c = false;
                    }
                    if(answer.e2answer.Is_Selected__c != answer.isSelected
                    	&& !string.isBlank(answer.bindedScopes)) {
                    	if(answer.e2answer.Action__c =='Deactivate child scope'
                    	   || (answer.e2answer.Action__c =='Activate child scope' && 
                    	   	   !answer.e2answer.Is_Selected__c)) {
                    		for(string scopeid : answer.bindedScopes.split(E2_Constants.COMMA)) {
                    			scopeIdsToDeactivate.add(scopeid);
                    		}
                    	} else if(answer.e2answer.Action__c =='Activate child scope' 
                    			  || (answer.e2answer.Action__c =='Deactivate child scope' && 
                    	   	   		  !answer.e2answer.Is_Selected__c)) {
                    		for(string scopeid : answer.bindedScopes.split(E2_Constants.COMMA)) {
                    			scopeIdsToActivate.add(scopeid);
                    		}
                    	}
	                }
                }
                if(!string.isBlank(answer.bindedScopes) && 
                	(string.isBlank(answer.originalBindedScopes) || 
                	answer.originalBindedScopes != answer.bindedScopes)) {
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
        		answer.originalBindedScopes = answer.bindedScopes;
        	}
        }        
    }
    
    public pagereference addNewQuestion() {
        this.listQuestions.add(new Question(new E2_Question__c(Scope__c = scope.Id, Is_Active__c = true)));
        return null;
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
        public boolean isSelected{get;set;}
        public string bindedScopes{get;set;}
        public string originalBindedScopes{get;set;}
        public E2_Answer__c e2answer{get;set;}
        
        public Answer (E2_Answer__c e2answer) {
            this.isDeleted = false;   
            this.isCloned = false;
            this.isEdit = false;
            this.bindedScopes = E2_constants.BLANK;
            this.originalBindedScopes = E2_constants.BLANK;
            if(e2answer.Source_Answer__c <> NULL){
                this.isCloned = true;           
            }
            this.isSelected = e2answer.Is_Selected__c;
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