/**=====================================================================
 * Appirio, Inc
 * Name: E2_Constants
 * Description: Class to store Constant variables
 * Created Date: 
 * Created By: 
 * 
 * Date Modified      Modified By                  Description of the update
 * Apr 18th, 2016     Arpita                       T-494117
 * Nov 11th, 2016     Rohit Sharma                 S-447474 : Fixed fee calculation support
 * Dec 8th, 2016      Rohit Sharma                 S-449145 :Ability to find the Scope by type, 
 * Dec, 12th, 2016    Rohit Sharma                 S-437670 :Added couple of constants like SCOPE_TYPES, COMPLEXITIES etc 
 * Jan 25, 2017       Rohit Sharma                 S-453758 : Added new constant permission set name : Derived_Effort_Template_Manager
 * Feb 08, 2017       Rohit Sharma                 S-447325 : Add multiplier on Scope : new contants for multiplier badge.
*  =====================================================================*/
public class E2_Constants {

  public final static string ESTIMATE_KEYPREFIX = 'a0F';
  public final static string COMPONENT_KEYPREFIX = 'a01';
  public final static string SCOPE_KEYPREFIX = 'a0A';
  
  public final static Set<String> SCOPE_TYPES = new Set<String>{'capability', 'epic', 'story', 'component'};
  public final static Set<String> SCOPE_COMPLEXITIES = new Set<String>{'high', 'medium', 'low'};
  
  public final static decimal DEFAULT_SCOPE_DISPLAY_ORDER = 10000;
  
  //record type of Scope
  public final static String SCOPE_RT_TEMPLATE = 'Template';
  public final static String SCOPE_RT_SCOPE = 'Scope';
  
  public final static String DERIVEDEFFORT_RT_TEMPLATE = 'Template';
  public final static String DERIVEDEFFORT_RT_DERIVED_EFFORT = 'Derived Effort';
  
  public final static string ENTIRE_PROJECT = 'Entire Project';
  
  public final static string PROFILE_SYS_ADMIN = 'System Administrator';
  public final static string CURRENCY_ISO_CODE_USD = 'USD';
  
  public static final string URL_KEY_ID = 'id';
  public final static string URL_KEY_ESTIMATE_ID = 'estimate_id';
  public final static string URL_KEY_SCOPEGROUP_ID = 'scopegroup_id';
  public final static string URL_KEY_IS_VIEW = 'is_View';
  public final static string URL_KEY_IS_EDIT = 'is_Edit';
  
  public static final string FORWARD_SLASH = '/';
  public final static string BLANK = '';
  public final static string HASH_TAG = '#';
  public final static string NA = 'N/A';
  
  public final static string DATETIME_FORMAT_YYYYMMDD = 'yyyy-MM-dd HH:mm:ss.SSS';
  public final static string STRING_1000 = '1000';
  public final static string MD5 = 'MD5';
  
  public final static string E2_SCOPE_API_NAME = 'E2_Scope__c';
  
  public final static string DML_OPERATION_MESSAGE_FAIL = 'Fail';
  public final static string DML_OPERATION_MESSAGE_SUCCESS = 'Success';
  
  public final static string SEPARATOR = '|';
  public final static string HYPHEN_SEPARATOR = ' - ';
  public final static string OPEN_BRACKET = '(';
  public final static string CLOSE_BRACKET = ')';
  public final static string SPACE = ' ';
  public final static string COMMA = ',';
  
  public final static string HIGH = 'high';
  public final static string MEDIUM = 'medium';
  public final static string LOW = 'low';
  
  public final static string BYASC = 'ByAsc';
  public final static string BYDESC = 'ByDesc';
  
  public static final string ALWAYS = 'always';
  public final static string WHEN_HOURS_EXCEED = 'hours exceed or equals';
  public final static string IF_HOURS_ARE_LESS_THAN = 'hours are less than';
  
