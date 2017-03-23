/**=====================================================================
 * Appirio, Inc
 * Name: E2_MilestoneTemplateWS
 * Description: S-464465: This webservice contains all the methods related to E2_MilestoneTemplate page
 * Created Date: Sept 6th, 2016
 * Created By: Rahul Jain (Appirio)
 * 
 * Date Modified        Modified By          Description
 * Sep 12, 2016         Arpita Bose          Moved the methods in E2_MilestoneTemplateWSManager and added the reference to the class 
*  =====================================================================*/
global with sharing class E2_MilestoneTemplateWS {
    
    webservice static string deleteAllRows(string templateId){
        return E2_MilestoneTemplateWSManager.deleteAllRows(templateId);
    }
    
    webservice static string mergeUnmerge(string jsonstr){
      return E2_MilestoneTemplateWSManager.mergeUnmerge(jsonstr);    
    }
   
    webservice static string updateColorCode(string jsonstr){
      return E2_MilestoneTemplateWSManager.updateColorCode(jsonstr);
    }
    
    webservice static string updateMilestone1(string templateId, string milestoneId, string milestone1){
      return E2_MilestoneTemplateWSManager.updateMilestone1(templateId, milestoneId, milestone1);
    }
    
    webservice static string updateMilestone2(string templateId, string milestoneId, string milestone2){
      return E2_MilestoneTemplateWSManager.updateMilestone2(templateId, milestoneId, milestone2);
    }
    
    webservice static string updateBulkText(string jsonstr){
      return E2_MilestoneTemplateWSManager.updateBulkText(jsonstr);
    }
 
    webservice static string updateText(string weekId, string milestoneId, string text){
      return E2_MilestoneTemplateWSManager.updateText(weekId, milestoneId, text);
    }

    webservice static string reOrderRows(string jsonstr){
      return E2_MilestoneTemplateWSManager.reOrderRows(jsonstr);        
    }
      
    webservice static string addRow(string templateId, integer order, string milestone1, string milestone2){
      return E2_MilestoneTemplateWSManager.addRow(templateId, order, milestone1, milestone2);
    }
  
    webservice static string deleteRow(string rowId){
      return E2_MilestoneTemplateWSManager.deleteRow(rowId);
    }
    
    webservice static string deleteColumn(string templateId, string weekId){
      return E2_MilestoneTemplateWSManager.deleteColumn( templateId,  weekId);
    }
    
    webservice static string addMoreColumnsOnLeft(string templateId, string weekId, integer noOfColumnsToAdd){                                                   
      return E2_MilestoneTemplateWSManager.addMoreColumnsOnLeft( templateId, weekId, noOfColumnsToAdd);
    }
    
    webservice static string addMoreColumnsOnRight(string templateId, string weekId, integer noOfColumnsToAdd){                                                   
      return E2_MilestoneTemplateWSManager.addMoreColumnsOnRight( templateId, weekId, noOfColumnsToAdd);
    }
    
    webservice static string onBuild(string templateId, /*string sDate,*/ integer noOfColumnsToAdd){
      return E2_MilestoneTemplateWSManager.onBuild( templateId,  /*sDate,*/  noOfColumnsToAdd);
    }
    
    webservice static string onStartDateSelectionChange(string templateId, string sDate, integer order, string name){
      return  E2_MilestoneTemplateWSManager.onStartDateSelectionChange( templateId, sDate,  order, name);                                         
    }
    
    
    webservice static List<E2_MilestoneRow> getMilestoneRows(string templateId){
      return E2_MilestoneTemplateWSManager.getMilestoneRows(templateId);
    }
    
    webservice static List<E2_MilestoneColumn> getMilestoneColumns(string templateId){
      return E2_MilestoneTemplateWSManager.getMilestoneColumns(templateId);
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