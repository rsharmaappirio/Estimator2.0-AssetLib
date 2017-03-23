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
   public static final integer NO_OF_DAYS_IN_WEEK = 7;
   public static final string WEEKNAME_PREFIX = 'Week';
   
    
    public static string addFromTemplate(string selectedTemplate, string estimateId){
       //method to insert E2_Estimate_Milestone__c records from Template based on the type
       //for 'Workday' or 'SFDC'
        system.debug('selectedTemplate>>' +selectedTemplate);
        map<string, E2_Estimate_Milestone__c> lstToInsert = new map<string, E2_Estimate_Milestone__c>();
        map<string, E2_Estimate_Week_Milestone__c> weeksToInsert = new map<string, E2_Estimate_Week_Milestone__c>();
        list<E2_Estimate_Milestone_Week__c> milestoneScheduleToInsert = new list<E2_Estimate_Milestone_Week__c>();
        
        List<E2_Estimate_Milestone__c> estimateMilestones = E2_MilestoneDataUtil_WS.getEstimateMilestones(estimateId);
        List<E2_Estimate_Week_Milestone__c> estimateWeekMilestones = E2_MilestoneDataUtil_WS.getEstimateWeekMilestoneRecords(estimateId);
        //system.debug('estimateId>>' +estimateId);
        List<E2_Timeline_Milestone__c> lstMilestones = E2_MilestoneDataUtil_WS.getTimelineMilestones(selectedTemplate);
        
        for(E2_Timeline_Milestone__c milestone : lstMilestones){
            lstToInsert.put(milestone.Id, new E2_Estimate_Milestone__c(Estimate__c = estimateId, 
                                        Milestone1__c = milestone.Milestone1__c, 
                                        Milestone2__c = milestone.Milestone2__c, 
                                        Order__c = milestone.Order__c));
        }
        Date startDate = Date.today();
        if(!estimateWeekMilestones.isEmpty()){
            startDate = estimateWeekMilestones.get(0).Date__c;
        }
        
        List<E2_Week_Milestone_Template__c> lstWeeks = E2_MilestoneDataUtil_WS.getTemplateWeeks(selectedTemplate);

        for(E2_Week_Milestone_Template__c week : lstWeeks) {
            weeksToInsert.put(week.Id, new E2_Estimate_Week_Milestone__c(Name = week.Name,
                                                                    Date__c = startDate.addDays(NO_OF_DAYS_IN_WEEK * (Integer.valueOf(week.Order__c)-1)), 
                                                                    Estimate__c = estimateId,
                                                                    Order__c = week.Order__c));
        }
        
        //insert and return success, else show the exception
        try{
            
            if(!estimateMilestones.isEmpty()){
                delete estimateMilestones;
            }
            
            if(!estimateWeekMilestones.isEmpty()){
                delete estimateWeekMilestones;
            }
            if(!lstToInsert.isEmpty()){
                insert lstToInsert.values();
            }
            if(!weeksToInsert.isEmpty()){
                insert weeksToInsert.values();
            }
            for(E2_Milestone_Week_Template_Junction__c milestoneWeek : E2_MilestoneDataUtil_WS.getTemplateMilestoneWeeksforWeek(weeksToInsert.keySet(), lstToInsert.keySet())) {
                milestoneScheduleToInsert.add(new E2_Estimate_Milestone_Week__c(Text__c = milestoneWeek.Text__c, 
                                                                    TextColorCode__c = milestoneWeek.TextColorCode__c, 
                                                                    Estimate_Milestone__c = lstToInsert.get(milestoneWeek.Timeline_Milestone__c).Id, 
                                                                    Estimate_Week_Milestone__c = weeksToInsert.get(milestoneWeek.Week_Milestone_Template__c).Id));
            }
            if(!milestoneScheduleToInsert.isEmpty()){
                insert milestoneScheduleToInsert;
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
               string key = rwW.Estimate_Milestone__c + SEPARATOR + rwW.Estimate_Week_Milestone__c;
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
                E2_Estimate_Milestone_Week__c eRW = new E2_Estimate_Milestone_Week__c(Text__c = text, TextColorCode__c = colorCode, Estimate_Milestone__c = rwW.milestoneId, Estimate_Week_Milestone__c = rwW.weekId);
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
               
               string key = rwW.Estimate_Milestone__c + SEPARATOR + rwW.Estimate_Week_Milestone__c;
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
                E2_Estimate_Milestone_Week__c eRW = new E2_Estimate_Milestone_Week__c(TextColorCode__c = colorCode, Estimate_Milestone__c = rwW.rowId, Estimate_Week_Milestone__c = rwW.weekId);
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
        List<E2_MilestoneWS.MilestoneWeekWrapper> lstColorCodes = (List<E2_MilestoneWS.MilestoneWeekWrapper>)JSON.deserialize(jsonstr, List<E2_MilestoneWS.MilestoneWeekWrapper>.class);
        Set<String> weekIds = new Set<String>();
        Set<String> milestoneIds = new Set<String>();
        Map<String, E2_Estimate_Milestone_Week__c> milestoneWeekMap = new Map<String, E2_Estimate_Milestone_Week__c>();
        List<E2_Estimate_Milestone_Week__c> lstToInsert = new List<E2_Estimate_Milestone_Week__c>();
        List<E2_Estimate_Milestone_Week__c> lstToUpdate = new List<E2_Estimate_Milestone_Week__c>();
        List<E2_Estimate_Milestone__c> lstMilestoneToInsert = new List<E2_Estimate_Milestone__c>();
        List<E2_Estimate_Milestone__c> lstMilestoneToUpdate = new List<E2_Estimate_Milestone__c>();
        
        for(E2_MilestoneWS.MilestoneWeekWrapper rwW : lstColorCodes){
            
            weekIds.add(rwW.weekId);
            milestoneIds.add(rwW.milestoneId);    
        }
        
        for(E2_Estimate_Milestone_Week__c rwW : E2_MilestoneDataUtil_WS.getEstimateMilestoneWeeks(weekIds, milestoneIds)){
               
               string key = rwW.Estimate_Milestone__c + SEPARATOR + rwW.Estimate_Week_Milestone__c;
               milestoneWeekMap.put(key, rwW);           
        }
         
       for(E2_MilestoneWS.MilestoneWeekWrapper rwW : lstColorCodes){
            string key = rwW.milestoneId + SEPARATOR + rwW.weekId;
            string text = rwW.text;
            string colorCode = rwW.textcolorcode;
            
            if(rwW.weekId == MILESTONE1_ID && String.isNotBlank(rwW.milestoneId)){
               lstMilestoneToUpdate.add(new E2_Estimate_Milestone__c( id = rwW.milestoneId, Milestone1__c = text));
            }else if(rwW.weekId == MILESTONE2_ID && String.isNotBlank(rwW.milestoneId)){
               lstMilestoneToUpdate.add(new E2_Estimate_Milestone__c( id = rwW.milestoneId, Milestone2__c = text)); 
            }else{
                if(milestoneWeekMap.containsKey(key)){
                    E2_Estimate_Milestone_Week__c eRW = milestoneWeekMap.get(key);
                    eRW.Text__c = text;
                    eRW.TextColorCode__c = colorCode;
                    lstToUpdate.add(eRW);
                }else{
                    E2_Estimate_Milestone_Week__c eRW = new E2_Estimate_Milestone_Week__c(Text__c = text, TextColorCode__c = colorCode, Estimate_Milestone__c = rwW.milestoneId, Estimate_Week_Milestone__c = rwW.weekId);
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
          resWeeks.add(new E2_Estimate_Milestone_Week__c( Text__c = text, Estimate_Week_Milestone__c = weekId, Estimate_Milestone__c = milestoneId));
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
               colRows.add(new E2_MilestoneWS.E2_MilestoneRowColumn(colRow.id, colRow.Estimate_Week_Milestone__c, 
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
        
        for(E2_Estimate_Week_Milestone__c estimateWeekMilestone : E2_MilestoneDataUtil_WS.getEstimateWeekMilestoneRecords(estimateId)){
             
              Date weekDate = estimateWeekMilestone.Date__c;
              string sDate = weekDate.month() + DATE_SLASH + weekDate.day() + DATE_SLASH + weekDate.year(); 
              string name = weekDate.month() + DATE_SLASH + weekDate.day();   
              string nameWithYear = weekDate.month() + '/' + weekDate.day() + '/' + String.valueOf(weekDate.year()).right(2);
              columns.add(new E2_MilestoneWS.E2_MilestoneColumn(estimateWeekMilestone.id, 
                                            //name,
                                            nameWithYear,
                                            estimateWeekMilestone.id,
                                            width,
                                            behavior,
                                            editor,
                                            groupName,
                                            estimateWeekMilestone.Order__c == null ? 1 : estimateWeekMilestone.Order__c.intValue(),
                                            selectable,
                                            resizable,
                                            cssClass,
                                            header,
                                            sDate
                                            ));                                       
        }
        return columns;
    }
    
    // method to delete columns
    public static string deleteColumn(string estimateId, string weekId){
        List<E2_Estimate_Week_Milestone__c> milestoneWeeksToUpsert = new List<E2_Estimate_Week_Milestone__c>();
        List<E2_Estimate_Week_Milestone__c> milestoneWeeksToDelete = new List<E2_Estimate_Week_Milestone__c>();
        
        boolean incrementalUpdateRequired = false;
        //integer noOfColumnsToDelete = 1;
        boolean dateUpdateRequiredForSucceedingRecords = false;
        Date newStartDate; 
        Decimal newOrder; 
        for(E2_Estimate_Week_Milestone__c estimateWeekMilestone : E2_MilestoneDataUtil_WS.getEstimateWeekMilestoneRecords(estimateId)){
            
            // we don't need to process or update records whose order or start date is less than the current week
            if(incrementalUpdateRequired){
               if(dateUpdateRequiredForSucceedingRecords){
                   // set the new start date for this record
                   estimateWeekMilestone.Date__c = newStartDate;
                   // reset newStartDate variable with date + 7 days
                   newStartDate = estimateWeekMilestone.Date__c.addDays(NO_OF_DAYS_IN_WEEK);
               } 
               //check that order is already populated
               if(estimateWeekMilestone.Order__c <> NULL){
                   // set the new order for this record
                   estimateWeekMilestone.Order__c = newOrder;
                   // reset newOrder variable with +1 increment
                   newOrder = estimateWeekMilestone.Order__c + 1;
                   // set the week name with the order
                   estimateWeekMilestone.Name = WEEKNAME_PREFIX + estimateWeekMilestone.Order__c;
                   milestoneWeeksToUpsert.add(estimateWeekMilestone);               
               }
            }
            
            //delete the selected week record   
            if(estimateWeekMilestone.id == weekId){
               milestoneWeeksToDelete.add(estimateWeekMilestone);
               
               // set the newOrder of succeeding record based on this records order
               newOrder = estimateWeekMilestone.Order__c;
               if(estimateWeekMilestone.Order__c <> NULL && estimateWeekMilestone.Order__c.intValue() > 1){
                 // set the new start date to this records date for the succeeding records
                 newStartDate = estimateWeekMilestone.Date__c;
                 dateUpdateRequiredForSucceedingRecords = true;  
               } 
               incrementalUpdateRequired = true;
            }                                    
        }
        
        // process insert/update in database           
        try{ 
           if(!milestoneWeeksToDelete.isEmpty()) delete milestoneWeeksToDelete;                               
           if(!milestoneWeeksToUpsert.isEmpty()) upsert milestoneWeeksToUpsert;
           
           resetOrderOnMilestoneWeeks(estimateId);
        }catch(Exception ex){
           return 'Failed: ' + ex.getMessage();
        }                                                                                         
        return 'Success';
    }
    
    // method to add more columns on Left
    public static string addMoreColumnsOnLeft(string estimateId, 
                                                   string weekId, 
                                                   integer noOfColumnsToAdd){                                                   
        List<E2_Estimate_Week_Milestone__c> milestoneWeeksToUpsert = new List<E2_Estimate_Week_Milestone__c>();
        
        boolean incrementalUpdateRequired = false;
        boolean dateUpdateRequiredForSucceedingRecords = false;
        
        // retrieve all the existing estimate week records in the ascending order of start date
        for(E2_Estimate_Week_Milestone__c estimateWeekMilestone : E2_MilestoneDataUtil_WS.getEstimateWeekMilestoneRecords(estimateId)){
            
            if(incrementalUpdateRequired){
               // change the succeeding dates only when adding in between the columns
               // if it is first column selected then we don't need to change the dates
               if(dateUpdateRequiredForSucceedingRecords) estimateWeekMilestone.Date__c = estimateWeekMilestone.Date__c.addDays(NO_OF_DAYS_IN_WEEK * noOfColumnsToAdd);
               
               estimateWeekMilestone.Order__c = estimateWeekMilestone.Order__c + noOfColumnsToAdd;
               estimateWeekMilestone.Name = WEEKNAME_PREFIX + estimateWeekMilestone.Order__c;
               milestoneWeeksToUpsert.add(estimateWeekMilestone);               
            }
            
            if(estimateWeekMilestone.id == weekId){
                
               if(estimateWeekMilestone.Order__c <> NULL && estimateWeekMilestone.Order__c.intValue() > 1){
                   estimateWeekMilestone.Date__c = estimateWeekMilestone.Date__c.addDays(NO_OF_DAYS_IN_WEEK * (noOfColumnsToAdd));
                   dateUpdateRequiredForSucceedingRecords = true;
               }       
               
               // inrement the order with the number of columns now adding at left position
               estimateWeekMilestone.Order__c = estimateWeekMilestone.Order__c + noOfColumnsToAdd;
               // change week name with the new order
               estimateWeekMilestone.Name = WEEKNAME_PREFIX + estimateWeekMilestone.Order__c;
               // add in to upsert list
               milestoneWeeksToUpsert.add(estimateWeekMilestone);  
               
               integer order = estimateWeekMilestone.Order__c.intValue();
               Date sDate = estimateWeekMilestone.Date__c;
               
               for(integer indx = 1; indx <= noOfColumnsToAdd; indx++){   
                  integer newOrderToBeAssigned = (order - indx);
                  Date newDateToBeAssinged = sDate.addDays(NO_OF_DAYS_IN_WEEK * (-indx));
                  milestoneWeeksToUpsert.add(createMilestoneColumnOverload(estimateId, newDateToBeAssinged, newOrderToBeAssigned, WEEKNAME_PREFIX + newOrderToBeAssigned));               
               }
               incrementalUpdateRequired = true;
            }
        }
        
        // process insert/update in database           
        try{                                
           if(!milestoneWeeksToUpsert.isEmpty()) upsert milestoneWeeksToUpsert;
        }catch(Exception ex){
           return 'Failed: ' + ex.getMessage();
        }                                                                                         
        return 'Success';
    }
    
    // method to add more columns on right
    public static string addMoreColumnsOnRight(string estimateId, 
                                                   string weekId, 
                                                   integer noOfColumnsToAdd){                                                   
        List<E2_Estimate_Week_Milestone__c> milestoneWeeksToUpsert = new List<E2_Estimate_Week_Milestone__c>();
        boolean incrementalUpdateRequired = false;
        for(E2_Estimate_Week_Milestone__c estimateWeekMilestone : E2_MilestoneDataUtil_WS.getEstimateWeekMilestoneRecords(estimateId)){
            
            if(incrementalUpdateRequired){
               estimateWeekMilestone.Date__c = estimateWeekMilestone.Date__c.addDays(NO_OF_DAYS_IN_WEEK * noOfColumnsToAdd);
               estimateWeekMilestone.Order__c = estimateWeekMilestone.Order__c + noOfColumnsToAdd;
               estimateWeekMilestone.Name = WEEKNAME_PREFIX + estimateWeekMilestone.Order__c;
               milestoneWeeksToUpsert.add(estimateWeekMilestone);               
            }
            
            
            if(estimateWeekMilestone.id == weekId){
               integer order = estimateWeekMilestone.Order__c.intValue();
               Date sDate = estimateWeekMilestone.Date__c;
               for(integer indx = 1; indx <= noOfColumnsToAdd; indx++){                   
                  milestoneWeeksToUpsert.add(createMilestoneColumnOverload(estimateId, sDate.addDays(NO_OF_DAYS_IN_WEEK * indx), order + indx, WEEKNAME_PREFIX + (order + indx)));               
               }
               incrementalUpdateRequired = true;
            }                                    
        }
        
        // process insert/update in database           
        try{                                
           upsert milestoneWeeksToUpsert;
           //resetOrderOnEstimateWeeks(estimateId);
        }catch(Exception ex){
           return 'Failed: ' + ex.getMessage();
        }                                                                                         
        return 'Success';
    }
    
    // method to create estimate weeks on build
    public static string onBuild(string estimateId, string sDate, integer noOfColumnsToAdd){
        List<E2_Estimate_Week_Milestone__c> milestoneWeeksToUpsert = new List<E2_Estimate_Week_Milestone__c>();
        Date startDate = date.valueOf(sDate);
        
        List<E2_Estimate_Week_Milestone__c> existingList = [SELECT Id, Order__c
                                          FROM E2_Estimate_Week_Milestone__c                                                    
                                          WHERE Estimate__c = :estimateId
                                          ORDER BY Date__c ASC];
                                          
        // No need to build new weeks when there are weeks already defined.
        // build feature is just used to create fist time weeks and than this feature doesn't 
        // need to work.
        if(!existingList.isEmpty()){
            return 'Success';
        }
        
        
        for(integer indx = 0; indx < noOfColumnsToAdd; indx++){
            milestoneWeeksToUpsert.add(createMilestoneColumnOverload(estimateId, startDate.addDays(NO_OF_DAYS_IN_WEEK * indx), indx + 1, WEEKNAME_PREFIX + (indx + 1)));
        }
        
        // process insert/update in database           
        try{                                
          if(!milestoneWeeksToUpsert.isEmpty()) upsert milestoneWeeksToUpsert;
        }catch(Exception ex){
           return 'Failed: ' + ex.getMessage();
        }                                                                                         
        return 'Success';
        
    }
    
    
    // method to create estimate week on selection of start date on the page
    public static string onStartDateSelectionChange(string estimateId, 
                                                  string sDate, 
                                                  integer order,
                                                  string name){
                                                  
        List<E2_Estimate_Week_Milestone__c> milestoneWeeksToUpsert = new List<E2_Estimate_Week_Milestone__c>();
        Date startDate = date.valueOf(sDate);
        Integer index = 0;
        for(E2_Estimate_Week_Milestone__c estimateWeekMilestone : E2_MilestoneDataUtil_WS.getEstimateWeekMilestoneRecords(estimateId)){
                                                 
             estimateWeekMilestone.Date__c = startDate.addDays(NO_OF_DAYS_IN_WEEK * index);
             estimateWeekMilestone.Name = WEEKNAME_PREFIX + (index + 1);
             estimateWeekMilestone.Order__c = index + 1;
             milestoneWeeksToUpsert.add(estimateWeekMilestone);
             index++;
        }
        // there are no column exists than create new                                          
        if(milestoneWeeksToUpsert.isEmpty()){
          milestoneWeeksToUpsert.add(createMilestoneColumn(estimateId, sDate, order, name));
        }   
        // process insert/update in database           
        try{                                
           upsert milestoneWeeksToUpsert;
        }catch(Exception ex){
           return 'Failed: ' + ex.getMessage();
        }                                                                                         
        return 'Success';                                          
    }
    
    public static void resetOrderOnMilestoneWeeks(string estimateId){
           List<E2_Estimate_Week_Milestone__c> milestoneWeeksToUpdate = new List<E2_Estimate_Week_Milestone__c>();
           integer displayOrder = 1;
           for(E2_Estimate_Week_Milestone__c eW : [SELECT Id, Name, Order__c
                                          FROM E2_Estimate_Week_Milestone__c                                                    
                                          WHERE Estimate__c = :estimateId
                                          ORDER BY Date__c ASC]){
                 eW.Order__c = displayOrder;
                 eW.Name = WEEKNAME_PREFIX + eW.Order__c;
                 displayOrder++;
                 milestoneWeeksToUpdate.add(eW); 
           }
           
           if(!milestoneWeeksToUpdate.isEmpty()){
               update milestoneWeeksToUpdate;
           }
    }
    
    // method to create timeline columns on load
    public static E2_Estimate_Week_Milestone__c createMilestoneColumnOverload(string estimateId, 
                                                  date sDate, 
                                                  integer order,
                                                  string name){
       E2_Estimate_Week_Milestone__c milestoneWeek = new E2_Estimate_Week_Milestone__c(Name = name,
                                                                    Date__c = sDate, 
                                                                    Estimate__c = estimateId,
                                                                    Order__c = Decimal.valueOf(order)
                                                                    );
       return milestoneWeek;                                                             
    }
    
    // method to create timeline column 
    public static E2_Estimate_Week_Milestone__c createMilestoneColumn(string estimateId, 
                                                  string sDate, 
                                                  integer order,
                                                  string name){
       E2_Estimate_Week_Milestone__c milestoneWeek = new E2_Estimate_Week_Milestone__c(Name = name,
                                                                    Date__c = date.valueOf(sDate), 
                                                                    Estimate__c = estimateId,                                                                     
                                                                    Order__c = Decimal.valueOf(order));
       return milestoneWeek;                                                             
    }
}