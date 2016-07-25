/**=====================================================================
 * Appirio, Inc
 * Name: E2_Estimator_WSManager
 * Description: Modal class to E2_Estimator web service 
 * Created Date: May 13, 2016
 * Created By: Rohit Sharma (Appirio)
 * 
 * Date Modified      Modified By                  Description of the update
*  =====================================================================*/
public class E2_Estimator_WSManager {
    private final static string NODE_TYPE_SCOPE = 'scope';
    private final static string NODE_TYPE_EFFORT = 'effort';
    
    public static List<E2_TreeNode> retrieveAllScopeTreeNodesOnEstimateId(string estimateId){
        // This method is used to retrieve all the scopes child to an estimate record 
        // Ideally used for the first time load of Scope Tree 
        List<E2_TreeNode> nodeList = new List<E2_TreeNode>();
        boolean hasChildren = true;
        list<E2_Scope__c> allEstimatescopes = E2_DataUtil_WS.getChildScopesOfEstimate(estimateId);
        map<String, decimal> scopeRollhrs = generateParentHoursMap(allEstimatescopes);
        for(E2_Scope__c scope : allEstimatescopes) {
        	string scopeId = ((string)scope.Id).length() == 18 ? 
        				((string)scope.Id).substring(0, 15) : ((string)scope.Id);  
        	decimal totalhrs = scopeRollhrs.containsKey(scopeId) ? scopeRollhrs.get(scopeId) : 0;
            nodeList.add(new E2_TreeNode(scope.id, scope.name, getFormatedScopeNameForFlag(scope, totalhrs), 
                             (scope.Parent_Scope__c == NULL ? E2_Constants.HASH_TAG : scope.Parent_Scope__c), 
                             hasChildren, scope.Source_Scope__c, NODE_TYPE_SCOPE, 
                             (scope.Display_Order__c == NULL ? E2_Constants.DEFAULT_SCOPE_DISPLAY_ORDER : scope.Display_Order__c))
            );                                                
        }
        return nodeList;
    }
    
    // Code block to Calculate total LOE hrs on Ultimate parent  
    private static map<String, decimal> generateParentHoursMap(list<E2_Scope__c> allScopes) {
    	map<String, decimal> scopeRollhrs = new map<String, decimal>();
        for(E2_Scope__c scope : allScopes) {
        	if(scope.Parent_Scope__c == NULL) {
        		string scopeId = ((string)scope.Id).length() == 18 ? 
        				((string)scope.Id).substring(0, 15) : ((string)scope.Id);
        		if(!scopeRollhrs.containsKey(scopeId)) 
        			scopeRollhrs.put(scopeId, 0);
        	} else if(scope.Is_Active__c) {
        		if(!scopeRollhrs.containsKey(scope.Ultimate_Parent_Id__c)) 
        			scopeRollhrs.put(scope.Ultimate_Parent_Id__c, scope.LOE_Hrs__c);
        		else
        			scopeRollhrs.put(scope.Ultimate_Parent_Id__c, 
        					scopeRollhrs.get(scope.Ultimate_Parent_Id__c) + scope.LOE_Hrs__c);
        		
        	}
        }
        return scopeRollhrs;
    }
   	// Code block to Calculate total LOE hrs on Ultimate parent : End
    
    public static List<E2_TreeNode> retrieveAllScopeTreeNodesOnScopeGroup(string scopeGrpId){
        // This method is used to retrieve all the scopes child to an Scope Group record 
        // Ideally used for the first time load of Scope Tree 
        List<E2_TreeNode> nodeList = new List<E2_TreeNode>();
        boolean hasChildren = true;
        list<E2_Scope__c> allScopes = E2_DataUtil_WS.getChildScopesOfScopeGroup(scopeGrpId);
        map<String, decimal> scopeRollhrs = generateParentHoursMap(allScopes);
        for(E2_Scope__c scope : allScopes){
        	string scopeId = ((string)scope.Id).length() == 18 ? 
        				((string)scope.Id).substring(0, 15) : ((string)scope.Id);  
        	decimal totalhrs = scopeRollhrs.containsKey(scopeId) ? scopeRollhrs.get(scopeId) : 0;           
            nodeList.add(new E2_TreeNode(scope.id, getFormatedScopeName(scope, totalhrs), 
                             (scope.Parent_Scope__c == NULL ? E2_Constants.HASH_TAG : scope.Parent_Scope__c), 
                             hasChildren, scope.Source_Scope__c, NODE_TYPE_SCOPE)
            );                                                
        }
        return nodeList;
    }
    
