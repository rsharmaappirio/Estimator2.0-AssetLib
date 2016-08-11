@isTest(seeAllData=false)
public class E2_AddBulkEffortsControllerTest {
    
    public static testmethod void testBulkEfforts(){
        E2_AddBulkEffortsController ctrl = new E2_AddBulkEffortsController();
        
        system.assertEquals(5, ctrl.lstEfforts.size());
        system.assertNotEquals(0, ctrl.roles.size());
        system.assertNotEquals(0, ctrl.phases.size());
        system.assertEquals('', ctrl.effortsJson);
        
        ctrl.addEfforts();
        system.assertEquals(10, ctrl.lstEfforts.size());
        
        ctrl.prepareEffortsJson();
        system.assertNotEquals('', ctrl.effortsJson);
    }
}