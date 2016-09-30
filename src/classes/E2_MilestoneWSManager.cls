/**=====================================================================
 * Appirio, Inc
 * Name: E2_MilestoneWSManager
 * Description: This is a manager class; constitutes all the business logic for E2_MilestoneWS webservcie
 * Created Date: Sept 12th, 2016
 * Created By: Arpita Bose (Appirio)
 * 
 * Date Modified          Modified by            Description
 * 
*  =====================================================================*/
public class E2_MilestoneWSManager {
   public static final string SEPARATOR = '|';    
   public static final string TEXT_SEPARATOR = '-';  
   public static final string DATE_SLASH = '/'; 
   public static final string MILESTONE1_ID = 'milestone1';
   public static final string MILESTONE2_ID = 'milestone2';
   
    
    public static string addFromTemplate(string selectedTemplate, string estimateId){
       //method to insert E2_Estimate_Milestone__c records from Template based on the type
       //for 'Workday' or 'SFDC'
        system.debug('selectedTemplate>>' +selectedTemplate);
        List<E2_Estimate_Milestone__c> lstToInsert = new List<E2_Estimate_Milestone__c>();
        List<E2_Estimate_Milestone__c> estimateMilestones = E2_MilestoneDataUtil_WS.getEstimateMilestones(estimateId);
        system.debug('estimateId>>' +estimateId);
        List<E2_Timeline_Milestone__c> lstMilestones = E2_MilestoneDataUtil_WS.getTimelineMilestones(selectedTemplate);
        
        Integer index = estimateMilestones.size() + 1;
        for(E2_Timeline_Milestone__c milestone : lstMilestones){
            lstToInsert.add(new E2_Estimate_Milestone__c(Estimate__c = estimateId, 
                                        Milestone1__c = milestone.Milestone1__c, 
                                        Milestone2__c = milestone.Milestone2__c, 
                                        Order__c = index++));
        }
        
        //insert and return success, else show the exception
        try{
            if(!lstToInsert.isEmpty()){
                insert lstToInsert;
            }
        }catch(Exception ex){
            return 'Failed: ' + ex.getMessage();
        }
        return 'Success';
    }
   
