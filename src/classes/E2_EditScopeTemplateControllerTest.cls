/**=====================================================================
 * Appirio, Inc
 * Name: E2_EditScopeTemplateController
 * Description: Controller class for E2_EditScopeTemplate page
 * Created Date: June 21, 2016
 * Created By:  Rohit Sharma
 * 
 * Date Modified      Modified By                  Description of the update
   October 19th,2016  Rohit Sharma                 I-241595 : Enhance the E2 code where algo has developed 
                                                    around "Scope Template manager" permission set 
*  =====================================================================*/
@isTest(seeAllData=false)
public class E2_EditScopeTemplateControllerTest {
  public static E2_Scope__c scope;
  public static CMC_Presales_LOE__c estimate;
  public static List<E2_Effort__c> effortLst;  
  public static Id recTypeId1 = E2_RecordTypeClass.getId('E2_Scope__c', E2_Constants.SCOPE_RT_SCOPE);
  public static E2_Recommended_Asset__c recommendedAsset;
  
  public static testmethod void testNoScope(){
    estimate = [SELECT Id FROM CMC_Presales_LOE__c];   
    User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
    
    System.runAs(sysAdmin){
        Test.startTest();
            E2_Scope__c scope1 = E2_Test_Utils.insertScope(false);
            
            PageReference pageRef = Page.E2_EditScopeTemplate;
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController stdController = new ApexPages.StandardController(scope1);
            E2_EditScopeTemplateController controller = new E2_EditScopeTemplateController(stdController);
            controller.pageAction();
            
            List<Apexpages.Message> msgs = ApexPages.getMessages();
                boolean b = false;
                for(Apexpages.Message msg:msgs){
                    if (msg.getDetail().contains('No scope defined to edit!!!')){ 
                      b = true;
                    }
                }
                system.assertEquals(b, true, 'Should return true when no scope defined');
        Test.stopTest();  
     }
  }
  
  public static testmethod void testEditScope(){
    scope = [SELECT Id, LastModifiedById FROM E2_Scope__c];
    estimate = [SELECT Id FROM CMC_Presales_LOE__c];
    effortLst = [SELECT Id FROM E2_Effort__c WHERE Scope__c = :scope.Id];
    User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
    
    E2_Scope__c source_scope =  E2_Test_Utils.insertScope(false);
    source_scope.recordTypeId = recTypeId1;
    source_scope.Presales_LOE__c = estimate.id;  
    insert source_scope;
    
    scope.Source_Scope__c = source_scope.Id;
    update scope;
    
    E2_Scope__c scope1 =  E2_Test_Utils.insertScope(false);
    scope1.recordTypeId = recTypeId1;
    scope1.Presales_LOE__c = estimate.id;  
    scope1.Effort_Quantity__c = 2;  
    insert scope1;
    
    E2_Scope__c childScope =  E2_Test_Utils.insertScope(false);
    childScope.recordTypeId = recTypeId1;
    childScope.Presales_LOE__c = estimate.id; 
    childScope.Ultimate_Parent_Scope__c=scope1.ID;
    childScope.Parent_Scope__c=scope1.ID;
    insert childScope;
    
    
    E2_Effort__c source_effort = E2_Test_Utils.insertEffort(true, scope.Id);
    
    E2_Effort__c effort1 = E2_Test_Utils.insertEffort(false, scope.Id);
    E2_Effort__c effort2 = E2_Test_Utils.insertEffort(false, scope1.Id);
    effort2.Source_Effort__c = source_effort.Id;
    List<E2_Effort__c> effortLst1 = new List<E2_Effort__c>();
    effortLst1.add(effort1);
    effortLst1.add(effort2);
    insert effortLst1;
    
    System.runAs(sysAdmin){
        Test.startTest();           
            PageReference pageRef = Page.E2_EditScopeTemplate;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put(E2_Constants.URL_KEY_ESTIMATE_ID, estimate.Id);
            
            ApexPages.StandardController stdController = new ApexPages.StandardController(scope);
            E2_EditScopeTemplateController controller = new E2_EditScopeTemplateController(stdController);
           
            controller.pageAction();
            
                  E2_EditScopeTemplateController.Scope scope_wrap = controller.childScope;
                  scope_wrap.addNewEffort();
                  scope_wrap.addNewEffort();
                  scope_wrap.hasClonedEfforts = true;
                  system.assertEquals(scope_wrap.isCloned, true); 
                  system.assertEquals(scope_wrap.key, scope.Id);
                  
                  for(E2_EditScopeTemplateController.Effort eff: scope_wrap.efforts){
                        
                      eff.effort.Is_Active__c = true;
                      eff.effort.Effort_Hrs__c = 40;
                      eff.effort.Phase__c = 'Build';
                      eff.effort.Resource_Role__c = 'Project Manager';
                      eff.effort.Complexity_Factor_High__c = 10;
                      eff.effort.Complexity_Factor_Low__c = 10;
                  }  
                  system.assertEquals(scope_wrap.getEffortsSize(), 160, 'scope cumulative efforts size should match'); 
                  scope_wrap.reload();
                  scope_wrap.changeComplexity();
                  
                  List<E2_EffortsWrapper> lstEfforts = new List<E2_EffortsWrapper>();
                  lstEfforts.add(new E2_EffortsWrapper());
                  lstEfforts.add(new E2_EffortsWrapper());
                  lstEfforts[0].hours = 5;
                  String effortsJson = JSON.serialize(lstEfforts, true);
                  controller.effortsJson = effortsJson;
                  controller.addBulkEfforts();
                  controller.saveScope();
                  
                  //Scope wrapper instance
                  E2_EditScopeTemplateController.Scope scopeWrapper=new E2_EditScopeTemplateController.Scope(scope1,effortLst1); 
                  controller.childScope=scopeWrapper; 
                  controller.childScope.multiplier=1;
                  scopeWrapper.efforts.get(0).isDeleted=true;
                  controller.saveScope();     
                  List<E2_Scope__c> scopeList = E2_DataUtil.getScopeAndChildrenOnScopeIdForEditScope(scope.id);
                  system.assertEquals(scopeList[0].Efforts__r.size(),4, '4 efforts should saved');
                  
                  for(E2_EditScopeTemplateController.Effort eff: scope_wrap.efforts){
                     eff.remove();    
                  }         
                  controller.saveScope();     
                  scopeList = E2_DataUtil.getScopeAndChildrenOnScopeIdForEditScope(scope.id);
                  system.assertEquals(scopeList[0].Efforts__r.size(), 4, '4 effort should removed');
                    
                  scope_wrap.remove();
                    
                  controller.getEffortsInstanceList();
                  
                  controller.resetChildScopesOnException();
        Test.stopTest();  
     }
  }
  
