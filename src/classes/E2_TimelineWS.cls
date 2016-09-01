/**=====================================================================
 * Appirio, Inc
 * Name: E2_TimelineWS
 * Description: This webservice contains all the methods related to E2_Timeline page
 * Created Date: Aug 12, 2016
 * Created By: Rahul Jain (Appirio)
*  =====================================================================*/
global with sharing class E2_TimelineWS {
    
    webservice static string updateSkill(string estimateId, string resourceId, string skill){
        return E2_TimelineWSManager.updateSkill( estimateId,  resourceId,  skill);
    }
    
    
    webservice static List<E2_Estimate_Rate_Card__c> getEstimateRateCards(string estimateId){
        return E2_TimelineWSManager.getEstimateRateCards(estimateId);
    }
    
    webservice static string updatePhase(string weekId, string phase){
      return E2_TimelineWSManager.updatePhase( weekId,  phase);  
    }
    
    webservice static string updateMilestone(string weekId, string milestone){
       return E2_TimelineWSManager.updateMilestone( weekId,  milestone);  
    }
    
    webservice static string updateHours(string weekId, string resourceId, integer hours){
       return E2_TimelineWSManager.updateHours(weekId, resourceId, hours) ;                                                        
    
    }
    
    webservice static string autoFill(string jsonstr){
        return E2_TimelineWSManager.autoFill( jsonstr);
    }


    webservice static string reOrderResources(string jsonstr){
        return E2_TimelineWSManager.reOrderResources(jsonstr);   
    }
      
    webservice static string addRow(string estimateId, integer order, integer cost, integer rate, string role, string skill, string estimateRateCardId){
      return E2_TimelineWSManager.addRow( estimateId,  order, cost,  rate,  role, skill,  estimateRateCardId);
    }
    
    webservice static string updateRow(string estimateId, string rowId, string role, string skill, integer cost, integer rate, string estimateRateCardId){
       return E2_TimelineWSManager.updateRow( estimateId,  rowId,  role, skill,  cost,  rate,  estimateRateCardId);
    }
    
    webservice static string deleteRow(string rowId){
       return E2_TimelineWSManager.deleteRow( rowId);
    }
    
    
    webservice static string deleteColumn(string estimateId, string weekId){
        return E2_TimelineWSManager.deleteColumn( estimateId,  weekId);
    
    }
    
    webservice static string addMoreColumnsOnLeft(string estimateId, string weekId, integer noOfColumnsToAdd){                                                   
        return E2_TimelineWSManager.addMoreColumnsOnLeft( estimateId, weekId, noOfColumnsToAdd);
    }
    
    webservice static string addMoreColumnsOnRight(string estimateId, string weekId, integer noOfColumnsToAdd){                                                   
        return E2_TimelineWSManager.addMoreColumnsOnRight( estimateId, weekId, noOfColumnsToAdd);
    }
    
    webservice static string onBuild(string estimateId, string sDate, integer noOfColumnsToAdd){
        return E2_TimelineWSManager.onBuild( estimateId,  sDate,  noOfColumnsToAdd);
        
    }
    
    
    
    webservice static string onStartDateSelectionChange(string estimateId, string sDate, integer order, string name){
        return  E2_TimelineWSManager.onStartDateSelectionChange( estimateId, sDate,  order, name);                                         
    }
    
    
    webservice static List<E2_TimelineRow> getTimelineRows(string estimateId){
        return E2_TimelineWSManager.getTimelineRows( estimateId);
    }
    
    
    webservice static List<E2_TimelineColumn> getTimelineColumns(string estimateId){
        return E2_TimelineWSManager.getTimelineColumns(estimateId);
    }
    
    global class E2_TimelineRow{
       webservice string id;
       webservice string resource;
       webservice string skill;
       webservice integer rate;
       webservice integer order;
       webservice integer cost;
       webservice List<E2_TimelineRowColumn> colRows;
       
       public E2_TimelineRow(string id, string resource, string skill, integer rate, integer order, integer cost, List<E2_TimelineRowColumn> colRows){
          this.id = id;
          this.resource = resource;
          this.skill = skill;
          this.rate = rate;
          this.order = order;
          this.cost = cost;
          this.colRows = colRows;
       }
    }
    
    global class E2_TimelineRowColumn{
      webservice string id;
      webservice string columnId;
      webservice integer hours;
      
      public E2_TimelineRowColumn(string id, string columnId, integer hours){
        this.id = id;
        this.columnId = columnId;
        this.hours = hours;
      } 
    
    }
    
    
    global class E2_TimelineColumn {
        webservice string id; 
        webservice string name;
        webservice string field;
        webservice integer width;
        webservice string behavior;
        webservice string editor;
        webservice string groupName;
        webservice integer order;
        webservice boolean selectable;
        webservice boolean resizable;
        webservice string cssClass;
        webservice string header;
        webservice string sDate;
        webservice string weekName;
        webservice string phase;
        webservice string milestone;
        public E2_TimelineColumn(string id, 
                                 string name,
                                 string field,
                                 integer width,
                                 string behavior,
                                 string editor,
                                 string groupName,
                                 integer order,
                                 boolean selectable,
                                 boolean resizable,
                                 string cssClass,
                                 string header,
                                 string sDate,
                                 string weekName,
                                 string phase,
                                 string milestone){
                                 
                this.id = id; 
                this.name = name;
                this.field = field;
                this.width = width;
                this.behavior = behavior;
                this.editor = editor;
                this.groupName = groupName;
                this.order = order;
                this.selectable = selectable;
                this.resizable = resizable;
                this.cssClass = cssClass;
                this.header = header;
                this.sDate = sDate;   
                this.weekName = weekName;
                this.phase = phase;  
                this.milestone = milestone;           
        
        }
     } 
     
     public class ResourceWrapper{
        public string resourceId;
        public string displayOrder;
     }
     
     public class ResourceWeekWrapper{
         public string resourceId;
         public string weekId;
         public integer hours;
     }
        
}