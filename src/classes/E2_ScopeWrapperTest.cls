@isTest(seeAllData=false)
public class E2_ScopeWrapperTest {
    public static E2_Scope__c scope;
    public static CMC_Presales_LOE__c estimate;
    public static List<E2_Effort__c> effortLst;  
    public static Id recTypeId = E2_RecordTypeClass.getId('E2_Scope__c', E2_Constants.SCOPE_RT_SCOPE);
    
   static testmethod void testcase1(){
        Presales_Request__c psr;
        estimate = [SELECT Id FROM CMC_Presales_LOE__c]; 
        scope = [SELECT ID FROM E2_SCOPE__C];      
       
        User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
        psr =  [SELECT Id, Description__c, Name,Account_Name__c, Opportunity__r.Account.Id,Opportunity__c FROM Presales_Request__c];
        
        System.runAs(sysAdmin){
            //start test
            Test.startTest();
            
            E2_ScopeWrapper scope_wrap = new E2_ScopeWrapper();
            
            E2_ScopeWrapper scope_wrap1 = new E2_ScopeWrapper([Select Id, Scope_Group__c, Parent_Scope__c, Name, Scope_Item_Type__c, Presales_LOE__c, Description__c, 
			    		 Is_Favourite__c, LOE_Hrs__c, Complexity__c, E2_Assumption__c, Is_Active__c, LastViewedDate, Scope_Group__r.Name
						   From E2_Scope__c e 
               where e.id = : scope.Id][0]);
            
            E2_Scope_Group__c scopeGroup = E2_Test_Utils.insertScopeGroup(false);
            scopeGroup.Name = 'NEW NAME';
            insert scopeGroup;
            
            E2_Scope__c scope0 =  E2_Test_Utils.insertScope(false);
            scope0.recordTypeId = recTypeId;
            scope0.Presales_LOE__c = estimate.id;  
            scope0.Scope_Group__c = scopeGroup.id;
            insert scope0;
            
            E2_ScopeWrapper scope1 = new E2_ScopeWrapper([Select Id, Scope_Group__c, Parent_Scope__c, Name, Scope_Item_Type__c, Presales_LOE__c, Description__c, 
			    		 Is_Favourite__c, LOE_Hrs__c, Complexity__c, E2_Assumption__c, Is_Active__c, LastViewedDate, Scope_Group__r.Name
						   From E2_Scope__c e 
               where e.id = : scope0.Id][0]);
            
            scope_wrap1.compareTo(scope1);
            
            E2_ScopeWrapper.sortBy = E2_ScopeWrapper.SORT_BY.ByComplexity;
            scope_wrap1.compareTo(scope1);
            system.assertEquals(0, scope_wrap1.compareTo(scope1));
            
            E2_ScopeWrapper.sortBy = E2_ScopeWrapper.SORT_BY.ByGroup;
            scope_wrap1.compareTo(scope1);
            system.assertEquals(6, scope_wrap1.compareTo(scope1));
            
            E2_ScopeWrapper.sortBy = E2_ScopeWrapper.SORT_BY.ByEfforts;
            scope_wrap1.compareTo(scope1);
            system.assertEquals(0, scope_wrap1.compareTo(scope1));
            
            E2_ScopeWrapper.sortBy = E2_ScopeWrapper.SORT_BY.ByLastView;
            scope_wrap1.compareTo(scope1);
            system.assertEquals(0, scope_wrap1.compareTo(scope1));
            
            E2_ScopeWrapper.sortBy = E2_ScopeWrapper.SORT_BY.ByLastView;
            scope_wrap1.compareTo(scope1); 
            system.assertEquals(0, scope_wrap1.compareTo(scope1));          
            
            E2_ScopeWrapper.sortBy = E2_ScopeWrapper.SORT_BY.ByScopeName;
            E2_ScopeWrapper.sortOreder = E2_ScopeWrapper.SORT_ORDER.ByDESC;
            scope_wrap1.compareTo(scope1);
            system.assertEquals(0, scope_wrap1.compareTo(scope1));
            
            E2_ScopeWrapper.sortBy = E2_ScopeWrapper.SORT_BY.ByComplexity;
            E2_ScopeWrapper.sortOreder = E2_ScopeWrapper.SORT_ORDER.ByDESC;
            scope_wrap1.compareTo(scope1);
            system.assertEquals(0, scope_wrap1.compareTo(scope1));
            
            E2_ScopeWrapper.sortBy = E2_ScopeWrapper.SORT_BY.ByGroup;
            E2_ScopeWrapper.sortOreder = E2_ScopeWrapper.SORT_ORDER.ByDESC;
            scope_wrap1.compareTo(scope1);
            system.assertEquals(-6, scope_wrap1.compareTo(scope1));
            
            E2_ScopeWrapper.sortBy = E2_ScopeWrapper.SORT_BY.ByEfforts;
            E2_ScopeWrapper.sortOreder = E2_ScopeWrapper.SORT_ORDER.ByDESC;
            scope_wrap1.compareTo(scope1);
            system.assertEquals(0, scope_wrap1.compareTo(scope1));
            
            E2_ScopeWrapper.sortBy = E2_ScopeWrapper.SORT_BY.ByLastView;
            E2_ScopeWrapper.sortOreder = E2_ScopeWrapper.SORT_ORDER.ByDESC;
            scope_wrap1.compareTo(scope1);
            system.assertEquals(0, scope_wrap1.compareTo(scope1));
            
            E2_ScopeWrapper.sortBy = E2_ScopeWrapper.SORT_BY.ByLastView;
            E2_ScopeWrapper.sortOreder = E2_ScopeWrapper.SORT_ORDER.ByDESC;
            scope_wrap1.compareTo(scope1);
            system.assertEquals(0, scope_wrap1.compareTo(scope1));
            
            E2_ScopeWrapper.sortBy = E2_ScopeWrapper.SORT_BY.ByGroup;
            E2_ScopeWrapper.sortOreder = E2_ScopeWrapper.SORT_ORDER.ByDESC;
            scope_wrap1.scope.Scope_Group__c = null;
            scope_wrap1.compareTo(scope1);
            system.assertEquals(-1, scope_wrap1.compareTo(scope1));
            
            scope_wrap1.scope.Scope_Group__c = scopeGroup.id;
            E2_ScopeWrapper.sortBy = E2_ScopeWrapper.SORT_BY.ByGroup;
            E2_ScopeWrapper.sortOreder = E2_ScopeWrapper.SORT_ORDER.ByDESC;
            scope1.scope.Scope_Group__c = null;
            scope_wrap1.compareTo(scope1);
            system.assertEquals(1, scope_wrap1.compareTo(scope1));
            
            
            
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
    Id recTypeId1 = E2_RecordTypeClass.getId(E2_Constants.E2_SCOPE_API_NAME, E2_Constants.SCOPE_RT_SCOPE);
    
    CMC_Presales_LOE__c estimate1 = E2_Test_Utils.insertEstimate(psr.id, false);  
    insert estimate1;
    
    E2_Scope_Group__c scopeGroup = E2_Test_Utils.insertScopeGroup(true);  
      
    scope1 =  E2_Test_Utils.insertScope(false);
    scope1.recordTypeId = recTypeId1;
    scope1.Presales_LOE__c = estimate1.id;  
    scope1.Scope_Group__c = scopeGroup.id;
    insert scope1;
  }
}