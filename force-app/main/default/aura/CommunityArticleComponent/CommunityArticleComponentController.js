({
    doInit : function(cmp, evt, helper) {
        var parsed_url = new URL(window.location.href);
        var search_text = parsed_url.searchParams.get('searchText');
        var topic_name = parsed_url.searchParams.get('topicName');
        if (search_text != null && search_text != '' && topic_name != null && topic_name != '') {
            cmp.set("v.current_search", search_text);
            cmp.set("v.current_topic", topic_name);
            helper.performTextAndTopicSearch(cmp, search_text, topic_name);
        }
        else if (search_text != null && search_text != '') {
            cmp.set("v.current_search", search_text);
            helper.performTextSearch(cmp, search_text);
        }
        else if (topic_name != null && topic_name != '') {
            cmp.set("v.current_topic", topic_name);
            helper.performTopicSearch(cmp, topic_name);
        }
        else {
            helper.getAllArticles(cmp);
        }
    },
    
    performTextSearch : function(cmp, evt, helper) {
        var search_term = evt.getParam("queryText");
        cmp.set("v.current_search", search_term);
        if (search_term != null && search_term != '') {
            var topic_name = cmp.get("v.current_topic");
            if (topic_name != null && topic_name != '') {
                helper.performTextAndTopicSearch(cmp, search_term, topic_name);
            }
            else {
                helper.performTextSearch(cmp, search_term);
            }
        }
    },

    performTopicSearch : function(cmp, evt, helper) {
        var topic_name = evt.getParam("category_text");
        cmp.set("v.current_topic", topic_name);
        if (topic_name != null && topic_name != '') {
            var search_term = cmp.get("v.current_search");
            if (search_term != null && search_term != '') {
                helper.performTextAndTopicSearch(cmp, search_term, topic_name);
            }
            else {
                helper.performTopicSearch(cmp, topic_name);
            }
        }
    },

    goToArticlePage : function(cmp, evt) {
        var article_page = cmp.get("v.blog_page");
        var articles = cmp.get("v.articles");
        var url_event = $A.get("e.force:navigateToURL");
        var selected_item = evt.currentTarget;
        var index = selected_item.dataset.record;
        
        url_event.setParams({
            "url" : article_page + '?articleID=' + articles[index].Id
        });
        url_event.fire();
    },

    clearSearch : function(cmp, evt, helper) {
        var createEvent = $A.get("e.PexlifyArticles:clearSearchEvent");
        createEvent.fire();
        cmp.set("v.current_search", '');

        var createEvent = $A.get("e.PexlifyArticles:clearTopicEvent");
        createEvent.fire();
        cmp.set("v.current_topic", '');

        helper.getAllArticles(cmp);
    }
})