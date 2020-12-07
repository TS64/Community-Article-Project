({
    doInit : function(cmp, evt, helper) {
        var parsed_url = new URL(window.location.href);
        var topic_name = parsed_url.searchParams.get('topicName');
        var search_term = parsed_url.searchParams.get('searchText');
        cmp.set("v.selected_topic", topic_name);
        cmp.set("v.current_search_term", search_term);

        var action = cmp.get("c.getTopics");
        action.setCallback(this, function(response) {
            var data = response.getReturnValue();
            if (data.ErrorMessage == null && data.Topics != null && data.Topics.length > 0) {
                cmp.set("v.keywords", data.Topics);
                helper.getRowNumbers(cmp, data.Topics.length);
                helper.getRowNumbersMobile(cmp, data.Topics.length);
            }
            else if (data.ErrorMessage != null) {
                helper.displayErrorToast(data.ErrorMessage);
            }
        });
        $A.enqueueAction(action);
    },

    selectedCategory : function(cmp, evt, helper) {
        var article_page_url = cmp.get("v.article_page_url");
        if (article_page_url == '' || article_page_url == window.location.href) {
            helper.performTopicSearch(cmp, evt);
        }
        else if (article_page_url != window.location.href) {
            helper.goToArticlePage(cmp, evt, article_page_url);
        }
    },

    clearSearch : function(cmp) {
        cmp.set("v.selected_topic", '');
        cmp.set("v.current_search_term", '');
    },

    trackSearchTerm : function(cmp, evt, helper) {
        var search_term = evt.getParam("queryText");
        console.log("trackSearchTerm: " + search_term);
        cmp.set("v.current_search_term", search_term);
    },

    setSelectedTopic : function(cmp, evt) {
        var topic_name = evt.getParam("category_text");
        console.log('Retrieved topic: ' + topic_name);
        cmp.set("v.selected_topic", topic_name);
    }
})