  //public final static string NODE_DISPLAY_TEMPLATE = '<span><span>{SCOPE_NAME}</span>&nbsp;&nbsp;&nbsp;<span class="slds-badge slds-badge-custom">{COMPLEXITY}</span><span class="slds-badge slds-badge-custom">{TYPE}</span><span class="slds-badge slds-badge-custom">{EFFORT} hrs</span></span>';
  //public final static string NODE_DISPLAY_TEMPLATE = '<span><span{ADD_CLASS}>{SCOPE_NAME}</span>&nbsp;&nbsp;&nbsp;<span class="slds-badge slds-badge-custom">{EFFORT}</span>&nbsp;&nbsp;&nbsp;<span class="slds-badge slds-badge-custom flag flag{FLAG_COLOR}" onclick="AddEditScope.updateFlag(event, this);return false;">{SCOPE_FLAG}</span></span>';
  //public final static string NODE_DISPLAY_TEMPLATE_WITHOUT_EFFORTS = '<span><span{ADD_CLASS}>{SCOPE_NAME}</span>&nbsp;&nbsp;&nbsp;<span class="slds-badge slds-badge-custom flag flag{FLAG_COLOR}" onclick="AddEditScope.updateFlag(event, this);return false;">{SCOPE_FLAG}</span></span>';
  public final static string NODE_DISPLAY_TEMPLATE = '<span id="{SCOPE_ID}_ATTR"><span{ADD_CLASS}>{SCOPE_NAME}</span>&nbsp;&nbsp;&nbsp;<span class="slds-badge slds-badge-custom">{EFFORT}</span></span>';
  public final static string NODE_DISPLAY_TEMPLATE_WITHOUT_EFFORTS = '<span id="{SCOPE_ID}_ATTR"><span{ADD_CLASS}>{SCOPE_NAME}</span></span>';
  public final static string NODE_DISPLAY_TEMPLATE_FLAG = '<span id="{SCOPE_ID}_ATTR"><span{ADD_CLASS}>{SCOPE_NAME}</span>&nbsp;&nbsp;&nbsp;<span class="slds-badge slds-badge-custom">{EFFORT}</span>&nbsp;<span class="slds-badge flag flag{FLAG_COLOR}" title="Set red/amber/green status of this scope item" onclick="AddEditScope&&AddEditScope.updateFlag(event, this);return false;"></span></span>';
  public final static string NODE_DISPLAY_TEMPLATE_WITHOUT_EFFORTS_FLAG = '<span id="{SCOPE_ID}_ATTR"><span{ADD_CLASS}>{SCOPE_NAME}</span>&nbsp;<span class="slds-badge flag flag{FLAG_COLOR}" title="Set red/amber/green status of this scope item" onclick="AddEditScope&&AddEditScope.updateFlag(event, this);return false;"></span></span>';
  public final static string NODE_SCOPE_NAME_FORMAT = '{SCOPE_NAME}';
  public final static string NODE_SCOPE_ID_FORMAT = '{SCOPE_ID}';
  public final static string NODE_SCOPE_FLAG_FORMAT = '{SCOPE_FLAG}';
  public final static string NODE_EFFORT_FORMAT = '{EFFORT}';
  public final static string NODE_COMPLEXITY_FORMAT = '{COMPLEXITY}';
  public final static string NODE_TYPE_FORMAT = '{TYPE}';
  public final static string NODE_ADD_CLASS = '{ADD_CLASS}';
  public final static string NODE_CSS_CLASS = ' class=\"node_is_active\"';
  public final static string NODE_FLAG_COLOR = '{FLAG_COLOR}';
  
  public final static string FLAG_VALUE_RED = 'Red';
  public final static string FLAG_VALUE_YELLOW = 'Yellow';
  public final static string FLAG_VALUE_GREEN = 'Green';
  
  public final static string INSUFFICIENT_ACCESS_OR_READONLY = 'INSUFFICIENT_ACCESS_OR_READONLY';
  public final static String INSUFFICIENT_ERROR_MSSG = 'ERROR : You do not have permission to edit the data. Please contact the owner of this record.';
  
  public final static string SCOPE_CSV_HEADER = '"Scope Name","Parent Scope Name","Complexity","Scope Item Type","Description","Assumption","LOE Hrs"';
  public final static string SCOPE_XLS_HEADER = '<tr><td>Scope Name</td><td>Parent Scope Name</td><td>Complexity</td><td>Scope Item Type</td><td>Description</td><td>Assumption</td><td>LOE Hrs</td></tr>';
  
  public final static string PERCENTAGE = '%';
  public final static string STM_PERMISSION_SET = 'Scope_Template_manager';
  
  public final static string ASSET_MULTIPLE_PRACTICE_IMAGE = 'multiple-practice.png';
  public final static string ASSET_NO_PRACTICE_IMAGE = 'no-practice.png';
  public final static string ASSET_PRACTICE_IMAGE_SUFFIX = '-practice.png';
  
  public final static Decimal DEFAULT_BULK_EFFORTS_TO_ADD = 5;
  public final static string DEFAULT_ROLE_FOR_BULK_EFFORT = 'Developer';
  public final static string DEFAULT_PHASE_FOR_BULK_EFFORT = 'Build';
  public final static string EFFORT_ROLE_FIELD_API_NAME = 'Resource_Role__c';
  public final static string EFFORT_PHASE_FIELD_API_NAME = 'Phase__c';
  
  public final static Map<String, String> PHASE_COLORCODE_MAP = new Map<String, String>{ 'Strategy' => '#8FBC8F', 'Plan' => '#e67e00', 'Architect' => '#7289b8', 'Build' => '#9bd431', 'Test' => '#6b7078', 'Deploy & Thrive' => '#9c1940' };
  
  public final static Map<String, String> ROLE_RESOURCEROLE_MAP = new Map<String, String> { 'GS - Jaipur Delivery - Business Analyst' => 'Business Analyst - Jaipur',
                                                                                            'GS - Jaipur Delivery - Project Manager' => 'Project Manager - Jaipur',
                                                                                            'GS - Jaipur Delivery - Technical Lead' => 'Technical Lead - Jaipur',
                                                                                            'GS - North America Delivery - Technical Consultant - Express' => 'Technical Consultant',
                                                                                            'North America - Global Services - Technical Consultant - Express' => 'Technical Consultant'
  };
  
  public final static String ESTIMATE_MODE_T_AND_M = 'tm';
  public final static String ESTIMATE_MODE_FIXED_FEE = 'fixed';
  public final static Decimal DEFAULT_FIXED_FEE_UPLIFT = 5;
  
  public final static String DERIVED_EFFORT_TEMPLATE_MANAGER = 'Derived_Effort_Template_Manager';
  
  public final static String PAGE_PARAMETER_CUSTOMERMODE = 'customerMode';
  
  // S-447325 : Effort badge Css constant
  public final static String CSS_SLDS_BADGE_CUSTOM = 'slds-badge-custom';
  public final static String CSS_SLDS_BADGE_EFFORT_MULTIPLIER = 'slds-badge-effort-multiplier';
  
  public void testConstantsMethod(){}
}