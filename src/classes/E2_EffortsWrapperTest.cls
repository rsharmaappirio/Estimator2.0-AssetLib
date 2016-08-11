@isTest(seeAllData=false)
public class E2_EffortsWrapperTest {
    
    public static testmethod void testEffortsWrapper(){
        E2_EffortsWrapper wrapperObj = new E2_EffortsWrapper();
        system.assertEquals(0, wrapperObj.hours);
        system.assertEquals(E2_Constants.DEFAULT_ROLE_FOR_BULK_EFFORT, wrapperObj.roleName);
        system.assertEquals(E2_Constants.DEFAULT_PHASE_FOR_BULK_EFFORT, wrapperObj.phaseName);
    }
}