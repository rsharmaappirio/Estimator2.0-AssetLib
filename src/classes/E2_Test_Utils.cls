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
                                     E2_Version_Notes__c = null,
                                     Discount_Percent__c = 0);
    
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
  
  //insert CMC Asset record
  public static CMC_Asset__c insertAsset(String assetName, String shortDesc, String assetType, String assetSubtype, 
  																			String technologies, string servicePractice, decimal reuseLoe, Boolean isInsert){
  	CMC_Asset__c asset = new CMC_Asset__c(Name = assetName, Short_Description__c = shortDesc, Technologies__c = technologies,
  												Asset_Type__c = assetType, Asset_SubType__c = assetSubtype, 
  												Appirio_Services_Practice__c = servicePractice,	Reuse_LOE__c = reuseLoe);
  	if(isInsert) {                                  
      insert(asset);
    }
    return asset;
  }
  
  // insert E2 Recommended Asset record
  public static E2_Recommended_Asset__c insertRecommendedAsset(Id scopeId, Id assetId, Boolean isInsert){
  	E2_Recommended_Asset__c recommendedAsset = new E2_Recommended_Asset__c(Scope__c = scopeId, Asset__c = assetId);
  	if(isInsert) {                                  
      insert(recommendedAsset);
    }
    return recommendedAsset;
  }
  
  // insert E2 Question record
  public static E2_Question__c insertQuestions(Id scopeId, Boolean isInsert){
    E2_Question__c question = new E2_Question__c(Scope__c = scopeId, Is_Active__c = true);
    if(isInsert) {                                  
      insert(question);
    }
    return question; 
  }
  

  // insert E2 Answer record
  public static E2_Answer__c insertAnswer(Id questionId, Boolean isInsert){
    E2_Answer__c answer = new E2_Answer__c(Question__c = questionId, Is_Active__c = true, Sequence__c = 1, 
                                            Is_Selected__c =true);
    if(isInsert) {                                  
      insert(answer);
    }
    return answer; 
  }
  
  //insert Region
  public static pse__Region__c insertRegion(Boolean isInsert){
    pse__Region__c region = new pse__Region__c();
    region.Name = 'GS - North America Delivery';
    region.Assignable_to_Resources__c = true;
    region.Assignable_to_Resource_Requests__c = true;
    
    if(isInsert)  {
      insert (region);
    } 
    return region;
  }
  
  //insert Practice
  public static pse__Practice__c insertPractice(Boolean isInsert){
    pse__Practice__c practice = new pse__Practice__c();
    practice.Name = 'Test Practice';
    practice.Assignable_to_Resources__c = true;
    practice.Assignable_to_Resource_Requests__c = true;
    
    if(isInsert) {
      insert (practice);
    }
    return practice;
  }
  
  
  //insert rate card
  public static pse__Rate_Card__c insertRateCard(Id accountId, Id regionId, Id practiceId, Boolean isInsert){
    pse__Rate_Card__c pserateCard = new pse__Rate_Card__c();
    pserateCard.pse__Account__c = accountId;
    pserateCard.pse__Average_Cost_Rate__c = 10000;
    pserateCard.pse__Suggested_Bill_Rate__c = 5000;
    pserateCard.pse__Role__c = 'Account Director';
    pserateCard.Code__c = 'Code 1 for testing';
    pserateCard.pse__Region__c = regionId;
    pserateCard.pse__Practice__c = practiceId;
    pserateCard.CurrencyIsoCode = E2_Constants.CURRENCY_ISO_CODE_USD;
    
    if(isInsert) {                                  
      insert(pserateCard);
    }
    return pserateCard; 
  }
  
  //insert estimate Rate Card
  public static E2_Estimate_Rate_Card__c insertEstimateRateCard(String estimateId, Boolean isInsert){
    E2_Estimate_Rate_Card__c estimateRC = new E2_Estimate_Rate_Card__c();
    estimateRC.Estimate__c = estimateId;
    estimateRC.Region__c = 'Jaipur';
    
    if(isInsert) {
      insert estimateRC;
    }
    return estimateRC;
    
  }
  
  //insert CMC Estimate resource
  public static CMC_Estimate_Resource__c insertCMCEstimateRes(String estimateId, Boolean isInsert){
    CMC_Estimate_Resource__c res = new CMC_Estimate_Resource__c();
    res.Name = 'Test Estimate Resource';
    res.Estimate__c = estimateId;
    res.Role__c = 'GS - North America Delivery - Technical Architect';
    res.Skill__c = 'Salesforce';
    res.Is_Used_For_Calculations__c = true; //, Estimate__c, , , Role__c
    res.Cost__c = 105;
    res.Order__c = 2;
    res.Rate__c = 250;
    
    
    if(isInsert) {
      insert res;
    }
    return res;
  }
  
  //insert Estimate week
  public static CMC_Estimate_Week__c insertEstimateWeek(String estimateId, Boolean isInsert){
    CMC_Estimate_Week__c week = new CMC_Estimate_Week__c(Name = 'Week1',Estimate__c = estimateId, Order__c = 2,
                                                         Date__c = system.today(), Phase__c = 'Plan', Milestone__c = 'Test');
    if(isInsert) {
      insert week;
    }
    return week;                                                     
  }
  
  //insert CMC Estimate Resource Week
  public static CMC_Estimate_Resource_Week__c insertCMCEstimateResWeek(String estimateResourceId, String weekId, Boolean isInsert){
    CMC_Estimate_Resource_Week__c resWeek = new CMC_Estimate_Resource_Week__c(Estimate_Resource__c = estimateResourceId, 
                                                                              Estimate_Week__c = weekId, Hours__c = 10);
    if(isInsert) {
      insert resWeek;
    }
    return resWeek;                                                                          
    
  }
  
  //insert E2_Estimate_Milestone__c
  public static E2_Estimate_Milestone__c insertEstimateMilestone(String estimateId, Boolean isInsert){
    E2_Estimate_Milestone__c milestone = new E2_Estimate_Milestone__c(Estimate__c = estimateId, Milestone1__c = 'Test milestone 1', 
                                                        Milestone2__c = 'Test milestone 2', Order__c = 10);
    if(isInsert) {
      insert milestone;
    }
    return milestone;                                                     
                                                        
  }
  
  //insert E2_Estimate_Milestone_Week__c
  public static E2_Estimate_Milestone_Week__c insertMilestoneWeek(Id milestoneId, Id weekId, Boolean isInsert){
    E2_Estimate_Milestone_Week__c milestoneWk = new E2_Estimate_Milestone_Week__c(Estimate_Milestone__c = milestoneId, Estimate_Week__c = weekId, 
                                                         TextColorCode__c = 'Red'); 
    if(isInsert) {
      insert milestoneWk;
    }
    return milestoneWk;                                                         
  }
  
  //insert E2_Milestone_Library__c
  public static E2_Milestone_Library__c insertMilestoneLibrary (Boolean isInsert){
    E2_Milestone_Library__c milestoneLib = new E2_Milestone_Library__c(Name = 'Test Milestone 1', Is_Active__c = true);
    
    if(isInsert) {
      insert milestoneLib;
    }
    return milestoneLib; 
    
  }
  
  //insert E2_Timeline_Milestone__c
  public static E2_Timeline_Milestone__c insertTimelineMilestone (Id milestoneLibId, Boolean isInsert){
    E2_Timeline_Milestone__c TLMilestone = new E2_Timeline_Milestone__c(E2_Milestone_Library__c = milestoneLibId, Is_Active__c = true, 
                                                            Milestone1__c = 'Test Milestone 1', Milestone2__c = 'Test Milestone 2',  Order__c = 10);  
    
    if(isInsert) {
      insert TLMilestone;
    }
    return TLMilestone; 
    
  }
  

}