    public static string getFormatedScopeName(E2_Scope__c scope){
        string name = scope.name, complexity = scope.Complexity__c, sType = scope.Scope_Item_Type__c, flag = scope.Scope_Flag__c; decimal hrs = scope.LOE_Hrs__c;
        if(hrs == 0) {
            return E2_Constants.NODE_DISPLAY_TEMPLATE_WITHOUT_EFFORTS.replace(E2_Constants.NODE_SCOPE_NAME_FORMAT, name)
                    .replace(E2_Constants.NODE_ADD_CLASS, scope.Is_Active__c ? E2_Constants.BLANK : E2_Constants.NODE_CSS_CLASS);
        }
        return E2_Constants.NODE_DISPLAY_TEMPLATE.replace(E2_Constants.NODE_SCOPE_NAME_FORMAT, name)
                       .replace(E2_Constants.NODE_EFFORT_FORMAT, hrs.format())
                       .replace(E2_Constants.NODE_ADD_CLASS, scope.Is_Active__c ? E2_Constants.BLANK : E2_Constants.NODE_CSS_CLASS);  
    }
    
    // method to calculate total LOE hrs on ultimate parent scope
    public static string getFormatedScopeNameForFlag(E2_Scope__c scope, decimal totalhrs){
        string name = scope.name, complexity = scope.Complexity__c, sType = scope.Scope_Item_Type__c, flag = scope.Scope_Flag__c; decimal hrs = scope.LOE_Hrs__c + totalhrs;
        if(hrs == 0) {
            return E2_Constants.NODE_DISPLAY_TEMPLATE_WITHOUT_EFFORTS_FLAG.replace(E2_Constants.NODE_SCOPE_NAME_FORMAT, name)
                    .replace(E2_Constants.NODE_ADD_CLASS, scope.Is_Active__c ? E2_Constants.BLANK : E2_Constants.NODE_CSS_CLASS)
                    .replace(E2_Constants.NODE_FLAG_COLOR, (scope.Scope_Flag__c == null) ? E2_Constants.BLANK : flag);
        }
        return E2_Constants.NODE_DISPLAY_TEMPLATE_FLAG.replace(E2_Constants.NODE_SCOPE_NAME_FORMAT, name)
                       .replace(E2_Constants.NODE_EFFORT_FORMAT, hrs.format())
                       .replace(E2_Constants.NODE_ADD_CLASS, scope.Is_Active__c ? E2_Constants.BLANK : E2_Constants.NODE_CSS_CLASS)
                       .replace(E2_Constants.NODE_FLAG_COLOR, (scope.Scope_Flag__c == null) ? E2_Constants.BLANK : flag);
    }
    
    // method to calculate total LOE hrs on ultimate parent scope : template Pill
    public static string getFormatedScopeName(E2_Scope__c scope, decimal totalhrs){
        string name = scope.name, complexity = scope.Complexity__c, sType = scope.Scope_Item_Type__c, flag = scope.Scope_Flag__c; decimal hrs = scope.LOE_Hrs__c + totalhrs;
        if(hrs == 0) {
            return E2_Constants.NODE_DISPLAY_TEMPLATE_WITHOUT_EFFORTS.replace(E2_Constants.NODE_SCOPE_NAME_FORMAT, name)
                    .replace(E2_Constants.NODE_ADD_CLASS, scope.Is_Active__c ? E2_Constants.BLANK : E2_Constants.NODE_CSS_CLASS);
        }
        return E2_Constants.NODE_DISPLAY_TEMPLATE.replace(E2_Constants.NODE_SCOPE_NAME_FORMAT, name)
                       .replace(E2_Constants.NODE_EFFORT_FORMAT, hrs.format())
                       .replace(E2_Constants.NODE_ADD_CLASS, scope.Is_Active__c ? E2_Constants.BLANK : E2_Constants.NODE_CSS_CLASS);  
    }
    
