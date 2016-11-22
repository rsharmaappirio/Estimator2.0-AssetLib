/**=====================================================================
 * Appirio, Inc
 * Name: E2_MilestoneWS
 * Description: This webservice contains all the methods related to E2_Milestone page
 * Created Date: Sept 6th, 2016
 * Created By: Rahul Jain (Appirio)
 * 
 * Date Modified        Modified By          Description
 * Sep 12, 2016         Arpita Bose          Moved the methods in E2_MilestoneWSManager and added the reference to the class 
*  =====================================================================*/
global with sharing class E2_MilestoneWS {
    
    webservice static string deleteAllRows(string estimateId){
        return E2_MilestoneWSManager.deleteAllRows(estimateId);
    }
    
    webservice static string addFromTemplate(string type, string estimateId){
      return E2_MilestoneWSManager.addFromTemplate(type, estimateId);
    }  
   
    webservice static string mergeUnmerge(string jsonstr){
      return E2_MilestoneWSManager.mergeUnmerge(jsonstr);    
    }
   
    webservice static string updateColorCode(string jsonstr){
      return E2_MilestoneWSManager.updateColorCode(jsonstr);
    }
    
    webservice static string updateMilestone1(string estimateId, string milestoneId, string milestone1){
      return E2_MilestoneWSManager.updateMilestone1(estimateId, milestoneId, milestone1);
    }
    
    webservice static string updateMilestone2(string estimateId, string milestoneId, string milestone2){
      return E2_MilestoneWSManager.updateMilestone2(estimateId, milestoneId, milestone2);
    }
    
    webservice static string updateBulkText(string jsonstr){
      return E2_MilestoneWSManager.updateBulkText(jsonstr);
    }
 
    webservice static string updateText(string weekId, string milestoneId, string text){
      return E2_MilestoneWSManager.updateText(weekId, milestoneId, text);
    }
    
   // webservice static string autoFill(string jsonstr){
   //     return E2_TimelineWSManager.autoFill( jsonstr);
   // }

    webservice static string reOrderRows(string jsonstr){
      return E2_MilestoneWSManager.reOrderRows(jsonstr);        
    }
      
    webservice static string addRow(string estimateId, integer order, string milestone1, string milestone2){
      return E2_MilestoneWSManager.addRow(estimateId, order, milestone1, milestone2);
    }
    
    //webservice static string updateRow(string estimateId, string rowId, string role, string skill, integer cost, integer rate, string estimateRateCardId){
    //   return E2_TimelineWSManager.updateRow( estimateId,  rowId,  role, skill,  cost,  rate,  estimateRateCardId);
    //}
    
    webservice static string deleteRow(string rowId){
      return E2_MilestoneWSManager.deleteRow(rowId);
    }
    
    webservice static string deleteColumn(string estimateId, string weekId){
      return E2_MilestoneWSManager.deleteColumn( estimateId,  weekId);
    }
    
    webservice static string addMoreColumnsOnLeft(string estimateId, string weekId, integer noOfColumnsToAdd){                                                   
      return E2_MilestoneWSManager.addMoreColumnsOnLeft( estimateId, weekId, noOfColumnsToAdd);
    }
    
    webservice static string addMoreColumnsOnRight(string estimateId, string weekId, integer noOfColumnsToAdd){                                                   
      return E2_MilestoneWSManager.addMoreColumnsOnRight( estimateId, weekId, noOfColumnsToAdd);
    }
    
    webservice static string onBuild(string estimateId, string sDate, integer noOfColumnsToAdd){
      return E2_MilestoneWSManager.onBuild( estimateId,  sDate,  noOfColumnsToAdd);
    }
    
    webservice static string onStartDateSelectionChange(string estimateId, string sDate, integer order, string name){
      return  E2_MilestoneWSManager.onStartDateSelectionChange( estimateId, sDate,  order, name);                                         
    }
    
    
    webservice static List<E2_MilestoneRow> getMilestoneRows(string estimateId){
      return E2_MilestoneWSManager.getMilestoneRows(estimateId);
    }
    
    webservice static List<E2_MilestoneColumn> getMilestoneColumns(string estimateId){
      return E2_MilestoneWSManager.getMilestoneColumns(estimateId);
    }
    
    global class E2_MilestoneRow{
       webservice string id;
       webservice string milestone1;
       webservice string milestone2;
       webservice integer order;
       webservice List<E2_MilestoneRowColumn> colRows;
       
       public E2_MilestoneRow(string id, string milestone1, string milestone2, integer order, List<E2_MilestoneRowColumn> colRows){
          this.id = id;
          this.milestone1 = milestone1;
          this.milestone2 = milestone2;
          
          this.order = order;
          
          this.colRows = colRows;
       }
    }
    
    global class E2_MilestoneRowColumn{
      webservice string id;
      webservice string columnId;
      webservice string text;
      webservice string textcolorcode;
      
      public E2_MilestoneRowColumn(string id, string columnId, string text, string textcolorcode){
        this.id = id;
        this.columnId = columnId;
        this.text = text;
        this.textcolorcode = textcolorcode;
      } 
    
    }
    
    
    global class E2_MilestoneColumn {
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
       
        public E2_MilestoneColumn(string id, 
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
                                 string sDate){
                                 
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
        
        }
     } 
     
     public class RowWrapper{
        public string milestoneId;
        public string displayOrder;
     }
     
     public class MilestoneWeekWrapper{
         public string milestoneId;
         public string weekId;
         public string text;
         public string textcolorcode;
     }
     
     public class RowColumnWrapper{
         public string weekId;
         public string rowId;
         public string value;
     }
        
}