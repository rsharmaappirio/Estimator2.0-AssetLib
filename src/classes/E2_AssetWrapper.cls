/**=====================================================================
 * Appirio, Inc
 * Name					: E2_AssetWrapper
 * Description	: Asset wrapper for typeahead functionality on E2_EditScope page
 * Created Date	: July 22nd, 2016
 * Created By		: Vikash Goyal (Appirio)
 * 
 * Date Modified      Modified By                  Description of the update

*  =====================================================================*/
global class E2_AssetWrapper {
		webservice string id {get; set;}
		webservice string recommendedAssetRecId;
		webservice string assetName {get; set;}
		webservice string description {get; set;}
		webservice string primaryContributors;
		webservice string technologies {get; set;}
		webservice string assetType;
		webservice string assetSubtype;
		webservice string releaseStage  {get; set;}
		webservice string imageName;
		webservice string assetTypeImage;
		webservice decimal assetUsage;
		webservice decimal totalHours {get; set;}
		webservice decimal reuseLoe {get; set;}
		webservice boolean isRecommended;
		webservice boolean isExisting;
		webservice boolean isDeleted;
				
		public E2_AssetWrapper(string id, string assetName, string description, string primaryContributors, string technologies, string releaseStage,
										string assetType, string assetSubtype, string servicePractice, decimal assetUsage, boolean isRecommended, decimal totalHours, decimal reuseLoe){
			this.id = id;
			this.assetName = assetName;
			this.description = description;
			this.primaryContributors = primaryContributors;
			this.technologies = technologies;
			this.assetType = assetType;
			this.assetSubtype = assetSubtype;
			this.assetUsage = assetUsage;
			this.releaseStage = releaseStage;
			this.isRecommended = isRecommended;
			this.totalHours = totalHours;
			this.reuseLoe = reuseLoe;
			this.isDeleted = false;
			this.isExisting = false;
			
			if(assetType.equalsIgnoreCase('document')){
			    assetTypeImage = 'Document';
			}
			else{
			    assetTypeImage = 'Code';
			}
			
			if(servicePractice != null && servicePractice.length() > 0){
			   if(servicePractice.contains(';')){
			      this.imageName = E2_Constants.ASSET_MULTIPLE_PRACTICE_IMAGE; 
			   }
			   else{
			      this.imageName = servicePractice.replace(' ', '-').toLowerCase() + E2_Constants.ASSET_PRACTICE_IMAGE_SUFFIX; 
			   }
			}
			else{
			    this.imageName = E2_Constants.ASSET_NO_PRACTICE_IMAGE;
			}
		}
		
		public E2_AssetWrapper(string recommendedAssetRecId, string id, string assetName, string description, string technologies, 
		                                            string releaseStage, boolean isExisting, boolean isDeleted, decimal totalHours, decimal reuseLoe){
			this.recommendedAssetRecId = recommendedAssetRecId;
			this.id = id;
			this.assetName = assetName;
			this.description = description;
			this.technologies = technologies;
			this.releaseStage = releaseStage;
			this.isExisting = isExisting;
			this.isDeleted = isDeleted;
			this.totalHours = totalHours;
			this.reuseLoe = reuseLoe;
		}
}