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
    public String changecomplexty{get;set;}
    public String scopeToActivate{get;set;}
    public String scopeToDeactivate{get;set;}
    
    // Question wrapper list for question and answer 
	public List<Question> listQuestions {get;set;}
	
	// constructor 
	public E2_ScopeQuestionAnswerManager() {
		listQuestions = new List<Question>();
		this.changecomplexty = E2_Constants.BLANK;
		this.scopeToActivate = E2_Constants.BLANK;
		this.scopeToDeactivate = E2_Constants.BLANK;
	}
		
	// method to save questions 
	public pagereference saveQuestion(String errorMessage, string dmlOperationMessage) {
        this.changecomplexty = E2_Constants.BLANK;
		this.scopeToActivate = E2_Constants.BLANK;
		this.scopeToDeactivate = E2_Constants.BLANK;
        // Question and Answer collections to upsert and delete
        map<string,E2_Question__c> questionToUpsert = new map<string,E2_Question__c>();
        List<E2_Question__c> questionToDelete = new List<E2_Question__c>();
        map<string,List<E2_Answer__c>> answerToUpsert = new map<string,List<E2_Answer__c>>();
        List<E2_Answer__c> answerToDelete = new List<E2_Answer__c>();
        map<E2_Answer__c, string> answerScopeMap = new map<E2_Answer__c, string>();
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
                    if(answerToUpsert.containsKey(mapKey)) {
                    	for(E2_Answer__c e2Answer : answerToUpsert.get(mapKey)) {
	                        if(e2Answer.Id == NULL) {
	                            e2Answer.Question__c = question.Id; 
	                        }                       
	                        e2Answers.add(e2Answer);
	                    }
                    }                    
                }
                upsert e2Answers;
                set<Id> answersId = new set<Id>();
                list<E2_Action_Scope__c> answerScopes = new list<E2_Action_Scope__c>();
                for(E2_Answer__c answer : answerScopeMap.keySet()) {
                	if(answer.Id != NULL) {
                		answersId.add(answer.Id);
                		string actionsScopes =  answerScopeMap.get(answer);
                		if(!string.isBlank(actionsScopes)) {
                		for(String scopeId : actionsScopes.split(E2_Constants.COMMA)) {
                			answerScopes.add(new E2_Action_Scope__c(Answer__c = answer.Id,
                									Scope__c = scopeId,
                									Unique_Key__c = answer.Id+scopeId));
                		}
                		}
                	}
                }
                if(!answersId.isEmpty()) { 
                	list<E2_Action_Scope__c> relatedScopes = E2_DataUtil.getRelatedScopes(answersId);
                	if(!relatedScopes.isEmpty())
                		delete relatedScopes;
                }
                if(!answerScopes.isEmpty())
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
    
    // Method to get answer and question to insert, update and delete
    public void updateQuestionUpsertList(map<string,E2_Question__c> questionToUpsert,
                                            map<string,List<E2_Answer__c>> answerToUpsert,
                                            List<E2_Answer__c> answerToDelete,
                                            map<E2_Answer__c,string> answerScopeMap,
                                            Question question, string mapKey) {
        questionToUpsert.put(mapKey, question.e2question);
        for(Answer answer : question.e2answers) {                       
            if(!answer.isDeleted) {
                if(question.selectedAnswer != NULL) {
                	if(question.selectedAnswer.indexOf(answer.key) != -1) {
	                	answer.e2answer.Is_Selected__c = true;
	                } else {
	                	answer.e2answer.Is_Selected__c = false;
	                }
	                if(answer.e2answer.Is_Selected__c != answer.isSelected 
	                	&& answer.e2answer.Is_Selected__c) {
	                	if(answer.e2answer.Action__c == 'Change Complexity to Low') {
	                		this.changecomplexty = 'Low';
	                	}else if(answer.e2answer.Action__c =='Change Complexity to Medium') {
	                		this.changecomplexty = 'Medium';
	                	}else if(answer.e2answer.Action__c =='Change Complexity to High') {
	                		this.changecomplexty = 'High';
	                	}else if(answer.e2answer.Action__c =='Activate child scope' 
	                		&& !string.isBlank(answer.bindedScopes)) {
	                		for(string scopeid : answer.bindedScopes.split(E2_Constants.COMMA)) {
	                			this.scopeToActivate += (!string.isBlank(this.scopeToActivate) ? E2_Constants.COMMA : E2_Constants.BLANK) +
	                							  scopeid;
	                		}
	                	}else if(answer.e2answer.Action__c =='Deactivate child scope' 
	                		&& !string.isBlank(answer.bindedScopes)) {
	                		for(string scopeid : answer.bindedScopes.split(E2_Constants.COMMA)) {
	                			this.scopeToDeactivate += (!string.isBlank(this.scopeToDeactivate) ? E2_Constants.COMMA : E2_Constants.BLANK) +
	                							  scopeid;
	                		}
	                	}
	                }
                }
                if(answer.e2answer.Action__c =='Activate child scope' || 
                   answer.e2answer.Action__c =='Deactivate child scope') {
	                  if(!string.isBlank(answer.bindedScopes) && 
	                  (string.isBlank(answer.originalBindedScopes) || 
	                  answer.originalBindedScopes != answer.bindedScopes)) {
	                  answerScopeMap.put(answer.e2answer, answer.bindedScopes);
	                }
                } else if(!string.isBlank(answer.originalBindedScopes)) {
                  answerScopeMap.put(answer.e2answer, E2_Constants.BLANK);
                }
                if((answer.answerstring != NULL && 
                   answer.answerstring != '') || question.e2question.Type__c == 'Summary') {
                	answer.e2answer.Answer_Text__c = answer.answerstring;
                	if(!answerToUpsert.containsKey(mapKey)) {
		            	answerToUpsert.put(mapKey, new List<E2_Answer__c>());
		            }
		            answerToUpsert.get(mapKey).add(answer.e2answer);
                }
            }else if(answer.e2answer.Id != NULL) {
                answerToDelete.add(answer.e2answer);
            }
        }
        if(question.e2question.Id == NULL && question.e2answers.isEmpty()) {
            answerToUpsert.put(mapKey, new List<E2_Answer__c>());
            answerToUpsert.get(mapKey).add(new E2_Answer__c(Is_Active__c = true));
        }
    }
    
    // Method to retrieve question 
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
        		answer.bindedActionScopes.add(actionScopes);
        		if(answer.bindedScopes.length() >=15) {
        			answer.bindedScopes = answer.bindedScopes+E2_Constants.COMMA+actionScopes.Scope__c;
        		}else {
        			answer.bindedScopes = actionScopes.Scope__c;
        		}
        		answer.originalBindedScopes = answer.bindedScopes;
        	}
        }        
    }
    
    // Method to add new question
    public pagereference addNewQuestion() {
    	if(this.listQuestions.isEmpty())
        	this.listQuestions.add(new Question(new E2_Question__c(Scope__c = scope.Id, Is_Active__c = true)));
        else
        	this.listQuestions.add(0,new Question(new E2_Question__c(Scope__c = scope.Id, Is_Active__c = true)));
        return null;
    }
    
    // wrapper class for question
    public class Question {
        public boolean isDeleted{get;set;}
        public boolean isCloned{get;set;}
        public boolean isEdit{get;set;}
        public String key{get;set;}
        public string qType{get;set;}
        public E2_Question__c e2question{get;set;}
        public list<Answer> e2answers{get;set;}
        public string selectedAnswer{get;set;}
        public integer sequence{get;set;}
        public Question (E2_Question__c e2question) {
          getQuestionAndAnswer(e2question);                  
        }
        // method to add answer
        public pagereference addAnswer() {
        	this.isEdit = true;        	           
            if(e2question.Type__c != 'Summary' && this.e2answers.size() == 0) {
                for(integer index = 1;index <= 2;index++) {
                    E2_Answer__c answer = new E2_Answer__c(Is_Active__c = true,Sequence__c = index);
                    this.e2answers.add(new Answer(answer));
                }
                this.sequence = 2;
            }else if(e2question.Type__c == 'Summary') {
            	for(Answer answer : this.e2answers) {
            		answer.isDeleted = true;
            	}
            	E2_Answer__c answer = new E2_Answer__c(Is_Active__c = true,Sequence__c = 1);
                this.e2answers.add(new Answer(answer));
            } else if(qType == 'Summary' && e2question.Type__c != 'Summary' && this.e2answers.size() > 0) {
            	for(Answer answer : this.e2answers) {
            		answer.isDeleted = true;
            	}
            }
            qType = e2question.Type__c;
            return null;
        }
        // method to add new answer instance in answer 
        public pagereference addNewAnswerInstance() {
        	this.sequence = this.sequence + 1;
        	E2_Answer__c answer = new E2_Answer__c(Is_Active__c = true,Sequence__c = this.sequence);
            this.e2answers.add(new Answer(answer));
            this.isEdit = true;
        	return null;
        } 
        // method to remove 
        public pagereference remove(){
            this.isDeleted = true;
            return null;            
        }
        
        public pagereference markEdit() {
        	this.isEdit = true;
        	return null;
        }
        
        public pagereference removeEditMode() {
          E2_Question__c e2questiontemp = E2_DataUtil.getE2Questions(e2question.Id);
        	this.isEdit = false;
        	getQuestionAndAnswer(e2questiontemp);
        	mapAnswerWithQuestion();
        	return null;
        } 
        
        private void getQuestionAndAnswer(E2_Question__c e2question){
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
            this.qType = e2question.Type__c;
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
        
        private void mapAnswerWithQuestion(){
		      map<Id,Answer> answermap = new map<Id,Answer>();
		      for(Answer answer : e2answers) {
		        answermap.put(answer.e2answer.Id, answer);
		      }
		          
		      if(!answermap.isEmpty()) {
		          for(E2_Action_Scope__c actionScopes : E2_DataUtil.getRelatedScopes(answermap.KeySet())) {
		            Answer answer = answermap.get(actionScopes.Answer__c);
		            answer.bindedActionScopes.add(actionScopes);
		            if(answer.bindedScopes.length() >=15) {
		              answer.bindedScopes = answer.bindedScopes+E2_Constants.COMMA+actionScopes.Scope__c;
		            }else {
		              answer.bindedScopes = actionScopes.Scope__c;
		            }
		            answer.originalBindedScopes = answer.bindedScopes;
		          }
           }
        }
    }
    
    
    // wrapper class for Answer
    public class Answer {
        public boolean isDeleted{get;set;}
        public boolean isCloned{get;set;}
        public boolean isEdit{get;set;}
        public String key{get;set;}
        public boolean isSelected{get;set;}
        public list<E2_Action_Scope__c> bindedActionScopes{get;set;}
        public string bindedScopes{get;set;}
        public string originalBindedScopes{get;set;}
        public E2_Answer__c e2answer{get;set;}
        public string answerString{get;set;}
        
        public Answer (E2_Answer__c e2answer) {
            this.isDeleted = false;   
            this.isCloned = false;
            this.isEdit = false;
            this.bindedScopes = E2_constants.BLANK;
            this.originalBindedScopes = E2_constants.BLANK;
            this.bindedActionScopes = new list<E2_Action_Scope__c>();
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
            this.answerString = e2answer.Answer_Text__c;
        }
        // method to remove 
        public pagereference remove(){
            this.isDeleted = true;
            return null;            
        }
    }
}