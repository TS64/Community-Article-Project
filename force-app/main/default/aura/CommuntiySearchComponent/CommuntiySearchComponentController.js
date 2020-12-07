({
    doInit : function(cmp, evt, helper) {
        var parsed_url = new URL(window.location.href);
        var search_text = parsed_url.searchParams.get('searchText');
        var current_topic = parsed_url.searchParams.get('topicName');
        if (search_text != null && search_text != '') {
            cmp.find('enter-search').set('v.value', search_text);
        }
        if (current_topic != null && current_topic != '') {
            cmp.set("v.current_topic", current_topic);
        }
    },

    handleKeyUp : function(cmp, evt, helper) {
    	var isEnterKey = evt.keyCode === 13;
        if (isEnterKey) {
            helper.handleSearchInput(cmp);
        }
    },
    
    clearSearch : function(cmp, evt, helper) {
        cmp.find('enter-search').set('v.value', '');
        cmp.set("v.current_topic", '');
    },

    trackTopicSearch : function(cmp, evt, helper) {
        var topic_name = evt.getParam("category_text");
        console.log("trackTopicSearch: " + topic_name);
        cmp.set("v.current_topic", topic_name);
    },

    performSearch : function(cmp, evt, helper) {
        helper.performSearch(cmp);
    }
})