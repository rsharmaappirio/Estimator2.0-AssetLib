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
  
  public E2_Master(){
    this.isEditable = true;     
  }
  
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
}