   public static testmethod void testEditScope2(){
    
      
    scope = [SELECT Id, LastModifiedById FROM E2_Scope__c];
    estimate = [SELECT Id FROM CMC_Presales_LOE__c];
    effortLst = [SELECT Id FROM E2_Effort__c WHERE Scope__c = :scope.Id];
    User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
    
    E2_Scope__c scope1 =  E2_Test_Utils.insertScope(false);
    scope1.recordTypeId = recTypeId1;
    scope1.Presales_LOE__c = estimate.id;  
    insert scope1;  
      
    System.runAs(sysAdmin){
    //start test
    Test.startTest();
      PageReference pageRef = Page.E2_EditScopeTemplate;
      Test.setCurrentPage(pageRef);
      ApexPages.currentPage().getParameters().put(E2_Constants.URL_KEY_ESTIMATE_ID, estimate.Id);
    
      ApexPages.StandardController stdController = new ApexPages.StandardController(scope);
      E2_EditScopeTemplateController controller = new E2_EditScopeTemplateController(stdController);
    
      controller.pageAction();
      // Permission set removed
      //system.assertEquals(controller.showFavForSTMPermissionSet, true);  
      controller.saveScope();  
      
    //stop test
    Test.stopTest(); 
    } 
  }
  
  public static testmethod void testEditScope3(){ 
    scope = [SELECT Id, LastModifiedById FROM E2_Scope__c];
    estimate = [SELECT Id FROM CMC_Presales_LOE__c];
    effortLst = [SELECT Id FROM E2_Effort__c WHERE Scope__c = :scope.Id];
    User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
    
    E2_Scope__c scope1 =  E2_Test_Utils.insertScope(false);
    scope1.recordTypeId = recTypeId1;
    scope1.Presales_LOE__c = estimate.id;  
    insert scope1;  
    
    E2_Effort__c source_effort = E2_Test_Utils.insertEffort(true, scope.Id);
    
    E2_Effort__c effort1 = E2_Test_Utils.insertEffort(false, scope.Id);
    E2_Effort__c effort2 = E2_Test_Utils.insertEffort(false, scope1.Id);
    effort2.Source_Effort__c = source_effort.Id;
    List<E2_Effort__c> effortLst1 = new List<E2_Effort__c>();
    effortLst1.add(effort1);
    effortLst1.add(effort2);
    insert effortLst1;  
    
    CMC_Asset__c asset = E2_Test_Utils.insertAsset('Test Asset 1', 'Test asset record', 'Component', 'User Interface', 
                                                   'Apex', 'Salesforce;Data integration', 1, 'Active', true);
    E2_Recommended_Asset__c recommendedAsset1 = E2_Test_Utils.insertRecommendedAsset(scope1.id, asset.id, true);
    
    System.runAs(sysAdmin){
    //start test
    Test.startTest();
      PageReference pageRef = Page.E2_EditScopeTemplate;
      Test.setCurrentPage(pageRef);
      ApexPages.currentPage().getParameters().put(E2_Constants.URL_KEY_ESTIMATE_ID, estimate.Id);
    
      ApexPages.StandardController stdController = new ApexPages.StandardController(scope);
      E2_EditScopeTemplateController controller = new E2_EditScopeTemplateController(stdController);
    
      controller.pageAction();
      system.assert(controller.childScope <> null, '1 child scope should be added in list');
       
      controller.childScope.scope.Is_Favourite__c = true;  
      controller.assetsRecsJson = '{"'+ recommendedAsset1.Asset__c + '" : {"recommendedAssetRecId" : "' + recommendedAsset1.Id + 
                                    '", "id" : "' + recommendedAsset1.Asset__c + '", '+
                                    '"isExisting" : "false", "isDeleted" : "false"}}'; 
      controller.saveScope();     
      
      List<E2_Recommended_Asset__c> relatedAssets = new List<E2_Recommended_Asset__c>([SELECT Scope__c, Asset__c 
                                                                                FROM E2_Recommended_Asset__c
                                                                                WHERE Scope__c = :scope.Id]);     
      System.assertEquals(relatedAssets.size(), 2);
                
      system.assertNotEquals([SELECT Id FROM E2_Favourite_Scope__c WHERE Scope__c =:scope.Id].size(), 1); 
      
      controller.addNewQuestion();                 
       
    //stop test
    Test.stopTest(); 
    } 
  }
  
