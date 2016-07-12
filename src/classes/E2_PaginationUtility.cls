public without sharing class E2_PaginationUtility {
  static final Integer DEFAULT_LINKS_AT_A_TIME;
  static final Integer DEFAULT_NUMBER_OF_LINKS_BEFORE_CURRENT;
  static final Integer DEFAULT_NUMBER_OF_LINKS_AFTER_CURRENT;
  static {
    DEFAULT_LINKS_AT_A_TIME = 5;
    DEFAULT_NUMBER_OF_LINKS_BEFORE_CURRENT = 1;
    DEFAULT_NUMBER_OF_LINKS_AFTER_CURRENT = 1;
  }

  public Integer pageSize;

  List<List<Object>> customPaginationList;
  public Integer totalRecords {get; private set;}
  public Integer selectedPageNumber {get; private set;}
  
  public E2_PaginationUtility() {
    selectedPageNumber = 1;
    customPaginationList = new List<List<Object>>();
  }

  public List<Object> setPagination(List<Object> customList) {
    customPaginationList.clear();
    totalRecords = customList != null ? customList.size() : 0;
    //Set page size default to 20 if user not override this.
    if(pageSize == null) pageSize = 20;
    selectedPageNumber = 1;

    for(Object obj : customList) {
      if(customPaginationList.size() == 0 ||
          customPaginationList.get(customPaginationList.size() - 1).size() == pageSize) {
        customPaginationList.add(new List<Object>());
      }
      customPaginationList.get(customPaginationList.size() - 1).add(Obj);
    }
    if(customPaginationList.size() > 0) {
      return customPaginationList.get(0);
    }
    return new List<Object>();
  }

  public List<Object> getPage(Integer selectedPage) {
    if(customPaginationList != null && selectedPage > 0 &&
        selectedPage <= customPaginationList.size()) {
      selectedPageNumber = selectedPage;
      return customPaginationList.get(selectedPageNumber - 1);
    }
    return null;
  }

  public List<Object> next() {
    Integer nextPage = selectedPageNumber + 1;
    if(customPaginationList != null && nextPage > 0 &&
        nextPage <= customPaginationList.size()) {
      selectedPageNumber++;
      return customPaginationList.get(selectedPageNumber - 1);
    }
    return null;
  }

  public List<Object> previous() {
    Integer previousPage = selectedPageNumber - 1;
    if(customPaginationList != null && previousPage > 0 &&
        previousPage <= customPaginationList.size()) {
      selectedPageNumber--;
      return customPaginationList.get(selectedPageNumber - 1);
    }
    return null;
  }

  public List<Object> first() {
    if(customPaginationList != null &&
        customPaginationList.size() > 1) {
      selectedPageNumber = 1;
      return customPaginationList.get(selectedPageNumber - 1);
    }
    return null;
  }

  public List<Object> last() {
    if(customPaginationList != null) {
      selectedPageNumber = totalPage;
      return customPaginationList.get(selectedPageNumber - 1);
    }
    return null;
  }

  // Property that returs the total number of pages
  public Integer totalPage {
    get {
      if(customPaginationList != null) {
        return customPaginationList.size();
      }
      return 0;
    }
  }

  //----------------------------------------------------------------------------------------------------------------------------------------
  // Method that return the Index number of first record on the page
  //----------------------------------------------------------------------------------------------------------------------------------------
  public Integer getShowingFrom() {
    if(totalRecords != 0) {
      Integer showingFrom = (selectedPageNumber * pageSize) - pageSize + 1;
      return showingFrom;
    }
    return 0;
  }

  //----------------------------------------------------------------------------------------------------------------------------------------
  // Method that return the Index number of last record on the page
  //----------------------------------------------------------------------------------------------------------------------------------------
  public Integer getShowingTo() {
    Integer showingTo = selectedPageNumber * pageSize ;
    if (totalRecords < showingTo) {
      showingTo = totalRecords;
    }
    return showingTo;
  }

  //----------------------------------------------------------------------------------------------------------------------------------------
  // Property which return the list of page links to be display
  //----------------------------------------------------------------------------------------------------------------------------------------
  public List<Integer> listOfLinks {
    get {
      Integer linkCounter = 0;
      Integer current = selectedPageNumber;
      Integer startFrom = current - DEFAULT_NUMBER_OF_LINKS_BEFORE_CURRENT;
      Integer endTo = current + DEFAULT_NUMBER_OF_LINKS_AFTER_CURRENT;
      if(startFrom <= 0) startFrom = 1;
      if(endTo > totalPage) endTo = totalPage;

      List<Integer> links = new List<Integer>();


      Integer numberOfLinksToBeDisplayed = totalPage - startFrom;
      if(numberOfLinksToBeDisplayed < DEFAULT_LINKS_AT_A_TIME - 2) startFrom = startFrom - (DEFAULT_LINKS_AT_A_TIME - numberOfLinksToBeDisplayed - 2);
      if(startFrom <= 1) startFrom = 2;

      if(startFrom != 1) {
        links.add(1);
        linkCounter++;
        if(startFrom != 2) links.add(0);
      }

      if(endTo != totalPage) linkCounter++;

      for(Integer linkNumber = startFrom; linkNumber <= totalPage; linkNumber++) {
        links.add(linkNumber);
        linkCounter++;
        if(linkCounter >= DEFAULT_LINKS_AT_A_TIME) break;
      }

      if(endTo != totalPage) {
        if(endTo != totalPage - 1) links.add(0);
        if(links.get(links.size() - 1) != totalPage) {
          links.add(totalPage);
        }
      }
      return links;
    }
  }
  
  //----------------------------------------------------------------------------------------------------------------------------------------
    // Property that return true if there are more links (in backward direction) to be display
    //----------------------------------------------------------------------------------------------------------------------------------------
    public Boolean isMorePrevious {
        get {
            if(listOfLinks.size() > 0 && Integer.valueOf(listOfLinks.get(0)) != 1) {
                return true;
        }
        return false;
        }
        set; 
    }
                
    //----------------------------------------------------------------------------------------------------------------------------------------
    // Property that return true if there are more links (in forward direction) to be display 
    //----------------------------------------------------------------------------------------------------------------------------------------
    public Boolean isMoreNext {
    get {
        if(listOfLinks.size() > 0 && Integer.valueOf(listOfLinks.get(listOfLinks.size() - 1)) < totalPage) {
            return true;
        }
        return false;
    }
    set;
    }
    
    //----------------------------------------------------------------------------------------------------------------------------------------
    // Property that return full list of all records
    //----------------------------------------------------------------------------------------------------------------------------------------
    public List<Object> getRecordsList() {
        List<Object> listOfRecords = new List<Object>();
        for(List<Object> pagewiseList : customPaginationList) {
            listOfRecords.addAll(pagewiseList);
        }
        return listOfRecords;
    }
}