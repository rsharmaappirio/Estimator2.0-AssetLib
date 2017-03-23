/**=====================================================================
 * Appirio, Inc
 * Name: E2_Master
 * Description: Master/Controlling class for All the Estimate 2.0 pages
                that controls the edit access    
 * Created Date: May 19th, 2016
 * Created By: Rahul Jain (Appirio)
 * 
 * Date Modified      Modified By                  Description of the update
      
*  =====================================================================*/
public with sharing abstract class E2_Master {
  public boolean isEditable{get;set;}
  private static final string URL_KEY_PSR_ID = 'psr_id';
  public string psrId{get;set;}
  //constructor 
  public E2_Master(){
    this.isEditable = true;     
  }
  //method to check edit access on the estimate 
  public void validateAccess(CMC_Presales_LOE__c estimate){
     this.psrId = E2_Constants.BLANK;
     
    if(estimate.id <> NULL){
      //this.isEditable = true;
      List<CMC_Presales_LOE__c> estimateList = E2_DataUtil.getEstimateDetailForAccess(estimate.id);
      if(!estimateList.isEmpty()){
        estimate = estimateList[0];
        this.psrId = estimate.Presales_Request__c;
        //if(estimate.ownerId == UserInfo.getUserId()){
        //  this.isEditable = true;
        //}
      }       
    }else{
      //this.isEditable = true;
      this.psrId = ApexPages.currentPage().getParameters().get(URL_KEY_PSR_ID);
    }   
  }  
  
  //page action method on the load of page
  public PageReference validateForTimelineEstimate(CMC_Presales_LOE__c estimate){
    if(estimate.E2_Parent_Estimate__c <> NULL) {
        // THIS IS THE CLOSEST YOU CAN GET SO FAR
         String pageName = ApexPages.CurrentPage().getUrl();
         // IT ALWAYS STARTS WITH /APEX/ SO REMOVE IT
         pageName = pageName.replaceFirst('/apex/', '');
         pageName = EncodingUtil.urlEncode(pageName, 'UTF-8');
         // %3F IS THE VALUE OF THE QUESTION MARK IN UTF-8 
         string[] pageNameExtra = pageName.split('%3F', 0);
         // SO YOU MAY SPLIT THE STRING AT THAT POINT
         // FOR THIS PURPOSE YOU ONLY NEED THE FIRST
         // IN THE RESULTING ARRAY
         pageName = pageNameExtra[0];
        PageReference page = new PageReference('/apex/' + pageName + '?id=' + estimate.E2_Parent_Estimate__c);
        page.setRedirect(true);
        return page;
    }
    return NULL;
  }
}