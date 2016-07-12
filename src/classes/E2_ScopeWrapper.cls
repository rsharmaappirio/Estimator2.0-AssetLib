/**=====================================================================
 * Appirio, Inc
 * Name: E2_ScopeWrapper
 * Description: Wrapper class of Scope used in ScopeTemplateSearch page
 * Created Date: Apr 8th, 2016
 * Created By: Rohit Sharma (Appirio)
 * 
 * Date Modified      Modified By                  Description of the update
    
*  =====================================================================*/
global class E2_ScopeWrapper implements Comparable {
    public Boolean isSelected {get; set;}
    public E2_Scope__c scope {get; set;}
    
    public enum SORT_BY {
        ByScopeName,ByComplexity,ByGroup,ByEfforts,ByLastView
    }
    
    public enum SORT_ORDER {
        ByDESC,ByASC
    }
    
    public static SORT_BY sortBy = SORT_BY.ByScopeName;
    public static SORT_ORDER sortOreder = SORT_ORDER.ByASC;


    //constructor    
    public E2_ScopeWrapper(){
      scope = new E2_Scope__c();
      isSelected = false;
    }
    
    public E2_ScopeWrapper(E2_Scope__c scope){
      this.scope = scope;
      isSelected = false;
    }
    
    global Integer compareTo(Object objToCompare) {
        if(sortBy == SORT_BY.ByComplexity){
            if(sortOreder==SORT_ORDER.ByASC) 
                return scope.Complexity__c.compareTo(((E2_ScopeWrapper)objToCompare).scope.Complexity__c);
            else
                return ((E2_ScopeWrapper)objToCompare).scope.Complexity__c.compareTo(scope.Complexity__c); 
        }else if(sortBy == SORT_BY.ByGroup){
            if(scope.Scope_Group__c==null) {
                return -1;
            }else if(((E2_ScopeWrapper)objToCompare).scope.Scope_Group__c==null) {
                return 1;
            }
            if(sortOreder==SORT_ORDER.ByASC) 
                return scope.Scope_Group__r.Name.compareTo(((E2_ScopeWrapper)objToCompare).scope.Scope_Group__r.Name);
            else
                return ((E2_ScopeWrapper)objToCompare).scope.Scope_Group__r.Name.compareTo(scope.Scope_Group__r.Name);
        }else if(sortBy == SORT_BY.ByEfforts){
            if(sortOreder==SORT_ORDER.ByASC) 
                return Integer.valueOf(scope.LOE_Hrs__c - ((E2_ScopeWrapper)objToCompare).scope.LOE_Hrs__c);
            else
                return Integer.valueOf(((E2_ScopeWrapper)objToCompare).scope.LOE_Hrs__c - scope.LOE_Hrs__c);
        }else if(sortBy == SORT_BY.ByLastView) {
            return 0;//scope.LastViewedDate==null ? -1 : ((E2_ScopeWrapper)objToCompare).scope.LastViewedDate==null ? 0 : Integer.valueOf((scope.LastViewedDate.getTime() / 1000) - (((E2_ScopeWrapper)objToCompare).scope.LastViewedDate.getTime() /1000));
        }else {
           if(sortOreder==SORT_ORDER.ByASC) 
                return scope.Name.compareTo(((E2_ScopeWrapper)objToCompare).scope.Name);
            else
                return ((E2_ScopeWrapper)objToCompare).scope.Name.compareTo(scope.Name); 
        }
    }
    
  }