    public static string reparentScope(string scopeId, string parentId){
       if(parentId == E2_Constants.HASH_TAG) parentId = null;
       if(scopeId == E2_Constants.BLANK) return 'Failed to move: Current scope not identified!!!';
       try{
          update new E2_Scope__c(id = scopeId, parent_scope__c = parentId);
       }catch(Exception ex){
          return 'Failed: ' + ex.getMessage();
       }
       return scopeId; 
    }
    
    public static string deleteScope(string scopeId, string parentId){
       if(parentId == E2_Constants.HASH_TAG) parentId = null;
       if(scopeId == E2_Constants.BLANK) return 'Failed to delete: Current scope not identified!!!';
       try{
          delete new E2_Scope__c(id = scopeId);
       }catch(Exception ex){
            string errorMessage = 'Failed: ' + ex.getMessage();
            if(ex.getMessage().contains(E2_constants.INSUFFICIENT_ACCESS_OR_READONLY))
                errorMessage = 'Failed to delete selected scope: ' + E2_constants.INSUFFICIENT_ACCESS_OR_READONLY+'!!!';  
            return errorMessage;
       }
       return scopeId;
    }
    
    public static List<E2_TreeNode> getParentNodesWithEffortsOnEstimateId(string estimateId){
        List<E2_Scope__c> scopeList = new List<E2_Scope__c>();
        List<E2_TreeNode> nodeList = new List<E2_TreeNode>();
        boolean hasChildren = false;
        for(E2_Scope__c scope : E2_DataUtil_WS.getScopeDetails(estimateId)){
           hasChildren = false;
           if(scope.Child_Scopes__r.size() > 0 ||
              scope.Efforts__r.size() > 0){
              hasChildren = true;
           }
            nodeList.add(new E2_TreeNode(scope.id, getFormatedScopeName(scope , 0), 
                             E2_Constants.HASH_TAG, hasChildren, 
                             scope.Source_Scope__c, NODE_TYPE_SCOPE));
        }
        return nodeList;
    }
           
    public static List<E2_TreeNode> getImmediateChildNodesWithEffortsOnScopeId(string scopeId){
        List<E2_TreeNode> nodeList = new List<E2_TreeNode>();
        boolean hasChildren = false;             
        for(E2_Scope__c scope : E2_DataUtil_WS.getFullScopeDetails(scopeId)) {
          for(E2_Scope__c childScope : scope.Child_Scopes__r){
            nodeList.add(new E2_TreeNode(childScope.id, getFormatedScopeName(childScope, 0), 
                                         scopeId, true, '', NODE_TYPE_SCOPE));
          }                   
          for(E2_Effort__c effort : scope.Efforts__r){
            nodeList.add(new E2_TreeNode(effort.id, effort.Name, scopeId, false, 
                                         '', NODE_TYPE_EFFORT));
          }          
        }        
        return nodeList;    
    }
    
    public static E2_TreeNodeMap getClonedNodes(string scopeId, string estimateId, string parentScopeId){
        E2_TreeNodeMap scopeIdToNodeList;
        List<E2_Scope__c> scopeList = new List<E2_Scope__c>();
        List<E2_TreeNode> nodeList = new List<E2_TreeNode>();
        parentScopeId = (parentScopeId == null || parentScopeId == E2_Constants.BLANK ? E2_Constants.HASH_TAG : parentScopeId);
        Id recTypeId = E2_RecordTypeClass.getId(E2_Constants.E2_SCOPE_API_NAME, E2_Constants.SCOPE_RT_SCOPE);
        boolean hasChildren = false;
        for(E2_Scope__c scope : E2_DataUtil_WS.getFullScopeDetailsWithLimit(scopeId)){
           E2_Scope__c cloneScope = scope.clone(false, true, false, false);
           cloneScope.Source_Scope__c = scope.id;
           cloneScope.Presales_LOE__c = estimateId;
           cloneScope.Parent_Scope__c = (parentScopeId == E2_Constants.HASH_TAG ? null : parentScopeId);
           cloneScope.recordTypeId = recTypeId;    
           cloneScope.Scope_Group__c = null;                      
           scopeList.add(cloneScope);
           if(scope.Child_Scopes__r.size() > 0 ||
              scope.Efforts__r.size() > 0){
              hasChildren = true;
           }                                                
        }
        if(!scopeList.isEmpty()){
            insert scopeList;        
            for(E2_Scope__c scope : scopeList){
               nodeList.add(new E2_TreeNode(scope.id, getFormatedScopeNameForFlag(scope, 0), 
                                            parentScopeId, hasChildren, 
                                            scope.Source_Scope__c));   
            }               
        }
        scopeIdToNodeList = new E2_TreeNodeMap(scopeId, nodeList);        
        return scopeIdToNodeList;            
    }
    
