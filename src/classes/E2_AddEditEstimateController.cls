/**=====================================================================
 * Appirio, Inc
 * Name: E2_AddEditEstimateController
 * Description: Controller class to create & edit Estimate
 * Created Date: Apr 8th, 2016
 * Created By: Arpita Bose (Appirio)
 * 
 * Date Modified      Modified By                  Description of the update
 * May 17, 2016       Rahul Jain                   Added Local constants, removed hardcoded strings from the methods.     
*  =====================================================================*/
public class E2_AddEditEstimateController extends E2_Master{
  //declare variables
  public CMC_Presales_LOE__c estimate {get;set;}
  public Boolean isEdit {get;set;}
  public ApexPages.StandardController std{get;set;}
  public Presales_Request__c psr{get;set;}
  public Date estimateDateScoped{get;set;}
  private static final string URL_KEY_PSR_ID = 'psr_id';
  private static final string URL_KEY_IS_SAVE = 'is_save';
  private static final string URL_VALUE_TRUE = 'true';
 
  
  public E2_AddEditEstimateController(ApexPages.StandardController std) {    
    this.estimate = (CMC_Presales_LOE__c)std.getRecord();                      
    this.isEdit = false;
    this.estimateDateScoped = system.today(); 
    this.std = std;
    this.psr = new Presales_Request__c(); 
     
  }

  public boolean getHasMessages(){
     return ApexPages.hasMessages();
  }


  public PageReference pageAction(){
    super.validateAccess(this.estimate);
    string psr_id = E2_Constants.BLANK;
    if(this.estimate.id == null){
      psr_id = ApexPages.currentPage().getParameters().get(URL_KEY_PSR_ID);
    }else{
      psr_id = this.estimate.Presales_Request__c;
    }
    
    // on add/edit: both the cases we need to query the reference record of psr
    if(psr_id <> NULL || psr_id <> E2_Constants.BLANK){
        this.estimate.Presales_Request__c = psr_id;
        List<Presales_Request__c> presalesRequestList = E2_DataUtil.getPSRDetailOnPsrId(psr_id);                                                         
        if(!presalesRequestList.isEmpty()) psr = presalesRequestList[0];                                               
    }
        
    // on add only: retrieve field values from psr object
    if(this.estimate.id == null && psr.id <> null){
            this.estimate.Description__c = psr.Description__c;
            this.estimate.Name = psr.Name;
            this.estimate.Account_Name__c = psr.Account_Name__c;
            this.estimate.Opportunity_Name__c = psr.Account_Name__c;
            this.estimate.E2_Date_Scoped__c = system.today();
            this.estimate.E2_SA__c = userinfo.getuserId();
    }
    
    if(this.estimate.Id != null && psr.id <> null){
      List<CMC_Presales_LOE__c> estimateList = E2_DataUtil.getEstimateDetailOnId(this.estimate.Id);
      if(!estimateList.isEmpty()){
        estimate = estimateList[0];
      }      
    }    
    return null;
  }


  public PageReference doSave() {   
    try {
      // insert / update estimate record into the database
      upsert estimate;      
    } catch (DMLException e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error creating new E2_estimate.'));         
    }
    return null;
  }
  
  public Pagereference save(){
    // This method is invoked when save button is clicked on the addeditestimate page
    PageReference pg =  doSave();
    if(!getHasMessages()){ 
        this.estimate = (CMC_Presales_LOE__c)std.getRecord(); 
        PageReference pgEdit = Page.E2_AddEditEstimate;
        pgEdit.getParameters().put(E2_Constants.URL_KEY_ID, this.estimate.id);
        pgEdit.getParameters().put(URL_KEY_IS_SAVE, URL_VALUE_TRUE);
        pgEdit.setRedirect(true); 
        return pgEdit;        
    }
    return null;    
  }
  
  public Pagereference saveAndNext(){
    // NOT NEEDED RIGHT NOW - MAY BE UNCOMMENT IN FUTURE
    // This method is invoked when next button is clicked on the addeditestimate page
    //PageReference pg =  doSave();
     //if(!getHasMessages()){
        //PageReference pgNext = Page.E2_AddEditScope;
        //pgNext.getParameters().put(E2_Constants.URL_KEY_ID, this.estimate.id);
        //pgNext.setRedirect(true);
        //return pgNext;
     //}
     return null;
  }
  
  public Pagereference cancel(){
    // by default cancel this page out to the psr detail page from where this page was landed
    PageReference pg = new PageReference(E2_Constants.FORWARD_SLASH + this.psr.id);
    // however if estimate was created earlier; cancel action will cancel current operation
    if(this.estimate.id <> NULL){
      pg = Page.E2_AddEditEstimate;
      pg.getParameters().put(E2_Constants.URL_KEY_ID, this.estimate.id);
    }
    return pg;
  }
  
  public PageReference buildCapacity() {
    E2_CapacityController.reBuildCapacity(this.estimate);
    PageReference pg = Page.E2_Capacity;
    pg.getParameters().put('id', this.estimate.id);    
    return pg; 
  }
  
}