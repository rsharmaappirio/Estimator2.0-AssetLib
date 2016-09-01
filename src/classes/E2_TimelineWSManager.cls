/**=====================================================================
 * Appirio, Inc
 * Name: E2_TimelineWSManager
 * Description: This is a manager class; constitutes all the business logic for E2_TimelineWS webservcie
 * Created Date: Aug 12, 2016
 * Created By: Rahul Jain (Appirio)
*  =====================================================================*/
public class E2_TimelineWSManager {
   public static List<E2_Estimate_Rate_Card__c> getEstimateRateCards(string estimateId){
        List<E2_Estimate_Rate_Card__c> estimateRateCards = E2_TimelineDataUtil_WS.getEstimateRateCards(estimateId);
        return estimateRateCards;
    }
    
    public static string updatePhase(string weekId, string phase){
       try{
         update new CMC_Estimate_Week__c(Id = weekId,
                                         Phase__c = phase);
       }catch(Exception ex){
         return 'Failed: ' + ex.getMessage(); 
       }
       return weekId;  
    }
    
    public static string updateMilestone(string weekId, string milestone){
       try{
         update new CMC_Estimate_Week__c(Id = weekId,
                                         Milestone__c = milestone);
       }catch(Exception ex){
         return 'Failed: ' + ex.getMessage(); 
       }
       return weekId;  
    }
    
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
               
