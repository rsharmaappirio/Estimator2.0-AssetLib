/**=====================================================================
 * Appirio, Inc
 * Name: E2_ScopeWrapper
 * Description: Wrapper class of Scope used in ScopeTemplateSearch page
 * Created Date: Apr 8th, 2016
 * Created By: Arpita Bose (Appirio)
 * 
 * Date Modified      Modified By                  Description of the update
 * Dec 15, 2016       Jitendra Jangid              S-456645: Search on child scopes on scope library. [- Updated existing test method to increase test coverage corresponding to this story.]
 *                               
*  =====================================================================*/

@isTest(seeAllData=false)
public class E2_ScopeWrapperTest {
    public static E2_Scope__c scope;
    public static CMC_Presales_LOE__c estimate;
    public static List<E2_Effort__c> effortLst;  
    public static Id scopeRecTypeId = E2_RecordTypeClass.getId('E2_Scope__c', E2_Constants.SCOPE_RT_SCOPE);
    public static Id templateRecTypeId = E2_RecordTypeClass.getId('E2_Scope__c', E2_Constants.SCOPE_RT_TEMPLATE);
    
   static testmethod void testcase1(){
        Presales_Request__c psr;
        estimate = [SELECT Id FROM CMC_Presales_LOE__c]; 
        scope = [SELECT ID FROM E2_SCOPE__C where recordTypeId = :scopeRecTypeId and Parent_Scope__c = null];      
       
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
               
             //Start: S-456645 [to cover overloaded constructor]
             E2_ScopeWrapper favScope_wrap = new E2_ScopeWrapper([Select Id, Scope_Group__c, Parent_Scope__c, Name, Scope_Item_Type__c, Presales_LOE__c, Description__c, 
			    		 Is_Favourite__c, LOE_Hrs__c, Complexity__c, E2_Assumption__c, Is_Active__c, LastViewedDate, Scope_Group__r.Name
						   From E2_Scope__c e where e.id = : scope.Id][0],true);   
             //End: S-456645  
            
            E2_Scope_Group__c scopeGroup = E2_Test_Utils.insertScopeGroup(false);
            scopeGroup.Name = 'NEW NAME';
            insert scopeGroup;
            
            E2_Scope__c scope0 =  E2_Test_Utils.insertScope(false);
            scope0.recordTypeId = scopeRecTypeId;
            scope0.Presales_LOE__c = estimate.id;  
            insert scope0;
            
            E2_ScopeWrapper scope1 = new E2_ScopeWrapper([Select Id, Scope_Group__c, Parent_Scope__c, Name, Scope_Item_Type__c, Presales_LOE__c, Description__c, 
			    		 Is_Favourite__c, LOE_Hrs__c, Complexity__c, E2_Assumption__c, Is_Active__c, LastViewedDate, Scope_Group__r.Name
						   From E2_Scope__c e 
               where e.id = : scope0.Id][0]);
            
            scope_wrap1.compareTo(scope1);
            
            E2_ScopeWrapper.sortBy = E2_ScopeWrapper.SORT_BY.ByComplexity;
            scope_wrap1.compareTo(scope1);
            system.assertEquals(0, scope_wrap1.compareTo(scope1));
            
            // E2_ScopeWrapper.sortBy = E2_ScopeWrapper.SORT_BY.ByGroup;
            // scope_wrap1.compareTo(scope1);
            // system.assertEquals(-1, scope_wrap1.compareTo(scope1));
            
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
            system.assertEquals(-1, scope_wrap1.compareTo(scope1));
            
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
            
            Test.stopTest();
        }    
  } 
  
//   public static testMethod void testSortByParentScopeCondition(){
//       User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
//       Presales_Request__c  psr =  [SELECT Id, Description__c, Name,Account_Name__c, Opportunity__r.Account.Id,Opportunity__c FROM Presales_Request__c];
          
//         System.runAs(sysAdmin){
            
//             Test.startTest();
//                 List<E2_Scope__c> lsChildScope=[SELECT ID,Parent_Scope__c,Name,Scope_Group__c,Presales_LOE__c,Parent_Scope__r.Name  FROM E2_SCOPE__C where recordTypeId = :scopeRecTypeId and Parent_Scope__c != null];
//                 E2_Scope__c parentScope=[SELECT ID,Parent_Scope__c,Name,Scope_Group__c,Presales_LOE__c,Parent_Scope__r.Name FROM E2_SCOPE__C where recordTypeId = :scopeRecTypeId and Parent_Scope__c = null];
//                 E2_ScopeWrapper swChild_1 = new E2_ScopeWrapper(lsChildScope.get(0));
//                 E2_ScopeWrapper swChild_2 = new E2_ScopeWrapper(lsChildScope.get(1));
//                 E2_ScopeWrapper swParentScope = new E2_ScopeWrapper(parentScope);
                
//                 //To cover: if(sortOreder==SORT_ORDER.ByASC) :: False part
//                 E2_ScopeWrapper.sortBy = E2_ScopeWrapper.SORT_BY.ByParentScope;
//                 E2_ScopeWrapper.sortOreder = E2_ScopeWrapper.SORT_ORDER.ByDESC;
//                 system.assertEquals(0, swChild_1.compareTo(swChild_2));
                
//                 //To cover: if(sortOreder==SORT_ORDER.ByASC) :: True part
//                 E2_ScopeWrapper.sortOreder = E2_ScopeWrapper.SORT_ORDER.ByASC;
//                 system.assertEquals(0, swChild_1.compareTo(swChild_2));
                
