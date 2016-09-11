/**=====================================================================
 * Appirio, Inc
 * Name: E2_SelectDerivedEffortTemplateController
 * Description: Controller class for DerivedEffortTemplate Search page
 * Created Date: Apr 8th, 2016
 * Created By: Rohit Sharma (Appirio)
 * 
 * Date Modified      Modified By                  Description of the update
    
*  =====================================================================*/
public with sharing class E2_SelectDerivedEffortTemplateController {
    
    public String searchGroup{get;set;}
    public List<DerivedGroup> derivedGroups{get;set;}
    public E2_PaginationUtility effortPaging {get; set;}
    public Integer selectedPageNumber{get;set;}
    
    //constructor 
    public E2_SelectDerivedEffortTemplateController() {
        selectedPageNumber = 1;
        derivedGroups = new List<DerivedGroup>();
        effortPaging = new E2_PaginationUtility();
        effortPaging.pageSize = 15;
    }
    
    //page action method which is called on page load 
    public PageReference pageAction(){
        for(E2_Derived_Effort_Group__c dg : Database.query(E2_DataUtil.getDerivedEffortGroup(null))) {
            derivedGroups.add(new DerivedGroup(dg));
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
                derivedGroups.add(new DerivedGroup(dg));
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