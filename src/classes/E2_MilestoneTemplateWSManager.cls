/**=====================================================================
 * Appirio, Inc
 * Name: E2_MilestoneTemplateWSManager
 * Description: S-464465: This is a manager class; constitutes all the business logic for E2_MilestoneTemplateWS webservcie
 * Created Date: Feb 05, 2017
 * Created By: Rohit Sharma
 * 
 * Date Modified          Modified by            Description
 * 
*  =====================================================================*/
public class E2_MilestoneTemplateWSManager {
   public static final string SEPARATOR = '|';    
   public static final string TEXT_SEPARATOR = '-';  
   public static final string DATE_SLASH = '/'; 
   public static final string MILESTONE1_ID = 'milestone1';
   public static final string MILESTONE2_ID = 'milestone2';
   public static final integer NO_OF_DAYS_IN_WEEK = 7;
   public static final string WEEKNAME_PREFIX = 'Week';
   
   
    public static string mergeUnmerge(string jsonstr){
        //method to merge/ unmerge E2_Milestone_Week_Template_Junction__c
        List<E2_MilestoneTemplateWS.MilestoneWeekWrapper> lst = (List<E2_MilestoneTemplateWS.MilestoneWeekWrapper>)JSON.deserialize(jsonstr, List<E2_MilestoneTemplateWS.MilestoneWeekWrapper>.class);
        
        Set<String> weekIds = new Set<String>();
        Set<String> milestoneIds = new Set<String>();
        Map<String, E2_Milestone_Week_Template_Junction__c> milestoneWeekMap = new Map<String, E2_Milestone_Week_Template_Junction__c>();
        List<E2_Milestone_Week_Template_Junction__c> lstToInsert = new List<E2_Milestone_Week_Template_Junction__c>();
        List<E2_Milestone_Week_Template_Junction__c> lstToUpdate = new List<E2_Milestone_Week_Template_Junction__c>();
        
        for(E2_MilestoneTemplateWS.MilestoneWeekWrapper rwW : lst){
            
            weekIds.add(rwW.weekId);
            milestoneIds.add(rwW.milestoneId);    
        }
        
        for(E2_Milestone_Week_Template_Junction__c rwW : E2_MilestoneTemplateDataUtil_WS.getTemplateMilestoneWeeks(weekIds, milestoneIds)){
               system.debug('rwW>>>' +rwW);
               string key = rwW.Timeline_Milestone__c + SEPARATOR + rwW.Week_Milestone_Template__c;
               milestoneWeekMap.put(key, rwW);           
        }
         
       for(E2_MilestoneTemplateWS.MilestoneWeekWrapper rwW : lst){
            string key = rwW.milestoneId + SEPARATOR + rwW.weekId;
            string text = rwW.text;
            string colorCode = rwW.textcolorcode;
            
            if(milestoneWeekMap.containsKey(key)){
                E2_Milestone_Week_Template_Junction__c eRW = milestoneWeekMap.get(key);
                eRW.Text__c = text;
                eRW.TextColorCode__c = colorCode;
                lstToUpdate.add(eRW);
            }else{
                E2_Milestone_Week_Template_Junction__c eRW = new E2_Milestone_Week_Template_Junction__c(Text__c = text, TextColorCode__c = colorCode, Timeline_Milestone__c = rwW.milestoneId, Week_Milestone_Template__c = rwW.weekId);
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
        //method to update color code for E2_Milestone_Week_Template_Junction__c
        List<E2_MilestoneTemplateWS.RowColumnWrapper> lstColorCodes = (List<E2_MilestoneTemplateWS.RowColumnWrapper>)JSON.deserialize(jsonstr, List<E2_MilestoneTemplateWS.RowColumnWrapper>.class);
        Set<String> weekIds = new Set<String>();
        Set<String> milestoneIds = new Set<String>();
        Map<String, E2_Milestone_Week_Template_Junction__c> milestoneWeekMap = new Map<String, E2_Milestone_Week_Template_Junction__c>();
        List<E2_Milestone_Week_Template_Junction__c> lstToInsert = new List<E2_Milestone_Week_Template_Junction__c>();
        List<E2_Milestone_Week_Template_Junction__c> lstToUpdate = new List<E2_Milestone_Week_Template_Junction__c>();
        
        for(E2_MilestoneTemplateWS.RowColumnWrapper rwW : lstColorCodes){
            
            weekIds.add(rwW.weekId);
            milestoneIds.add(rwW.rowId);    
        }
        
        for(E2_Milestone_Week_Template_Junction__c rwW : E2_MilestoneTemplateDataUtil_WS.getTemplateMilestoneWeeks(weekIds, milestoneIds)){
               
               string key = rwW.Timeline_Milestone__c + SEPARATOR + rwW.Week_Milestone_Template__c;
               milestoneWeekMap.put(key, rwW);           
        }
         
       for(E2_MilestoneTemplateWS.RowColumnWrapper rwW : lstColorCodes){
            string key = rwW.rowId + SEPARATOR + rwW.weekId;
            string colorCode = rwW.value;
            
            if(milestoneWeekMap.containsKey(key)){
                E2_Milestone_Week_Template_Junction__c eRW = milestoneWeekMap.get(key);
                eRW.TextColorCode__c = colorCode;
                lstToUpdate.add(eRW);
            }else{
                E2_Milestone_Week_Template_Junction__c eRW = new E2_Milestone_Week_Template_Junction__c(TextColorCode__c = colorCode, Timeline_Milestone__c = rwW.rowId, Week_Milestone_Template__c = rwW.weekId);
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
    
    
    
    public static string updateMilestone1(string templateId, string milestoneId, string milestone1){
        //method to update Milestone1__c 
        List<E2_Timeline_Milestone__c> estimatResourceList = E2_MilestoneTemplateDataUtil_WS.getMilestone(templateId, milestoneId);
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
    
    
    
    public static string updateMilestone2(string templateId, string milestoneId, string milestone2){
        //method to update Milestone2__c
        List<E2_Timeline_Milestone__c> estimatResourceList = E2_MilestoneTemplateDataUtil_WS.getMilestone(templateId, milestoneId);
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
        List<E2_MilestoneTemplateWS.MilestoneWeekWrapper> lstColorCodes = (List<E2_MilestoneTemplateWS.MilestoneWeekWrapper>)JSON.deserialize(jsonstr, List<E2_MilestoneTemplateWS.MilestoneWeekWrapper>.class);
        Set<String> weekIds = new Set<String>();
        Set<String> milestoneIds = new Set<String>();
        Map<String, E2_Milestone_Week_Template_Junction__c> milestoneWeekMap = new Map<String, E2_Milestone_Week_Template_Junction__c>();
        List<E2_Milestone_Week_Template_Junction__c> lstToInsert = new List<E2_Milestone_Week_Template_Junction__c>();
        List<E2_Milestone_Week_Template_Junction__c> lstToUpdate = new List<E2_Milestone_Week_Template_Junction__c>();
        List<E2_Timeline_Milestone__c> lstMilestoneToInsert = new List<E2_Timeline_Milestone__c>();
        List<E2_Timeline_Milestone__c> lstMilestoneToUpdate = new List<E2_Timeline_Milestone__c>();
        
        for(E2_MilestoneTemplateWS.MilestoneWeekWrapper rwW : lstColorCodes){
            
            weekIds.add(rwW.weekId);
            milestoneIds.add(rwW.milestoneId);    
        }
        
        for(E2_Milestone_Week_Template_Junction__c rwW : E2_MilestoneTemplateDataUtil_WS.getTemplateMilestoneWeeks(weekIds, milestoneIds)){
               
               string key = rwW.Timeline_Milestone__c + SEPARATOR + rwW.Week_Milestone_Template__c;
               milestoneWeekMap.put(key, rwW);           
        }
         
       for(E2_MilestoneTemplateWS.MilestoneWeekWrapper rwW : lstColorCodes){
            string key = rwW.milestoneId + SEPARATOR + rwW.weekId;
            string text = rwW.text;
            string colorCode = rwW.textcolorcode;
            
            if(rwW.weekId == MILESTONE1_ID && String.isNotBlank(rwW.milestoneId)){
               lstMilestoneToUpdate.add(new E2_Timeline_Milestone__c( id = rwW.milestoneId, Milestone1__c = text));
            }else if(rwW.weekId == MILESTONE2_ID && String.isNotBlank(rwW.milestoneId)){
               lstMilestoneToUpdate.add(new E2_Timeline_Milestone__c( id = rwW.milestoneId, Milestone2__c = text)); 
            }else{
                if(milestoneWeekMap.containsKey(key)){
                    E2_Milestone_Week_Template_Junction__c eRW = milestoneWeekMap.get(key);
                    eRW.Text__c = text;
                    eRW.TextColorCode__c = colorCode;
                    lstToUpdate.add(eRW);
                }else{
                    E2_Milestone_Week_Template_Junction__c eRW = new E2_Milestone_Week_Template_Junction__c(Text__c = text, TextColorCode__c = colorCode, Timeline_Milestone__c = rwW.milestoneId, Week_Milestone_Template__c = rwW.weekId);
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
       List<E2_Milestone_Week_Template_Junction__c> resWeeks = E2_MilestoneTemplateDataUtil_WS.getTemplateMilestoneWeeksforWeek(weekId, milestoneId);
                                                       
       for(E2_Milestone_Week_Template_Junction__c resWeek : resWeeks){
          resWeek.Text__c = text;
       }
       
       // when no related record exist in database; do insert else do modify
       if(resWeeks.isEmpty()){
          resWeeks.add(new E2_Milestone_Week_Template_Junction__c( Text__c = text, Week_Milestone_Template__c = weekId, Timeline_Milestone__c = milestoneId));
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
        List<E2_MilestoneTemplateWS.RowWrapper> lstResourceWrapper = (List<E2_MilestoneTemplateWS.RowWrapper>)JSON.deserialize(jsonstr, List<E2_MilestoneTemplateWS.RowWrapper>.class);
        
        List<E2_Timeline_Milestone__c> lstResources = new List<E2_Timeline_Milestone__c>();
        for(E2_MilestoneTemplateWS.RowWrapper resWrapper : lstResourceWrapper){
            lstResources.add(new E2_Timeline_Milestone__c(Id = resWrapper.milestoneId, 
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
      
    public static string addRow(string templateId, integer order, string milestone1, string milestone2){
       //method to add rows in milestone     
       try{                             
         insert new E2_Timeline_Milestone__c( Milestone1__c = milestone1, 
                                             E2_Milestone_Library__c = templateId,     
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
         delete new E2_Timeline_Milestone__c(id = rowId);
       }catch(Exception ex){
         return 'Failed: ' + ex.getMessage();
       }
       return 'Success';
    }
    
    public static string deleteAllRows(string templateId){
        //method to delete row in milestone 
        try{                             
         delete [SELECT id from E2_Timeline_Milestone__c WHERE E2_Milestone_Library__c =: templateId];
       }catch(Exception ex){
         return 'Failed: ' + ex.getMessage();
       }
       return 'Success';
    }
    
    
    public static List<E2_MilestoneTemplateWS.E2_MilestoneRow> getMilestoneRows(string templateId){
        //method to get milestone rows for a given templateId
        List<E2_MilestoneTemplateWS.E2_MilestoneRow> rows = new List<E2_MilestoneTemplateWS.E2_MilestoneRow>();
        
        
        for(E2_Timeline_Milestone__c res : E2_MilestoneTemplateDataUtil_WS.getTemplateMilestoneAndAllWeeks(templateId)){
                                                      
             List<E2_MilestoneTemplateWS.E2_MilestoneRowColumn> colRows = new List<E2_MilestoneTemplateWS.E2_MilestoneRowColumn>();
             for(E2_Milestone_Week_Template_Junction__c colRow : res.Milestone_Week_Template_Junction__r){
               colRows.add(new E2_MilestoneTemplateWS.E2_MilestoneRowColumn(colRow.id, colRow.Week_Milestone_Template__c, 
                                                                    (colRow.Text__c == null ? '' : colRow.Text__c) , 
                                                                    colRow.TextColorCode__c == null ? '' : colRow.TextColorCode__c));
             }
             rows.add(new E2_MilestoneTemplateWS.E2_MilestoneRow(res.id, res.Milestone1__c, 
                      res.Milestone2__c,  
                      res.Order__c.intValue(), 
                      colRows));                                   
         }        
        return rows;
    }
    
    
    public static List<E2_MilestoneTemplateWS.E2_MilestoneColumn> getMilestoneColumns(string templateId){
        //method to get milestone column for templateId
        List<E2_MilestoneTemplateWS.E2_MilestoneColumn> columns = new List<E2_MilestoneTemplateWS.E2_MilestoneColumn>();        
        integer width = 60;
        string behavior = '';
        string editor = '';
        string groupName = 'none';        
        boolean selectable = false;
        boolean resizable = false;
        string cssClass = '';
        string header = '{"menu": { "items": [{ "title": "Insert 1 right", "command" : "insert_1_right" },{ "title" : "Insert 2 right", "command" : "insert_2_right" }, { "title" : "Insert 1 left", "command" : "insert_1_left" }, { "title" : "Insert 2 left", "command" : "insert_2_left" }, { "title" : "Delete column", "command" : "delete_column" }]}}';
        
        for(E2_Week_Milestone_Template__c TemplateWeekMilestone : E2_MilestoneTemplateDataUtil_WS.getTemplateWeekMilestoneRecords(templateId)){
             
              Date weekDate = TemplateWeekMilestone.Date__c;
              string sDate = E2_Constants.BLANK;//weekDate.month() + DATE_SLASH + weekDate.day() + DATE_SLASH + weekDate.year(); 
              string name = TemplateWeekMilestone.Name;//weekDate.month() + DATE_SLASH + weekDate.day();   
             // string nameWithYear = weekDate.month() + '/' + weekDate.day() + '/' + String.valueOf(weekDate.year()).right(2);
              columns.add(new E2_MilestoneTemplateWS.E2_MilestoneColumn(TemplateWeekMilestone.id, 
                                            name,
                                            //nameWithYear,
                                            TemplateWeekMilestone.id,
                                            width,
                                            behavior,
                                            editor,
                                            groupName,
                                            TemplateWeekMilestone.Order__c == null ? 1 : TemplateWeekMilestone.Order__c.intValue(),
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
    public static string deleteColumn(string templateId, string weekId){
        List<E2_Week_Milestone_Template__c> milestoneWeeksToUpsert = new List<E2_Week_Milestone_Template__c>();
        List<E2_Week_Milestone_Template__c> milestoneWeeksToDelete = new List<E2_Week_Milestone_Template__c>();
        
        boolean incrementalUpdateRequired = false;
        //integer noOfColumnsToDelete = 1;
        boolean dateUpdateRequiredForSucceedingRecords = false;
        Date newStartDate; 
        Decimal newOrder; 
        for(E2_Week_Milestone_Template__c TemplateWeekMilestone : E2_MilestoneTemplateDataUtil_WS.getTemplateWeekMilestoneRecords(templateId)){
            
            // we don't need to process or update records whose order or start date is less than the current week
            if(incrementalUpdateRequired){
               /*if(dateUpdateRequiredForSucceedingRecords){
                   // set the new start date for this record
                   TemplateWeekMilestone.Date__c = newStartDate;
                   // reset newStartDate variable with date + 7 days
                   newStartDate = TemplateWeekMilestone.Date__c.addDays(NO_OF_DAYS_IN_WEEK);
               } */
               //check that order is already populated
               if(TemplateWeekMilestone.Order__c <> NULL){
                   // set the new order for this record
                   TemplateWeekMilestone.Order__c = newOrder;
                   // reset newOrder variable with +1 increment
                   newOrder = TemplateWeekMilestone.Order__c + 1;
                   // set the week name with the order
                   TemplateWeekMilestone.Name = WEEKNAME_PREFIX + TemplateWeekMilestone.Order__c;
                   milestoneWeeksToUpsert.add(TemplateWeekMilestone);               
               }
            }
            
            //delete the selected week record   
            if(TemplateWeekMilestone.id == weekId){
               milestoneWeeksToDelete.add(TemplateWeekMilestone);
               
               // set the newOrder of succeeding record based on this records order
               newOrder = TemplateWeekMilestone.Order__c;
               if(TemplateWeekMilestone.Order__c <> NULL && TemplateWeekMilestone.Order__c.intValue() > 1){
                 // set the new start date to this records date for the succeeding records
                 newStartDate = TemplateWeekMilestone.Date__c;
                 dateUpdateRequiredForSucceedingRecords = true;  
               } 
               incrementalUpdateRequired = true;
            }                                    
        }
        
        // process insert/update in database           
        try{ 
           if(!milestoneWeeksToDelete.isEmpty()) delete milestoneWeeksToDelete;                               
           if(!milestoneWeeksToUpsert.isEmpty()) upsert milestoneWeeksToUpsert;
           
           resetOrderOnMilestoneWeeks(templateId);
        }catch(Exception ex){
           return 'Failed: ' + ex.getMessage();
        }                                                                                         
        return 'Success';
    }
    
    // method to add more columns on Left
    public static string addMoreColumnsOnLeft(string templateId, 
                                                   string weekId, 
                                                   integer noOfColumnsToAdd){                                                   
        List<E2_Week_Milestone_Template__c> milestoneWeeksToUpsert = new List<E2_Week_Milestone_Template__c>();
        
        boolean incrementalUpdateRequired = false;
        boolean dateUpdateRequiredForSucceedingRecords = false;
        
        // retrieve all the existing Template week records in the ascending order of start date
        for(E2_Week_Milestone_Template__c TemplateWeekMilestone : E2_MilestoneTemplateDataUtil_WS.getTemplateWeekMilestoneRecords(templateId)){
            
            if(incrementalUpdateRequired){
               // change the succeeding dates only when adding in between the columns
               // if it is first column selected then we don't need to change the dates
               if(dateUpdateRequiredForSucceedingRecords) TemplateWeekMilestone.Date__c = TemplateWeekMilestone.Date__c.addDays(NO_OF_DAYS_IN_WEEK * noOfColumnsToAdd);
               
               TemplateWeekMilestone.Order__c = TemplateWeekMilestone.Order__c + noOfColumnsToAdd;
               TemplateWeekMilestone.Name = WEEKNAME_PREFIX + TemplateWeekMilestone.Order__c;
               milestoneWeeksToUpsert.add(TemplateWeekMilestone);               
            }
            
            if(TemplateWeekMilestone.id == weekId){
                
               /*if(TemplateWeekMilestone.Order__c <> NULL && TemplateWeekMilestone.Order__c.intValue() > 1){
                   TemplateWeekMilestone.Date__c = TemplateWeekMilestone.Date__c.addDays(NO_OF_DAYS_IN_WEEK * (noOfColumnsToAdd));
                   dateUpdateRequiredForSucceedingRecords = true;
               }       
               */
               // inrement the order with the number of columns now adding at left position
               TemplateWeekMilestone.Order__c = TemplateWeekMilestone.Order__c + noOfColumnsToAdd;
               // change week name with the new order
               TemplateWeekMilestone.Name = WEEKNAME_PREFIX + TemplateWeekMilestone.Order__c;
               // add in to upsert list
               milestoneWeeksToUpsert.add(TemplateWeekMilestone);  
               
               integer order = TemplateWeekMilestone.Order__c.intValue();
               //Date sDate = TemplateWeekMilestone.Date__c;
               
               for(integer indx = 1; indx <= noOfColumnsToAdd; indx++){   
                  integer newOrderToBeAssigned = (order - indx);
                  //Date newDateToBeAssinged = sDate.addDays(NO_OF_DAYS_IN_WEEK * (-indx));
                  milestoneWeeksToUpsert.add(createMilestoneColumnOverload(templateId, /*newDateToBeAssinged,*/ newOrderToBeAssigned, WEEKNAME_PREFIX + newOrderToBeAssigned));               
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
    public static string addMoreColumnsOnRight(string templateId, 
                                                   string weekId, 
                                                   integer noOfColumnsToAdd){                                                   
        List<E2_Week_Milestone_Template__c> milestoneWeeksToUpsert = new List<E2_Week_Milestone_Template__c>();
        boolean incrementalUpdateRequired = false;
        for(E2_Week_Milestone_Template__c TemplateWeekMilestone : E2_MilestoneTemplateDataUtil_WS.getTemplateWeekMilestoneRecords(templateId)){
            
            if(incrementalUpdateRequired){
               //TemplateWeekMilestone.Date__c = TemplateWeekMilestone.Date__c.addDays(NO_OF_DAYS_IN_WEEK * noOfColumnsToAdd);
               TemplateWeekMilestone.Order__c = TemplateWeekMilestone.Order__c + noOfColumnsToAdd;
               TemplateWeekMilestone.Name = WEEKNAME_PREFIX + TemplateWeekMilestone.Order__c;
               milestoneWeeksToUpsert.add(TemplateWeekMilestone);               
            }
            
            
            if(TemplateWeekMilestone.id == weekId){
               integer order = TemplateWeekMilestone.Order__c.intValue();
               //Date sDate = TemplateWeekMilestone.Date__c;
               for(integer indx = 1; indx <= noOfColumnsToAdd; indx++){                   
                  milestoneWeeksToUpsert.add(createMilestoneColumnOverload(templateId, /*sDate.addDays(NO_OF_DAYS_IN_WEEK * indx),*/ order + indx, WEEKNAME_PREFIX + (order + indx)));               
               }
               incrementalUpdateRequired = true;
            }                                    
        }
        
        // process insert/update in database           
        try{                                
           upsert milestoneWeeksToUpsert;
           //resetOrderOnTemplateWeeks(templateId);
        }catch(Exception ex){
           return 'Failed: ' + ex.getMessage();
        }                                                                                         
        return 'Success';
    }
    
    // method to create Template weeks on build
    public static string onBuild(string templateId, /*string sDate,*/ integer noOfColumnsToAdd){
        List<E2_Week_Milestone_Template__c> milestoneWeeksToUpsert = new List<E2_Week_Milestone_Template__c>();
        //Date startDate = date.valueOf(sDate);
        
        List<E2_Week_Milestone_Template__c> existingList = [SELECT Id, Order__c
                                          FROM E2_Week_Milestone_Template__c                                                    
                                          WHERE Milestone_Library__c = :templateId
                                          ORDER BY Order__c ASC];
                                          
        // No need to build new weeks when there are weeks already defined.
        // build feature is just used to create fist time weeks and than this feature doesn't 
        // need to work.
        if(!existingList.isEmpty()){
            return 'Success';
        }
        
        
        for(integer indx = 0; indx < noOfColumnsToAdd; indx++){
            milestoneWeeksToUpsert.add(createMilestoneColumnOverload(templateId, /*startDate.addDays(NO_OF_DAYS_IN_WEEK * indx),*/ indx + 1, WEEKNAME_PREFIX + (indx + 1)));
        }
        
        // process insert/update in database           
        try{                                
          if(!milestoneWeeksToUpsert.isEmpty()) upsert milestoneWeeksToUpsert;
        }catch(Exception ex){
           return 'Failed: ' + ex.getMessage();
        }                                                                                         
        return 'Success';
        
    }
    
    
    // method to create Template week on selection of start date on the page
    public static string onStartDateSelectionChange(string templateId, 
                                                  string sDate, 
                                                  integer order,
                                                  string name){
                                                  
        List<E2_Week_Milestone_Template__c> milestoneWeeksToUpsert = new List<E2_Week_Milestone_Template__c>();
        Date startDate = date.valueOf(sDate);
        Integer index = 0;
        for(E2_Week_Milestone_Template__c TemplateWeekMilestone : E2_MilestoneTemplateDataUtil_WS.getTemplateWeekMilestoneRecords(templateId)){
                                                 
             TemplateWeekMilestone.Date__c = startDate.addDays(NO_OF_DAYS_IN_WEEK * index);
             TemplateWeekMilestone.Name = WEEKNAME_PREFIX + (index + 1);
             TemplateWeekMilestone.Order__c = index + 1;
             milestoneWeeksToUpsert.add(TemplateWeekMilestone);
             index++;
        }
        // there are no column exists than create new                                          
        if(milestoneWeeksToUpsert.isEmpty()){
          milestoneWeeksToUpsert.add(createMilestoneColumn(templateId, /*sDate,*/ order, name));
        }   
        // process insert/update in database           
        try{                                
           upsert milestoneWeeksToUpsert;
        }catch(Exception ex){
           return 'Failed: ' + ex.getMessage();
        }                                                                                         
        return 'Success';                                          
    }
    
    public static void resetOrderOnMilestoneWeeks(string templateId){
           List<E2_Week_Milestone_Template__c> milestoneWeeksToUpdate = new List<E2_Week_Milestone_Template__c>();
           integer displayOrder = 1;
           for(E2_Week_Milestone_Template__c eW : [SELECT Id, Name, Order__c
                                          FROM E2_Week_Milestone_Template__c                                                    
                                          WHERE Milestone_Library__c = :templateId
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
    public static E2_Week_Milestone_Template__c createMilestoneColumnOverload(string templateId, 
                                                  //date sDate, 
                                                  integer order,
                                                  string name){
       E2_Week_Milestone_Template__c milestoneWeek = new E2_Week_Milestone_Template__c(Name = name,
                                                                    //Date__c = sDate, 
                                                                    Milestone_Library__c = templateId,
                                                                    Order__c = Decimal.valueOf(order)
                                                                    );
       return milestoneWeek;                                                             
    }
    
    // method to create timeline column 
    public static E2_Week_Milestone_Template__c createMilestoneColumn(string templateId, 
                                                  //string sDate, 
                                                  integer order,
                                                  string name){
       E2_Week_Milestone_Template__c milestoneWeek = new E2_Week_Milestone_Template__c(Name = name,
                                                                    //Date__c = date.valueOf(sDate), 
                                                                    Milestone_Library__c = templateId,                                                                     
                                                                    Order__c = Decimal.valueOf(order));
       return milestoneWeek;                                                             
    }
}