    public static string mergeUnmerge(string jsonstr){
        //method to merge/ unmerge E2_Estimate_Milestone_Week__c
        List<E2_MilestoneWS.MilestoneWeekWrapper> lst = (List<E2_MilestoneWS.MilestoneWeekWrapper>)JSON.deserialize(jsonstr, List<E2_MilestoneWS.MilestoneWeekWrapper>.class);
        
        Set<String> weekIds = new Set<String>();
        Set<String> milestoneIds = new Set<String>();
        Map<String, E2_Estimate_Milestone_Week__c> milestoneWeekMap = new Map<String, E2_Estimate_Milestone_Week__c>();
        List<E2_Estimate_Milestone_Week__c> lstToInsert = new List<E2_Estimate_Milestone_Week__c>();
        List<E2_Estimate_Milestone_Week__c> lstToUpdate = new List<E2_Estimate_Milestone_Week__c>();
        
        for(E2_MilestoneWS.MilestoneWeekWrapper rwW : lst){
            
            weekIds.add(rwW.weekId);
            milestoneIds.add(rwW.milestoneId);    
        }
        
        for(E2_Estimate_Milestone_Week__c rwW : E2_MilestoneDataUtil_WS.getEstimateMilestoneWeeks(weekIds, milestoneIds)){
               system.debug('rwW>>>' +rwW);
               string key = rwW.Estimate_Milestone__c + SEPARATOR + rwW.Estimate_Week__c;
               milestoneWeekMap.put(key, rwW);           
        }
         
       for(E2_MilestoneWS.MilestoneWeekWrapper rwW : lst){
            string key = rwW.milestoneId + SEPARATOR + rwW.weekId;
            string text = rwW.text;
            string colorCode = rwW.textcolorcode;
            
            if(milestoneWeekMap.containsKey(key)){
                E2_Estimate_Milestone_Week__c eRW = milestoneWeekMap.get(key);
                eRW.Text__c = text;
                eRW.TextColorCode__c = colorCode;
                lstToUpdate.add(eRW);
            }else{
                E2_Estimate_Milestone_Week__c eRW = new E2_Estimate_Milestone_Week__c(Text__c = text, TextColorCode__c = colorCode, Estimate_Milestone__c = rwW.milestoneId, Estimate_Week__c = rwW.weekId);
                lstToInsert.add(eRW);
            }
        }
       //insert/ update  
       try{
          if(!lstToUpdate.isEmpty()) update lstToUpdate;
          if(!lstToInsert.isEmpty()) insert lstToInsert;
       }catch(Exception ex){
          return 'Failed: ' + ex.getMessage();
       }        
       return 'Success';
        
    }
   
   
    public static string updateColorCode(string jsonstr){
        //method to update color code for E2_Estimate_Milestone_Week__c
        List<E2_MilestoneWS.RowColumnWrapper> lstColorCodes = (List<E2_MilestoneWS.RowColumnWrapper>)JSON.deserialize(jsonstr, List<E2_MilestoneWS.RowColumnWrapper>.class);
        Set<String> weekIds = new Set<String>();
        Set<String> milestoneIds = new Set<String>();
        Map<String, E2_Estimate_Milestone_Week__c> milestoneWeekMap = new Map<String, E2_Estimate_Milestone_Week__c>();
        List<E2_Estimate_Milestone_Week__c> lstToInsert = new List<E2_Estimate_Milestone_Week__c>();
        List<E2_Estimate_Milestone_Week__c> lstToUpdate = new List<E2_Estimate_Milestone_Week__c>();
        
        for(E2_MilestoneWS.RowColumnWrapper rwW : lstColorCodes){
            
            weekIds.add(rwW.weekId);
            milestoneIds.add(rwW.rowId);    
        }
        
        for(E2_Estimate_Milestone_Week__c rwW : E2_MilestoneDataUtil_WS.getEstimateMilestoneWeeks(weekIds, milestoneIds)){
               
               string key = rwW.Estimate_Milestone__c + SEPARATOR + rwW.Estimate_Week__c;
               milestoneWeekMap.put(key, rwW);           
        }
         
       for(E2_MilestoneWS.RowColumnWrapper rwW : lstColorCodes){
            string key = rwW.rowId + SEPARATOR + rwW.weekId;
            string colorCode = rwW.value;
            
            if(milestoneWeekMap.containsKey(key)){
                E2_Estimate_Milestone_Week__c eRW = milestoneWeekMap.get(key);
                eRW.TextColorCode__c = colorCode;
                lstToUpdate.add(eRW);
            }else{
                E2_Estimate_Milestone_Week__c eRW = new E2_Estimate_Milestone_Week__c(TextColorCode__c = colorCode, Estimate_Milestone__c = rwW.rowId, Estimate_Week__c = rwW.weekId);
                lstToInsert.add(eRW);
            }
        }
       //insert/ update 
       try{
          if(!lstToUpdate.isEmpty()) update lstToUpdate;
          if(!lstToInsert.isEmpty()) insert lstToInsert;
       }catch(Exception ex){
          return 'Failed: ' + ex.getMessage();
       }        
       return 'Success';
    }
    
    
    
    public static string updateMilestone1(string estimateId, string milestoneId, string milestone1){
        //method to update Milestone1__c 
        List<E2_Estimate_Milestone__c> estimatResourceList = E2_MilestoneDataUtil_WS.getMilestone(estimateId, milestoneId);
        try{
            if(!estimatResourceList.isEmpty()){
                estimatResourceList[0].Milestone1__c = milestone1;
                update estimatResourceList;
            }
        }catch(Exception ex){
            return 'Failed: ' + ex.getMessage();
        }
        return 'Success';
    }
    
    
    
