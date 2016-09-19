/**=====================================================================
 * Appirio, Inc
 * Name: E2_TimelineWSManager
 * Description: This is a manager class; constitutes all the business logic for E2_TimelineWS webservcie
 * Created Date: Aug 12, 2016
 * Created By: Rahul Jain (Appirio)
 * 08 Sep 2016: Modified: RJ : Added E2_Estimate_Rate_Card__r.Resource_Role__c, E2_Estimate_Rate_Card__r.Region__c field in the query method for 
 *                             Capacity Needs and Timeline Hours based on roles
*  =====================================================================*/
public class E2_TimelineWSManager {
    
   public static final string SEPARATOR = ' - ';    
   public static final integer NO_OF_DAYS_IN_WEEK = 7;    
   public static final string PHASE_TEXT = 'phase';
   public static final string MILESTONE_TEXT = 'milestone';
   public static final string MILESTONE1_TEXT = 'milestone1';
   public static final string MILESTONE2_TEXT = 'milestone2';
   public static final string KEY_SEPARATOR = '|';
   public static final string WEEKNAME_PREFIX = 'Week';
   
   
   // method to get estimate rate card for an estimate 
   public static List<E2_Estimate_Rate_Card__c> getEstimateRateCards(string estimateId){
        List<E2_Estimate_Rate_Card__c> estimateRateCards = E2_TimelineDataUtil_WS.getEstimateRateCards(estimateId);
        return estimateRateCards;
   }
   
   // method to update Color Code depending upon code type 
   public static string updateColorCode(string jsonstr){
        List<E2_TimelineWS.ColorCode> lstColorCodes = (List<E2_TimelineWS.ColorCode>)JSON.deserialize(jsonstr, List<E2_TimelineWS.ColorCode>.class);
        Map<String, CMC_Estimate_Week__c> estimateWeeksMap = new Map<String, CMC_Estimate_Week__c>();
        for(E2_TimelineWS.ColorCode cCode: lstColorCodes){
            if(!estimateWeeksMap.containsKey(cCode.weekId))  estimateWeeksMap.put(cCode.weekId, new CMC_Estimate_Week__c(Id = cCode.weekId));
            if(cCode.type == PHASE_TEXT){
                CMC_Estimate_Week__c week = estimateWeeksMap.get(cCode.weekId);
                week.E2_PhaseColorCode__c = cCode.value;
                estimateWeeksMap.put(cCode.weekId, week);
            } 
            
            if(cCode.type == MILESTONE_TEXT) {
                CMC_Estimate_Week__c week = estimateWeeksMap.get(cCode.weekId);
                week.E2_MilestoneColorCode__c = cCode.value;
                estimateWeeksMap.put(cCode.weekId, week);
            }
            
            if(cCode.type == MILESTONE1_TEXT) {
                CMC_Estimate_Week__c week = estimateWeeksMap.get(cCode.weekId);
                week.E2_Milestone1ColorCode__c = cCode.value;
                estimateWeeksMap.put(cCode.weekId, week);
            }
            
            
            if(cCode.type == MILESTONE2_TEXT) {
                CMC_Estimate_Week__c week = estimateWeeksMap.get(cCode.weekId);
                week.E2_Milestone2ColorCode__c = cCode.value;
                estimateWeeksMap.put(cCode.weekId, week);
            }
        }
        
        try{

         if(!estimateWeeksMap.isEmpty()) update estimateWeeksMap.values();
         
        }catch(Exception ex){
         return 'Failed: ' + ex.getMessage(); 
        }
         
        return 'Success';
    }
    
    // method to update Phase color code 
    public static string updatePhaseColorCode(string weekId, string phaseColorCode){
       try{
         update new CMC_Estimate_Week__c(Id = weekId,
                                         E2_PhaseColorCode__c = phaseColorCode);
       }catch(Exception ex){
         return 'Failed: ' + ex.getMessage(); 
       }
       return weekId;  
    }
    
    // method to update Milestone color code for type = 'milestone'
    public static string updateMilestoneColorCode(string weekId, string milestoneColorCode){
       try{
         update new CMC_Estimate_Week__c(Id = weekId,
                                         E2_MilestoneColorCode__c = milestoneColorCode);
       }catch(Exception ex){
         return 'Failed: ' + ex.getMessage(); 
       }
       return weekId;  
    }
    
    //  method to update Milestone color code for type = 'milestone1'
    public static string updateMilestoneColorCode1(string weekId, string milestoneColorCode1){
       try{
         update new CMC_Estimate_Week__c(Id = weekId,
                                         E2_Milestone1ColorCode__c = milestoneColorCode1);
       }catch(Exception ex){
         return 'Failed: ' + ex.getMessage(); 
       }
       return weekId;  
    }
    
