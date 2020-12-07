({
    performSearch : function(cmp) {
        var query_term = cmp.find('enter-search').get('v.value');

        var create_event = $A.get("e.c:searchTermEvent");
        create_event.setParams({ "queryText" : query_term });
        create_event.fire();

        cmp.set('v.isSearching', true);
        setTimeout(function() {
            cmp.set('v.isSearching', false);
        }, 2000);
    },

    goToArticlePage : function(cmp, article_page_url) {
        var topic = cmp.set("v.current_topic");
        var url_event = $A.get("e.force:navigateToURL");
        var query_term = cmp.find('enter-search').get('v.value');
        var url_string = article_page_url + '?searchText=' + query_term;
        if (topic != null && topic != '') {
            url_string = article_page_url + '?searchText=' + query_term + '&topicName=' + topic;
        } 

        url_event.setParams({
            "url" : url_string
        });
        url_event.fire();
    },

    handleSearchInput : function(cmp) {
        var article_page_url = cmp.get("v.article_page_url");
        if (article_page_url == '' || article_page_url == window.location.href) {
            this.performSearch(cmp);
        }
        else if (article_page_url != window.location.href) {
            this.goToArticlePage(cmp, article_page_url);
        }
    }
})