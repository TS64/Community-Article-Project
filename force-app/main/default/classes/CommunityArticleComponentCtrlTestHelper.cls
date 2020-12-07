@isTest
public with sharing class CommunityArticleComponentCtrlTestHelper {

    public static List<SObject> createValidArticles(Integer number_of_articles) {
        List<SObject> list_of_articles = new List<SObject>();

        for (integer i = 0; i < number_of_articles; i++) {
            SObject article = Schema.getGlobalDescribe().get(getKnowledgeObjectNameWithNamespace()).newSObject();
            article.put('Title', 'TestTitle' + i);
            article.put('Summary', 'TestSummary' + i);
            article.put('UrlName', 'TestUrlName' + i);
            list_of_articles.add(article);
        }

        Database.SaveResult[] results = Database.insert(list_of_articles);
        for (Database.SaveResult result : results) {
            System.assert(result.isSuccess());
        }

        return list_of_articles;
    }

    public static List<SObject> createValidArticlesAndPublish(Integer number_of_articles) {
        List<SObject> list_of_articles = new List<SObject>();

        for (integer i = 0; i < number_of_articles; i++) {
            SObject article = Schema.getGlobalDescribe().get(getKnowledgeObjectNameWithNamespace()).newSObject();
            article.put('Title', 'TestTitle' + i);
            article.put('Summary', 'TestSummary' + i);
            article.put('UrlName', 'TestUrlName' + i);
            list_of_articles.add(article);
        }

        Database.SaveResult[] results = Database.insert(list_of_articles);
        for (Database.SaveResult result : results) {
            System.assert(result.isSuccess());
        }

        publishArticles(list_of_articles);

        return list_of_articles;
    }

    public static List<SObject> createIncorrectArticles(Integer number_of_articles) {
        List<SObject> list_of_articles = new List<SObject>();

        for (integer i = 0; i < number_of_articles; i++) {
            SObject article = Schema.getGlobalDescribe().get(getKnowledgeObjectNameWithNamespace()).newSObject();
            article.put('Title', 'IncorrectTitle' + i);
            article.put('Summary', 'IncorrectSummary' + i);
            article.put('UrlName', 'IncorrectUrlName' + i);
            list_of_articles.add(article);
        }

        Database.SaveResult[] results = Database.insert(list_of_articles);
        for (Database.SaveResult result : results) {
            System.assert(result.isSuccess());
        }

        return list_of_articles;
    }

    public static Topic createTopic(String topic_name) {
        Topic test_topic = new Topic(Name = topic_name);
        Database.SaveResult result = Database.insert(test_topic);
        System.assert(result.isSuccess());
        return test_topic;
    }

    public static List<Topic> createTopics(List<String> topic_names) {
        List<Topic> topic_list = new List<Topic>();
        for (String str : topic_names) {
            topic_list.add(new Topic(Name = str));
        }
        Database.SaveResult[] results = Database.insert(topic_list);
        for (Integer i = 0; i < results.size(); i++) {
            System.assert(results[i].isSuccess());
        }
        return topic_list;
    }

    public static void assertSingleArticleIsCorrect(CommunityArticleComponentController.SingleArticleInfo article, List<String> topics) {
        System.assertEquals(1, topics.size());
        System.assertEquals('TestTitle0', article.TitleField);
        System.assertEquals('TestSummary0', article.SummaryField);
        System.assertEquals('TestTopic', article.Topics[0]);
    }

    public static void assertTopicArticleMapIsCorrect(Map<ID, Set<String>> topic_map, List<SObject> articles) {
        System.assertEquals(5, topic_map.keySet().size());
        List<ID> article_ids = new List<ID>(topic_map.keySet());
        for (Integer i = 0; i < articles.size(); i++) {
            System.assertEquals(articles[i].get('Id'), article_ids[i]);
            List<String> topic_names = new List<String>(topic_map.get(article_ids[i]));
            System.debug('1- assert topic_names: ' + topic_names);
            System.assertEquals('TopicOne', topic_names[0]);
            System.assertEquals('TopicTwo', topic_names[1]);
        }
    }

    public static void assertMapOfTopicIDsAndNamesIsCorrect(Map<ID, String> topic_map, List<Topic> topic_list) {
        System.assertEquals(topic_list.size(), topic_map.size());
        Integer i = 0;
        for (ID topic_id : topic_map.keySet()) {
            System.assertEquals(topic_list[i].Id, topic_id);
            System.assertEquals(topic_list[i].Name, topic_map.get(topic_list[i].Id));
            i++;
        }
    }

    public static void assertArticleInfoHasCorrectTopics(List<CommunityArticleComponentController.SingleArticleInfo> returned_articles, List<Topic> topics) {
        for (Integer x = 0; x < returned_articles.size(); x++) {
            for (Integer y = 0; y < topics.size(); y++) {
                System.assertEquals(topics[y].Name, returned_articles[x].Topics[y]);
            }
        }
    }

    public static void assertMissingFieldErrorMessageIsCorrect(Integer number_of_articles, List<CommunityArticleComponentController.SingleArticleInfo> returned_articles) {
        System.assertEquals(number_of_articles, returned_articles.size());
        for (Integer i = 0; i < returned_articles.size(); i++) {
            System.assertEquals('SObject row was retrieved via SOQL without querying the requested field: ' + getKnowledgeObjectNameWithNamespace() + '.Title', returned_articles[i].ErrorMessage);
        }
    }

    public static void publishArticles(List<SObject> articles) {
        List<Id> article_IDs = new List<Id>();
        for (SObject article : articles) {
            article_IDs.add(article.Id);
        }
        String sQuery = 'SELECT KnowledgeArticleId FROM ' + getKnowledgeObjectNameWithNamespace() + ' WHERE Id IN: article_IDs';
        List<SObject> knowledge_articles = Database.query(sQuery);
        for (SObject article : knowledge_articles) {
            KbManagement.PublishingService.publishArticle((Id)article.get('KnowledgeArticleId'), true);
        }
    }

    public static void assertArticlesAreCorrect(Integer number_of_articles, List<CommunityArticleComponentController.SingleArticleInfo> returned_articles) {
        List<SObject> articles = getArticlesFromReturnedList(returned_articles);
        System.assertEquals(number_of_articles, articles.size());
        for (Integer i = 0; i < number_of_articles; i++) {
            System.assertEquals('TestTitle' + i, articles[i].get('Title'));
            System.assertEquals('TestSummary' + i, articles[i].get('Summary'));
        }
    }

    public static void assertArticleIDsAreCorrect(List<SObject> articles, List<ID> retrieved_ID_list) {
        System.assertEquals(articles.size(), retrieved_ID_list.size());
        List<Id> knowledge_article_IDs = new List<Id>();
        for (Integer i = 0; i < articles.size(); i++) {
            knowledge_article_IDs.add((Id)articles[i].get('ID'));
        }
        retrieved_ID_list.sort();
        knowledge_article_IDs.sort();
        System.assertEquals(knowledge_article_IDs, retrieved_ID_list);
    }

    public static void assertFirstPublishedDatesAreCorrect(List<DateTime> returned_dates, List<DateTime> article_dates) {
        for (Integer i = 0; i < returned_dates.size(); i++) {
            System.assertEquals(returned_dates, article_dates);
        }
    }

    public static void assertTitlesAreCorrect(List<String> returned_titles, List<String> article_titles) {
        for (Integer i = 0; i < returned_titles.size(); i++) {
            System.assertEquals(returned_titles, article_titles);
        }
    }

    public static void assertSummariesAreCorrect(List<String> returned_summaries, List<String> article_summaries) {
        for (Integer i = 0; i < returned_summaries.size(); i++) {
            System.assertEquals(returned_summaries, article_summaries);
        }
    }

    public static List<Topic> insertTopics(Integer number_of_topics) {
        List<Topic> topics = new List<Topic>();
        for (Integer i = 0; i < number_of_topics; i++) {
            Topic new_topic = new Topic(NetworkId = Network.getNetworkId(), Name = 'TestTopic' + i);
            topics.add(new_topic);
        }
        Database.SaveResult[] results = Database.insert(topics);
        for (Database.SaveResult result : results) {
            System.assert(result.isSuccess());
        }

        return topics;
    }

    public static void createTopicAssignment(SObject article, Topic topic_obj) {
        TopicAssignment topic_assignment = new TopicAssignment(EntityId = (Id)article.get('Id'), TopicId = topic_obj.Id);
        Database.SaveResult result = Database.insert(topic_assignment);
        System.assert(result.isSuccess());
    }

    public static void createTopicAssignments(List<SObject> articles, Topic topic_obj) {
        List<TopicAssignment> topic_assignments = new List<TopicAssignment>();
        for (SObject article : articles) {
            topic_assignments.add(new TopicAssignment(EntityId = (Id)article.get('Id'), TopicId = topic_obj.Id));
        }
        Database.SaveResult[] results = Database.insert(topic_assignments);
        for (Database.SaveResult result : results) {
            System.assert(result.isSuccess());
        }
    }

    public static List<SObject> getArticlesFromReturnedList(List<CommunityArticleComponentController.SingleArticleInfo> returned_articles) {
        List<SObject> articles = new List<SObject>();
        for (Integer i = 0; i < returned_articles.size(); i++) {
            articles.add(returned_articles[i].Article);
        }
        return articles;
    }

    public static List<ID> getKnowledgeArticleIDs(List<SObject> articles) {
        List<ID> article_IDs = new List<ID>();
        for (SObject article : articles) {
            article_IDs.add((Id)article.get('Id'));
        }
        return article_IDs;
    }
    
    public static String getKnowledgeObjectNameWithNamespace() {
        String namespace = [SELECT NamespacePrefix FROM Organization].NamespacePrefix;
        if (namespace != '' && namespace != null) {
            return namespace + '__Knowledge__kav';
        } else {
            return 'Knowledge__kav';
        }
    }
}