    public static string updateMilestone2(string estimateId, string milestoneId, string milestone2){
        //method to update Milestone2__c
        List<E2_Estimate_Milestone__c> estimatResourceList = E2_MilestoneDataUtil_WS.getMilestone(estimateId, milestoneId);
        try{
            if(!estimatResourceList.isEmpty()){
                estimatResourceList[0].Milestone2__c = milestone2;
                update estimatResourceList;
            }
        }catch(Exception ex){
            return 'Failed: ' + ex.getMessage();
        }
        return 'Success';
    }
    
 
    public static string updateBulkText(string jsonstr){
        //method to update bulk Text__c
        List<E2_MilestoneWS.RowColumnWrapper> lstColorCodes = (List<E2_MilestoneWS.RowColumnWrapper>)JSON.deserialize(jsonstr, List<E2_MilestoneWS.RowColumnWrapper>.class);
        Set<String> weekIds = new Set<String>();
        Set<String> milestoneIds = new Set<String>();
        Map<String, E2_Estimate_Milestone_Week__c> milestoneWeekMap = new Map<String, E2_Estimate_Milestone_Week__c>();
        List<E2_Estimate_Milestone_Week__c> lstToInsert = new List<E2_Estimate_Milestone_Week__c>();
        List<E2_Estimate_Milestone_Week__c> lstToUpdate = new List<E2_Estimate_Milestone_Week__c>();
        List<E2_Estimate_Milestone__c> lstMilestoneToInsert = new List<E2_Estimate_Milestone__c>();
        List<E2_Estimate_Milestone__c> lstMilestoneToUpdate = new List<E2_Estimate_Milestone__c>();
        
        for(E2_MilestoneWS.RowColumnWrapper rwW : lstColorCodes){
            
            weekIds.add(rwW.weekId);
            milestoneIds.add(rwW.rowId);    
        }
        
        for(E2_Estimate_Milestone_Week__c rwW : E2_MilestoneDataUtil_WS.getEstimateMilestoneWeeks(weekIds, milestoneIds)){
               
               string key = rwW.Estimate_Milestone__c + SEPARATOR + rwW.Estimate_Week__c;
               milestoneWeekMap.put(key, rwW);           
        }
         
       for(E2_MilestoneWS.RowColumnWrapper rwW : lstColorCodes){
            string key = rwW.rowId + SEPARATOR + rwW.weekId;
            string text = rwW.value;
            
            if(rwW.weekId == MILESTONE1_ID && String.isNotBlank(rwW.rowId)){
               lstMilestoneToUpdate.add(new E2_Estimate_Milestone__c( id = rwW.rowId, Milestone1__c = text));
            }else if(rwW.weekId == MILESTONE2_ID && String.isNotBlank(rwW.rowId)){
               lstMilestoneToUpdate.add(new E2_Estimate_Milestone__c( id = rwW.rowId, Milestone2__c = text)); 
            }else{
                if(milestoneWeekMap.containsKey(key)){
                    E2_Estimate_Milestone_Week__c eRW = milestoneWeekMap.get(key);
                    eRW.Text__c = text;
                    lstToUpdate.add(eRW);
                }else{
                    E2_Estimate_Milestone_Week__c eRW = new E2_Estimate_Milestone_Week__c(Text__c = text, Estimate_Milestone__c = rwW.rowId, Estimate_Week__c = rwW.weekId);
                    lstToInsert.add(eRW);
                }
            }
        }
        
       try{
          if(!lstToUpdate.isEmpty()) update lstToUpdate;
          if(!lstToInsert.isEmpty()) insert lstToInsert;
          if(!lstMilestoneToUpdate.isEmpty()) update lstMilestoneToUpdate;
       }catch(Exception ex){
          return 'Failed: ' + ex.getMessage();
       }        
       return 'Success';
    }
 
    
    public static string updateText(string weekId, string milestoneId, string text){
        //method to update Text__c for milestone week 
       List<E2_Estimate_Milestone_Week__c> resWeeks = E2_MilestoneDataUtil_WS.getEstimateMilestoneWeeksforWeek(weekId, milestoneId);
                                                       
       for(E2_Estimate_Milestone_Week__c resWeek : resWeeks){
          resWeek.Text__c = text;
       }
       
       // when no related record exist in database; do insert else do modify
       if(resWeeks.isEmpty()){
          resWeeks.add(new E2_Estimate_Milestone_Week__c( Text__c = text, Estimate_Week__c = weekId, Estimate_Milestone__c = milestoneId));
       } 
       
       try{
          upsert resWeeks;
        }catch(Exception ex){
          return 'Failed: ' + ex.getMessage();
       }        
       return weekId + TEXT_SEPARATOR + milestoneId;
    }

    public static string reOrderRows(string jsonstr){
        //method to reoder rows
        List<E2_MilestoneWS.RowWrapper> lstResourceWrapper = (List<E2_MilestoneWS.RowWrapper>)JSON.deserialize(jsonstr, List<E2_MilestoneWS.RowWrapper>.class);
        
        List<E2_Estimate_Milestone__c> lstResources = new List<E2_Estimate_Milestone__c>();
        for(E2_MilestoneWS.RowWrapper resWrapper : lstResourceWrapper){
            lstResources.add(new E2_Estimate_Milestone__c(Id = resWrapper.milestoneId, 
                                                          Order__c = Integer.valueOf(resWrapper.displayOrder)
                                          ));
        }
        
        try{
            update lstResources;
        }catch(Exception ex){
          return 'Failed: ' + ex.getMessage();
        }        
        return 'Success';        
    }
      