    ///
    public static E2_TreeNodeMap getSelectedScopeNodes(string scopeIdCSV, string estimateId, string parentScopeId){
        E2_TreeNodeMap scopeIdToNodeList;
        List<E2_Scope__c> scopeList = new List<E2_Scope__c>();
        List<E2_TreeNode> nodeList = new List<E2_TreeNode>();
        parentScopeId = (parentScopeId == null || parentScopeId == E2_Constants.BLANK ? E2_Constants.HASH_TAG : parentScopeId);
        Id recTypeId = E2_RecordTypeClass.getId(E2_Constants.E2_SCOPE_API_NAME, E2_Constants.SCOPE_RT_SCOPE);
        boolean hasChildren = false;
        List<String> scopeIDs = scopeIdCSV.split(',');
        
        Map<Id, List<E2_Scope__c>> mapParentScopeIdToChild = new Map<Id, List<E2_Scope__c>>();
                
        List<E2_Scope__c> scopeLst = [SELECT Id, Source_Scope__c, Scope_Group__c, Name, 
                                        Presales_LOE__c, Description__c , LOE_Hrs__c, 
                                        Complexity__c, Scope_Item_Type__c, Is_Active__c, Scope_Flag__c, E2_Assumption__c,
                                        Parent_Scope__c, Parent_Scope__r.Parent_Scope__c,  Parent_Scope__r.Parent_Scope__r.Parent_Scope__c,
                                        Parent_Scope__r.Parent_Scope__r.Parent_Scope__r.Parent_Scope__c, 
                                        Parent_Scope__r.Parent_Scope__r.Parent_Scope__r.Parent_Scope__r.Parent_Scope__c,
                                        (Select Id FROM Child_Scopes__r limit 5), 
										                    (Select Id FROM Efforts__r limit 1) 
										                    FROM E2_Scope__c 
										                    WHERE Parent_Scope__c = :scopeIDs OR Id IN :scopeIDs];
                                        
        for(E2_Scope__c sc : scopeLst){
          if (!mapParentScopeIdToChild.containsKey(sc.Parent_Scope__c)){
            mapParentScopeIdToChild.put(sc.Id, new list<E2_Scope__c>());
          }
          else{
              mapParentScopeIdToChild.get(sc.Parent_Scope__c).add(sc);
          } 
        }
        system.debug('==mapParentScopeIdToChild>>' +mapParentScopeIdToChild.size()); 
        
        for(E2_Scope__c scope : scopeLst){
          if(mapParentScopeIdToChild.containsKey(parentScopeId)){
             E2_Scope__c cloneScope = scope.clone(false, true, false, false);
	           cloneScope.Source_Scope__c = scope.id;
	           cloneScope.Presales_LOE__c = estimateId;
	           cloneScope.Parent_Scope__c = (parentScopeId == E2_Constants.HASH_TAG ? null : parentScopeId);
	           cloneScope.recordTypeId = recTypeId;    
	           cloneScope.Scope_Group__c = null;                      
	           scopeList.add(cloneScope);
	           if(scope.Child_Scopes__r.size() > 0 ||
	              scope.Efforts__r.size() > 0){
	              hasChildren = true;
	           }                                                
	        }
        } 
	        if(!scopeList.isEmpty()){
	            insert scopeList;        
	            for(E2_Scope__c scope : scopeList){
	               nodeList.add(new E2_TreeNode(scope.id, getFormatedScopeNameForFlag(scope, 0), 
	                                            parentScopeId, hasChildren, 
	                                            scope.Source_Scope__c));   
	            }               
	        }
        scopeIdToNodeList = new E2_TreeNodeMap(scopeIdCSV, nodeList);
        return scopeIdToNodeList;												            
    }
    