    //  method to update Milestone color code for type = 'milestone2'
    public static string updateMilestoneColorCode2(string weekId, string milestoneColorCode2){
       try{
         update new CMC_Estimate_Week__c(Id = weekId,
                                         E2_Milestone2ColorCode__c = milestoneColorCode2);
       }catch(Exception ex){
         return 'Failed: ' + ex.getMessage(); 
       }
       return weekId;  
    }
    
    // method to update Phase__c and color code
    public static string updatePhaseAndColorCode(string weekId, string phase, string colorCode){
       try{
         update new CMC_Estimate_Week__c(Id = weekId,
                                         Phase__c = phase,
                                         E2_PhaseColorCode__c = colorCode);
       }catch(Exception ex){
         return 'Failed: ' + ex.getMessage(); 
       }
       return weekId;  
    }
    
    // method to update Phase__c
    public static string updatePhase(string weekId, string phase){
       try{
         update new CMC_Estimate_Week__c(Id = weekId,
                                         Phase__c = phase);
       }catch(Exception ex){
         return 'Failed: ' + ex.getMessage(); 
       }
       return weekId;  
    }
    
    // method to update Milestone__c
    public static string updateMilestone(string weekId, string milestone){
       try{
         update new CMC_Estimate_Week__c(Id = weekId,
                                         Milestone__c = milestone);
       }catch(Exception ex){
         return 'Failed: ' + ex.getMessage(); 
       }
       return weekId;  
    }
    
    // method to update E2_Milestone1__c
    public static string updateMilestone1(string weekId, string milestone1){
       try{
         update new CMC_Estimate_Week__c(Id = weekId,
                                         E2_Milestone1__c = milestone1);
       }catch(Exception ex){
         return 'Failed: ' + ex.getMessage(); 
       }
       return weekId;  
    }
    
    // method to update E2_Milestone2__c
    public static string updateMilestone2(string weekId, string milestone2){
       try{
         update new CMC_Estimate_Week__c(Id = weekId,
                                         E2_Milestone2__c = milestone2);
       }catch(Exception ex){
         return 'Failed: ' + ex.getMessage(); 
       }
       return weekId;  
    }
    
    // method to update Skills
    public static string updateSkill(string estimateId, string resourceId, string skill){
        List<CMC_Estimate_Resource__c> estimatResourceList = E2_TimelineDataUtil_WS.getEstimateResourceForSkill(estimateId, resourceId);
        try{
            if(!estimatResourceList.isEmpty()){
                estimatResourceList[0].Skill__c = skill;
                update estimatResourceList;
            }
        }catch(Exception ex){
            return 'Failed: ' + ex.getMessage();
        }
        return 'Success';
    }
    
    // method to update Hours__c
    public static string updateHours(string weekId, string resourceId, integer hours){
       List<CMC_Estimate_Resource_Week__c> resWeeks = E2_TimelineDataUtil_WS.getHoursforEstimateResourceWeek(weekId, resourceId);
                                                       
       for(CMC_Estimate_Resource_Week__c resWeek : resWeeks){
          resWeek.Hours__c = hours;
       }
       // when no related record exist in database; do insert else do modify
       if(resWeeks.isEmpty()){
          resWeeks.add(new CMC_Estimate_Resource_Week__c( Hours__c = hours, Estimate_Week__c = weekId, Estimate_Resource__c = resourceId));
       } 
       
       try{
          upsert resWeeks;
        }catch(Exception ex){
          return 'Failed: ' + ex.getMessage();
       }        
       return weekId + '-' + resourceId;                                                         
    
    }
    
