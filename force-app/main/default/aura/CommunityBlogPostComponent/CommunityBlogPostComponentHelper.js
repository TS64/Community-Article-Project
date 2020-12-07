({
    getArticle : function(cmp, article_id) {
        var action = cmp.get("c.getSingleArticle");
        action.setParams({
            "article_id" : article_id,
            "date_field" : cmp.get("v.datetime"),
            "title_field" : cmp.get("v.title_field"),
            "summary_field" : cmp.get("v.summary_field"),
            "namespace" : cmp.get("v.namespace")
        });

        action.setCallback(this, function(response) {
            var data = response.getReturnValue();
            if (data.ErrorMessage == null && data.Article != null) {
                var article = data.Article;
                article.Date = data.DateString;
                article.Title = data.TitleField;
                article.Summary = data.SummaryField;
                cmp.set("v.article", article);
                cmp.set("v.topics", data.Topics);
                this.setImageDimensions(cmp);
            } else {
                this.displayErrorToast(data.ErrorMessage);
            }
        });
        $A.enqueueAction(action);
    },

    performTopicSearch : function(cmp, topic) {
        var create_event = $A.get("e.Pexlify_Article:searchCategoryEvent");
        create_event.setParams({ 
            "category_text" : topic
        });
        create_event.fire();
        cmp.set("v.selected_topic", topic);
    },

    goToArticlePage : function(article_page_url, topic) {
        var url_event = $A.get("e.force:navigateToURL");
        var url_string = article_page_url + "?topicName=" + topic;

        url_event.setParams({
            "url" : url_string
        });
        url_event.fire();
    },

    setImageDimensions : function(cmp) {
        var image_dimensions = cmp.get("v.image_dimensions").toLowerCase();
        var index_of_x = image_dimensions.indexOf('x');
        cmp.set("v.image_height", image_dimensions.slice(0, index_of_x));
        cmp.set("v.image_width", image_dimensions.slice(index_of_x + 1));
    },

    displayErrorToast : function(error_message) {
        var toast_event = $A.get("e.force:showToast");
        toast_event.setParams({
            "type" : "error",
            "title": "Error",
            "message": error_message
        });
        toast_event.fire();
    }
})