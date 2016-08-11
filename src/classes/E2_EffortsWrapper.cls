/**=====================================================================
 * Appirio, Inc
 * Name			: E2_EffortsWrapper
 * Description	: Effort wrapper for building bulk add efforts functionality
 * Created Date	: Aug 9th, 2016
 * Created By	: Vikash Goyal (Appirio)
 * 
 * Date Modified      Modified By                  Description of the update

*  =====================================================================*/
global class E2_EffortsWrapper {
    public String roleName {get;set;}
    public String phaseName {get;set;}
    public Decimal hours {get;set;}
        
    public E2_EffortsWrapper(){
        hours = 0;
        phaseName = E2_Constants.DEFAULT_PHASE_FOR_BULK_EFFORT;
        roleName = E2_Constants.DEFAULT_ROLE_FOR_BULK_EFFORT;
    }
}