               string key = rwW.Estimate_Resource__c + '|' + rwW.Estimate_Week__c;
               resourceWeekMap.put(key, rwW);
                   
                   
        }
        
         for(E2_TimelineWS.ResourceWeekWrapper rwW : lstResourceWeekWrapper){
            string key = rwW.resourceId + '|' + rwW.weekId;
            integer hours = rwW.hours;
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
      
    public static string addRow(string estimateId, integer order, 
                                    integer cost, integer rate, string role,
                                    string skill, string estimateRateCardId){
       List<CMC_Presales_LOE__c> estimateList = E2_TimelineDataUtil_WS.getCurrencyISOCodeonEstimate(estimateId);
                                             
       try{                             
         insert new CMC_Estimate_Resource__c(Cost__c = cost, 
                                             Estimate__c = estimateId,     
                                             Order__c = order, 
                                             Rate__c = rate, 
                                             Role__c = role, 
                                             Skill__c = skill, 
                                             Is_Used_For_Calculations__c = true,
                                             CurrencyIsoCode = estimateList[0].CurrencyIsoCode,
                                             Estimate_Rate_Card__c = (String.isEmpty(estimateRateCardId) ? null : estimateRateCardId));
       }catch(Exception ex){
         return 'Failed: ' + ex.getMessage();
       }
       return 'Success';
    }
    
    public static string updateRow(string estimateId, string rowId, 
                                    string role,
                                    string skill, integer cost, integer rate, string estimateRateCardId){
       try{                             
         update new CMC_Estimate_Resource__c(id = rowId,                                                                                        
                                             Role__c = role, 
                                             Cost__c = cost, 
                                             Rate__c = rate, 
                                             Estimate_Rate_Card__c = (String.isEmpty(estimateRateCardId) ? null : estimateRateCardId));
       }catch(Exception ex){
         return 'Failed: ' + ex.getMessage();
       }
       return 'Success';
    }
    
    public static string deleteRow(string rowId){
       try{                             
         delete new CMC_Estimate_Resource__c(id = rowId);
       }catch(Exception ex){
         return 'Failed: ' + ex.getMessage();
       }
       return 'Success';
    }
    
    
    public static string deleteColumn(string estimateId, string weekId){
        List<CMC_Estimate_Week__c> estimateWeeksToUpsert = new List<CMC_Estimate_Week__c>();
        List<CMC_Estimate_Week__c> estimateWeeksToDelete = new List<CMC_Estimate_Week__c>();
        
        boolean incrementalUpdateRequired = false;
        integer noOfColumnsToDelete = -1;
        boolean dateUpdateRequired = false;
        for(CMC_Estimate_Week__c estimateWeek : E2_TimelineDataUtil_WS.getEstimateWeekRecords(estimateId)){
            
            if(incrementalUpdateRequired){
               if(dateUpdateRequired) estimateWeek.Date__c = estimateWeek.Date__c.addDays(7 * noOfColumnsToDelete);
               estimateWeek.Order__c = estimateWeek.Order__c + noOfColumnsToDelete;
               estimateWeek.Name = 'Week' + estimateWeek.Order__c;
               estimateWeeksToUpsert.add(estimateWeek);               
            }
            
            
            if(estimateWeek.id == weekId){
               estimateWeeksToDelete.add(estimateWeek);
               if(estimateWeek.Order__c > 1) dateUpdateRequired = true;
               incrementalUpdateRequired = true;
            }                                    
        }
        
        // process insert/update in database           
        try{ 
           delete estimateWeeksToDelete;                               
           upsert estimateWeeksToUpsert;
        }catch(Exception ex){
           return 'Failed: ' + ex.getMessage();
        }                                                                                         
        return 'Success';
    
    }
    
    public static string addMoreColumnsOnLeft(string estimateId, 
                                                   string weekId, 
                                                   integer noOfColumnsToAdd){                                                   
        List<CMC_Estimate_Week__c> estimateWeeksToUpsert = new List<CMC_Estimate_Week__c>();
        boolean incrementalUpdateRequired = false;
        boolean decrementalUpdateRequired = true;
        for(CMC_Estimate_Week__c estimateWeek : E2_TimelineDataUtil_WS.getEstimateWeekRecords(estimateId)){
            
            if(incrementalUpdateRequired){
               //estimateWeek.Date__c = estimateWeek.Date__c.addDays(7 * noOfColumnsToAdd);
               estimateWeek.Order__c = estimateWeek.Order__c + noOfColumnsToAdd;
               estimateWeek.Name = 'Week' + estimateWeek.Order__c;
               estimateWeeksToUpsert.add(estimateWeek);               
            }
            
            
            if(estimateWeek.id == weekId){
               
               //estimateWeek.Date__c = estimateWeek.Date__c.addDays(7 * noOfColumnsToAdd);
               estimateWeek.Order__c = estimateWeek.Order__c + noOfColumnsToAdd;
               estimateWeek.Name = 'Week' + estimateWeek.Order__c;
               estimateWeeksToUpsert.add(estimateWeek);  
               
               integer order = estimateWeek.Order__c.intValue();
               Date sDate = estimateWeek.Date__c;
               
               for(integer indx = 1; indx <= noOfColumnsToAdd; indx++){                   
                  estimateWeeksToUpsert.add(createTimelineColumnOverload(estimateId, sDate.addDays(7 * (-indx)), order - indx, 'Week' + (order - indx)));               
               }
               incrementalUpdateRequired = true;
               decrementalUpdateRequired = false;
            }
            
            if(decrementalUpdateRequired){
               estimateWeek.Date__c = estimateWeek.Date__c.addDays(7 * (-noOfColumnsToAdd));
               estimateWeek.Order__c = estimateWeek.Order__c - noOfColumnsToAdd;
               estimateWeek.Name = 'Week' + estimateWeek.Order__c;
               estimateWeeksToUpsert.add(estimateWeek);
            }
                                                 
        }
        
        // process insert/update in database           
        try{                                
           upsert estimateWeeksToUpsert;
        }catch(Exception ex){
           return 'Failed: ' + ex.getMessage();
        }                                                                                         
        return 'Success';
    }
    
    public static string addMoreColumnsOnRight(string estimateId, 
                                                   string weekId, 
                                                   integer noOfColumnsToAdd){                                                   
        List<CMC_Estimate_Week__c> estimateWeeksToUpsert = new List<CMC_Estimate_Week__c>();
        boolean incrementalUpdateRequired = false;
        for(CMC_Estimate_Week__c estimateWeek : E2_TimelineDataUtil_WS.getEstimateWeekRecords(estimateId)){
            
            if(incrementalUpdateRequired){
               estimateWeek.Date__c = estimateWeek.Date__c.addDays(7 * noOfColumnsToAdd);
               estimateWeek.Order__c = estimateWeek.Order__c + noOfColumnsToAdd;
               estimateWeek.Name = 'Week' + estimateWeek.Order__c;
               estimateWeeksToUpsert.add(estimateWeek);               
            }
            
            
            if(estimateWeek.id == weekId){
               integer order = estimateWeek.Order__c.intValue();
               Date sDate = estimateWeek.Date__c;
               for(integer indx = 1; indx <= noOfColumnsToAdd; indx++){                   
                  estimateWeeksToUpsert.add(createTimelineColumnOverload(estimateId, sDate.addDays(7 * indx), order + indx, 'Week' + (order + indx)));               
               }
               incrementalUpdateRequired = true;
            }                                    
        }
        
        // process insert/update in database           
        try{                                
           upsert estimateWeeksToUpsert;
        }catch(Exception ex){
           return 'Failed: ' + ex.getMessage();
        }                                                                                         
        return 'Success';
    }
    
    public static string onBuild(string estimateId, string sDate, integer noOfColumnsToAdd){
        List<CMC_Estimate_Week__c> estimateWeeksToUpsert = new List<CMC_Estimate_Week__c>();
        Date startDate = date.valueOf(sDate);
        
        for(integer indx = 0; indx < noOfColumnsToAdd; indx++){
            estimateWeeksToUpsert.add(createTimelineColumnOverload(estimateId, startDate.addDays(7 * indx), indx + 1, 'Week' + (indx + 1)));
        }
        
        // process insert/update in database           
        try{                                
          if(!estimateWeeksToUpsert.isEmpty()) upsert estimateWeeksToUpsert;
        }catch(Exception ex){
           return 'Failed: ' + ex.getMessage();
        }                                                                                         
        return 'Success';
        
    }
    
    
    
    public static string onStartDateSelectionChange(string estimateId, 
                                                  string sDate, 
                                                  integer order,
                                                  string name){
                                                  
        List<CMC_Estimate_Week__c> estimateWeeksToUpsert = new List<CMC_Estimate_Week__c>();
        Date startDate = date.valueOf(sDate);
        Integer index = 0;
        for(CMC_Estimate_Week__c estimateWeek : E2_TimelineDataUtil_WS.getEstimateWeekRecords(estimateId)){
                                                 
             estimateWeek.Date__c = startDate.addDays(7 * index);
             estimateWeek.Name = 'Week' + (index + 1);
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
    
    public static List<E2_TimelineWS.E2_TimelineRow> getTimelineRows(string estimateId){
        List<E2_TimelineWS.E2_TimelineRow> rows = new List<E2_TimelineWS.E2_TimelineRow>();
        
        
        for(CMC_Estimate_Resource__c res : E2_TimelineDataUtil_WS.getEstimateResourceAndResourceWeekRec(estimateId)){
             List<E2_TimelineWS.E2_TimelineRowColumn> colRows = new List<E2_TimelineWS.E2_TimelineRowColumn>();
             for(CMC_Estimate_Resource_Week__c colRow : res.Estimate_Resource_Weeks__r){
               colRows.add(new E2_TimelineWS.E2_TimelineRowColumn(colRow.id, colRow.Estimate_Week__c, colRow.Hours__c.intValue()));
             }
             rows.add(new E2_TimelineWS.E2_TimelineRow(res.id, res.Role__c, 
                      res.Skill__c, res.Rate__c.intValue(), 
                      res.Order__c.intValue(), res.Cost__c.intValue()
                      ,colRows));                                   
         }        
        return rows;
    }
    
    
    public static List<E2_TimelineWS.E2_TimelineColumn> getTimelineColumns(string estimateId){
        List<E2_TimelineWS.E2_TimelineColumn> columns = new List<E2_TimelineWS.E2_TimelineColumn>();        
        integer width = 50;
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
              columns.add(new E2_TimelineWS.E2_TimelineColumn(estimateWeek.id, 
                                            name,
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
                                            estimateWeek.Milestone__c                                            
                                            ));                                       
        }
                                 
        
        return columns;
    }
}