    public static E2_TreeNodeMap getChildCloneNodes(string parentId, string sourceId, string estimateId){
        E2_TreeNodeMap scopeIdToNodeList;
        List<E2_Scope__c> scopeList = new List<E2_Scope__c>();        
        List<E2_Effort__c> effortList = new List<E2_Effort__c>();
        List<E2_TreeNode> nodeList = new List<E2_TreeNode>();
        Id recTypeId = E2_RecordTypeClass.getId(E2_Constants.E2_SCOPE_API_NAME, E2_Constants.SCOPE_RT_SCOPE);
        boolean hasChildren = false;
        
        for(E2_Scope__c scope : E2_DataUtil_WS.getFullScopeDetails(sourceId)){                               
           for(E2_Scope__c childScope : scope.Child_Scopes__r){
            E2_Scope__c cloneScope = childScope.clone(false, true, false, false);
            cloneScope.Source_Scope__c = childScope.id;
            cloneScope.Presales_LOE__c = estimateId;
            cloneScope.Parent_Scope__c = parentId;
            cloneScope.recordTypeId = recTypeId;
            cloneScope.Scope_Group__c = null;
            scopeList.add(cloneScope); 
           }           
           for(E2_Effort__c effort : scope.Efforts__r){
            E2_Effort__c cloneEffort = effort.clone(false, true, false, false);
            cloneEffort.Scope__c = parentId;
            cloneEffort.Source_Effort__c = effort.id;
            effortList.add(cloneEffort);
           }
        }        
        
        if(!effortList.isEmpty()){
            insert effortList;
        }
        
        if(!scopeList.isEmpty()){
            insert scopeList;       
            for(E2_Scope__c scope : scopeList){
               nodeList.add(new E2_TreeNode(scope.id, getFormatedScopeNameForFlag(scope, 0), 
                                             parentId, true, scope.Source_Scope__c));   
            }               
        }
        scopeIdToNodeList = new E2_TreeNodeMap(parentId, nodeList);
        return scopeIdToNodeList;    
    }
    
    
    public static E2_TreeNodeMap getChildScopeDetailNodes(string parentId) {
        E2_TreeNodeMap scopeIdToNodeList;
        List<E2_TreeNode> nodeList = new List<E2_TreeNode>();
        boolean hasChildren = false;
        for(E2_Scope__c scope : E2_DataUtil_WS.getChildScopeByParentId(parentId)){                         
           nodeList.add(new E2_TreeNode(scope.id, scope.Name, getFormatedScopeName(scope, 0), 
                             (scope.Parent_Scope__c == NULL ? E2_Constants.HASH_TAG : scope.Parent_Scope__c), 
                             (scope.Child_Scopes__r.size() > 0), scope.Source_Scope__c, NODE_TYPE_SCOPE));
        }
        scopeIdToNodeList = new E2_TreeNodeMap(parentId, nodeList);        
        return scopeIdToNodeList;  
    }
    
    public static E2_TreeNodeMap getScopeDetailNodes(string scopeId){
        List<E2_TreeNode> nodeList = new List<E2_TreeNode>();
        List<E2_Scope__c> scopes =  E2_DataUtil_WS.getScopeChildList(scopeId);
        if(!scopes.isEmpty()) {
        	decimal totalhours = 0;        	
        	
        	for(E2_Scope__c scope : E2_DataUtil_WS.getUltimateScopeLOE((scopeId.length() == 18 ? scopeId.substring(0, 15) : scopeId))) {
        		totalhours = scope.LOE_Hrs__c + totalhours; 
        	}
	        for(E2_Scope__c scope : E2_DataUtil_WS.getScopeChildList(scopeId)){           
	           nodeList.add(new E2_TreeNode(scope.id, scope.Name, getFormatedScopeName(scope, totalhours), 
	                             (scope.Parent_Scope__c == NULL ? E2_Constants.HASH_TAG : scope.Parent_Scope__c), 
	                             (scope.Child_Scopes__r.size() > 0), scope.Source_Scope__c, NODE_TYPE_SCOPE));   
	        }
        }
        E2_TreeNodeMap scopeIdToNodeList = new E2_TreeNodeMap(scopeId, nodeList);        
        return scopeIdToNodeList;            
    }
    
