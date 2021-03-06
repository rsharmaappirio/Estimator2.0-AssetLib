// 
// (c) 2014 Appirio, Inc.
//
// A shell or container for data passed from CMC to PSA.
// Instances of this class will be used for passing data from CMC Estimates app to 
// an Opportunity button used to Create/Update PSA Resource Request records.
//
// 10/8/2014    Will Supinski 
// 9/13/2016    Rohit Sharma : clonned from CMC_EstimateResource Wrapper to 
//                             extend estimator 2.0 functionality.
// 12/26/2016   Rahul Jain   : Added a new wrapper property to store level. 
// 02/06/2017   Rohit Sharma : S-462242 : Add Primary Skill of the resource role on timeline
//                             added a new wrapper property to store skill id. 
// 02/09/2017   Rohit Sharma : S-438002 : resource request creation with schedules.
//                             weekHoursMap added to store week start date and hours
public class E2_EstimateResource {
	 
	public Double rate {get;set;}
	public Double cost {get;set;}
	public Decimal hours {get;set;}
	
	public String role {get;set;}
	public String regionName {get;set;}
	public String practiceName {get;set;}
	public String skill {get;set;}
	public String level {get;set;}
	
	public Date endDate {get;set;}
	public Date startDate {get;set;}
	
	public String regionId {get;set;}
	public String practiceId {get;set;}
	public String rateCardId {get;set;}
	public String resourceId {get;set;}
	public String skillId {get;set;}

	public String curCode {get;set;}
	// RS:S-438002 Hours for resource schedule
	public map<Date, decimal> weekHoursMap{get;set;}
}