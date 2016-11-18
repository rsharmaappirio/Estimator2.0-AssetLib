/**=====================================================================
 * Appirio, Inc
 * Name: E2_Estimator_WSManager
 * Description: Modal class to E2_Estimator web service 
 * Created Date: May 13, 2016
 * Created By: Rohit Sharma (Appirio)
 * 
 * Date Modified      Modified By                  Description of the update
 * Oct 17, 2016       Vikash Goyal                 S-445267 : Update asset JSON to remove all 
 *                                                 speical charctors from asset name and Description.
 * Oct 19, 2016       Arpita Bose                  S-448268 : Cloned scope item on right click
 * Oct 27, 2016       Rohit Sharma                 I-241822 : Total effort of scope hierarchy has not displayed over ultimate parent node
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
        	string scopeId = (string)scope.Id;  
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
        		string scopeId = (string)scope.Id;
        		if(!scopeRollhrs.containsKey(scopeId)) 
        			scopeRollhrs.put(scopeId, 0);
        	} else if(scope.Is_Active__c) {
        	    // RS : I-241822 : Total effort of scope hierarchy has not displayed over ultimate parent node
        		if(!scopeRollhrs.containsKey(scope.Ultimate_Parent_Scope__c)) 
        			scopeRollhrs.put(scope.Ultimate_Parent_Scope__c, scope.LOE_Hrs__c);
        		else
        			scopeRollhrs.put(scope.Ultimate_Parent_Scope__c, 
        					scopeRollhrs.get(scope.Ultimate_Parent_Scope__c) + scope.LOE_Hrs__c);
        		
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
        system.debug('==allScopes>>'+allScopes);
        map<String, decimal> scopeRollhrs = generateParentHoursMap(allScopes);
        system.debug('==scopeRollhrs>>'+scopeRollhrs);
        for(E2_Scope__c scope : allScopes){
        	string scopeId = (string)scope.Id;  
        	decimal totalhrs = scopeRollhrs.containsKey(scopeId) ? scopeRollhrs.get(scopeId) : 0;           
            nodeList.add(new E2_TreeNode(scope.id, getFormatedScopeName(scope, totalhrs), 
                             (scope.Parent_Scope__c == NULL ? E2_Constants.HASH_TAG : scope.Parent_Scope__c), 
                             hasChildren, scope.Source_Scope__c, NODE_TYPE_SCOPE, 
                             (scope.Display_Order__c == NULL ? E2_Constants.DEFAULT_SCOPE_DISPLAY_ORDER : scope.Display_Order__c)) 
            );                                                
        }
        return nodeList;
    }
    
    //method to get formated scope name 
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
    
    //method to reparent scopes 
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
    
    //method to delete scope 
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
    
    //method to get parent node with efforts 
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
    
    //method to get immediate child node with efforts        
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
        
    // Method to clonned scope from scope library
    public static List<E2_TreeNode> getSelectedScopeNodes(string scopeIdCSV, string estimateId, string parentScopeId) {
        List<E2_TreeNode> nodeList = new List<E2_TreeNode>();
        parentScopeId = (parentScopeId == null || parentScopeId == E2_Constants.BLANK ? E2_Constants.HASH_TAG : parentScopeId);
        Id recTypeId = E2_RecordTypeClass.getId(E2_Constants.E2_SCOPE_API_NAME, E2_Constants.SCOPE_RT_SCOPE);
		boolean hasChildren = true;
		List<E2_Scope__c> scopeList = new List<E2_Scope__c>();
        map<string,E2_Scope__c> hasChildrenScope = new map<string,E2_Scope__c>();
        map<string, E2_Scope__c> clonedSourceMap = new map<string, E2_Scope__c>();
        
        List<String> scopeIDs = scopeIdCSV.split(E2_constants.COMMA);        
        
        for(E2_Scope__c scope : E2_DataUtil_WS.getFullScopesDetailsWithLimit(scopeIDs)){
           E2_Scope__c cloneScope = scope.clone(false, true, false, false);
           cloneScope.Source_Scope__c = scope.id;
           cloneScope.Presales_LOE__c = estimateId;
           cloneScope.Parent_Scope__c = (parentScopeId == E2_Constants.HASH_TAG ? null : parentScopeId);
           cloneScope.recordTypeId = recTypeId;    
           cloneScope.Scope_Group__c = null;                      
           scopeList.add(cloneScope);
           clonedSourceMap.put(scope.id, cloneScope);
           if(scope.Efforts__r.size() > 0 || scope.E2_Recommended_Assets__r.size() > 0
           	   || scope.Questions__r.size() > 0){
              	hasChildrenScope.put(scope.id, scope);
           }                                                
        }
        if(!scopeList.isEmpty()){
            insert scopeList;   
            cloneScopesChild(scopeList, hasChildrenScope, clonedSourceMap);
            reParentClonedScopes(clonedSourceMap);
            set<Id> scopesId = new set<Id>();
            for(E2_Scope__c scope : scopeList) {
                scopesId.add(scope.Id);
            }
            
            list<E2_Scope__c> allscopes = E2_DataUtil_WS.getChildScopesById(scopesId);
            map<String, decimal> scopeRollhrs = generateParentHoursMap(allscopes);
            for(E2_Scope__c scope : allscopes) {
            	string scopeId = (string)scope.Id;  
            	decimal totalhrs = scopeRollhrs.containsKey(scopeId) ? scopeRollhrs.get(scopeId) : 0;
                nodeList.add(new E2_TreeNode(scope.id, scope.name, getFormatedScopeNameForFlag(scope, totalhrs), 
                                 (scope.Parent_Scope__c == NULL ? E2_Constants.HASH_TAG : scope.Parent_Scope__c), 
                                 hasChildren, scope.Source_Scope__c, NODE_TYPE_SCOPE, 
                                 (scope.Display_Order__c == NULL ? E2_Constants.DEFAULT_SCOPE_DISPLAY_ORDER : scope.Display_Order__c))
                );                                                
            }
        }
        return nodeList;												            
    }
    
    // private method to insert scope child efforts and update parent hierarchy 
    private static void cloneScopesChild(List<E2_Scope__c> scopeList, 
    									map<string,E2_Scope__c> hasChildrenScope,
    									map<string, E2_Scope__c> clonedSourceMap) {
    	List<E2_Effort__c> effortList = new List<E2_Effort__c>();
    	List<E2_Recommended_Asset__c> assetList = new List<E2_Recommended_Asset__c>();
    	map<Id, E2_Question__c> questionsmap = new map<Id, E2_Question__c>();
        for(E2_Scope__c scope : scopeList) {
        	if(hasChildrenScope.containsKey(scope.Source_Scope__c)) {
            	E2_Scope__c sourceScope = hasChildrenScope.get(scope.Source_Scope__c);          
			    for(E2_Effort__c effort : sourceScope.Efforts__r){
			    	E2_Effort__c cloneEffort = effort.clone(false, true, false, false);
			        cloneEffort.Scope__c = scope.Id;
			        cloneEffort.Source_Effort__c = effort.id;
			        effortList.add(cloneEffort);
			    }
			    for(E2_Recommended_Asset__c asset : sourceScope.E2_Recommended_Assets__r) {
		           	E2_Recommended_Asset__c clonedAsset = asset.clone(false, true, false, false);
		           	clonedAsset.Scope__c = scope.Id;
		           	assetList.add(clonedAsset);	
		    	}
		    	for(E2_Question__c sourceQuestion : sourceScope.Questions__r) {
		    		E2_Question__c clonedQuestion  = sourceQuestion.clone(false, true, false, false);
		    		clonedQuestion.Scope__c = scope.Id;
		    		clonedQuestion.Source_Question__c = sourceQuestion.Id;
		    		questionsmap.put(sourceQuestion.Id, clonedQuestion);
		    	}
            }   
		}
        if(!effortList.isEmpty()) {
        	insert effortList;
        }
        if(!assetList.isEmpty()) {
        	insert assetList;
        }
        if(!questionsmap.isEmpty()) {
        	List<E2_Answer__c> allAnswers = E2_DataUtil_WS.getAnswersDetails(questionsmap.KeySet());
        	set<Id> questionsIds = questionsmap.KeySet();
        	for(Id questionsId : questionsIds) {
        		Boolean hasAnswers = false;
        		for(E2_Answer__c sourceAnswer : allAnswers) {
        			if(sourceAnswer.Question__c == questionsId) {
        				hasAnswers = true;
        			}
        		} 
        		if(hasAnswers == false)
        			questionsmap.remove(questionsId);
        	}
        	insert questionsmap.values();
        	map<id,E2_Answer__c> answersList = new map<id,E2_Answer__c>();
        	map<id,List<E2_Action_Scope__c>> actionScopes = new map<id,List<E2_Action_Scope__c>>();
        	for(E2_Answer__c sourceAnswer : allAnswers) {
        		E2_Answer__c clonedAnswer = sourceAnswer.clone(false, true, false, false);
        		clonedAnswer.Question__c = questionsmap.get(sourceAnswer.Question__c).Id;
        		clonedAnswer.Source_Answer__c = sourceAnswer.Id;
        		answersList.put(sourceAnswer.Id,clonedAnswer);
        		if(!sourceAnswer.Action_Scopes__r.isEmpty()) {
        			actionScopes.put(sourceAnswer.Id,sourceAnswer.Action_Scopes__r);
        		}
        	}
        	if(!answersList.isEmpty()) {
	        	insert answersList.values();
	        	List<E2_Action_Scope__c> actionscopestoinsert = new List<E2_Action_Scope__c>();
	        	for(Id sourceAnswer : answersList.keySet()) {
	        		if(actionScopes.containsKey(sourceAnswer)) {
	        			for(E2_Action_Scope__c actionScope : actionScopes.get(sourceAnswer)) {
	        				if(clonedSourceMap.containsKey(actionScope.Scope__c)) {
	        					E2_Scope__c clonedScope = clonedSourceMap.get(actionScope.Scope__c);
	        					E2_Answer__c clonedAnswer = answersList.get(sourceAnswer);
	        					string uniqueKey = clonedAnswer.Id + E2_Constants.BLANK + clonedScope.Id;
	        					actionscopestoinsert.add(new E2_Action_Scope__c(Answer__c = clonedAnswer.Id,
                									Scope__c = clonedScope.Id,
                									Unique_Key__c = uniqueKey));
	        				}			        		
			        	}
	        		}
	        	}
	        	if(!actionscopestoinsert.isEmpty()) {
	        		insert actionscopestoinsert;
	        	}	        	
	        }
        }
    }
    
    private static void reParentClonedScopes(map<string, E2_Scope__c> clonedSourceMap) {
        // RS : Re-parent all cloned child scopes in new estimate/scope group hierarchy 
        list<E2_Scope__c> scopesToUpdate = new list<E2_Scope__c>();
        for(E2_Scope__c scope : E2_dataUtil_WS.getParentScopeIds(clonedSourceMap.KeySet())) {
         	E2_Scope__c clonedScope = clonedSourceMap.get(scope.Id);
            string parentScope = null;
            if(scope.Parent_Scope__c != null && clonedSourceMap.containsKey(scope.Parent_Scope__c)) {
            	parentScope = scope.Parent_Scope__c;
            } else if(scope.Parent_Scope__r.Parent_Scope__c != null && clonedSourceMap.containsKey(scope.Parent_Scope__r.Parent_Scope__c)) {
            	parentScope = scope.Parent_Scope__r.Parent_Scope__c;
            } else if(scope.Parent_Scope__r.Parent_Scope__r.Parent_Scope__c != null 
            		&& clonedSourceMap.containsKey(scope.Parent_Scope__r.Parent_Scope__r.Parent_Scope__c)) {
            	parentScope = scope.Parent_Scope__r.Parent_Scope__r.Parent_Scope__c;
            } else if(scope.Parent_Scope__r.Parent_Scope__r.Parent_Scope__r.Parent_Scope__c != null 
            		&& clonedSourceMap.containsKey(scope.Parent_Scope__r.Parent_Scope__r.Parent_Scope__r.Parent_Scope__c)) {
            	parentScope = scope.Parent_Scope__r.Parent_Scope__r.Parent_Scope__r.Parent_Scope__c;
            } else if(scope.Parent_Scope__r.Parent_Scope__r.Parent_Scope__r.Parent_Scope__r.Parent_Scope__c != null 
            		&& clonedSourceMap.containsKey(scope.Parent_Scope__r.Parent_Scope__r.Parent_Scope__r.Parent_Scope__r.Parent_Scope__c)) {
            	parentScope = scope.Parent_Scope__r.Parent_Scope__r.Parent_Scope__r.Parent_Scope__r.Parent_Scope__c;
            }
            if(parentScope != null && clonedScope.Id != null) {            		
            	E2_Scope__c scopeToUpdate = new E2_Scope__c(Id = clonedScope.Id, Parent_Scope__c = clonedSourceMap.get(parentScope).Id);
            	scopesToUpdate.add(scopeToUpdate);
            }
		}
        if(!scopesToUpdate.isEmpty()) {
        	update scopesToUpdate;
        }
    }
    //method to get child scope details 
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
    
    //method to get scope detail nodes 
    public static E2_TreeNodeMap getScopeDetailNodes(string scopeId){
        List<E2_TreeNode> nodeList = new List<E2_TreeNode>();
        List<E2_Scope__c> scopes =  E2_DataUtil_WS.getScopeChildList(scopeId);
        if(!scopes.isEmpty()) {
        	decimal totalhours = 0;        	
        	string scopeIdString = scopeId.length() == 18 ? scopeId.substring(0, 15) : scopeId;
        	for(E2_Scope__c scope : E2_DataUtil_WS.getUltimateScopeLOE(scopeIdString)) {
        		if(scope.Ultimate_Parent_Id__c.equals(scopeIdString)) 
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
    
    //method to get clonned nodes template 
    public static List<E2_TreeNode> getClonedNodesTemplate(string scopeId, string scopeGrpId, string parentScopeId){
        List<E2_TreeNode> nodeList = new List<E2_TreeNode>();
        boolean hasChildren = true;
        parentScopeId = (parentScopeId == null || parentScopeId == E2_Constants.BLANK ? E2_Constants.HASH_TAG : parentScopeId);
        Id recTypeId = E2_RecordTypeClass.getId(E2_Constants.E2_SCOPE_API_NAME, E2_Constants.SCOPE_RT_TEMPLATE);
		
		List<E2_Scope__c> scopeList = new List<E2_Scope__c>();
        map<string,E2_Scope__c> hasChildrenScope = new map<string,E2_Scope__c>();
        map<string, E2_Scope__c> clonedSourceMap = new map<string, E2_Scope__c>();
        
        List<String> scopeIDs = scopeId.split(E2_constants.COMMA);        
        
        for(E2_Scope__c scope : E2_DataUtil_WS.getFullScopesDetailsWithLimit(scopeIDs)){
           E2_Scope__c cloneScope = scope.clone(false, true, false, false);
           cloneScope.Source_Scope__c = scope.id;
           cloneScope.Parent_Scope__c = (parentScopeId == E2_Constants.HASH_TAG ? null : parentScopeId);
           cloneScope.recordTypeId = recTypeId;    
           cloneScope.Scope_Group__c = scopeGrpId;
           cloneScope.Presales_LOE__c = null;                      
           scopeList.add(cloneScope);
           clonedSourceMap.put(scope.id, cloneScope);
           if(scope.Efforts__r.size() > 0){
              	hasChildrenScope.put(scope.id, scope);
           }                                                
        }
        if(!scopeList.isEmpty()){
            insert scopeList;   
            cloneScopesChild(scopeList, hasChildrenScope, clonedSourceMap);
            reParentClonedScopes(clonedSourceMap);
            set<Id> scopesId = new set<Id>();
            for(E2_Scope__c scope : scopeList) {
                scopesId.add(scope.Id);
            }
            
            list<E2_Scope__c> allscopes = E2_DataUtil_WS.getChildScopesById(scopesId);
            map<String, decimal> scopeRollhrs = generateParentHoursMap(allscopes);
            for(E2_Scope__c scope : allscopes) {
            	string newScopeId = (string)scope.Id;  
            	decimal totalhrs = scopeRollhrs.containsKey(newScopeId) ? scopeRollhrs.get(newScopeId) : 0;
                nodeList.add(new E2_TreeNode(scope.id, scope.name, getFormatedScopeNameForFlag(scope, totalhrs), 
                                 (scope.Parent_Scope__c == NULL ? E2_Constants.HASH_TAG : scope.Parent_Scope__c), 
                                 hasChildren, scope.Source_Scope__c, NODE_TYPE_SCOPE, 
                                 (scope.Display_Order__c == NULL ? E2_Constants.DEFAULT_SCOPE_DISPLAY_ORDER : scope.Display_Order__c))
                );                                                
            }
        }        
        return nodeList;            
    }
    
    //method to update scope flag to colors based on flag value 
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
    		lstScopes.add(new E2_Scope__c(Id= scopeWrapper.scopeId, 
    		                              Display_Order__c = Integer.valueOf(scopeWrapper.displayOrder),
    		                              Sequence__c = Integer.valueOf(scopeWrapper.sequence)));
    	}
    	
    	try{
    		update lstScopes;
    	}catch(Exception ex){
          return 'Failed: ' + ex.getMessage();
       }    	
    	return 'success';
    }
    
    //Method to get assets based on search string
    public static E2_AssetWrapperMap searchAssets(string searchStr, List<string> exisitingAssetIds){   	
			E2_AssetWrapperMap assetWrapperMap;
			List<CMC_Asset__c> listAssets = new List<CMC_Asset__c>();  										 
	  	
	  	List<E2_AssetWrapper> lstAssetsWrapper = new List<E2_AssetWrapper>();
	  	try{
	  	    system.debug('searchStr>>'+searchStr); 
	  	    system.debug('exisitingAssetIds>>'+exisitingAssetIds); 
	  		List<List<SObject>> results = E2_DataUtil_WS.getRelatedAssets(searchStr, exisitingAssetIds);
	  		system.debug('results>>'+results); 
	  		listAssets = (List<CMC_Asset__c>)results[0];
	  		
	  		Map<Id, String> mapAssetContributors = new Map<Id, String>();
	  		system.debug('listAssets>>'+listAssets); 
	  		for(CMC_Asset_Contributor__c assetContibutor : E2_DataUtil_WS.getAssetContributors(listAssets)){
	  		  system.debug('==assetContibutor>>'+assetContibutor);
	  			if(!mapAssetContributors.containsKey(assetContibutor.Asset__c)){
	  				mapAssetContributors.put(assetContibutor.Asset__c, '');
	  			}
	  			String contributors = mapAssetContributors.get(assetContibutor.Asset__c) + assetContibutor.Contact__r.Name;
	  			mapAssetContributors.put(assetContibutor.Asset__c, contributors);
	  		}
	  		
	  		for(CMC_Asset__c assetRec : listAssets){
	  			lstAssetsWrapper.add(new E2_AssetWrapper(assetRec.Id, assetRec.Name, 
	  			                    (assetRec.Short_Description__c == null ? '' : assetRec.Short_Description__c),	
	  			                    (mapAssetContributors.get(assetRec.Id) == null ? '' : mapAssetContributors.get(assetRec.Id)), 
	  			                    (assetRec.Technologies__c == null ? '' : assetRec.Technologies__c), 
	  			                    (assetRec.Release_Stage__c == null ? '' : assetRec.Release_Stage__c),
	  			                    (assetRec.Asset_Type__c == null ? '' : assetRec.Asset_Type__c), 
	  			                    (assetRec.Asset_SubType__c == null ? '' : assetRec.Asset_SubType__c), 
	  			                    (assetRec.Appirio_Services_Practice__c == null ? '' : assetRec.Appirio_Services_Practice__c), 
	  			                    (assetRec.Number_of_Uses__c == null ? 0 : assetRec.Number_of_Uses__c), 
	  			                    (assetRec.Is_Recommended__c == null ? false : assetRec.Is_Recommended__c), 
	  			                    (assetRec.Total_Hours__c == null ? 0 : assetRec.Total_Hours__c), 
	  			                    (assetRec.Reuse_LOE__c == null ? 0 : assetRec.Reuse_LOE__c)));
	  		}
	  		assetWrapperMap = new E2_AssetWrapperMap(searchStr, lstAssetsWrapper);
	  	}catch(Exception ex){
          return null;
      } 
	  	
	  	//return lstAssetsWrapper;
	  	return assetWrapperMap;
    }
    
    //method to get all the existing assets for a Scope 
    public static String getExistingAssetsForScope(string scopeId){
        String assetsRecsJson;
        Map<Id, E2_Recommended_Asset__c> recommendedAssetsMap = new Map<Id, E2_Recommended_Asset__c>();
      	try{
          	for (E2_Recommended_Asset__c assetRec : E2_DataUtil_WS.getRecommendedAssetsForScope(scopeId)){
           			recommendedAssetsMap.put(assetRec.Asset__c, assetRec);																			
           	}
           	
           	List<E2_AssetWrapper> lstExistingAssets = new List<E2_AssetWrapper>();
           	if(recommendedAssetsMap.keySet().size() > 0){
           		Map<String, CMC_Asset__c> mapAssets = E2_DataUtil_WS.getAssetsMap(recommendedAssetsMap.keySet());
           		for(Id assetId : mapAssets.keySet()){
           		    CMC_Asset__c assetRec = mapAssets.get(assetId);
                    lstExistingAssets.add(new E2_AssetWrapper(recommendedAssetsMap.get(assetId).Id, assetId, assetRec.Name, 
                                                (assetRec.Short_Description__c == null ? '' : assetRec.Short_Description__c), 
                                                (assetRec.Technologies__c == null ? '' : assetRec.Technologies__c),
                                                (assetRec.Release_Stage__c == null ? '' : assetRec.Release_Stage__c),
                                                true, false, 
                                                (assetRec.Total_Hours__c == null ? 0 : assetRec.Total_Hours__c), 
    	  			                            (assetRec.Reuse_LOE__c == null ? 0 : assetRec.Reuse_LOE__c)));
           		}
           	}
           	
           	if(lstExistingAssets.size() > 0){
            	assetsRecsJson = '{';        
    	        
    	        for(E2_AssetWrapper assetWrapper : lstExistingAssets){	        	        	
    	        	assetsRecsJson += '"'+ assetWrapper.id + '" : {"recommendedAssetRecId" : "' + assetWrapper.recommendedAssetRecId + '",' + 
    	        	                                                '"id" : "' + assetWrapper.id + '", ' +
    	        	                                                // VG : S-445267 : replaceAll special charcter in asset name and description
    	        	                                                '"assetName" : "' + (assetWrapper.assetName).replaceAll('"', '\\\\"').replaceAll('[\r\n]','') + '", ' +
    	        	                                                '"description" : "' + (assetWrapper.description).replaceAll('"', '\\\\"').replaceAll('[\r\n]','') + '", ' +
    	        	                                                '"technologies" : "' + assetWrapper.technologies + '", ' +
    	        	                                                '"totalHours" : "' + assetWrapper.totalHours + '", ' +
    	        	                                                '"reuseLoe" : "' + assetWrapper.reuseLoe + '", ' +
    	        	                                                '"releaseStage" : "' + assetWrapper.releaseStage + '", ' +
    	        	                                                '"isExisting" : "true", ' + 
    	        	                                                '"isDeleted" : "false"},'; 
    	        }
    	        
    	        if(assetsRecsJson != '' && assetsRecsJson.endsWith(',')){
    	        	assetsRecsJson = assetsRecsJson.removeEnd(',');
    	        }
    	        
    	        assetsRecsJson += '}';
            }
           	
      	}catch(Exception ex){
          return null;
        }
        return assetsRecsJson;
    }
    
    //method to update scope status as active or inactive 
    public static string updateScopesStatus(string complexity, string scopeToActivate, string scopeToDeactivate,
    										string allscopesIds) {
    	list<E2_Scope__c> scopesToUpdate = new list<E2_Scope__c>();
    	for(string scopeid : allscopesIds.split(E2_constants.COMMA)) {
    		E2_Scope__c scope = NULL;
    		if(!string.isBlank(complexity)) {
    			scope = new E2_Scope__c(Complexity__c = complexity, id = scopeid);
    		}
    		if(!string.isBlank(scopeToActivate) && scopeToActivate.contains(scopeid)) {
    			if(scope == NULL)
    				scope = new E2_Scope__c(Is_Active__c = true, id = scopeid);
    			else
    				scope.Is_Active__c = true;
    		}else if(!string.isBlank(scopeToDeactivate) && scopeToDeactivate.contains(scopeid)) {
    			if(scope == NULL)
    				scope = new E2_Scope__c(Is_Active__c = false, id = scopeid);
    			else
    				scope.Is_Active__c = false;
    		}
    		if(scope != NULL) {
    			scopesToUpdate.add(scope);
    		}
    	}
    	if(!scopesToUpdate.isEmpty())
    		update scopesToUpdate;
    	return 'Success';
    }
    
    // AB : S-448268 : Cloned scope item on right click
    public static List<E2_TreeNode> cloneScopeWithChild(string scopeIdCSV) {
        List<E2_Scope__c> scopeList = new List<E2_Scope__c>();
        Map<string, E2_Scope__c> hasChildrenScope = new Map<string, E2_Scope__c>();
        Map<string, E2_Scope__c> clonedSourceMap = new Map<string, E2_Scope__c>();
        List<E2_TreeNode> nodeList = new List<E2_TreeNode>();
        boolean hasChildren = true;
        List<String> scopeIDs = scopeIdCSV.split(E2_constants.COMMA);        
        
        for(E2_Scope__c scope : E2_DataUtil_WS.getFullScopesDetailsWithLimit(scopeIDs)){
           E2_Scope__c cloneScope = scope.clone(false, true, false, false);
           cloneScope.Source_Scope__c = scope.id;
           scopeList.add(cloneScope);
           clonedSourceMap.put(scope.id, cloneScope);
           if(scope.Efforts__r.size() > 0 || scope.E2_Recommended_Assets__r.size() > 0
               || scope.Questions__r.size() > 0){
                hasChildrenScope.put(scope.id, scope);
           }                                                
        }
        if(!scopeList.isEmpty()){
            insert scopeList;   
            cloneScopesChild(scopeList, hasChildrenScope, clonedSourceMap);
            reParentClonedScopes(clonedSourceMap);
            set<Id> scopesId = new set<Id>();
            for(E2_Scope__c scope : scopeList) {
                scopesId.add(scope.Id);
            }
            
            list<E2_Scope__c> allscopes = E2_DataUtil_WS.getChildScopesById(scopesId);
            map<String, decimal> scopeRollhrs = generateParentHoursMap(allscopes);
            for(E2_Scope__c scope : allscopes) {
            	string scopeId = (string)scope.Id;  
            	decimal totalhrs = scopeRollhrs.containsKey(scopeId) ? scopeRollhrs.get(scopeId) : 0;
                nodeList.add(new E2_TreeNode(scope.id, scope.name, getFormatedScopeNameForFlag(scope, totalhrs), 
                                 (scope.Parent_Scope__c == NULL ? E2_Constants.HASH_TAG : scope.Parent_Scope__c), 
                                 hasChildren, scope.Source_Scope__c, NODE_TYPE_SCOPE, 
                                 (scope.Display_Order__c == NULL ? E2_Constants.DEFAULT_SCOPE_DISPLAY_ORDER : scope.Display_Order__c))
                );                                                
            }
        }
        
        return nodeList; 
    }
    
    //wrapper class for scope 
    public class ScopeWrapper{
    	public string scopeId;
    	public string displayOrder;
    	public string sequence;
    }
    
    // Start : Estimate clone functionality
    // clone Estimate 
    public static string cloneEstimate(string estimateId) {
        if(!string.isBlank(estimateId)) {
            List<CMC_Presales_LOE__c> estimatesToClone = E2_DataUtil_WS.getEstimateFullDetailById(estimateId);
            CMC_Presales_LOE__c estimateToClone = estimatesToClone.get(0);
            CMC_Presales_LOE__c clonedEstimate = estimateToClone.clone(false, true, false, false);
            clonedEstimate.Name = 'Cloned ' + estimateToClone.Name;
            try {
                insert clonedEstimate;
                return clonedEstimate.id;
            } catch(Exception ex) {
                return 'Failed: ' + ex.getMessage();
            }
        }
        return 'Failed: Invalid estimateId';
    } 
    
    // clone Scopes
    public static string cloneEstimateScopes(string estimateId, string newEstimateId) {
        if(!string.isBlank(estimateId)) {
            List<E2_Scope__c> scopeList = new List<E2_Scope__c>();
            Map<string, E2_Scope__c> hasChildrenScope = new Map<string, E2_Scope__c>();
            Map<string, E2_Scope__c> clonedSourceMap = new Map<string, E2_Scope__c>();

            for(E2_Scope__c scope : E2_DataUtil_WS.getFullScopesDetailsByEstimateId(estimateId)){
                E2_Scope__c cloneScope = scope.clone(false, true, false, false);
                cloneScope.Source_Scope__c = scope.id;
                cloneScope.Presales_LOE__c = newEstimateId;
                scopeList.add(cloneScope);
                clonedSourceMap.put(scope.id, cloneScope);
                if(scope.Efforts__r.size() > 0 || scope.E2_Recommended_Assets__r.size() > 0
                    || scope.Questions__r.size() > 0){
                    hasChildrenScope.put(scope.id, scope);
                }                                                
            }
            if(!scopeList.isEmpty()) {
                try {
                    insert scopeList;   
                    cloneScopesChild(scopeList, hasChildrenScope, clonedSourceMap);
                    reParentClonedScopes(clonedSourceMap);
                } catch (Exception ex) {
                    deleteEstimate(newEstimateId);
                    return 'Failed: ' + ex.getMessage();
                }   
            }
        }
        return 'success';
    }
    
    // clone Capacity
    public static string cloneEstimateCapacity(string estimateId, string newEstimateId) {
        if(!string.isBlank(estimateId)) {
            List<E2_Capacity__c> capacityList = new List<E2_Capacity__c>();
            for(E2_Capacity__c capacity : E2_DataUtil_WS.getCapacityListByEstimateId(estimateId)){
                E2_Capacity__c clonedCapacity = capacity.clone(false, true, false, false);
                clonedCapacity.Estimator__c = newEstimateId;
                capacityList.add(clonedCapacity);
            }
            if(!capacityList.isEmpty()) {
                try {
                    insert capacityList;
                } catch (Exception ex) {
                    deleteEstimate(newEstimateId);
                    return 'Failed: ' + ex.getMessage();
                }
            }
        }
        return 'success';
    }
    
    // clone estimate milestones
    public static string cloneEstimateMilestone(string estimateId, string newEstimateId) {
        map<id, E2_Estimate_Week_Milestone__c> clonedMilestoneWeeks = new map<id, E2_Estimate_Week_Milestone__c>();
        map<id, E2_Estimate_Milestone__c> clonedEstimateMilestones = new map<id, E2_Estimate_Milestone__c>();
        list<E2_Estimate_Milestone_Week__c> clonedEstimateMilestoneWeekMapping = new list<E2_Estimate_Milestone_Week__c>();
        // clone estimate weeks
        for(E2_Estimate_Week_Milestone__c estimateWeek : [SELECT Id, Name, Date__c, Estimate__c, Milestone__c, Order__c, 
                                                          Phase__c 
                                                          FROM E2_Estimate_Week_Milestone__c 
                                                          WHERE Estimate__c =: estimateId]) {
            E2_Estimate_Week_Milestone__c clonedEstimateWeek = estimateWeek.clone(false, true, false, false);
            clonedEstimateWeek.Estimate__c = newEstimateId;
            clonedMilestoneWeeks.put(estimateWeek.Id, clonedEstimateWeek);
        }
        // clone estimate milestones
        for(E2_Estimate_Milestone__c estimateMilestone : [SELECT Id, Estimate__c, Order__c, Milestone1__c, Milestone2__c  
                                                        FROM E2_Estimate_Milestone__c 
                                                        WHERE Estimate__c =: estimateId]) {
            E2_Estimate_Milestone__c clonedEstimateMilestone = estimateMilestone.clone(false, true, false, false);
            clonedEstimateMilestone.Estimate__c = newEstimateId;
            clonedEstimateMilestones.put(estimateMilestone.Id, clonedEstimateMilestone);
        }
        
        try {
           if(!clonedMilestoneWeeks.isEmpty()) {
            insert clonedMilestoneWeeks.values();
           }
           if(!clonedEstimateMilestones.isEmpty()) {
            insert clonedEstimateMilestones.values();
           }
           if(!clonedMilestoneWeeks.isEmpty() && !clonedEstimateMilestones.isEmpty()) {
             // clone estimate resource weeks
             for(E2_Estimate_Milestone_Week__c milestoneWeek : [SELECT Estimate_Milestone__c, Estimate_Week_Milestone__c, Text__c, TextColorCode__c 
                                                               FROM E2_Estimate_Milestone_Week__c 
                                                               WHERE Estimate_Milestone__c IN: clonedEstimateMilestones.keySet() AND
                                                                     Estimate_Week_Milestone__c IN: clonedMilestoneWeeks.keySet()]) {
                E2_Estimate_Milestone_Week__c clonedmilestoneWeek = milestoneWeek.clone(false, true, false, false);
                clonedmilestoneWeek.Estimate_Milestone__c = clonedEstimateMilestones.get(milestoneWeek.Estimate_Milestone__c).id;
                clonedmilestoneWeek.Estimate_Week_Milestone__c = clonedMilestoneWeeks.get(milestoneWeek.Estimate_Week_Milestone__c).id;
                clonedEstimateMilestoneWeekMapping.add(clonedmilestoneWeek);
             }
             insert clonedEstimateMilestoneWeekMapping;
           }
        } catch(Exception ex) {
            deleteEstimate(newEstimateId);
            return 'Failed: ' + ex.getMessage();
        }
        return 'success';
    }
    
    // clone timeline with rate card
    public static string cloneEstimateTimeline(string estimateId, string newEstimateId) {
        if(!string.isBlank(estimateId)) {
            try {
                map<Id, E2_Estimate_Rate_Card__c> clonedRateCards = cloneRateCards( estimateId, newEstimateId);
                if(!clonedRateCards.isEmpty()) {
                    cloneEstimateTimeline( estimateId, newEstimateId, clonedRateCards);
                }
            } catch (Exception ex) {
                deleteEstimate(newEstimateId);
                return 'Failed: ' + ex.getMessage();
            }
        }
        return 'success';
    }
    
    // clone etimate rate cards
    private static map<id, E2_Estimate_Rate_Card__c> cloneRateCards(string estimateId, string newEstimateId) {
        map<id, E2_Estimate_Rate_Card__c> ratecardsToClone = new map<id, E2_Estimate_Rate_Card__c>();
        for(E2_Estimate_Rate_Card__c estimateRateCards : [SELECT Id, Bill_Rate__c, Category__c, Code__c, Discounted_Rate__c, Estimate__c, 
                                                          Practice__c, Rate_Card__c, Region__c, Resource_Cost__c, Resource_Role__c 
                                                          FROM E2_Estimate_Rate_Card__c 
                                                          WHERE Estimate__c =: estimateId]) {
            E2_Estimate_Rate_Card__c clonedRateCard = estimateRateCards.clone(false, true, false, false);
            clonedRateCard.Estimate__c = newEstimateId;
            ratecardsToClone.put(estimateRateCards.Id, clonedRateCard);
        }
        if(!ratecardsToClone.isEmpty()) {
            insert ratecardsToClone.values();
        }
        return ratecardsToClone;
    }
    
    // clone Timeline
    private static void cloneEstimateTimeline(string estimateId, string newEstimateId, map<Id, E2_Estimate_Rate_Card__c> clonedRateCards) {
        map<id, CMC_Estimate_Week__c> clonedEstimateWeeks = new map<id, CMC_Estimate_Week__c>();
        map<id, CMC_Estimate_Resource__c> clonedEstimateResources = new map<id, CMC_Estimate_Resource__c>();
        list<CMC_Estimate_Resource_Week__c> clonedEstimateResourceWeekMapping = new list<CMC_Estimate_Resource_Week__c>();
        // clone estimate weeks
        for(CMC_Estimate_Week__c estimateWeek : [SELECT Id, Name, Date__c, Estimate__c, Milestone__c, E2_Milestone1__c, E2_Milestone2__c, 
                                                E2_Milestone1ColorCode__c, E2_Milestone2ColorCode__c, E2_MilestoneColorCode__c, Order__c, 
                                                Phase__c, E2_PhaseColorCode__c 
                                                FROM CMC_Estimate_Week__c 
                                                WHERE Estimate__c =: estimateId]) {
            CMC_Estimate_Week__c clonedEstimateWeek = estimateWeek.clone(false, true, false, false);
            clonedEstimateWeek.Estimate__c = newEstimateId;
            clonedEstimateWeeks.put(estimateWeek.Id, clonedEstimateWeek);
        }
        if(!clonedEstimateWeeks.isEmpty()) {
            // clone estimate resources
            for(CMC_Estimate_Resource__c estimateRecource : [SELECT Id, Name, CurrencyIsoCode, Estimate__c, Cost__c, Order__c, Rate__c, Role__c, 
                                                            Skill__c, Hours_Type__c, Is_Used_For_Calculations__c, Rate_Code__c, Resource_Column__c, 
                                                            E2_Estimate_Rate_Card__c, E2_Role__c 
                                                            FROM CMC_Estimate_Resource__c 
                                                            WHERE Estimate__c =: estimateId]) {
                CMC_Estimate_Resource__c clonedEstimateRecource = estimateRecource.clone(false, true, false, false);
                clonedEstimateRecource.Estimate__c = newEstimateId;
                clonedEstimateRecource.E2_Estimate_Rate_Card__c = estimateRecource.E2_Estimate_Rate_Card__c != NULL && 
                                                                    clonedRateCards.containsKey(estimateRecource.E2_Estimate_Rate_Card__c) ? 
                                                                    clonedRateCards.get(estimateRecource.E2_Estimate_Rate_Card__c).id : NULL;
                clonedEstimateResources.put(estimateRecource.Id, clonedEstimateRecource);
            }
            
            // insert Resource timeline 
            insert clonedEstimateWeeks.values();
            if(!clonedEstimateResources.isEmpty()) {
                insert clonedEstimateResources.values();
                // clone estimate resource weeks
                for(CMC_Estimate_Resource_Week__c estimateResourceWeek : [SELECT Hours__c, Estimate_Resource__c, Estimate_Week__c 
                                                                          FROM CMC_Estimate_Resource_Week__c 
                                                                          WHERE Estimate_Resource__c IN: clonedEstimateResources.keySet() AND
                                                                          Estimate_Week__c IN: clonedEstimateWeeks.keySet()]) {
                    CMC_Estimate_Resource_Week__c clonedEstimateResourceWeek = estimateResourceWeek.clone(false, true, false, false);
                    clonedEstimateResourceWeek.Estimate_Resource__c = clonedEstimateResources.get(estimateResourceWeek.Estimate_Resource__c).id;
                    clonedEstimateResourceWeek.Estimate_Week__c = clonedEstimateWeeks.get(estimateResourceWeek.Estimate_Week__c).id;
                    clonedEstimateResourceWeekMapping.add(clonedEstimateResourceWeek);
                }
                insert clonedEstimateResourceWeekMapping;
            }
        }
    }
    
    // delete estimate 
    public static void deleteEstimate(string estimateId) {
        try {
            CMC_Presales_LOE__c estimateDelete = new CMC_Presales_LOE__c(id = estimateId);
            delete estimateDelete;
        } catch(Exception ex) {
            system.debug('Failed: ' + ex.getMessage());
        }
    }
    // End : Estimate clone functionality
}