    public static E2_TreeNodeMap getClonedNodesTemplate(string scopeId, string scopeGrpId, string parentScopeId){
        E2_TreeNodeMap scopeIdToNodeList;
        List<E2_Scope__c> scopeList = new List<E2_Scope__c>();
        List<E2_TreeNode> nodeList = new List<E2_TreeNode>();
        parentScopeId = (parentScopeId == null || parentScopeId == E2_Constants.BLANK ? E2_Constants.HASH_TAG : parentScopeId);
        Id recTypeId = E2_RecordTypeClass.getId(E2_Constants.E2_SCOPE_API_NAME, E2_Constants.SCOPE_RT_TEMPLATE);
        boolean hasChildren = false;
        for(E2_Scope__c scope : E2_DataUtil_WS.getFullScopeDetailsWithLimit(scopeId)){
           E2_Scope__c cloneScope = scope.clone(false, true, false, false);
           cloneScope.Source_Scope__c = scope.id;
           cloneScope.Parent_Scope__c = (parentScopeId == E2_Constants.HASH_TAG ? null : parentScopeId);
           cloneScope.recordTypeId = recTypeId;    
           cloneScope.Scope_Group__c = scopeGrpId;
           cloneScope.Presales_LOE__c = null;                      
           scopeList.add(cloneScope);
           if(scope.Child_Scopes__r.size() > 0 ||
              scope.Efforts__r.size() > 0){
              hasChildren = true;
           }                                                
        }
        if(!scopeList.isEmpty()){
            insert scopeList;    
            for(E2_Scope__c scope : scopeList){
               nodeList.add(new E2_TreeNode(scope.id, getFormatedScopeName(scope, 0), 
                                            parentScopeId, hasChildren, 
                                            scope.Source_Scope__c));   
            }               
        }
        scopeIdToNodeList = new E2_TreeNodeMap(scopeId, nodeList);        
        return scopeIdToNodeList;            
    }
    
    public static E2_TreeNodeMap getChildCloneNodesTemplate(string parentId, string sourceId, string scopeGrpId){
        E2_TreeNodeMap scopeIdToNodeList;
        List<E2_Scope__c> scopeList = new List<E2_Scope__c>();        
        List<E2_Effort__c> effortList = new List<E2_Effort__c>();
        List<E2_TreeNode> nodeList = new List<E2_TreeNode>();
        Id recTypeId = E2_RecordTypeClass.getId(E2_Constants.E2_SCOPE_API_NAME, E2_Constants.SCOPE_RT_TEMPLATE);
        boolean hasChildren = false;
        
        for(E2_Scope__c scope : E2_DataUtil_WS.getFullScopeDetails(sourceId)){                               
           for(E2_Scope__c childScope : scope.Child_Scopes__r){
            E2_Scope__c cloneScope = childScope.clone(false, true, false, false);
            cloneScope.Source_Scope__c = childScope.id;
            cloneScope.Parent_Scope__c = parentId;
            cloneScope.recordTypeId = recTypeId;
            cloneScope.Scope_Group__c = scopeGrpId;
            cloneScope.Presales_LOE__c = null;
            scopeList.add(cloneScope); 
           }           
           for(E2_Effort__c effort : scope.Efforts__r){
            E2_Effort__c cloneEffort = effort.clone(false, true, false, false);
            cloneEffort.Scope__c = parentId;
            cloneEffort.Source_Effort__c = effort.id;
            effortList.add(cloneEffort);
           }
        }        
        
        if(!effortList.isEmpty()){
            insert effortList;
        }
        
        if(!scopeList.isEmpty()){
            insert scopeList;       
            for(E2_Scope__c scope : scopeList){
               nodeList.add(new E2_TreeNode(scope.id, getFormatedScopeName(scope, 0), 
                                             parentId, true, scope.Source_Scope__c));   
            }               
        }
        scopeIdToNodeList = new E2_TreeNodeMap(parentId, nodeList);
        return scopeIdToNodeList;    
    }
    
