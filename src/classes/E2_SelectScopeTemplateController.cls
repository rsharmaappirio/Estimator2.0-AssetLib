/**=====================================================================
 * Appirio, Inc
 * Name: E2_SelectScopeTemplateController
 * Description: Controller class to search Scope
 * Created Date: Apr 15th, 2016
 * Created By: Arpita Bose (Appirio)
 * 
 * Date Modified      Modified By                  Description of the update
 * Apr 18th, 2016     Arpita                       T-494117
*  =====================================================================*/
public with sharing class E2_SelectScopeTemplateController {
  //properties
  public List<E2_ScopeWrapper> scopeList {get;set;}
  public List<E2_ScopeWrapper> favScopeList {get;set;}
  
  private Id rtTemplateId;
  private Id rtScopeId;

  public E2_PaginationUtility scopePaging {get; set;}
  public E2_PaginationUtility favScopePaging {get; set;}
  
  public Integer selectedPageNumber{get;set;}
  public Integer selectedCon {get; set;}
  public Integer totalMyFav{get; set;}
  public Integer totalTemplate{get; set;}
  
  private List<E2_PaginationUtility> conList;
  
  public boolean isTemplatePage{get;set;}

  //public Id selectedRecordId{get;set;}
  //public Id selectedRecordTypeId{get;set;}
  
  public String sortDirection = 'ByAsc'; //Sort Order
  public String sortExp = 'ByScopeName'; //initial sort field

  public String sortExpression {
    get {
        return sortExp;
    } 
    set {
            if (value == sortExp)
            sortDirection = (sortDirection == 'ByDesc')? 'ByAsc' : 'ByDesc';
            else
            sortDirection = 'ByAsc';
            sortExp = value;
    }
  }
  
  public String getSortDirection() {
    if (sortExpression == null || sortExpression == '')
        return 'ASC';
    else
        return sortDirection;
  }
  
  public string scopeName { 
    get {
      if (scopeName == null)
        scopeName = '';
        return scopeName;
      }
    set;
  }
  
  public string scopeGroup { get;set; }
  
  public List<SelectOption> scopeGroups {
    get {
        if(scopeGroups == null) {
            scopeGroups = new List<SelectOption>();
            for(E2_Scope_Group__c sGroup : E2_DataUtil.getAllScopeGroups()) {
                scopeGroups.add(new SelectOption(sGroup.Id, sGroup.Name));
            }
        }
        return scopeGroups;
    }
    set;
  }
  
  //constructor
  public E2_SelectScopeTemplateController(){
    rtTemplateId = E2_RecordTypeClass.getId('E2_Scope__c', E2_Constants.SCOPE_RT_TEMPLATE);
    rtScopeId = E2_RecordTypeClass.getId('E2_Scope__c', E2_Constants.SCOPE_RT_SCOPE);
    conList = new List<E2_PaginationUtility>();
    scopeList = new List<E2_ScopeWrapper>();
    favScopeList = new List<E2_ScopeWrapper>();
    isTemplatePage = false;
    if(ApexPages.currentPage().getParameters().get('templatepage')!=null) {
        isTemplatePage = true;
    }
    pageAction();
  }
  
  //fetch last viewed scope records on load
  public void pageAction(){
    E2_ScopeWrapper.sortBy = E2_ScopeWrapper.SORT_BY.ByLastView;
    scopeList.clear();
    getTemplateScope(null, null);
    scopeList.sort();
    system.debug('===isTemplatePage>>' +isTemplatePage);
    if(!isTemplatePage) {
        favScopeList.clear();
        getMyScope(null);
        favScopeList.sort();
    }
    addPaginationOnFormList();
  }  
  
  private void getTemplateScope(String scopeName,String groupId) {
    List<E2_Scope__c> scopes = Database.query(E2_DataUtil.getScopesOnTemplateScopeSearchTemplate(scopeName, groupId, 
                                                                    rtTemplateId));
    this.totalTemplate = scopes.size();
    for(E2_Scope__c sc : scopes){
        scopeList.add(new E2_ScopeWrapper(sc));
    }
  }
  
  private void getMyScope(String scopeName) {
    system.debug('===userId>>>'+UserInfo.getUserId());
    List<E2_Scope__c> scopes = Database.query(E2_DataUtil.getScopesOnTemplateScopeSearchByUser(scopeName, 
                                                    UserInfo.getUserId(), rtScopeId));
    this.totalMyFav = scopes.size();
    system.debug('===scopes>>>'+scopes);
    for(E2_Scope__c sc : scopes){
        favScopeList.add(new E2_ScopeWrapper(sc));
    }
  }
  
  //fetch existing scope records on click of 'Search' button
  public void searchScopeRecords() {
    E2_ScopeWrapper.sortBy = E2_ScopeWrapper.SORT_BY.ByScopeName;
    scopeList.clear();
    getTemplateScope(scopeName, scopeGroup);
    if(!isTemplatePage) {
        favScopeList.clear();
        this.totalMyFav = 0; 
        if(String.isBlank(scopeGroup))
            getMyScope(scopeName);
    }    
    addPaginationOnFormList();
  }
  
  //Add pagination on Form list 
  // PaginationUtility class to used for pagination.
  public void addPaginationOnFormList() {
     conList.clear(); 
    selectedCon = 0;
    scopePaging = new E2_PaginationUtility();
    scopePaging.pageSize = 5;
    List<Object> tempList = scopePaging.setPagination(scopeList);
    scopeList = getWrapperList(tempList);
    conList.add(scopePaging);
        
    favScopePaging = new E2_PaginationUtility();
    favScopePaging.pageSize = 5;
    tempList = favScopePaging.setPagination(favScopeList);
    favScopeList = getWrapperList(tempList);
    conList.add(favScopePaging);
  }
   
   private List<E2_ScopeWrapper> getWrapperList(List<Object> currentList) {
     List<E2_ScopeWrapper> scpList = new List<E2_ScopeWrapper>();
     for(Object obj : currentList) {
        scpList.add((E2_ScopeWrapper)obj);
     }
     return scpList;
  }
  
  public PageReference getList() {
    try {       
      if(selectedCon < conList.size()) {
         E2_PaginationUtility con = conList.get(selectedCon);
         if(selectedCon == 0) 
            scopeList = getWrapperList(con.getPage(selectedPageNumber));
         else 
            favScopeList = getWrapperList(con.getPage(selectedPageNumber));
        }       
      }
    catch(Exception excep) {}
    return null;
  }
  
  //clear result
  public PageReference resetResults() {
     scopeName = null;
     scopeGroup = null;
     scopeList.clear();
     favScopeList.clear();
     pageAction();
     return null;
   } 
  
  public PageReference sortList() {
      if(sortExp=='ByComplexity'){
        E2_ScopeWrapper.sortBy = E2_ScopeWrapper.SORT_BY.ByComplexity;
      } else if(sortExp=='ByGroup'){
        E2_ScopeWrapper.sortBy = E2_ScopeWrapper.SORT_BY.ByGroup;
      } else if(sortExp=='ByEfforts'){
        E2_ScopeWrapper.sortBy = E2_ScopeWrapper.SORT_BY.ByEfforts;
      } else {
        E2_ScopeWrapper.sortBy = E2_ScopeWrapper.SORT_BY.ByScopeName;  
      } 
      if(sortDirection == 'ByDesc'){
        E2_ScopeWrapper.sortOreder = E2_ScopeWrapper.SORT_ORDER.ByDesc;
      } else {
        E2_ScopeWrapper.sortOreder = E2_ScopeWrapper.SORT_ORDER.ByAsc;
      }
      E2_PaginationUtility con = conList.get(selectedCon);
      if(selectedCon == 0) {
        scopeList = getWrapperList(con.getRecordsList());
        scopeList.sort();
        List<Object> tempList = scopePaging.setPagination(scopeList);
        scopeList = getWrapperList(tempList);
      } else {
        favScopeList = getWrapperList(con.getRecordsList());
        favScopeList.sort();
         List<Object> tempList = favScopePaging.setPagination(favScopeList);
         favScopeList = getWrapperList(tempList);
      }
    return null;   
  } 
}