({
    doInit : function(cmp, evt, helper) {
        var parsed_url = new URL(window.location.href);
        var article_id = parsed_url.searchParams.get('articleID');
        article_id = 'ka03X000000EzLqQAK';
        if (article_id != null && article_id != '') {
            helper.getArticle(cmp, article_id);
        }
    },

    searchForTopic : function(cmp, evt, helper) {
        var article_page_url = cmp.get("v.article_page_url");
        var topic = evt.getSource().get("v.value");

        if (article_page_url == '' || article_page_url == window.location.href) {
            helper.performTopicSearch(cmp, topic);
        }
        else if (article_page_url != window.location.href) {
            helper.goToArticlePage(article_page_url, topic);
        }
    }
})