    public static string updateScopeFlag(string scopeId, string flagValue){
        string flag = null;
        if(flagValue.toLowerCase() == 'flagred'){
            flag = E2_Constants.FLAG_VALUE_RED;
        }else if(flagValue.toLowerCase() == 'flagyellow'){
            flag = E2_Constants.FLAG_VALUE_YELLOW;
        }else if(flagValue.toLowerCase() == 'flaggreen'){
            flag = E2_Constants.FLAG_VALUE_GREEN;
        }
        
        
       if(scopeId == E2_Constants.BLANK) return 'Failed to update: Current scope not identified!!!';
       try{
          update new E2_Scope__c(id = scopeId, Scope_Flag__c = flag);
       }catch(Exception ex){
          return 'Failed: ' + ex.getMessage();
       }
       return scopeId; 
    }
    
    //Method to update display order of scopes when re-parented
    public static string updateScopesDisplayOrder(string scopeJsonStr){
    	List<E2_Estimator_WSManager.ScopeWrapper> lstScopesWrapper = (List<E2_Estimator_WSManager.ScopeWrapper>)JSON.deserialize(scopeJsonStr, List<E2_Estimator_WSManager.ScopeWrapper>.class);
    	
    	List<E2_Scope__c> lstScopes = new List<E2_Scope__c>();
    	for(E2_Estimator_WSManager.ScopeWrapper scopeWrapper : lstScopesWrapper){
    		lstScopes.add(new E2_Scope__c(Id= scopeWrapper.scopeId, Display_Order__c = Integer.valueOf(scopeWrapper.displayOrder)));
    	}
    	
    	try{
    		update lstScopes;
    	}catch(Exception ex){
          return 'Failed: ' + ex.getMessage();
       }    	
    	return 'success';
    }
    
    //Method to get assets based on search string
    public static List<E2_AssetWrapper> searchAssets(string searchStr, List<string> exisitingAssetIds){
    	String searchQueryStr = 'FIND \'' + searchStr + '*\' IN ALL FIELDS RETURNING CMC_Asset__c (Name, Short_Description__c, Technologies__c,' +
	  										 ' Asset_Type__c, Asset_SubType__c, Appirio_Services_Practice__c, Primary_Contact_UserId__c, Number_of_Uses__c, Is_Recommended__c' +
	  										 ' WHERE Release_Stage__c = \'Active\'';
	  	
	  	if(exisitingAssetIds != null && exisitingAssetIds.size() > 0){
	  		searchQueryStr += ' AND Id NOT IN :exisitingAssetIds';
	  	}
			searchQueryStr += ')';
			
			List<CMC_Asset__c> listAssets = new List<CMC_Asset__c>();  										 
	  	
	  	List<E2_AssetWrapper> lstAssetsWrapper = new List<E2_AssetWrapper>();
	  	try{
	  		List<List<SObject>> results = Search.query(searchQueryStr);
	  		listAssets = (List<CMC_Asset__c>)results[0];
	  		
	  		Map<Id, String> mapAssetContributors = new Map<Id, String>();
	  		
	  		for(CMC_Asset_Contributor__c assetContibutor : [SELECT Asset__c, Contact__c, Contact__r.Name 
	  																										FROM CMC_Asset_Contributor__c
	  																										WHERE Asset__c IN :listAssets AND Primary_Contact__c = true]){
	  			if(!mapAssetContributors.containsKey(assetContibutor.Asset__c)){
	  				mapAssetContributors.put(assetContibutor.Asset__c, '');
	  			}
	  			String contributors = mapAssetContributors.get(assetContibutor.Asset__c) + assetContibutor.Contact__r.Name;
	  			mapAssetContributors.put(assetContibutor.Asset__c, contributors);
	  		}
	  		
	  		for(CMC_Asset__c assetRec : listAssets){
	  			lstAssetsWrapper.add(new E2_AssetWrapper(searchStr, assetRec.Id, assetRec.Name, assetRec.Short_Description__c, 
	  											mapAssetContributors.get(assetRec.Id), assetRec.Technologies__c, assetRec.Asset_Type__c, assetRec.Asset_SubType__c, 
	  											assetRec.Appirio_Services_Practice__c, assetRec.Number_of_Uses__c, assetRec.Is_Recommended__c));
	  		}
	  		
	  	}catch(Exception ex){
          return null;
      } 
	  	
	  	return lstAssetsWrapper;
    }
    
    public class ScopeWrapper{
    	public string scopeId;
    	public string displayOrder;
    }
}