    public static string addRow(string estimateId, integer order, string milestone1, string milestone2){
       //method to add rows in milestone     
       try{                             
         insert new E2_Estimate_Milestone__c( Milestone1__c = milestone1, 
                                             Estimate__c = estimateId,     
                                             Order__c = order, 
                                             Milestone2__c = milestone2);
       }catch(Exception ex){
         return 'Failed: ' + ex.getMessage();
       }
       return 'Success';
    }

    public static string deleteRow(string rowId){
        //method to delete row in milestone 
        try{                             
         delete new E2_Estimate_Milestone__c(id = rowId);
       }catch(Exception ex){
         return 'Failed: ' + ex.getMessage();
       }
       return 'Success';
    }
    
    public static string deleteAllRows(string estimateId){
        //method to delete row in milestone 
        try{                             
         delete [SELECT id from E2_Estimate_Milestone__c WHERE Estimate__c =: estimateId];
       }catch(Exception ex){
         return 'Failed: ' + ex.getMessage();
       }
       return 'Success';
    }
    
    
    public static List<E2_MilestoneWS.E2_MilestoneRow> getMilestoneRows(string estimateId){
        //method to get milestone rows for a given estimateId
        List<E2_MilestoneWS.E2_MilestoneRow> rows = new List<E2_MilestoneWS.E2_MilestoneRow>();
        
        
        for(E2_Estimate_Milestone__c res : E2_MilestoneDataUtil_WS.getEstimateMilestoneAndAllWeeks(estimateId)){
                                                      
             List<E2_MilestoneWS.E2_MilestoneRowColumn> colRows = new List<E2_MilestoneWS.E2_MilestoneRowColumn>();
             for(E2_Estimate_Milestone_Week__c colRow : res.Estimate_Milestone_Weeks__r){
               colRows.add(new E2_MilestoneWS.E2_MilestoneRowColumn(colRow.id, colRow.Estimate_Week__c, 
                                                                    (colRow.Text__c == null ? '' : colRow.Text__c) , 
                                                                    colRow.TextColorCode__c == null ? '' : colRow.TextColorCode__c));
             }
             rows.add(new E2_MilestoneWS.E2_MilestoneRow(res.id, res.Milestone1__c, 
                      res.Milestone2__c,  
                      res.Order__c.intValue(), 
                      colRows));                                   
         }        
        return rows;
    }
    
    
    public static List<E2_MilestoneWS.E2_MilestoneColumn> getMilestoneColumns(string estimateId){
        //method to get milestone column for estimateId
        List<E2_MilestoneWS.E2_MilestoneColumn> columns = new List<E2_MilestoneWS.E2_MilestoneColumn>();        
        integer width = 60;
        string behavior = '';
        string editor = '';
        string groupName = 'none';        
        boolean selectable = false;
        boolean resizable = false;
        string cssClass = '';
        string header = '{"menu": { "items": [{ "title": "Insert 1 right", "command" : "insert_1_right" },{ "title" : "Insert 2 right", "command" : "insert_2_right" }, { "title" : "Insert 1 left", "command" : "insert_1_left" }, { "title" : "Insert 2 left", "command" : "insert_2_left" }, { "title" : "Delete column", "command" : "delete_column" }]}}';
        
        for(CMC_Estimate_Week__c estimateWeek : E2_TimelineDataUtil_WS.getEstimateWeekRecords(estimateId)){
             
              Date weekDate = estimateWeek.Date__c;
              string sDate = weekDate.month() + DATE_SLASH + weekDate.day() + DATE_SLASH + weekDate.year(); 
              string name = weekDate.month() + DATE_SLASH + weekDate.day();   
              string nameWithYear = weekDate.month() + '/' + weekDate.day() + '/' + String.valueOf(weekDate.year()).right(2);
              columns.add(new E2_MilestoneWS.E2_MilestoneColumn(estimateWeek.id, 
                                            //name,
                                            nameWithYear,
                                            estimateWeek.id,
                                            width,
                                            behavior,
                                            editor,
                                            groupName,
                                            estimateWeek.Order__c == null ? 1 : estimateWeek.Order__c.intValue(),
                                            selectable,
                                            resizable,
                                            cssClass,
                                            header,
                                            sDate
                                            ));                                       
        }
        return columns;
    }
}