    // method to auto fill CMC_Estimate_Resource_Week__c
    public static string autoFill(string jsonstr){
        system.debug('>>>>' + jsonstr);
        if(jsonstr == ']' || String.isEmpty(jsonstr)){
            return 'Failed to process: Please note that weeks has to be defined for auto fill';
        }
        List<E2_TimelineWS.ResourceWeekWrapper> lstResourceWeekWrapper = (List<E2_TimelineWS.ResourceWeekWrapper>)JSON.deserialize(jsonstr, List<E2_TimelineWS.ResourceWeekWrapper>.class);
        Set<String> weekIds = new Set<String>();
        Set<String> resourceIds = new Set<String>();
        Map<String, CMC_Estimate_Resource_Week__c> resourceWeekMap = new Map<String, CMC_Estimate_Resource_Week__c>();
        List<CMC_Estimate_Resource_Week__c> lstToInsert = new List<CMC_Estimate_Resource_Week__c>();
        List<CMC_Estimate_Resource_Week__c> lstToUpdate = new List<CMC_Estimate_Resource_Week__c>();
        
        for(E2_TimelineWS.ResourceWeekWrapper rwW : lstResourceWeekWrapper){
            
            weekIds.add(rwW.weekId);
            resourceIds.add(rwW.resourceId);    
        }
        
        for(CMC_Estimate_Resource_Week__c rwW : E2_TimelineDataUtil_WS.getEstimateResourceWeekRecords(weekIds, resourceIds)){
               
               string key = rwW.Estimate_Resource__c + KEY_SEPARATOR + rwW.Estimate_Week__c;
               resourceWeekMap.put(key, rwW);           
        }
        
         for(E2_TimelineWS.ResourceWeekWrapper rwW : lstResourceWeekWrapper){
            string key = rwW.resourceId + KEY_SEPARATOR + rwW.weekId;
            integer hours = rwW.hours;
            system.debug('==rwW.weekId'+rwW.weekId);
            if(resourceWeekMap.containsKey(key)){
                CMC_Estimate_Resource_Week__c eRW = resourceWeekMap.get(key);
                eRW.Hours__c = hours;
                lstToUpdate.add(eRW);
            }else{
                CMC_Estimate_Resource_Week__c eRW = new CMC_Estimate_Resource_Week__c(Hours__c = hours, Estimate_Resource__c = rwW.resourceId, Estimate_Week__c = rwW.weekId);
                lstToInsert.add(eRW);
            }
        }
        
       try{
          if(!lstToUpdate.isEmpty()) update lstToUpdate;
          if(!lstToInsert.isEmpty()) insert lstToInsert;
       }catch(Exception ex){
          return 'Failed: ' + ex.getMessage();
       }        
       return 'Success';
    }

