/**=====================================================================
 * Appirio, Inc
 * Name: E2_SelectDerivedEffortTemplateController
 * Description: Controller class for DerivedEffortTemplate Search page
 * Created Date: Apr 8th, 2016
 * Created By: Rohit Sharma (Appirio)
 * 
 * Date Modified      Modified By                  Description of the update
 * Jan 25, 2017       Rohit Sharma                 S-453758 : Status field (Active,Inactive) for Derived Effort Template and related
 *                                                 Added condition to add only active derived efforts template for selection
 *                                                 If logged-in user is derived effort template manager, user can access all active/
 *                                                 in-active derived effort templates.
*  =====================================================================*/
public with sharing class E2_SelectDerivedEffortTemplateController {
    
    public String searchGroup{get;set;}
    public List<DerivedGroup> derivedGroups{get;set;}
    public E2_PaginationUtility effortPaging {get; set;}
    public Integer selectedPageNumber{get;set;}
    public boolean isTemplateManager{get;set;}
    //constructor 
    public E2_SelectDerivedEffortTemplateController() {
        selectedPageNumber = 1;
        derivedGroups = new List<DerivedGroup>();
        effortPaging = new E2_PaginationUtility();
        effortPaging.pageSize = 15;
        this.isTemplateManager = false;
    }
    
    //page action method which is called on page load 
    public PageReference pageAction(){
        // RS 25/01: S-453758 : check user access: if logged-in user is derived effort template manager
        List <PermissionSetAssignment> permissionSetAssigneeList = [SELECT Id From PermissionSetAssignment Where PermissionSet.Name =: E2_CONSTANTS.DERIVED_EFFORT_TEMPLATE_MANAGER AND AssigneeId =: UserInfo.getUserId() LIMIT 1];
        if(!permissionSetAssigneeList.isEmpty()) this.isTemplateManager = true;
        for(E2_Derived_Effort_Group__c dg : Database.query(E2_DataUtil.getDerivedEffortGroup(null))) {
            if(dg.Is_Active__c || this.isTemplateManager)  derivedGroups.add(new DerivedGroup(dg));
        }
        List<Object> tempList = effortPaging.setPagination(derivedGroups);
        derivedGroups = getWrapperList(tempList);
        return null;
    }
    
    //utility method to derived groups 
    private List<DerivedGroup> getWrapperList(List<Object> currentList) {
     List<DerivedGroup> scpList = new List<DerivedGroup>();
     for(Object obj : currentList) {
        scpList.add((DerivedGroup)obj);
     }
     return scpList;
    }

    // method to select template effort 
    public PageReference selectTemplateEfforts() {
        derivedGroups.clear();
        // check that if selected Group is not null/empty than retrieve all the derived efforts of selected group
        // else show blank;
        if(!String.isBlank(searchGroup)){
            for(E2_Derived_Effort_Group__c dg : Database.query(E2_DataUtil.getDerivedEffortGroup(searchGroup))) {
                if(dg.Is_Active__c || this.isTemplateManager)  derivedGroups.add(new DerivedGroup(dg));
            }
            List<Object> tempList = effortPaging.setPagination(derivedGroups);
            derivedGroups = getWrapperList(tempList);        
        } else {
            pageAction();
        }
        return null;
    }
    
    // method to clear the search criteria 
    public PageReference clearTemplateSearch() {
        searchGroup = null;
        derivedGroups.clear();
        pageAction();
        return null;
    }
    
    // method to get the list of records 
    public PageReference getList() {
        try {
            derivedGroups = getWrapperList(effortPaging.getPage(selectedPageNumber));        
        } catch(Exception excep) {}
        return null;
    }
    
    //wrapper class for derived effort group 
    public class DerivedGroup {
        public E2_Derived_Effort_Group__c derivedGroups{get;set;}
        
        public DerivedGroup(E2_Derived_Effort_Group__c derivedGroups) {
            this.derivedGroups = derivedGroups;
        }
    }
}