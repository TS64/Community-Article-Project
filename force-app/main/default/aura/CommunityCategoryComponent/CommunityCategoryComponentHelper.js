({
    getRowNumbers : function(cmp, keyword_num) {
        var row_length = cmp.get('v.row_length');
        var topic_list_starts = [];
        topic_list_starts.push(0);

        for (var i = row_length; i < keyword_num; i = i + row_length) {
            topic_list_starts.push(i);
        }

        cmp.set("v.topic_list_starts", topic_list_starts);
    },

    getRowNumbersMobile : function(cmp, keyword_num) {
        var row_length = cmp.get('v.row_length_mobile');
        var topic_list_starts = [];
        topic_list_starts.push(0);

        for (var i = row_length; i < keyword_num; i = i + row_length) {
            topic_list_starts.push(i);
        }

        cmp.set("v.topic_list_starts_mobile", topic_list_starts);
    },

    performTopicSearch : function(cmp, evt) {
        var topic = evt.getSource().get("v.value");
        console.log('topic: ' + topic);

        var create_event = $A.get("e.Pexlify_Article:searchCategoryEvent");
        create_event.setParams({ 
            "category_text" : topic
        });
        create_event.fire();
        cmp.set("v.selected_topic", topic);
    },

    goToArticlePage : function(cmp, evt, article_page_url) {
        var search_text = cmp.get("v.current_search_term");
        var topic = evt.getSource().get("v.value");
        var url_string = article_page_url + '?topicName=' + topic;
        if (search_text != null && search_text != '') {
            url_string = article_page_url + '?topicName=' + topic + '&searchText=' + search_text;
        }

        var url_event = $A.get("e.force:navigateToURL");
        url_event.setParams({
            "url" : url_string
        });
        url_event.fire();
    },

    displayErrorToast : function(error_message) {
        var toast_event = $A.get("e.force:showToast");
        toast_event.setParams({
            "type" : "error",
            "title": "Topic Error Occured",
            "message": error_message
        });
        toast_event.fire();
    }
})