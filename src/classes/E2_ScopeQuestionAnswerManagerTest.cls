@isTest(seeAllData=false)
public class E2_ScopeQuestionAnswerManagerTest {
    public static E2_Scope__c scope;
    public static CMC_Presales_LOE__c estimate;
    public static Id recTypeId1 = E2_RecordTypeClass.getId('E2_Scope__c', E2_Constants.SCOPE_RT_SCOPE);
  
	public static testmethod void questionAnswerTest() {
        scope = [SELECT Id, LastModifiedById FROM E2_Scope__c];
        estimate = [SELECT Id FROM CMC_Presales_LOE__c];
        User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
        System.runAs(sysAdmin){
        E2_Scope__c scope1 =  E2_Test_Utils.insertScope(false);
        scope1.recordTypeId = recTypeId1;
        scope1.Parent_Scope__c = scope.id;
        scope1.Presales_LOE__c = estimate.id;
        insert scope1;   
        //start test
        Test.startTest();
        E2_ScopeQuestionAnswerManager scopeQuestionManager = new E2_ScopeQuestionAnswerManager();
        scopeQuestionManager.scope = scope;
        scopeQuestionManager.addNewQuestion();
        E2_ScopeQuestionAnswerManager.Question question1 = scopeQuestionManager.listQuestions[0];
        question1.e2question.Question_Text__c = 'Test question1';
        question1.e2question.Type__c = 'Summary';
        question1.addAnswer();
        question1.e2answers.clear();
        scopeQuestionManager.addNewQuestion();
        E2_ScopeQuestionAnswerManager.Question question2 = scopeQuestionManager.listQuestions[0];
        question2.e2question.Question_Text__c = 'Test question2';
        question2.e2question.Type__c = 'Single-select';
        question2.addAnswer();
        question2.addNewAnswerInstance();
        question2.addNewAnswerInstance();
        question2.addNewAnswerInstance();
        system.assertEquals(question2.e2answers.size(), 5, '5 new answers instance hass been added');
        
        question2.e2answers[0].answerString = 'Change Complexity to Low';
        question2.e2answers[0].e2answer.Action__c = 'Change Complexity to Low';
        
        question2.e2answers[1].answerString = 'Change Complexity to Medium';
        question2.e2answers[1].e2answer.Action__c = 'Change Complexity to Medium';
        
        question2.e2answers[2].answerString = 'Change Complexity to High';
        question2.e2answers[2].e2answer.Action__c = 'Change Complexity to High';
        
        
        question2.e2answers[3].answerString = 'Deactivate child scope';
        question2.e2answers[3].e2answer.Action__c = 'Deactivate child scope';
        question2.e2answers[3].bindedScopes = scope1.Id+','+scope.Id;
        
        question2.e2answers[4].answerString = 'Activate child scope';
        question2.e2answers[4].e2answer.Action__c = 'Activate child scope';
        question2.e2answers[4].bindedScopes = scope1.Id;
        question2.e2answers[4].e2answer.Is_Selected__c = true;
        question2.selectedAnswer = question2.e2answers[4].key;
        
        string errorMessage = '';
        string dmlOperationMessage = '';
        scopeQuestionManager.saveQuestion(errorMessage, dmlOperationMessage);
        system.assertEquals(errorMessage, '', 'New question has been successfully inserted');
        system.assertEquals(scopeQuestionManager.listQuestions.size(), 2, '2 new questions has been inserted');
        
        scopeQuestionManager.addNewQuestion();
        E2_ScopeQuestionAnswerManager.Question question3 = scopeQuestionManager.listQuestions[0];
        question3.e2question.Question_Text__c = 'Test question2';
        question3.addNewAnswerInstance();
        question3.e2question.Type__c = 'Summary';
        question3.addAnswer();
        question3.markEdit();
        question3.remove();
        integer index = 2;
        if(scopeQuestionManager.listQuestions[1].e2question.Type__c == 'Summary') {
            question1 = scopeQuestionManager.listQuestions[1];
        } else {
            question1 = scopeQuestionManager.listQuestions[2];
            index = 1;
        }
        question1.e2question.Question_Text__c = 'Test question3';
        question1.e2question.Type__c = 'Multi-select';
        question1.addAnswer();
        question1.addNewAnswerInstance();
        question1.addNewAnswerInstance();
        system.assertEquals(question1.e2answers.size(), 3, '2 new answer instance added');
        question1.e2answers[1].answerString = 'Change Complexity to Low';
        question1.e2answers[1].e2answer.Action__c = 'Change Complexity to Low';
            
        question1.e2answers[2].answerString = 'Change Complexity to Medium';
        question1.e2answers[2].e2answer.Action__c = 'Change Complexity to Medium';
        question1.selectedAnswer = question2.e2answers[1].key + ',' + question2.e2answers[2].key;
        
        question2 = scopeQuestionManager.listQuestions[index];
        question2.removeEditMode();
         question2.e2answers[2].remove();
        question2.e2answers[3].e2answer.Is_Selected__c = true;
        question2.selectedAnswer = question2.e2answers[3].key;
        question2.e2answers[4].e2answer.Action__c = '';
        
        scopeQuestionManager.saveQuestion(errorMessage, dmlOperationMessage);
        system.assertEquals(errorMessage, '', 'New question has been successfully inserted');
        system.assertEquals(scopeQuestionManager.listQuestions.size(), 2, '2 new questions has been updated');
        
        question3 = scopeQuestionManager.listQuestions[0];
        question3.remove();
        scopeQuestionManager.saveQuestion(errorMessage, dmlOperationMessage);
        system.assertEquals(errorMessage, '', 'New question has been successfully inserted');
        system.assertEquals(scopeQuestionManager.listQuestions.size(), 1, '1 questions has been deleted');
        // stop test
        Test.stopTest();
        }
	}
	
	//create test data
  @testSetup static void createTestData(){
    
    User solArchitect, accExecutive, delReviewer; 
    Account acc;
    Opportunity opp;
    Presales_Request__c psr;
    E2_Scope__c scope1; 
      
    acc = E2_Test_Utils.insertAccount(true);
    opp = E2_Test_Utils.insertOpportunity(acc.Id, true);
    
    solArchitect = E2_Test_Utils.insertSysAdminUser(false);
    solArchitect.firstName = 'Test SA';
    insert solArchitect;
    
    accExecutive = E2_Test_Utils.insertSysAdminUser(false);
    accExecutive.firstName = 'Test AE';
    insert accExecutive;
    
    delReviewer = E2_Test_Utils.insertSysAdminUser(false);
    delReviewer.firstName = 'Test Reviewer';
    insert delReviewer;
    
    psr = E2_Test_Utils.insertPresalesReq(opp.Id, 'Demo', false);
    insert psr;
    
    CMC_Presales_LOE__c estimate1 = E2_Test_Utils.insertEstimate(psr.id, false);  
    insert estimate1;
      
    scope1 =  E2_Test_Utils.insertScope(false);
    scope1.recordTypeId = recTypeId1;
    scope1.Presales_LOE__c = estimate1.id;  
    insert scope1;
    
  }

}