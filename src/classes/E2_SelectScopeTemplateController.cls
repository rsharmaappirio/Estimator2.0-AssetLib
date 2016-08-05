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
  private Set<Id> scopeIDs = new Set<Id>();
  
  public E2_PaginationUtility scopePaging {get; set;}
  public E2_PaginationUtility favScopePaging {get; set;}
  
  public Integer selectedPageNumber{get;set;}
  public Integer selectedCon {get; set;}
  public Integer totalMyFav{get; set;}
  public Integer totalTemplate{get; set;}
  
  private List<E2_PaginationUtility> conList;
  
  public boolean isTemplatePage{get;set;}
  public Boolean isFavourite {get;set;}
  public Id selectedScopeId {get;set;}
  
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
    isFavourite = false;
    if(ApexPages.currentPage().getParameters().get('templatepage')!=null) {
        isTemplatePage = true;
    }
    pageAction();
  }
  
  //fetch last viewed scope records on load
  public void pageAction(){
    E2_ScopeWrapper.sortBy = E2_ScopeWrapper.SORT_BY.ByLastView;
    system.debug('===isTemplatePage>>' +isTemplatePage);    
    if(!isTemplatePage) {
        scopeIDs.clear();
        favScopeList.clear();
        getMyScope(null, null);
        favScopeList.sort();
    }
    scopeList.clear();
    getTemplateScope(null, null);
    scopeList.sort();
    addPaginationOnFormList();
  }  
  
  private void getTemplateScope(String scopeName,String groupId) {
    List<E2_Scope__c> scopes = Database.query(E2_DataUtil.getScopesOnTemplateScopeSearchTemplate(scopeName, groupId, 
                                                                    rtTemplateId));
    this.totalTemplate = scopes.size();
    for(E2_Scope__c sc : scopes){
       boolean fav = false;
       if(scopeIDs.contains(sc.Id)){
         fav = true;
       }
       scopeList.add(new E2_ScopeWrapper(sc,fav));
    }
  }
  
  private void getMyScope(String scopeName, string groupId) {
    system.debug('===userId>>>'+UserInfo.getUserId());
    List<E2_Favourite_Scope__c> scopes = Database.query(E2_DataUtil.getFavScopesOnTemplateScopeSearchByUser(
    										scopeName, UserInfo.getUserId(), groupId));
                                                    
    this.totalMyFav = scopes.size();
    for(E2_Favourite_Scope__c fsc : scopes){
        scopeIDs.add(fsc.Scope__r.Id);
        favScopeList.add(new E2_ScopeWrapper(fsc.Scope__r,true));
    }    
  }
  
  //fetch existing scope records on click of 'Search' button
  public void searchScopeRecords() {
    E2_ScopeWrapper.sortBy = E2_ScopeWrapper.SORT_BY.ByScopeName;
    if(!isTemplatePage) {
        scopeIDs.clear();
        favScopeList.clear();
        this.totalMyFav = 0; 
        //if(String.isBlank(scopeGroup))
            getMyScope(scopeName, scopeGroup);
    } 
    scopeList.clear();
    getTemplateScope(scopeName, scopeGroup);   
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
  
  public PageReference addOrRemoveFavScope(){
  	try{
		if(selectedScopeId != null){
			if(isFavourite){
		    	E2_Favourite_Scope__c favSC = new E2_Favourite_Scope__c(Scope__c = selectedScopeId,
		      												User__c = UserInfo.getUserId(),
		      												Unique_Scope_User_Id__c = selectedScopeId +'-'+ UserInfo.getUserId());
		        insert favSC;
		 	} else {
		    	E2_Favourite_Scope__c favSC = null;
		        for(E2_Favourite_Scope__c fsc : [SELECT Id,Scope__r.RecordTypeId FROM E2_Favourite_Scope__c 
		                                           WHERE Scope__c =: selectedScopeId 
		                                           AND User__c =: UserInfo.getUserId()]){  
		          favSC = fsc;	          
		        }
		        if(favSC != null) {
		        	delete favSC;
		        	if(favSC.Scope__r.RecordTypeId == rtScopeId) 
		        		update (new E2_Scope__c(Id = selectedScopeId, Is_Favourite__c = false));
		        } 
		  	}
	 	}  
      	searchScopeRecords();
      }catch(Exception ex){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.Error, ex.getMessage()));
        return null;
      }
      return null; 
    }
 
}