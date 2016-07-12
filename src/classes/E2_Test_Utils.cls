/**=====================================================================
 * Appirio, Inc
 * Name: E2_Test_Utils
 * Description: Utility class for Test data
 * Created Date: May 2nd, 2016
 * Created By: Arpita Bose (Appirio)
 * 
 * Date Modified      Modified By                  Description of the update

*  =====================================================================*/
@isTest
public with sharing class E2_Test_Utils {
  
  //insert Account
  public static Account insertAccount(Boolean isInsert) {
    Account defaultAccount = new Account();
    defaultAccount.Name = 'Test Account'+randomNumber();
    if(isInsert) {
      insert(defaultAccount);
    }
    return defaultAccount;
  }
   
  //insert Contact
  public static Contact insertContact(Id accountId, Boolean isInsert){
    Contact contact = new Contact(MailingCountry='USA',MailingState='TX',MailingCity='Dallas',
                                  FirstName='firstname'+randomNumber(),Salutation='Mr.',LastName='test'+randomNumber(),
                                  email='test@'+randomNumber()+'test.com' , AccountId = accountId);
    if(isInsert) {                                  
      insert(contact);
    }
    return contact;
  }
  
  //insert Opportunity
   public static Opportunity insertOpportunity(Id accountId, Boolean isInsert){
    Opportunity opportunity = new Opportunity(Name = 'Test Opportunity', CloseDate = date.today().addDays(2),    
                                                StageName = 'Prospecting', AccountId = accountId,    
                                                CurrencyIsoCode = 'USD', Description ='Test description'); 
    if(isInsert) {                                  
      insert(opportunity);
    }
    return opportunity;
  }
  
  //insert User
  public static User insertUser(String profileName, Boolean isInsert){

    User testUser = new User();
    Profile p = [SELECT id from profile where name =: profileName ];

    testUser = new User(alias = 'testUser', email='standarduser' + randomNumber()  + '@testorg.com',
                             emailencodingkey='UTF-8', firstName='test user', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles',
                             username='teststandarduser' + randomNumber() + '@testorg.com', IsActive=true,
                             CompanyName = 'test Company');
    
    if(isInsert) {                                  
      insert(testUser);
    }
    return testUser;
  }
  
  
  public static User insertSysAdminUser(boolean isInsert){
    
    User testUser = insertUser(E2_Constants.PROFILE_SYS_ADMIN, isInsert);
    
    return testUser;
  }
  
  
  //insert presales Request
  public static Presales_Request__c insertPresalesReq(Id opptyId, String psrtype, Boolean isInsert){
    Presales_Request__c psr = new Presales_Request__c(Name='Test Presales'+randomNumber(), Type__c = psrtype,
                                      Focus_Area__c = 'SFDC Sales Cloud',Status__c='In Progress', Due_Date__c = date.today().addDays(5),
                                      Date_Initial_LOE_Anticipated_By__c = date.today().addDays(10), 
                                      Description__c = 'Test description', Opportunity__c = opptyId);
    
    if(isInsert) {                                  
      insert(psr);
    }
    return psr;
  }
  
  //insert E2 estimates
  public static CMC_Presales_LOE__c insertEstimate(Id presalesReqId, Boolean isInsert){
    CMC_Presales_LOE__c psrloe = new CMC_Presales_LOE__c(Name= 'Test Presales LOE', 
                                     Presales_Request__c = presalesReqId,
                                     CurrencyIsoCode = E2_Constants.CURRENCY_ISO_CODE_USD,
                                     Description__c = null,
                                     E2_AE__c = null,
                                     E2_Date_Scoped__c = null,
                                     E2_Reviewer__c = null,
                                     E2_Derived_Effort_Template__c = null,
                                     //E2_Total_Hrs__c = null, //RollUP: Not writable fields
                                     E2_Is_Primary__c = false,
                                     E2_Last_Build_Datetime__c = null,
                                     E2_SA__c = null,
                                     //E2_Total_Architect_Hrs__c = null,//RollUP: Not writable fields
                                     //E2_Total_Build_Hrs__c = null,
                                     //E2_Total_Deploy_Thrive_Hrs__c = null,//RollUP: Not writable fields
                                     //E2_Total_Plan_Hrs__c = null,//RollUP: Not writable fields
                                     //E2_Total_Strategy_Hrs__c = null,//RollUP: Not writable fields
                                     //E2_Total_Test_Hrs__c = null,//RollUP: Not writable fields
                                     E2_Version_Notes__c = null);
    
    if(isInsert) {                                  
      insert(psrloe);
    }
    return psrloe;
  }
  
  //insert E2 Scopes
  public static E2_Scope__c insertScope(Boolean isInsert){
    E2_Scope__c scope = new E2_Scope__c(Name ='Test Scope'
                                 , Is_Active__c = true
                                 , E2_Assumption__c = 'test assumption'
                                 , Complexity__c = 'Medium'
                                 , Description__c = 'desc'
                                 //, Direct_High_Hrs__c // ROLL UP
                                 //, Direct_Low_Hrs__c // ROLL UP
                                 //, Direct_Medium_Hrs__c// ROLL UP
                                 , Presales_LOE__c = null
                                 , Is_Favourite__c = false
                                 //, LOE_Hrs__c = //calculated from workflow 
                                 , Parent_Scope__c = null
                                 , Scope_Group__c = null
                                 , Scope_Item_Type__c = 'Component'
                                 , Source_Scope__c = null
                                 , Ultimate_Parent_Scope__c = null
                                 );
    
    if(isInsert) {                                  
      insert(scope);
    }
    return scope;
  }
  
  //insert E2 Scope Group
  public static E2_Scope_Group__c insertScopeGroup(Boolean isInsert){
    E2_Scope_Group__c scGrp = new E2_Scope_Group__c(Name = 'Test Scope Group');
    
    if(isInsert) {                                  
      insert(scGrp);
    }
    return scGrp;
  }
  
  //insert E2 Efforts
  public static E2_Effort__c insertEffort(Boolean isInsert, Id scopeId){
    E2_Effort__c effort = new E2_Effort__c(Name = 'Test Effort'
     , Scope__c = scopeId
     , Is_Active__c = true
     , Effort_Hrs__c = 40
     , Phase__c = 'Build'
     , Resource_Role__c = 'Project Manager'
     , Complexity_Factor_High__c = 10
     , Complexity_Factor_Low__c = 10
     , Source_Effort__c = null
     , Speciality__c = null
     );
    
    if(isInsert) {                                  
      insert(effort);
    }
    return effort;
  }
  
   //insert E2 Derived Effort Group
  public static E2_Derived_Effort_Group__c insertDerivedEffort(Boolean isInsert){
    E2_Derived_Effort_Group__c derivedEffGrp = new E2_Derived_Effort_Group__c(Name = 'Central SFDC Traditional Test', Description__c = 'Test Data');
    
    if(isInsert) {                                  
      insert(derivedEffGrp);
    }
    return derivedEffGrp;
  }
   
  //insert E2 Derived Effort
  public static E2_Derived_Effort__c insertDerivedEffort(String role,
                                    String phase, string ofrole, string ofphase,
                                    Id recordType, 
                                    Id effortGrpId, Boolean isInsert){
    E2_Derived_Effort__c derivedEffort = new E2_Derived_Effort__c(
                                                Is_Active__c = true
                                                , Of_Role__c = ofrole
                                                , Of_Phase__c = ofphase
                                                , To_Phase__c = phase
                                                , Allocation__c = 20
                                                , Role__c = role
                                                , Derived_Effort_Group__c = effortGrpId
                                                , RecordTypeId = recordType
                                                , Include_When__c = 'always'
                                                , Include_When_Hours__c = 0);
    derivedEffort.UniqueKey__c = derivedEffort.Name + E2_Constants.SEPARATOR + (!String.isBlank(derivedEffort.Of_Role__c) ? derivedEffort.Of_Role__c : '') +
                            E2_Constants.SEPARATOR + (!String.isBlank(derivedEffort.Of_Phase__c) ? derivedEffort.Of_Phase__c : '') +
                            E2_Constants.SEPARATOR + derivedEffort.Role__c + E2_Constants.SEPARATOR + derivedEffort.Allocation__c + 
                            E2_Constants.SEPARATOR + derivedEffort.To_Phase__c + E2_Constants.SEPARATOR + E2_Constants.SEPARATOR + 
                            derivedEffort.Is_Active__c;
    if(isInsert) {                                  
      insert(derivedEffort);
    }
    return derivedEffort;
  }
  
  
  
  // util method to get random number
  public static double randomNumber() {
    return Math.random();
  }

}