//                 //To cover: if(scope.Parent_Scope__c == null) {
//                 system.assertEquals(1, swParentScope.compareTo(swChild_2));
                
//                 //To cover: else if(((E2_ScopeWrapper)objToCompare).scope.Parent_Scope__c == null) {
//                 system.assertEquals(1, swChild_2.compareTo(swParentScope));
                
                
            
//             Test.stopTest();
//         }    
            
//   }
  
  
  public static testMethod void testSortByGroupCondition(){
      User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
      Presales_Request__c  psr =  [SELECT Id, Description__c, Name,Account_Name__c, Opportunity__r.Account.Id,Opportunity__c FROM Presales_Request__c];
          
        System.runAs(sysAdmin){
            
            Test.startTest();
                List<E2_Scope__c> lsChildScope=[SELECT ID,Parent_Scope__c,Name,Scope_Group__c,Presales_LOE__c,Parent_Scope__r.Name  FROM E2_SCOPE__C where recordTypeId = :scopeRecTypeId and Parent_Scope__c != null];
                List<E2_Scope__c> lsGRPChildScope=[SELECT ID,Parent_Scope__c,Name,Scope_Group__c,Presales_LOE__c,Parent_Scope__r.Name,Scope_Group__r.name  FROM E2_SCOPE__C where recordTypeId = :templateRecTypeId and Parent_Scope__c != null];
                E2_Scope__c parentScope=[SELECT ID,Parent_Scope__c,Name,Scope_Group__c,Presales_LOE__c,Parent_Scope__r.Name,Scope_Group__r.name FROM E2_SCOPE__C where recordTypeId = :scopeRecTypeId and Parent_Scope__c = null];
                E2_Scope__c grpParentScope=[SELECT ID,Parent_Scope__c,Name,Scope_Group__c,Presales_LOE__c,Parent_Scope__r.Name,Scope_Group__r.name FROM E2_SCOPE__C where recordTypeId = :templateRecTypeId and Parent_Scope__c = null];
                
                E2_ScopeWrapper swGRPChild_1 = new E2_ScopeWrapper(lsGRPChildScope.get(0));
                E2_ScopeWrapper swGRPChild_2 = new E2_ScopeWrapper(lsGRPChildScope.get(1));
                E2_ScopeWrapper swParentScope = new E2_ScopeWrapper(parentScope);
                E2_ScopeWrapper swGroupParentScope=new E2_ScopeWrapper(grpParentScope);
                E2_ScopeWrapper swChild_1 = new E2_ScopeWrapper(lsChildScope.get(0));
                E2_ScopeWrapper swChild_2 = new E2_ScopeWrapper(lsChildScope.get(1));
                
                E2_ScopeWrapper.sortBy = E2_ScopeWrapper.SORT_BY.ByGroup;
                E2_ScopeWrapper.sortOreder = E2_ScopeWrapper.SORT_ORDER.ByDESC;
                
                //To cover:  if(scope.Scope_Group__c==null) {
                system.assertEquals(-1, swChild_1.compareTo(swGroupParentScope));
                
                //To cover: else if(((E2_ScopeWrapper)objToCompare).scope.Scope_Group__c==null) {
                system.assertEquals(1, swGroupParentScope.compareTo(swChild_1));
                
                //To cover: if(sortOreder==SORT_ORDER.ByASC) :: False part
                system.assertEquals(0, swGRPChild_1.compareTo(swGRPChild_2));
                
                //To cover: if(sortOreder==SORT_ORDER.ByASC) :: True part
                E2_ScopeWrapper.sortOreder = E2_ScopeWrapper.SORT_ORDER.ByASC;
                system.assertEquals(0, swGRPChild_1.compareTo(swGRPChild_2));
            
            Test.stopTest();
        }    
            
  }
    
    
      //create test data
  @testSetup static void createTestData(){  	
    User solArchitect, accExecutive, delReviewer; 
  	Account acc;
    Opportunity opp;
    Presales_Request__c psr;
    E2_Scope__c grpScope,parentScope,childScope1,childScope2, grpChild1,grpChild2; 
      
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
      
    grpScope =  E2_Test_Utils.insertScope(false);
    grpScope.recordTypeId = templateRecTypeId;
    grpScope.Scope_Group__c = scopeGroup.id;
    insert grpScope;
    
    grpChild1 =  E2_Test_Utils.insertScope(false);
    grpChild1.recordTypeId = templateRecTypeId;
    grpChild1.Scope_Group__c = scopeGroup.id;
    grpChild1.Parent_Scope__c=grpScope.Id;
    insert grpChild1;
    
    grpChild2 =  E2_Test_Utils.insertScope(false);
    grpChild2.recordTypeId = templateRecTypeId;
    grpChild2.Scope_Group__c = scopeGroup.id;
    grpChild2.Parent_Scope__c=grpScope.Id;
    insert grpChild2;
    
    
    
    parentScope =  E2_Test_Utils.insertScope(false);
    parentScope.recordTypeId = scopeRecTypeId;
    parentScope.Presales_LOE__c = estimate1.id;  
    insert parentScope;
    
    childScope1 =  E2_Test_Utils.insertScope(false);
    childScope1.recordTypeId = scopeRecTypeId;
    childScope1.Presales_LOE__c = estimate1.id;  
    childScope1.Parent_Scope__c=parentScope.Id;
    insert childScope1;
    
    childScope2 =  E2_Test_Utils.insertScope(false);
    childScope2.recordTypeId = scopeRecTypeId;
    childScope2.Presales_LOE__c = estimate1.id;  
    childScope2.Parent_Scope__c=parentScope.Id;
    insert childScope2;
    
  }
}