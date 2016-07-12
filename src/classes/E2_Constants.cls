/**=====================================================================
 * Appirio, Inc
 * Name: E2_Constants
 * Description: Class to store Constant variables
 * Created Date: 
 * Created By: 
 * 
 * Date Modified      Modified By                  Description of the update
 * Apr 18th, 2016     Arpita                       T-494117
*  =====================================================================*/
public class E2_Constants {

  public final static string ESTIMATE_KEYPREFIX = 'a0F';
  public final static string COMPONENT_KEYPREFIX = 'a01';
  public final static string SCOPE_KEYPREFIX = 'a0A';
  
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
  public final static string NODE_DISPLAY_TEMPLATE = '<span><span{ADD_CLASS}>{SCOPE_NAME}</span>&nbsp;&nbsp;&nbsp;<span class="slds-badge slds-badge-custom">{EFFORT}</span></span>';
  public final static string NODE_DISPLAY_TEMPLATE_WITHOUT_EFFORTS = '<span><span{ADD_CLASS}>{SCOPE_NAME}</span></span>';
    public final static string NODE_DISPLAY_TEMPLATE_FLAG = '<span><span{ADD_CLASS}>{SCOPE_NAME}</span>&nbsp;&nbsp;&nbsp;<span class="slds-badge slds-badge-custom">{EFFORT}</span>&nbsp;<span class="slds-badge flag flag{FLAG_COLOR}" title="Set red/amber/green status of this scope item" onclick="AddEditScope&&AddEditScope.updateFlag(event, this);return false;"></span></span>';
  public final static string NODE_DISPLAY_TEMPLATE_WITHOUT_EFFORTS_FLAG = '<span><span{ADD_CLASS}>{SCOPE_NAME}</span>&nbsp;<span class="slds-badge flag flag{FLAG_COLOR}" title="Set red/amber/green status of this scope item" onclick="AddEditScope&&AddEditScope.updateFlag(event, this);return false;"></span></span>';
  public final static string NODE_SCOPE_NAME_FORMAT = '{SCOPE_NAME}';
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
  
  public void testConstantsMethod(){}
}