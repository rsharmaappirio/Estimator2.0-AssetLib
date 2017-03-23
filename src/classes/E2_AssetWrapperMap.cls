/**=====================================================================
 * Appirio, Inc
 * Name					: E2_AssetWrapperMap
 * Description	: E2_AssetWrapperMap to show recommended asset on E2_EditScopePage
 * Created Date	: July 25th, 2016
 * Created By		: Vikash Goyal (Appirio)
 * 
 * Date Modified      Modified By                  Description of the update

*  =====================================================================*/
global class E2_AssetWrapperMap {
	webservice string searchKey;
  webservice List<E2_AssetWrapper> assetList;
  
  public E2_AssetWrapperMap(string searchKey, List<E2_AssetWrapper> assetList){
    this.searchKey = searchKey;
    this.assetList = assetList;       
  }
}