  public static testmethod void testEditScopeWithAssets(){
    scope = [SELECT Id, LastModifiedById FROM E2_Scope__c];
    estimate = [SELECT Id FROM CMC_Presales_LOE__c];
    recommendedAsset = [SELECT Scope__c, Asset__c FROM E2_Recommended_Asset__c];
    
    User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
    
    System.runAs(sysAdmin){
        Test.startTest();           
            PageReference pageRef = Page.E2_EditScopeTemplate;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put(E2_Constants.URL_KEY_ESTIMATE_ID, estimate.Id);
            
            ApexPages.StandardController stdController = new ApexPages.StandardController(scope);
            E2_EditScopeTemplateController controller = new E2_EditScopeTemplateController(stdController);
            controller.pageAction();
            
            controller.assetsRecsJson = '{"'+ recommendedAsset.Asset__c + '" : {"recommendedAssetRecId" : "' + recommendedAsset.Id + 
                                    '", "id" : "' + recommendedAsset.Asset__c + '", '+
                                    '"isExisting" : "true", "isDeleted" : "true"}}'; 
            
            controller.saveScope();     
            List<E2_Recommended_Asset__c> relatedAssets = new List<E2_Recommended_Asset__c>([SELECT Scope__c, Asset__c 
                                                                                FROM E2_Recommended_Asset__c
                                                                                WHERE Scope__c = :scope.Id]);     
            System.assertEquals(relatedAssets.size(), 0);
        Test.stopTest();  
     }
  }
  
  public static testmethod void testEditScopewithPermission(){
    
      
    scope = [SELECT Id, LastModifiedById FROM E2_Scope__c];
    estimate = [SELECT Id FROM CMC_Presales_LOE__c];
    effortLst = [SELECT Id FROM E2_Effort__c WHERE Scope__c = :scope.Id];
    User sysAdmin = E2_Test_Utils.insertUser(E2_Constants.PROFILE_SYS_ADMIN, true);
    System.runAs(sysAdmin){
    //start test
    Test.startTest();
      PageReference pageRef = Page.E2_EditScopeTemplate;
      Test.setCurrentPage(pageRef);
      ApexPages.currentPage().getParameters().put(E2_Constants.URL_KEY_ESTIMATE_ID, estimate.Id);
    
      ApexPages.StandardController stdController = new ApexPages.StandardController(scope);
      E2_EditScopeTemplateController controller = new E2_EditScopeTemplateController(stdController);
    
      controller.pageAction();
                       			    
      
      controller.pageAction();
      system.assertEquals(controller.showFavForSTMPermissionSet, true); 
      controller.saveScope();  
      
    //stop test
    Test.stopTest(); 
    } 
  }
  
  //create test data
  @testSetup 
  public static void createTestData(){
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
    
    List<CMC_Asset__c> lstAssets = new List<CMC_Asset__c>();
    lstAssets.add(E2_Test_Utils.insertAsset('Test Asset 1', 'Test asset record', 'Component', 'User Interface', 
                                                'Apex', 'Salesforce;Data integration', 1, 'Active', false));
    lstAssets.add(E2_Test_Utils.insertAsset('Test Asset 2', 'Test asset record', 'Component', 'User Interface', 
                                                'Apex', 'Salesforce;Data integration', 1, 'Active', false));
    insert lstAssets;
        
    recommendedAsset = E2_Test_Utils.insertRecommendedAsset(scope1.id, lstAssets[0].id, true);
  }

}