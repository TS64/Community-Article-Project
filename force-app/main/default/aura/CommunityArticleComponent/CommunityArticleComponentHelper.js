({
    getAllArticles : function(cmp) {
        var action = cmp.get("c.getArticles");
        action.setParams({
            "sort_order" : this.getSortOrder(cmp.get("v.sort_order")),
            "sort_field" : cmp.get("v.sort_field"),
            "date_field" : cmp.get("v.datetime"),
            "title_field" : cmp.get("v.title"),
            "summary_field" : cmp.get("v.summary"),
            "namespace" : cmp.get("v.namespace")
        });

        action.setCallback(this, function(response) {
            this.setArticleList(cmp, response);
        });
        $A.enqueueAction(action);
    },

    performTextSearch : function(cmp, search_term) {
        var action = cmp.get("c.getArticlesWithSearchTerm");
        action.setParams({
            "search_term" : search_term,
            "sort_order" : this.getSortOrder("v.sort_order"),
            "fields_to_search" : cmp.get("v.search_field"),
            "sort_field" : cmp.get("v.sort_field"),
            "date_field" : cmp.get("v.datetime"),
            "title_field" : cmp.get("v.title"),
            "summary_field" : cmp.get("v.summary"),
            "namespace" : cmp.get("v.namespace")
        });

        action.setCallback(this, function(response) {
            this.setArticleList(cmp, response);
        });
        $A.enqueueAction(action);
    },

    performTopicSearch : function(cmp, topic_name) {
        var action = cmp.get("c.searchByTopic");
        action.setParams({
            "topic_name" : topic_name,
            "sort_order" : this.getSortOrder(cmp.get("v.sort_order")),
            "sort_field" : cmp.get("v.sort_field"),
            "date_field" : cmp.get("v.datetime"),
            "title_field" : cmp.get("v.title"),
            "summary_field" : cmp.get("v.summary"),
            "namespace" : cmp.get("v.namespace")
        });

        action.setCallback(this, function(response) {
            this.setArticleList(cmp, response);
        });
        $A.enqueueAction(action);
    },

    performTextAndTopicSearch : function(cmp, search_term, topic_name) {
        var action = cmp.get("c.getArticlesWithSearchTermAndTopic");
        action.setParams({
            "search_term" : search_term,
            "sort_order" : this.getSortOrder("v.sort_order"),
            "fields_to_search" : cmp.get("v.search_field"),
            "sort_field" : cmp.get("v.sort_field"),
            "date_field" : cmp.get("v.datetime"),
            "title_field" : cmp.get("v.title"),
            "summary_field" : cmp.get("v.summary"),
            "topic_name" : topic_name,
            "namespace" : cmp.get("v.namespace")
        });

        action.setCallback(this, function(response) {
            this.setArticleList(cmp, response);
        });
        $A.enqueueAction(action);
    },

    setArticleList : function(cmp, response) {
        var data = response.getReturnValue();
        var articles = this.getArticlesFromResponse(data);
        if (response.getState() === 'SUCCESS' && articles != null) {
            this.truncateSummary(cmp, articles);
        }
    },

    truncateSummary : function(cmp, articles) {
        var summary_length = cmp.get("v.summary_length");
        if (summary_length != null && summary_length != '') {
            for (var i = 0; i < articles.length; i++) {
                if (articles[i].Summary != null && articles[i].Summary.length > summary_length + 2) {
                    articles[i].Summary = articles[i].Summary.substring(0, summary_length) + '...';
                }
            }
        }
        cmp.set("v.articles", articles);
    },

    getSortOrder : function(sort_order) {
        if (sort_order == 'Ascending') {
            return 'ASC';
        }
        return 'DESC';
    },

    getArticlesFromResponse : function(data) {
        if (data == null || data.length <= 0) {
            return [];
        }
        var articles = [];
        var error_messages = [];
        for (var i = 0; i < data.length; i++) {
            if (data[i].ErrorMessage == null || data[i].ErrorMessage == '') {
                articles.push(data[i].Article);
                articles[i].Title = data[i].TitleField;
                articles[i].Summary = data[i].SummaryField;
                articles[i].Date = data[i].DateString;
                articles[i].Topics = data[i].Topics;
            }
            else {
                error_messages.push(data[i].ErrorMessage);
            }
        }
        if (error_messages.length > 0) {
            this.displayErrorToast(error_messages);
        }
        return articles;
    },

    displayErrorToast : function(error_messages) {
        var error_string = '';
        for (var i = 0; i < error_messages.length; i++) {
            error_string += error_messages[i] + '\n';
        }
        var toast_event = $A.get("e.force:showToast");
        toast_event.setParams({
            "type" : "error",
            "title": "Article Query Error Occured",
            "message": error_string
        });
        toast_event.fire();
    }
})