    // method to reorder resources in CMC_Estimate_Resource__c
    public static string reOrderResources(string jsonstr){
        List<E2_TimelineWS.ResourceWrapper> lstResourceWrapper = (List<E2_TimelineWS.ResourceWrapper>)JSON.deserialize(jsonstr, List<E2_TimelineWS.ResourceWrapper>.class);
        
        List<CMC_Estimate_Resource__c> lstResources = new List<CMC_Estimate_Resource__c>();
        for(E2_TimelineWS.ResourceWrapper resWrapper : lstResourceWrapper){
            lstResources.add(new CMC_Estimate_Resource__c(Id = resWrapper.resourceId, 
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
    
    // method to add rows in CMC_Estimate_Resource__c
    public static string addRow(string estimateId, integer order, 
                                    integer cost, integer rate, string role, string e2role,
                                    string skill, string rateCode, string estimateRateCardId){
       List<CMC_Presales_LOE__c> estimateList = E2_TimelineDataUtil_WS.getCurrencyISOCodeonEstimate(estimateId);
                                             
       try{                             
         insert new CMC_Estimate_Resource__c(Cost__c = cost, 
                                             Estimate__c = estimateId,     
                                             Order__c = order, 
                                             Rate__c = rate, 
                                             Role__c = role, 
                                             E2_Role__c = e2role,
                                             Skill__c = skill,
                                             Rate_Code__c = rateCode,
                                             Is_Used_For_Calculations__c = true,
                                             CurrencyIsoCode = estimateList[0].CurrencyIsoCode,
                                             E2_Estimate_Rate_Card__c = (String.isEmpty(estimateRateCardId) ? null : estimateRateCardId));
       }catch(Exception ex){
         return 'Failed: ' + ex.getMessage();
       }
       return 'Success';
    }
    
    // method to update a row in CMC_Estimate_Resource__c
    public static string updateRow(string estimateId, string rowId, 
                                    string role, string e2role,
                                    string skill, string rateCode, integer cost, integer rate, string estimateRateCardId){
       try{                             
         update new CMC_Estimate_Resource__c(id = rowId,                                                                                        
                                             Role__c = role, 
                                             E2_Role__c = e2role,
                                             Cost__c = cost, 
                                             Rate__c = rate,
                                             Rate_Code__c = rateCode,
                                             E2_Estimate_Rate_Card__c = (String.isEmpty(estimateRateCardId) ? null : estimateRateCardId));
       }catch(Exception ex){
         return 'Failed: ' + ex.getMessage();
       }
       return 'Success';
    }
    
    // method to delete a row of CMC_Estimate_Resource__c
    public static string deleteRow(string rowId){
       try{                             
         delete new CMC_Estimate_Resource__c(id = rowId);
       }catch(Exception ex){
         return 'Failed: ' + ex.getMessage();
       }
       return 'Success';
    }
    
    // method to delete columns
    public static string deleteColumn(string estimateId, string weekId){
        List<CMC_Estimate_Week__c> estimateWeeksToUpsert = new List<CMC_Estimate_Week__c>();
        List<CMC_Estimate_Week__c> estimateWeeksToDelete = new List<CMC_Estimate_Week__c>();
        
        boolean incrementalUpdateRequired = false;
        //integer noOfColumnsToDelete = 1;
        boolean dateUpdateRequiredForSucceedingRecords = false;
        Date newStartDate; 
        Decimal newOrder; 
        for(CMC_Estimate_Week__c estimateWeek : E2_TimelineDataUtil_WS.getEstimateWeekRecords(estimateId)){
            
            // we don't need to process or update records whose order or start date is less than the current week
            if(incrementalUpdateRequired){
               //if(dateUpdateRequiredForSucceedingRecords) estimateWeek.Date__c = estimateWeek.Date__c.addDays(NO_OF_DAYS_IN_WEEK * (-noOfColumnsToDelete));
               if(dateUpdateRequiredForSucceedingRecords){
                   // set the new start date for this record
                   estimateWeek.Date__c = newStartDate;
                   // reset newStartDate variable with date + 7 days
                   newStartDate = estimateWeek.Date__c.addDays(NO_OF_DAYS_IN_WEEK);
               } 
               //check that order is already populated
               if(estimateWeek.Order__c <> NULL){
                   //estimateWeek.Order__c = estimateWeek.Order__c - noOfColumnsToDelete;
                   // set the new order for this record
                   estimateWeek.Order__c = newOrder;
                   // reset newOrder variable with +1 increment
                   newOrder = estimateWeek.Order__c + 1;
                   // set the week name with the order
                   estimateWeek.Name = WEEKNAME_PREFIX + estimateWeek.Order__c;
                   estimateWeeksToUpsert.add(estimateWeek);               
               }
            }
            
            //delete the selected week record   
            if(estimateWeek.id == weekId){
               estimateWeeksToDelete.add(estimateWeek);
               // if selected week record order is greater than 1 
               //if(estimateWeek.Order__c <> NULL && estimateWeek.Order__c.intValue() > 1) dateUpdateRequiredForSucceedingRecords = true;
               
               // set the newOrder of succeeding record based on this records order
               newOrder = estimateWeek.Order__c;
               if(estimateWeek.Order__c <> NULL && estimateWeek.Order__c.intValue() > 1){
                 // set the new start date to this records date for the succeeding records
                 newStartDate = estimateWeek.Date__c;
                 dateUpdateRequiredForSucceedingRecords = true;  
               } 
               incrementalUpdateRequired = true;
            }                                    
        }
        
        // process insert/update in database           
        try{ 
           if(!estimateWeeksToDelete.isEmpty()) delete estimateWeeksToDelete;                               
           if(!estimateWeeksToUpsert.isEmpty()) upsert estimateWeeksToUpsert;
           
           resetOrderOnEstimateWeeks(estimateId);
        }catch(Exception ex){
           return 'Failed: ' + ex.getMessage();
        }                                                                                         
        return 'Success';
    
    }
    
    // method to add more columns on Left
    public static string addMoreColumnsOnLeft(string estimateId, 
                                                   string weekId, 
                                                   integer noOfColumnsToAdd){                                                   
        List<CMC_Estimate_Week__c> estimateWeeksToUpsert = new List<CMC_Estimate_Week__c>();
        
        boolean incrementalUpdateRequired = false;
        boolean dateUpdateRequiredForSucceedingRecords = false;
        //boolean decrementalUpdateRequired = true;
        
        // retrieve all the existing estimate week records in the ascending order of start date
        for(CMC_Estimate_Week__c estimateWeek : E2_TimelineDataUtil_WS.getEstimateWeekRecords(estimateId)){
            
            if(incrementalUpdateRequired){
               // change the succeeding dates only when adding in between the columns
               // if it is first column selected then we don't need to change the dates
               if(dateUpdateRequiredForSucceedingRecords) estimateWeek.Date__c = estimateWeek.Date__c.addDays(NO_OF_DAYS_IN_WEEK * noOfColumnsToAdd);
               
               estimateWeek.Order__c = estimateWeek.Order__c + noOfColumnsToAdd;
               estimateWeek.Name = WEEKNAME_PREFIX + estimateWeek.Order__c;
               estimateWeeksToUpsert.add(estimateWeek);               
            }
            
            
            if(estimateWeek.id == weekId){
                
                
               if(estimateWeek.Order__c <> NULL && estimateWeek.Order__c.intValue() > 1){
                   estimateWeek.Date__c = estimateWeek.Date__c.addDays(NO_OF_DAYS_IN_WEEK * (noOfColumnsToAdd));
                   dateUpdateRequiredForSucceedingRecords = true;
               }       
               
               
               // inrement the order with the number of columns now adding at left position
               estimateWeek.Order__c = estimateWeek.Order__c + noOfColumnsToAdd;
               // change week name with the new order
               estimateWeek.Name = WEEKNAME_PREFIX + estimateWeek.Order__c;
               // add in to upsert list
               estimateWeeksToUpsert.add(estimateWeek);  
               
               integer order = estimateWeek.Order__c.intValue();
               Date sDate = estimateWeek.Date__c;
               
               for(integer indx = 1; indx <= noOfColumnsToAdd; indx++){   
                  integer newOrderToBeAssigned = (order - indx);
                  System.debug('>>>>' + NO_OF_DAYS_IN_WEEK * (-indx));
                  Date newDateToBeAssinged = sDate.addDays(NO_OF_DAYS_IN_WEEK * (-indx));
                  System.debug('>>>>>>>>' + newDateToBeAssinged);
                  System.debug('>>>>>>>>' + newOrderToBeAssigned);
                  estimateWeeksToUpsert.add(createTimelineColumnOverload(estimateId, newDateToBeAssinged, newOrderToBeAssigned, WEEKNAME_PREFIX + newOrderToBeAssigned));               
               }
               incrementalUpdateRequired = true;
               //decrementalUpdateRequired = false;
            }
            
            //if(decrementalUpdateRequired){
               // the order and week name of the columns will remain the same
               // only date will get subtracted to the no. of weeks adding at left side
               
               //estimateWeek.Date__c = estimateWeek.Date__c.addDays(NO_OF_DAYS_IN_WEEK * (-noOfColumnsToAdd));
               //estimateWeek.Order__c = estimateWeek.Order__c - noOfColumnsToAdd;
               //estimateWeek.Name = WEEKNAME_PREFIX + estimateWeek.Order__c;
               //estimateWeeksToUpsert.add(estimateWeek);
            //}
                                                 
        }
        
        // process insert/update in database           
        try{                                
           if(!estimateWeeksToUpsert.isEmpty()) upsert estimateWeeksToUpsert;
           //resetOrderOnEstimateWeeks(estimateId);
           
           
        }catch(Exception ex){
           return 'Failed: ' + ex.getMessage();
        }                                                                                         
        return 'Success';
    }
    
    
    public static void resetOrderOnEstimateWeeks(string estimateId){
           List<CMC_Estimate_Week__c> estimateWeeksToUpdate = new List<CMC_Estimate_Week__c>();
           integer displayOrder = 1;
           for(CMC_Estimate_Week__c eW : [SELECT Id, Name, Order__c
                                          FROM CMC_Estimate_Week__c                                                    
                                          WHERE Estimate__c = :estimateId
                                          ORDER BY Date__c ASC]){
                 eW.Order__c = displayOrder;
                 eW.Name = WEEKNAME_PREFIX + eW.Order__c;
                 displayOrder++;
                 estimateWeeksToUpdate.add(eW); 
           }
           
           if(!estimateWeeksToUpdate.isEmpty()){
               update estimateWeeksToUpdate;
           }
    }
    
    
    // method to add more columns on right
    public static string addMoreColumnsOnRight(string estimateId, 
                                                   string weekId, 
                                                   integer noOfColumnsToAdd){                                                   
        List<CMC_Estimate_Week__c> estimateWeeksToUpsert = new List<CMC_Estimate_Week__c>();
        boolean incrementalUpdateRequired = false;
        for(CMC_Estimate_Week__c estimateWeek : E2_TimelineDataUtil_WS.getEstimateWeekRecords(estimateId)){
            
            if(incrementalUpdateRequired){
               estimateWeek.Date__c = estimateWeek.Date__c.addDays(NO_OF_DAYS_IN_WEEK * noOfColumnsToAdd);
               estimateWeek.Order__c = estimateWeek.Order__c + noOfColumnsToAdd;
               estimateWeek.Name = WEEKNAME_PREFIX + estimateWeek.Order__c;
               estimateWeeksToUpsert.add(estimateWeek);               
            }
            
            
            if(estimateWeek.id == weekId){
               integer order = estimateWeek.Order__c.intValue();
               Date sDate = estimateWeek.Date__c;
               for(integer indx = 1; indx <= noOfColumnsToAdd; indx++){                   
                  estimateWeeksToUpsert.add(createTimelineColumnOverload(estimateId, sDate.addDays(NO_OF_DAYS_IN_WEEK * indx), order + indx, WEEKNAME_PREFIX + (order + indx)));               
               }
               incrementalUpdateRequired = true;
            }                                    
        }
        
        // process insert/update in database           
        try{                                
           upsert estimateWeeksToUpsert;
           //resetOrderOnEstimateWeeks(estimateId);
        }catch(Exception ex){
           return 'Failed: ' + ex.getMessage();
        }                                                                                         
        return 'Success';
    }
    
    // method to create estimate weeks on build
    public static string onBuild(string estimateId, string sDate, integer noOfColumnsToAdd){
        List<CMC_Estimate_Week__c> estimateWeeksToUpsert = new List<CMC_Estimate_Week__c>();
        Date startDate = date.valueOf(sDate);
        
        List<CMC_Estimate_Week__c> existingList = [SELECT Id, Order__c
                                          FROM CMC_Estimate_Week__c                                                    
                                          WHERE Estimate__c = :estimateId
                                          ORDER BY Date__c ASC];
                                          
        // No need to build new weeks when there are weeks already defined.
        // build feature is just used to create fist time weeks and than this feature doesn't 
        // need to work.
        if(!existingList.isEmpty()){
            return 'Success';
        }
        
        
        for(integer indx = 0; indx < noOfColumnsToAdd; indx++){
            estimateWeeksToUpsert.add(createTimelineColumnOverload(estimateId, startDate.addDays(NO_OF_DAYS_IN_WEEK * indx), indx + 1, WEEKNAME_PREFIX + (indx + 1)));
        }
        
        // process insert/update in database           
        try{                                
          if(!estimateWeeksToUpsert.isEmpty()) upsert estimateWeeksToUpsert;
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
                                                  
        List<CMC_Estimate_Week__c> estimateWeeksToUpsert = new List<CMC_Estimate_Week__c>();
        Date startDate = date.valueOf(sDate);
        Integer index = 0;
        for(CMC_Estimate_Week__c estimateWeek : E2_TimelineDataUtil_WS.getEstimateWeekRecords(estimateId)){
                                                 
             estimateWeek.Date__c = startDate.addDays(NO_OF_DAYS_IN_WEEK * index);
             estimateWeek.Name = WEEKNAME_PREFIX + (index + 1);
             estimateWeek.Order__c = index + 1;
             estimateWeeksToUpsert.add(estimateWeek);
             index++;
        }
        // there are no column exists than create new                                          
        if(estimateWeeksToUpsert.isEmpty()){
          estimateWeeksToUpsert.add(createTimelineColumn(estimateId, sDate, order, name));
        }   
        // process insert/update in database           
        try{                                
           upsert estimateWeeksToUpsert;
        }catch(Exception ex){
           return 'Failed: ' + ex.getMessage();
        }                                                                                         
        return 'Success';                                          
    }
    
    // method to create timeline columns on load
    public static CMC_Estimate_Week__c createTimelineColumnOverload(string estimateId, 
                                                  date sDate, 
                                                  integer order,
                                                  string name){
       CMC_Estimate_Week__c estimateWeek = new CMC_Estimate_Week__c(Name = name,
                                                                    Date__c = sDate, 
                                                                    Estimate__c = estimateId,
                                                                    Order__c = Decimal.valueOf(order)
                                                                    );
       return estimateWeek;                                                             
    }
    
    // method to create timeline column 
    public static CMC_Estimate_Week__c createTimelineColumn(string estimateId, 
                                                  string sDate, 
                                                  integer order,
                                                  string name){
       CMC_Estimate_Week__c estimateWeek = new CMC_Estimate_Week__c(Name = name,
                                                                    Date__c = date.valueOf(sDate), 
                                                                    Estimate__c = estimateId,                                                                     
                                                                    Order__c = Decimal.valueOf(order));
       return estimateWeek;                                                             
    }
    
    // method to get timeline rows 
    public static List<E2_TimelineWS.E2_TimelineRow> getTimelineRows(string estimateId){
        List<E2_TimelineWS.E2_TimelineRow> rows = new List<E2_TimelineWS.E2_TimelineRow>();
        
        
        for(CMC_Estimate_Resource__c res : E2_TimelineDataUtil_WS.getEstimateResourceAndResourceWeekRec(estimateId)){
             List<E2_TimelineWS.E2_TimelineRowColumn> colRows = new List<E2_TimelineWS.E2_TimelineRowColumn>();
             for(CMC_Estimate_Resource_Week__c colRow : res.Estimate_Resource_Weeks__r){
               colRows.add(new E2_TimelineWS.E2_TimelineRowColumn(colRow.id, colRow.Estimate_Week__c, (colRow.Hours__c == null ? 0 : colRow.Hours__c.intValue())));
             }
             
            string resourceRole = (res.E2_Estimate_Rate_Card__c == null ? '' : res.E2_Estimate_Rate_Card__r.Resource_Role__c);
            string region = (res.E2_Estimate_Rate_Card__c == null ? '' : res.E2_Estimate_Rate_Card__r.Region__c);
            string key = region + SEPARATOR + resourceRole;
            if(E2_Constants.ROLE_RESOURCEROLE_MAP.containsKey(key)){
                resourceRole = E2_Constants.ROLE_RESOURCEROLE_MAP.get(key);
            }
            // E2_Constants.ROLE_RESOURCEROLE_MAP
             rows.add(new E2_TimelineWS.E2_TimelineRow(res.id, res.Role__c, 
                      res.E2_Role__c, resourceRole, 
                      res.Skill__c,
                      (res.Rate__c == null ? 0 : res.Rate__c.intValue()),
                      (res.Order__c == null ? 0 : res.Order__c.intValue()),
                      (res.Cost__c == null ? 0 : res.Cost__c.intValue())
                      ,colRows));                                   
         }        
        return rows;
    }
    
    // method to get timeline columns
    public static List<E2_TimelineWS.E2_TimelineColumn> getTimelineColumns(string estimateId){
        List<E2_TimelineWS.E2_TimelineColumn> columns = new List<E2_TimelineWS.E2_TimelineColumn>();        
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
              string sDate = weekDate.month() + '/' + weekDate.day() + '/' + weekDate.year(); 
              string name = weekDate.month() + '/' + weekDate.day();
              string nameWithYear = weekDate.month() + '/' + weekDate.day() + '/' + String.valueOf(weekDate.year()).right(2);
              columns.add(new E2_TimelineWS.E2_TimelineColumn(estimateWeek.id, 
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
                                            sDate,
                                            estimateWeek.Name,
                                            estimateWeek.Phase__c,
                                            estimateWeek.Milestone__c,
                                            estimateWeek.E2_PhaseColorCode__c == null ? '' : estimateWeek.E2_PhaseColorCode__c,
                                            estimateWeek.E2_MilestoneColorCode__c == null ? '' : estimateWeek.E2_MilestoneColorCode__c,
                                            estimateWeek.E2_Milestone1__c == null ? '' : estimateWeek.E2_Milestone1__c,
                                            estimateWeek.E2_Milestone1ColorCode__c == null ? '' : estimateWeek.E2_Milestone1ColorCode__c,
                                            estimateWeek.E2_Milestone2__c == null ? '' : estimateWeek.E2_Milestone2__c,
                                            estimateWeek.E2_Milestone2ColorCode__c == null ? '' : estimateWeek.E2_Milestone2ColorCode__c
                                            ));                                       
        }
        return columns;
    }
    
    // method to update Color Code and values depending upon code type 
   public static string updateMilestoneWeeks(string jsonstr){
        List<E2_TimelineWS.MilestoneWeekWrapper> lstMilestoneWeeks = (List<E2_TimelineWS.MilestoneWeekWrapper>)JSON.deserialize(jsonstr, List<E2_TimelineWS.MilestoneWeekWrapper>.class);
        Map<String, CMC_Estimate_Week__c> estimateWeeksMap = new Map<String, CMC_Estimate_Week__c>();
        for(E2_TimelineWS.MilestoneWeekWrapper mWeek: lstMilestoneWeeks){
            if(!estimateWeeksMap.containsKey(mWeek.weekId))  estimateWeeksMap.put(mWeek.weekId, new CMC_Estimate_Week__c(Id = mWeek.weekId));
            if(mWeek.type == PHASE_TEXT){
                CMC_Estimate_Week__c week = estimateWeeksMap.get(mWeek.weekId);
                week.Phase__c = mWeek.value;
                week.E2_PhaseColorCode__c = mWeek.colorCode;
                estimateWeeksMap.put(mWeek.weekId, week);
            } 
            
            if(mWeek.type == MILESTONE_TEXT) {
                CMC_Estimate_Week__c week = estimateWeeksMap.get(mWeek.weekId);
                week.Milestone__c = mWeek.value;
                week.E2_MilestoneColorCode__c = mWeek.colorCode;
                estimateWeeksMap.put(mWeek.weekId, week);
            }
            
            if(mWeek.type == MILESTONE1_TEXT) {
                CMC_Estimate_Week__c week = estimateWeeksMap.get(mWeek.weekId);
                week.E2_Milestone1__c = mWeek.value;
                week.E2_Milestone1ColorCode__c = mWeek.colorCode;
                estimateWeeksMap.put(mWeek.weekId, week);
            }
            
            
            if(mWeek.type == MILESTONE2_TEXT) {
                CMC_Estimate_Week__c week = estimateWeeksMap.get(mWeek.weekId);
                week.E2_Milestone2__c = mWeek.value;
                week.E2_Milestone2ColorCode__c = mWeek.colorCode;
                estimateWeeksMap.put(mWeek.weekId, week);
            }
        }
        
        try{

         if(!estimateWeeksMap.isEmpty()) update estimateWeeksMap.values();
         
        }catch(Exception ex){
         return 'Failed: ' + ex.getMessage(); 
        }
         
        return 'Success';
    }
    
    // method to bulk update weeks 
    // To update hours in bulk on copy and paste to cells - (Vikash - 12th Sep 2016)
   public static string updateResourceWeeks(string jsonstr){
        List<E2_TimelineWS.CellWrapper> lstWeeks = (List<E2_TimelineWS.CellWrapper>)JSON.deserialize(jsonstr, List<E2_TimelineWS.CellWrapper>.class);
        
        Set<String> weekIds = new Set<String>();
        Set<String> resourceIds = new Set<String>();
        Map<String, CMC_Estimate_Resource_Week__c> resourceWeekMap = new Map<String, CMC_Estimate_Resource_Week__c>();
        List<CMC_Estimate_Resource_Week__c> lstToInsert = new List<CMC_Estimate_Resource_Week__c>();
        List<CMC_Estimate_Resource_Week__c> lstToUpdate = new List<CMC_Estimate_Resource_Week__c>();
        List<CMC_Estimate_Week__c> lstWeekToUpdate = new List<CMC_Estimate_Week__c>();
        
        
        for(E2_TimelineWS.CellWrapper rWeek : lstWeeks){
            weekIds.add(rWeek.cellId);
            resourceIds.add(rWeek.rowId);    
        }
        
        for(CMC_Estimate_Resource_Week__c rwW : E2_TimelineDataUtil_WS.getEstimateResourceWeekRecords(weekIds, resourceIds)){
               string key = rwW.Estimate_Resource__c + KEY_SEPARATOR + rwW.Estimate_Week__c;
               resourceWeekMap.put(key, rwW); 
        }
        
        
        for(E2_TimelineWS.CellWrapper rWeek: lstWeeks){
            
            String rowType = rWeek.rowId;
            if(rowType.equalsIgnoreCase(MILESTONE_TEXT)) {
                lstWeekToUpdate.add(new CMC_Estimate_Week__c ( id = rWeek.cellId, Milestone__c = rWeek.value));
            }else if(rowType.equalsIgnoreCase(MILESTONE1_TEXT)) {
                lstWeekToUpdate.add(new CMC_Estimate_Week__c ( id = rWeek.cellId, E2_Milestone1__c = rWeek.value));
            }else if(rowType.equalsIgnoreCase(MILESTONE2_TEXT)) {
                lstWeekToUpdate.add(new CMC_Estimate_Week__c ( id = rWeek.cellId, E2_Milestone2__c = rWeek.value));
            }else{
                String key = rWeek.rowId + KEY_SEPARATOR + rWeek.cellId;
                if(resourceWeekMap.containsKey(key)){
                    CMC_Estimate_Resource_Week__c eRW = resourceWeekMap.get(key);
                    eRW.Hours__c = Integer.valueOf(rWeek.value.trim()); 
                    lstToUpdate.add(eRW);
                }else{
                    CMC_Estimate_Resource_Week__c eRW = new CMC_Estimate_Resource_Week__c(Hours__c = Integer.valueOf(rWeek.value.trim()), Estimate_Resource__c = rWeek.rowId, Estimate_Week__c = rWeek.cellId);
                    lstToInsert.add(eRW);
                }
                
                
            }
            
        }
        
        try{
         if(!lstWeekToUpdate.isEmpty()) update lstWeekToUpdate;
         if(!lstToUpdate.isEmpty()) update lstToUpdate;
         if(!lstToInsert.isEmpty()) insert lstToInsert;
        }catch(Exception ex){
         return 'Failed: ' + ex.getMessage(); 
        }
         
        return 'Success';
    }
}