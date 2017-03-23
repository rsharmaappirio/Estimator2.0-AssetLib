/**=====================================================================
 * Appirio, Inc
 * Name: E2_TimelineWS
 * Description: This webservice contains all the methods related to E2_Timeline page
 * Created Date: Aug 12, 2016
 * Created By: Rahul Jain (Appirio)
 * 19 Oct 2016: Modified RS : S-455931 : UI/UX-Conditional highlight on the overridden rates cells
*  =====================================================================*/
global with sharing class E2_TimelineWS {
    
    webservice static string updateMilestoneColorCode1(string weekId, string milestoneColorCode1){
       return  E2_TimelineWSManager.updateMilestoneColorCode1(weekId, milestoneColorCode1);    
    }
    
    webservice static string updateMilestoneColorCode2(string weekId, string milestoneColorCode2){
       return  E2_TimelineWSManager.updateMilestoneColorCode2(weekId, milestoneColorCode2);    
    }
    webservice static string updateMilestone1(string weekId, string milestone1){
       return  E2_TimelineWSManager.updateMilestone1(weekId, milestone1);   
    }
    
    webservice static string updateMilestone2(string weekId, string milestone2){
       return  E2_TimelineWSManager.updateMilestone2(weekId, milestone2);    
    }
    
    
    webservice static string updatePhaseAndColorCode(string weekId, string phase, string colorCode){
       return  E2_TimelineWSManager.updatePhaseAndColorCode(weekId, phase, colorCode);  
    }
    
    webservice static string updateColorCode(string jsonstr){
        return E2_TimelineWSManager.updateColorCode( jsonstr); 
    }
    
    webservice static string updatePhaseColorCode(string weekId, string phaseColorCode){
       return E2_TimelineWSManager.updatePhaseColorCode( weekId,  phaseColorCode);  
    }
    
    webservice static string updateMilestoneColorCode(string weekId, string milestoneColorCode){
       return E2_TimelineWSManager.updateMilestoneColorCode( weekId, milestoneColorCode);  
    }
    
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
      
    webservice static string addRow(string estimateId, integer order, decimal cost, decimal rate, string role, string e2role, string skill, string rateCode, string estimateRateCardId){
      return E2_TimelineWSManager.addRow( estimateId,  order, cost,  rate,  role, e2role, skill, rateCode,  estimateRateCardId);
      
    }
    
    webservice static string updateRow(string estimateId, string rowId, string role, string e2role,  string skill, string rateCode, decimal cost, decimal rate, string estimateRateCardId){
       return E2_TimelineWSManager.updateRow( estimateId,  rowId,  role, e2role, skill, rateCode,  cost,  rate,  estimateRateCardId);
       
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
        return E2_TimelineWSManager.getTimelineRows(estimateId);
    }
    
    
    webservice static List<E2_TimelineColumn> getTimelineColumns(string estimateId){
        return E2_TimelineWSManager.getTimelineColumns(estimateId);
    }
    
    webservice static string updateMilestoneWeeks(string jsonstr){
        return E2_TimelineWSManager.updateMilestoneWeeks(jsonstr); 
    }
    
    //To update hours in bulk on copy and paste to cells - (Vikash - 12th Sep 2016)
    webservice static string updateResourceWeeks(string jsonstr){
        return E2_TimelineWSManager.updateResourceWeeks(jsonstr); 
    }
    
    webservice static string updateDevCapacity(string estimateId, integer devCapacity) {
        return E2_TimelineWSManager.updateDevCapacity(estimateId, devCapacity); 
    }
    
    global class E2_TimelineRow{
       webservice string id;
       webservice string resource;
       webservice string skill;
       webservice decimal rate;
       webservice integer order;
       webservice decimal cost;
       webservice List<E2_TimelineRowColumn> colRows;
       webservice string resourceRateCardRole;
       webservice string e2Resource;
       webservice string roleToDisplay;
       webservice boolean isRateOverridden;
       
       public E2_TimelineRow(string id, string resource, string skill, decimal rate, integer order, decimal cost, List<E2_TimelineRowColumn> colRows){
          this.id = id;
          this.resource = resource;
          this.skill = skill;
          this.rate = rate;
          this.order = order;
          this.cost = cost;
          this.colRows = colRows;
       }
       
       public E2_TimelineRow(string id, string resource, string resourceRateCardRole, string skill, decimal rate, integer order, decimal cost, List<E2_TimelineRowColumn> colRows){
          this(id, resource, skill, rate, order, cost, colRows);
          this.resourceRateCardRole = resourceRateCardRole;
       }
       
       public E2_TimelineRow(string id, string resource, string e2Resource, string resourceRateCardRole, string skill, decimal rate, integer order, decimal cost, List<E2_TimelineRowColumn> colRows){
          this(id, resource, resourceRateCardRole, skill, rate, order, cost, colRows);
          this.e2Resource = e2Resource;
       }
       
       public E2_TimelineRow(string id, string resource, string e2Resource, string resourceRateCardRole, string skill, decimal rate, integer order, decimal cost, string roleToDisplay, List<E2_TimelineRowColumn> colRows){
          this(id, resource, e2Resource, resourceRateCardRole, skill, rate, order, cost, colRows);
          this.roleToDisplay = roleToDisplay;
       }
       
       public E2_TimelineRow(string id, string resource, string e2Resource, string resourceRateCardRole, string skill, decimal rate, integer order, decimal cost, string roleToDisplay, boolean isRateOverridden, List<E2_TimelineRowColumn> colRows){
          this(id, resource, e2Resource, resourceRateCardRole, skill, rate, order, cost, roleToDisplay, colRows);
          this.isRateOverridden = isRateOverridden;
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
        webservice string phaseColorCode;
        webservice string milestoneColorCode;
        webservice string milestone1;
        webservice string milestoneColorCode1;
        webservice string milestone2;
        webservice string milestoneColorCode2;
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
                                 string milestone,
                                 string phaseColorCode,
                                 string milestoneColorCode){
                                 
                this(id, name, field, width, behavior, editor, groupName, order, selectable, resizable, cssClass, header, sDate, weekName, phase, milestone);
                this.phaseColorCode = phaseColorCode;
                this.milestoneColorCode = milestoneColorCode;
        
        }
        
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
                                 string milestone,
                                 string phaseColorCode,
                                 string milestoneColorCode,
                                 string milestone1,
                                 string milestoneColorCode1,
                                 string milestone2,
                                 string milestoneColorCode2){
                                 
                this(id, name, field, width, behavior, editor, groupName, order, selectable, resizable, cssClass, header, sDate, weekName, phase, milestone, phaseColorCode, milestoneColorCode);
                this.milestone1 = milestone1;
                this.milestone2 = milestone2;
                this.milestoneColorCode1 = milestoneColorCode1;
                this.milestoneColorCode2 = milestoneColorCode2;
        
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
     
     public class ColorCode{
         public string weekId;
         public string value;
         public string type;
     }
     
     public class MilestoneWeekWrapper{
         public string weekId;
         public string value;
         public string colorCode;
         public string type;
     }     
          
     public class CellWrapper{
         public string rowId;
         public string cellId;
         public string value;
         public string colorCode;
     }
        
}