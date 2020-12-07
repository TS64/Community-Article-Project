@isTest
private class CommunityArticleComponentControllerTest {
    @isTest static void GetArticles_Bulk_Test() {
        Integer number_of_articles = 5;
        List<SObject> list_of_articles = CommunityArticleComponentCtrlTestHelper.createValidArticlesAndPublish(number_of_articles);

        Test.startTest();
        List<CommunityArticleComponentController.SingleArticleInfo> returned_articles = CommunityArticleComponentController.getArticles('ASC', 'Title', 'FirstPublishedDate', 'Title', 'Summary', [SELECT NamespacePrefix FROM Organization].NamespacePrefix);
        Test.stopTest();

        CommunityArticleComponentCtrlTestHelper.assertArticlesAreCorrect(number_of_articles, returned_articles);
    }

    @isTest static void GetArticles_Single_Test() {
        Integer number_of_articles = 1;
        List<SObject> list_of_articles = CommunityArticleComponentCtrlTestHelper.createValidArticlesAndPublish(number_of_articles);

        Test.startTest();
        List<CommunityArticleComponentController.SingleArticleInfo> returned_articles = CommunityArticleComponentController.getArticles('ASC', 'Title', 'FirstPublishedDate', 'Title', 'Summary', [SELECT NamespacePrefix FROM Organization].NamespacePrefix);
        Test.stopTest();

        CommunityArticleComponentCtrlTestHelper.assertArticlesAreCorrect(number_of_articles, returned_articles);
    }

    @isTest static void GetArticles_NotPublilshed_Test() {
        Integer number_of_articles = 5;
        List<SObject> list_of_articles = CommunityArticleComponentCtrlTestHelper.createValidArticles(number_of_articles);

        Test.startTest();
        List<CommunityArticleComponentController.SingleArticleInfo> returned_articles = CommunityArticleComponentController.getArticles('ASC', 'Title', 'FirstPublishedDate', 'Title', 'Summary', [SELECT NamespacePrefix FROM Organization].NamespacePrefix);
        Test.stopTest();

        System.assertEquals(0, returned_articles.size());
    }

    @isTest static void GetArticles_NoArticles_Test() {
        Test.startTest();
        List<CommunityArticleComponentController.SingleArticleInfo> returned_articles = CommunityArticleComponentController.getArticles('ASC', 'Title', 'FirstPublishedDate', 'Title', 'Summary', [SELECT NamespacePrefix FROM Organization].NamespacePrefix);
        Test.stopTest();

        System.assertEquals(0, returned_articles.size());
    }
    
    @isTest static void GetArticles_NoAccessibleFields_Test() {
        Integer number_of_articles = 5;
        List<SObject> list_of_articles = CommunityArticleComponentCtrlTestHelper.createValidArticlesAndPublish(number_of_articles);
        
        Test.startTest();
        List<CommunityArticleComponentController.SingleArticleInfo> returned_articles = CommunityArticleComponentController.getArticles('ASC', 'Title', 'InvalidDate', 'InvalidTitle', 'InvalidSummary', [SELECT NamespacePrefix FROM Organization].NamespacePrefix);
        Test.stopTest();

        System.assertEquals(1, returned_articles.size());
        System.assertEquals('You do not have the required field permissions.', returned_articles[0].ErrorMessage);
    }

    @isTest static void GetSingleArticle_Test() {
        List<SObject> list_of_articles = CommunityArticleComponentCtrlTestHelper.createValidArticlesAndPublish(1);
        Topic test_topic = new Topic(Name = 'TestTopic');
        Database.SaveResult topic_result = Database.insert(test_topic);
        System.assert(topic_result.isSuccess());
        CommunityArticleComponentCtrlTestHelper.createTopicAssignment(list_of_articles[0], test_topic);

        Test.startTest();
        CommunityArticleComponentController.SingleArticleInfo returned_article = CommunityArticleComponentController.getSingleArticle(list_of_articles[0].Id, 'FirstPublishedDate', 'Title', 'Summary', [SELECT NamespacePrefix FROM Organization].NamespacePrefix);
        Test.stopTest();

        CommunityArticleComponentCtrlTestHelper.assertSingleArticleIsCorrect(returned_article, returned_article.Topics);
    }

    @isTest static void GetSingleArticle_NotPublished_Test() {
        List<SObject> list_of_articles = CommunityArticleComponentCtrlTestHelper.createValidArticles(1);

        Topic test_topic = new Topic(Name = 'TestTopic');
        Database.SaveResult topic_result = Database.insert(test_topic);
        System.assert(topic_result.isSuccess());

        CommunityArticleComponentCtrlTestHelper.createTopicAssignment(list_of_articles[0], test_topic);

        Test.startTest();
        CommunityArticleComponentController.SingleArticleInfo returned_article = CommunityArticleComponentController.getSingleArticle(list_of_articles[0].Id, 'FirstPublishedDate', 'Title', 'Summary', [SELECT NamespacePrefix FROM Organization].NamespacePrefix);
        Test.stopTest();

        System.assertEquals('List has no rows for assignment to SObject', returned_article.ErrorMessage);
    }
    
    @isTest static void GetSingleArticle_NoAccessibleFields_Test() {
        List<SObject> list_of_articles = CommunityArticleComponentCtrlTestHelper.createValidArticlesAndPublish(1);
        Topic test_topic = new Topic(Name = 'TestTopic');
        Database.SaveResult topic_result = Database.insert(test_topic);
        System.assert(topic_result.isSuccess());
        CommunityArticleComponentCtrlTestHelper.createTopicAssignment(list_of_articles[0], test_topic);

        Test.startTest();
        CommunityArticleComponentController.SingleArticleInfo returned_article = CommunityArticleComponentController.getSingleArticle(list_of_articles[0].Id, 'InvalidDate', 'InvalidTitle', 'InvalidSummary', [SELECT NamespacePrefix FROM Organization].NamespacePrefix);
        Test.stopTest();

        System.assertEquals('You do not have the required field permissions.', returned_article.ErrorMessage);
    }

    @isTest static void GetArticlesWithSearchTerm_Test() {
        integer number_of_correct_articles = 3;
        integer number_of_incorrect_articles = 3;
        List<SObject> list_of_articles = CommunityArticleComponentCtrlTestHelper.createValidArticles(number_of_correct_articles);
        list_of_articles.addAll(CommunityArticleComponentCtrlTestHelper.createIncorrectArticles(number_of_incorrect_articles));

        CommunityArticleComponentCtrlTestHelper.publishArticles(list_of_articles);

        Test.startTest();
        List<CommunityArticleComponentController.SingleArticleInfo> returned_articles = CommunityArticleComponentController.getArticlesWithSearchTerm('Test', 'ASC', 'Title, Summary', 'Title', 'FirstPublishedDate', 'Title', 'Summary', [SELECT NamespacePrefix FROM Organization].NamespacePrefix);
        Test.stopTest();

        CommunityArticleComponentCtrlTestHelper.assertArticlesAreCorrect(number_of_correct_articles, returned_articles);
    }

    @isTest static void GetArticlesWithSearchTerm_Single_Test() {
        integer number_of_correct_articles = 1;
        List<SObject> list_of_articles = CommunityArticleComponentCtrlTestHelper.createValidArticlesAndPublish(number_of_correct_articles);

        Test.startTest();
        List<CommunityArticleComponentController.SingleArticleInfo> returned_articles = CommunityArticleComponentController.getArticlesWithSearchTerm('Test', 'ASC', 'Title, Summary', 'Title', 'FirstPublishedDate', 'Title', 'Summary', [SELECT NamespacePrefix FROM Organization].NamespacePrefix);
        Test.stopTest();

        CommunityArticleComponentCtrlTestHelper.assertArticlesAreCorrect(number_of_correct_articles, returned_articles);
    }

    @isTest static void GetArticlesWithSearchTerm_WrongTerm_Test() {
        integer number_of_correct_articles = 3;
        integer number_of_incorrect_articles = 3;
        List<SObject> list_of_articles = CommunityArticleComponentCtrlTestHelper.createValidArticles(number_of_correct_articles);
        list_of_articles.addAll(CommunityArticleComponentCtrlTestHelper.createIncorrectArticles(number_of_incorrect_articles));

        CommunityArticleComponentCtrlTestHelper.publishArticles(list_of_articles);

        Test.startTest();
        List<CommunityArticleComponentController.SingleArticleInfo> returned_articles = CommunityArticleComponentController.getArticlesWithSearchTerm('WrongTerm', 'ASC', 'Title, Summary', 'Title', 'FirstPublishedDate', 'Title', 'Summary', [SELECT NamespacePrefix FROM Organization].NamespacePrefix);
        Test.stopTest();

        System.assertEquals(0, returned_articles.size());
    }

    @isTest static void GetArticlesWithSearchTerm_WithMissingMatchingField_Test() {
        integer number_of_correct_articles = 3;
        integer number_of_incorrect_articles = 3;
        List<SObject> list_of_articles = CommunityArticleComponentCtrlTestHelper.createValidArticles(number_of_correct_articles);
        list_of_articles.addAll(CommunityArticleComponentCtrlTestHelper.createIncorrectArticles(number_of_incorrect_articles));

        CommunityArticleComponentCtrlTestHelper.publishArticles(list_of_articles);

        Test.startTest();
        List<CommunityArticleComponentController.SingleArticleInfo> returned_articles = CommunityArticleComponentController.getArticlesWithSearchTerm('Summary', 'ASC', 'Title', 'Title', 'FirstPublishedDate', 'Title', 'Summary', [SELECT NamespacePrefix FROM Organization].NamespacePrefix);
        Test.stopTest();

        System.assertEquals(0, returned_articles.size());
    }
    
    @isTest static void GetArticlesWithSearchTerm_NoAccessibleFields_Test() {
        integer number_of_correct_articles = 3;
        integer number_of_incorrect_articles = 3;
        List<SObject> list_of_articles = CommunityArticleComponentCtrlTestHelper.createValidArticles(number_of_correct_articles);
        list_of_articles.addAll(CommunityArticleComponentCtrlTestHelper.createIncorrectArticles(number_of_incorrect_articles));

        CommunityArticleComponentCtrlTestHelper.publishArticles(list_of_articles);

        Test.startTest();
        List<CommunityArticleComponentController.SingleArticleInfo> returned_articles = CommunityArticleComponentController.getArticlesWithSearchTerm('Test', 'ASC', 'Title, Summary', 'Title', 'InvalidDate', 'InvalidTitle', 'InvalidSummary', [SELECT NamespacePrefix FROM Organization].NamespacePrefix);
        Test.stopTest();

        System.assertEquals(1, returned_articles.size());
        System.assertEquals('You do not have the required field permissions.', returned_articles[0].ErrorMessage);
    }

    @isTest static void GetArticlesWithSearchTermAndTopic_Test() {
        Integer number_of_articles = 3;
        CommunityArticleComponentCtrlTestHelper.createValidArticlesAndPublish(number_of_articles);
        Topic test_topic = CommunityArticleComponentCtrlTestHelper.createTopic('TestTopic');
        CommunityArticleComponentCtrlTestHelper.createTopicAssignments(Database.query('SELECT KnowledgeArticleId FROM ' + CommunityArticleComponentCtrlTestHelper.getKnowledgeObjectNameWithNamespace()), test_topic);

        Test.startTest();
        List<CommunityArticleComponentController.SingleArticleInfo> returned_articles = CommunityArticleComponentController.getArticlesWithSearchTermAndTopic('TestTitle', 'ASC', 'Title, Summary', 'Title', 'FirstPublishedDate', 'Title', 'Summary', 'TestTopic', [SELECT NamespacePrefix FROM Organization].NamespacePrefix);
        Test.stopTest();

        CommunityArticleComponentCtrlTestHelper.assertArticlesAreCorrect(number_of_articles, returned_articles);
    }

    @isTest static void GetArticlesWithSearchTermAndTopic_Single_Test() {
        Integer number_of_articles = 1;
        CommunityArticleComponentCtrlTestHelper.createValidArticlesAndPublish(number_of_articles);
        Topic test_topic = CommunityArticleComponentCtrlTestHelper.createTopic('TestTopic');
        CommunityArticleComponentCtrlTestHelper.createTopicAssignments(Database.query('SELECT KnowledgeArticleId FROM ' + CommunityArticleComponentCtrlTestHelper.getKnowledgeObjectNameWithNamespace()), test_topic);

        Test.startTest();
        List<CommunityArticleComponentController.SingleArticleInfo> returned_articles = CommunityArticleComponentController.getArticlesWithSearchTermAndTopic('TestTitle', 'ASC', 'Title, Summary', 'Title', 'FirstPublishedDate', 'Title', 'Summary', 'TestTopic', [SELECT NamespacePrefix FROM Organization].NamespacePrefix);
        Test.stopTest();

        CommunityArticleComponentCtrlTestHelper.assertArticlesAreCorrect(number_of_articles, returned_articles);
    }

    @isTest static void GetArticlesWithSearchTermAndTopic_WrongTopic_Test() {
        Integer number_of_articles = 3;
        CommunityArticleComponentCtrlTestHelper.createValidArticlesAndPublish(number_of_articles);
        Topic test_topic = CommunityArticleComponentCtrlTestHelper.createTopic('TestTopic');
        Topic wrong_topic = CommunityArticleComponentCtrlTestHelper.createTopic('WrongTopic');
        CommunityArticleComponentCtrlTestHelper.createTopicAssignments(Database.query('SELECT KnowledgeArticleId FROM ' + CommunityArticleComponentCtrlTestHelper.getKnowledgeObjectNameWithNamespace()), test_topic);

        Test.startTest();
        List<CommunityArticleComponentController.SingleArticleInfo> returned_articles = CommunityArticleComponentController.getArticlesWithSearchTermAndTopic('TestTitle', 'ASC', 'Title, Summary', 'Title', 'FirstPublishedDate', 'Title', 'Summary', 'WrongTopic', [SELECT NamespacePrefix FROM Organization].NamespacePrefix);
        Test.stopTest();

        System.assertEquals(0, returned_articles.size());
    }

    @isTest static void GetArticlesWithSearchTermAndTopic_WrongKeyword_Test() {
        Integer number_of_articles = 3;
        CommunityArticleComponentCtrlTestHelper.createValidArticlesAndPublish(number_of_articles);
        Topic test_topic = CommunityArticleComponentCtrlTestHelper.createTopic('TestTopic');
        CommunityArticleComponentCtrlTestHelper.createTopicAssignments(Database.query('SELECT KnowledgeArticleId FROM ' + CommunityArticleComponentCtrlTestHelper.getKnowledgeObjectNameWithNamespace()), test_topic);

        Test.startTest();
        List<CommunityArticleComponentController.SingleArticleInfo> returned_articles = CommunityArticleComponentController.getArticlesWithSearchTermAndTopic('WrongKeyword', 'ASC', 'Title, Summary', 'Title', 'FirstPublishedDate', 'Title', 'Summary', 'TestTopic', [SELECT NamespacePrefix FROM Organization].NamespacePrefix);
        Test.stopTest();

        System.assertEquals(0, returned_articles.size());
    }

    @isTest static void GetArticlesWithSearchTermAndTopic_SomeArticlesFoundWithTopic_Test() {
        Integer number_of_articles = 2;
        CommunityArticleComponentCtrlTestHelper.createValidArticlesAndPublish(number_of_articles);
        List<SObject> articles = Database.query('SELECT KnowledgeArticleId FROM ' + CommunityArticleComponentCtrlTestHelper.getKnowledgeObjectNameWithNamespace() + ' ORDER BY Title');
        Topic first_topic = CommunityArticleComponentCtrlTestHelper.createTopic('FirstTopic');
        Topic second_topic = CommunityArticleComponentCtrlTestHelper.createTopic('SecondTopic');
        CommunityArticleComponentCtrlTestHelper.createTopicAssignment(articles[0], first_topic);
        CommunityArticleComponentCtrlTestHelper.createTopicAssignment(articles[1], second_topic);

        Test.startTest();
        List<CommunityArticleComponentController.SingleArticleInfo> returned_articles = CommunityArticleComponentController.getArticlesWithSearchTermAndTopic('TestTitle', 'ASC', 'Title, Summary', 'Title', 'FirstPublishedDate', 'Title', 'Summary', 'FirstTopic', [SELECT NamespacePrefix FROM Organization].NamespacePrefix);
        Test.stopTest();

        CommunityArticleComponentCtrlTestHelper.assertArticlesAreCorrect(1, returned_articles);
    }

    @isTest static void GetArticlesWithSearchTermAndTopic_SomeArticlesFoundWithKeyword_Test() {
        Integer number_of_articles = 2;
        CommunityArticleComponentCtrlTestHelper.createValidArticlesAndPublish(number_of_articles);
        Topic test_topic = CommunityArticleComponentCtrlTestHelper.createTopic('TestTopic');
        CommunityArticleComponentCtrlTestHelper.createTopicAssignments(Database.query('SELECT KnowledgeArticleId FROM ' + CommunityArticleComponentCtrlTestHelper.getKnowledgeObjectNameWithNamespace() + ' ORDER BY Title'), test_topic);

        Test.startTest();
        List<CommunityArticleComponentController.SingleArticleInfo> returned_articles = CommunityArticleComponentController.getArticlesWithSearchTermAndTopic('TestTitle0', 'ASC', 'Title, Summary', 'Title', 'FirstPublishedDate', 'Title', 'Summary', 'TestTopic', [SELECT NamespacePrefix FROM Organization].NamespacePrefix);
        Test.stopTest();

        CommunityArticleComponentCtrlTestHelper.assertArticlesAreCorrect(1, returned_articles);
    }
    
    @isTest static void GetArticlesWithSearchTermAndTopic_NoAccessibleFields_Test() {
        Integer number_of_articles = 3;
        CommunityArticleComponentCtrlTestHelper.createValidArticlesAndPublish(number_of_articles);
        Topic test_topic = CommunityArticleComponentCtrlTestHelper.createTopic('TestTopic');
        CommunityArticleComponentCtrlTestHelper.createTopicAssignments(Database.query('SELECT KnowledgeArticleId FROM ' + CommunityArticleComponentCtrlTestHelper.getKnowledgeObjectNameWithNamespace()), test_topic);

        Test.startTest();
        List<CommunityArticleComponentController.SingleArticleInfo> returned_articles = CommunityArticleComponentController.getArticlesWithSearchTermAndTopic('TestTitle', 'ASC', 'Title, Summary', 'Title', 'InvalidDate', 'InvalidTitle', 'InvalidSummary', 'TestTopic', [SELECT NamespacePrefix FROM Organization].NamespacePrefix);
        Test.stopTest();

        System.assertEquals(1, returned_articles.size());
        System.assertEquals('You do not have the required field permissions.', returned_articles[0].ErrorMessage);
    }

    @isTest static void GetTopics_Test() {
        List<Topic> topics = new List<Topic>();
        Integer number_of_topics = 5;
        for (Integer i = 0; i < number_of_topics; i++) {
            topics.add(new Topic(Name = 'TestTopic' + i));
        }
        Database.SaveResult[] results = Database.insert(topics);
        for (Database.SaveResult result : results) {
            System.assert(result.isSuccess());
        }

        Test.startTest();
        List<String> returned_topics = CommunityArticleComponentController.getTopics().Topics;
        Test.stopTest();

        System.assertEquals(5, returned_topics.size());
        for (Integer i = 0; i < number_of_topics; i++) {
            System.assertEquals('TestTopic' + i, returned_topics[i]);
        }
    }

    @isTest static void GetTopics_Single_Test() {
        Database.SaveResult result = Database.insert(new Topic(Name = 'TestTopic'));
        System.assert(result.isSuccess());

        Test.startTest();
        List<String> returned_topics = CommunityArticleComponentController.getTopics().Topics;
        Test.stopTest();

        System.assertEquals(1, returned_topics.size());
        System.assertEquals('TestTopic', returned_topics[0]);
    }

    @isTest static void SearchByTopic_Test() {
        Integer number_of_articles = 5;
        List<SObject> list_of_articles = CommunityArticleComponentCtrlTestHelper.createValidArticlesAndPublish(number_of_articles);

        List<Topic> test_topic = CommunityArticleComponentCtrlTestHelper.insertTopics(1);
        CommunityArticleComponentCtrlTestHelper.createTopicAssignments(list_of_articles, test_topic[0]);

        Test.startTest();
        List<CommunityArticleComponentController.SingleArticleInfo> returned_articles = CommunityArticleComponentController.searchByTopic('TestTopic0', 'ASC', 'Title', 'FirstPublishedDate', 'Title', 'Summary', [SELECT NamespacePrefix FROM Organization].NamespacePrefix);
        Test.stopTest();

        CommunityArticleComponentCtrlTestHelper.assertArticlesAreCorrect(number_of_articles, returned_articles);
    }

    @isTest static void SearchByTopic_WithNoArticles_Test() {
        Topic test_topic = CommunityArticleComponentCtrlTestHelper.createTopic('TestTopic');

        Test.startTest();
        List<CommunityArticleComponentController.SingleArticleInfo> returned_articles = CommunityArticleComponentController.searchByTopic('TestTopic', 'ASC', 'Title', 'FirstPublishedDate', 'Title', 'Summary', [SELECT NamespacePrefix FROM Organization].NamespacePrefix);
        Test.stopTest();

        System.assertEquals('No articles found under this topic' , returned_articles[0].ErrorMessage);
    }

    @isTest static void SearchByTopic_WithWrongTopic_Test() {
        Integer number_of_articles = 5;
        List<SObject> list_of_articles = CommunityArticleComponentCtrlTestHelper.createValidArticlesAndPublish(number_of_articles);

        List<Topic> test_topic = CommunityArticleComponentCtrlTestHelper.insertTopics(1);
        CommunityArticleComponentCtrlTestHelper.createTopicAssignments(list_of_articles, test_topic[0]);

        Test.startTest();
        List<CommunityArticleComponentController.SingleArticleInfo> returned_articles = CommunityArticleComponentController.searchByTopic('WrongTopic', 'ASC', 'Title', 'FirstPublishedDate', 'Title', 'Summary', [SELECT NamespacePrefix FROM Organization].NamespacePrefix);
        Test.stopTest();

        System.assertEquals('No articles found under this topic' , returned_articles[0].ErrorMessage);
    }

    @isTest static void SearchByTopic_SomeWrongTopics_Test() {
        Integer number_of_articles = 2;
        List<SObject> list_of_articles = CommunityArticleComponentCtrlTestHelper.createValidArticlesAndPublish(number_of_articles);

        List<Topic> test_topics = CommunityArticleComponentCtrlTestHelper.createTopics(new List<String>{'TestTopic', 'WrongTopic'});
        CommunityArticleComponentCtrlTestHelper.createTopicAssignment(list_of_articles[0], test_topics[0]);
        CommunityArticleComponentCtrlTestHelper.createTopicAssignment(list_of_articles[1], test_topics[1]);

        Test.startTest();
        List<CommunityArticleComponentController.SingleArticleInfo> returned_articles = CommunityArticleComponentController.searchByTopic('TestTopic', 'ASC', 'Title', 'FirstPublishedDate', 'Title', 'Summary', [SELECT NamespacePrefix FROM Organization].NamespacePrefix);
        Test.stopTest();

        CommunityArticleComponentCtrlTestHelper.assertArticlesAreCorrect(1, returned_articles);
    }
    
    @isTest static void SearchByTopic_NoAccessibleFields_Test() {
        Integer number_of_articles = 5;
        List<SObject> list_of_articles = CommunityArticleComponentCtrlTestHelper.createValidArticlesAndPublish(number_of_articles);

        List<Topic> test_topic = CommunityArticleComponentCtrlTestHelper.insertTopics(1);
        CommunityArticleComponentCtrlTestHelper.createTopicAssignments(list_of_articles, test_topic[0]);

        Test.startTest();
        List<CommunityArticleComponentController.SingleArticleInfo> returned_articles = CommunityArticleComponentController.searchByTopic('TestTopic0', 'ASC', 'Title', 'InvalidDate', 'InvalidTitle', 'InvalidSummary', [SELECT NamespacePrefix FROM Organization].NamespacePrefix);
        Test.stopTest();

        System.assertEquals(1, returned_articles.size());
        System.assertEquals('You do not have the required field permissions.', returned_articles[0].ErrorMessage);
    }

    @isTest static void GetFieldsToSearchBy_Test() {
        String terms = 'Title, Summary, FirstPublishedDate';
        Test.startTest();
        List<String> term_list = CommunityArticleComponentController.getFieldsToSearchBy(terms, [SELECT NamespacePrefix FROM Organization].NamespacePrefix);
        Test.stopTest();
        System.assertEquals(3, term_list.size());
        System.assertEquals(term_list[0], 'Title');
        System.assertEquals(term_list[1], 'Summary');
        System.assertEquals(term_list[2], 'FirstPublishedDate');
    }

    @isTest static void GetFieldsToSearchBy_SingleField_Test() {
        String terms = 'Title';
        Test.startTest();
        List<String> term_list = CommunityArticleComponentController.getFieldsToSearchBy(terms, [SELECT NamespacePrefix FROM Organization].NamespacePrefix);
        Test.stopTest();
        System.assertEquals(1, term_list.size());
        System.assertEquals(term_list[0], 'Title');
    }

    @isTest static void GetFieldsToSearchBy_NoFields_Test() {
        String terms = '';
        Test.startTest();
        List<String> term_list = CommunityArticleComponentController.getFieldsToSearchBy(terms, [SELECT NamespacePrefix FROM Organization].NamespacePrefix);
        Test.stopTest();
        System.assert(term_list.isEmpty());
    }

    @isTest static void GetAccessibleKnowledgeFields_Test() {
        Test.startTest();
        Set<String> accessible_fields = CommunityArticleComponentController.getAccessibleKnowledgeFields([SELECT NamespacePrefix FROM Organization].NamespacePrefix);
        Test.stopTest();
        System.assert(accessible_fields.contains('Id'));
    }

    @isTest static void GetAccessibleTopicFields_Test() {
        Test.startTest();
        Set<String> accessible_fields = CommunityArticleComponentController.getAccessibleTopicFields();
        Test.stopTest();
        System.assert(accessible_fields.contains('Id'));
    }

    @isTest static void GetAccessibleTopicAccessibleFields_Test() {
        Test.startTest();
        Set<String> accessible_fields = CommunityArticleComponentController.getAccessibleTopicAssignmentFields();
        Test.stopTest();
        System.assert(accessible_fields.contains('Id'));
    }

    @isTest static void CreateSearchQuery_Test() {
        String search_term = 'searchTerm';
        String sort_order = 'ASC';
        List<String> fields = new List<String>{'Title', 'Summary'};
        String sort_field = 'FirstPublishedDate';
        String date_field = 'FirstPublishedDate';

        Test.startTest();
        String query = CommunityArticleComponentController.createSearchQuery(search_term, sort_order, fields, sort_field, date_field, null, 'Title, Summary, FirstPublishedDate', false, [SELECT NamespacePrefix FROM Organization].NamespacePrefix);
        Test.stopTest();
        System.assertEquals('SELECT Title, Summary, FirstPublishedDate FROM ' + CommunityArticleComponentCtrlTestHelper.getKnowledgeObjectNameWithNamespace() + ' WHERE (Title LIKE: search_key OR Summary LIKE: search_key) AND PublishStatus = \'Online\' ORDER BY FirstPublishedDate ASC', query);
    }

    @isTest static void CreateSearchQuery_WithArticleIds_Test() {
        String search_term = 'searchTerm';
        String sort_order = 'ASC';
        List<String> fields = new List<String>{'Title', 'Summary'};
        String sort_field = 'FirstPublishedDate';
        String date_field = 'FirstPublishedDate';

        Integer number_of_articles = 3;
        List<SObject> list_of_articles = CommunityArticleComponentCtrlTestHelper.createValidArticles(number_of_articles);
        List<SObject> knowledge_articles = Database.query('SELECT KnowledgeArticleId FROM ' + CommunityArticleComponentCtrlTestHelper.getKnowledgeObjectNameWithNamespace());
        List<Id> knowledge_article_ids = new List<Id>();
        for (Integer i = 0; i < number_of_articles; i++) {
            knowledge_article_ids.add((Id)knowledge_articles[i].get('KnowledgeArticleId'));
        }

        Test.startTest();
        String query = CommunityArticleComponentController.createSearchQuery(search_term, sort_order, fields, sort_field, date_field, knowledge_article_ids, 'Title, Summary, FirstPublishedDate', true, [SELECT NamespacePrefix FROM Organization].NamespacePrefix);
        Test.stopTest();
        System.assertEquals('SELECT Title, Summary, FirstPublishedDate FROM ' + CommunityArticleComponentCtrlTestHelper.getKnowledgeObjectNameWithNamespace()  + ' WHERE (Title LIKE: search_key OR Summary LIKE: search_key) AND PublishStatus = \'Online\' AND Id IN: article_IDs ORDER BY FirstPublishedDate ASC', query);
    }

    @isTest static void MakeQueryWithString_AllArticles_Test() {
        integer number_of_articles = 5;
        List<SObject> list_of_articles = CommunityArticleComponentCtrlTestHelper.createValidArticlesAndPublish(number_of_articles);

        String query = 'SELECT Title, Summary, FirstPublishedDate FROM ' + CommunityArticleComponentCtrlTestHelper.getKnowledgeObjectNameWithNamespace() + ' WHERE PublishStatus = \'Online\' ORDER BY Title ASC';

        Test.startTest();
        List<CommunityArticleComponentController.SingleArticleInfo> returned_articles = CommunityArticleComponentController.MakeQueryWithString(query, null, null, 'FirstPublishedDate', 'Title', 'Summary');
        Test.stopTest();

        System.assertEquals(number_of_articles, returned_articles.size());
        for (Integer i = 0; i < number_of_articles; i++) {
            System.assertEquals('TestTitle' + i, returned_articles[i].TitleField);
            System.assertEquals('TestSummary' + i, returned_articles[i].SummaryField);
        }
    }

    @isTest static void MakeQueryWithString_Single_Test() {
        integer number_of_articles = 1;
        List<SObject> list_of_articles = CommunityArticleComponentCtrlTestHelper.createValidArticlesAndPublish(number_of_articles);

        String query = 'SELECT Title, Summary, FirstPublishedDate FROM ' + CommunityArticleComponentCtrlTestHelper.getKnowledgeObjectNameWithNamespace() + ' WHERE PublishStatus = \'Online\' ORDER BY Title ASC';

        Test.startTest();
        List<CommunityArticleComponentController.SingleArticleInfo> returned_articles = CommunityArticleComponentController.MakeQueryWithString(query, null, null, 'FirstPublishedDate', 'Title', 'Summary');
        Test.stopTest();

        System.assertEquals(number_of_articles, returned_articles.size());
        for (Integer i = 0; i < number_of_articles; i++) {
            System.assertEquals('TestTitle' + i, returned_articles[i].TitleField);
            System.assertEquals('TestSummary' + i, returned_articles[i].SummaryField);
        }
    }

    @isTest static void MakeQueryWithString_SearchWithKeyword_Test() {
        integer number_of_articles = 3;
        List<SObject> list_of_articles = CommunityArticleComponentCtrlTestHelper.createValidArticlesAndPublish(number_of_articles);

        String query = 'SELECT Title, Summary, FirstPublishedDate FROM ' + CommunityArticleComponentCtrlTestHelper.getKnowledgeObjectNameWithNamespace() + ' WHERE (Title LIKE: search_key OR Summary LIKE: search_key) AND PublishStatus = \'Online\' ORDER BY Title ASC';

        Test.startTest();
        List<CommunityArticleComponentController.SingleArticleInfo> returned_articles = CommunityArticleComponentController.MakeQueryWithString(query, '%Test%', null, 'FirstPublishedDate', 'Title', 'Summary');
        Test.stopTest();

        System.assertEquals(number_of_articles, returned_articles.size());
        for (Integer i = 0; i < number_of_articles; i++) {
            System.assertEquals('TestTitle' + i, returned_articles[i].TitleField);
            System.assertEquals('TestSummary' + i, returned_articles[i].SummaryField);
        }
    }

    @isTest static void MakeQueryWithString_SearchWithWrongKeyword_Test() {
        integer number_of_articles = 3;
        List<SObject> list_of_articles = CommunityArticleComponentCtrlTestHelper.createValidArticlesAndPublish(number_of_articles);

        String query = 'SELECT Title, Summary, FirstPublishedDate FROM ' + CommunityArticleComponentCtrlTestHelper.getKnowledgeObjectNameWithNamespace() + ' WHERE (Title LIKE: search_key OR Summary LIKE: search_key) AND PublishStatus = \'Online\' ORDER BY Title ASC';

        Test.startTest();
        List<CommunityArticleComponentController.SingleArticleInfo> returned_articles = CommunityArticleComponentController.MakeQueryWithString(query, '%Wrong%', null, 'FirstPublishedDate', 'Title', 'Summary');
        Test.stopTest();

        System.assertEquals(0, returned_articles.size());
    }

    @isTest static void MakeQueryWithString_SearchWithArticleIDs_Test() {
        integer number_of_articles = 3;
        CommunityArticleComponentCtrlTestHelper.createValidArticlesAndPublish(number_of_articles);
        List<ID> article_IDs = CommunityArticleComponentCtrlTestHelper.getKnowledgeArticleIDs(Database.query('SELECT Id FROM ' + CommunityArticleComponentCtrlTestHelper.getKnowledgeObjectNameWithNamespace()));

        String query = 'SELECT Title, Summary, FirstPublishedDate FROM ' + CommunityArticleComponentCtrlTestHelper.getKnowledgeObjectNameWithNamespace() + ' WHERE PublishStatus = \'Online\' AND Id IN: article_IDs ORDER BY Title ASC';

        Test.startTest();
        List<CommunityArticleComponentController.SingleArticleInfo> returned_articles = CommunityArticleComponentController.MakeQueryWithString(query, null, article_IDs, 'FirstPublishedDate', 'Title', 'Summary');
        Test.stopTest();

        System.assertEquals(number_of_articles, returned_articles.size());
        for (Integer i = 0; i < number_of_articles; i++) {
            System.assertEquals('TestTitle' + i, returned_articles[i].TitleField);
            System.assertEquals('TestSummary' + i, returned_articles[i].SummaryField);
        }
    }

    @isTest static void MakeQueryWithString_SearchWithTopicAndKeyword_Test() {
        integer number_of_articles = 3;
        CommunityArticleComponentCtrlTestHelper.createValidArticlesAndPublish(number_of_articles);
        List<ID> article_IDs = CommunityArticleComponentCtrlTestHelper.getKnowledgeArticleIDs(Database.query('SELECT Id FROM ' + CommunityArticleComponentCtrlTestHelper.getKnowledgeObjectNameWithNamespace()));

        String query = 'SELECT Title, Summary, FirstPublishedDate FROM ' + CommunityArticleComponentCtrlTestHelper.getKnowledgeObjectNameWithNamespace() + ' WHERE (Title LIKE: search_key OR Summary LIKE: search_key) AND PublishStatus = \'Online\' AND Id IN: article_IDs ORDER BY Title DESC';

        Test.startTest();
        List<CommunityArticleComponentController.SingleArticleInfo> returned_articles = CommunityArticleComponentController.MakeQueryWithString(query, '%TestTitle0%', article_IDs, 'FirstPublishedDate', 'Title', 'Summary');
        Test.stopTest();

        System.assertEquals(1, returned_articles.size());
        System.assertEquals('TestTitle0', returned_articles[0].TitleField);
        System.assertEquals('TestSummary0', returned_articles[0].SummaryField);
    }

    @isTest static void MakeQueryWithString_QueryException_Test() {
        integer number_of_articles = 3;
        CommunityArticleComponentCtrlTestHelper.createValidArticlesAndPublish(number_of_articles);
        List<ID> article_IDs = CommunityArticleComponentCtrlTestHelper.getKnowledgeArticleIDs(Database.query('SELECT Id FROM ' + CommunityArticleComponentCtrlTestHelper.getKnowledgeObjectNameWithNamespace()));

        String query = 'SELECT Title, Summary, FirstPublishedDate FROM ' + CommunityArticleComponentCtrlTestHelper.getKnowledgeObjectNameWithNamespace() + ' WHERE (Title LIKE: search_key OR Summary LIKE: search_key) AND PublishStatus = \'Online\' AND KnowledgeArticleId IN: ' + article_IDs + ' ORDER BY Title DESC';

        Test.startTest();
        List<CommunityArticleComponentController.SingleArticleInfo> returned_articles = CommunityArticleComponentController.MakeQueryWithString(query, '%TestTitle0%', article_IDs, 'FirstPublishedDate', 'Title', 'Summary');
        Test.stopTest();

        System.assertEquals(null, returned_articles[0].Article);
        System.assertEquals('Only variable references are allowed in dynamic SOQL/SOSL.', returned_articles[0].ErrorMessage);
    }

    @isTest static void GetArticleIDsUsingTopicName_Test() {
        Integer number_of_articles = 5;
        CommunityArticleComponentCtrlTestHelper.createValidArticlesAndPublish(number_of_articles);
        List<SObject> articles = Database.query('SELECT KnowledgeArticleId FROM ' + CommunityArticleComponentCtrlTestHelper.getKnowledgeObjectNameWithNamespace() + ' ORDER BY KnowledgeArticleId ASC');
        Topic test_topic = CommunityArticleComponentCtrlTestHelper.createTopic('TestTopic');

        CommunityArticleComponentCtrlTestHelper.createTopicAssignments(articles, test_topic);

        Test.startTest();
        List<ID> article_IDs = CommunityArticleComponentController.GetArticleIDsUsingTopicName('TestTopic');
        Test.stopTest();

        CommunityArticleComponentCtrlTestHelper.assertArticleIDsAreCorrect(articles, article_IDs);
    }

    @isTest static void GetArticleIDsUsingTopicName_Single_Test() {
        Integer number_of_articles = 1;
        CommunityArticleComponentCtrlTestHelper.createValidArticlesAndPublish(number_of_articles);
        List<SObject> articles = Database.query('SELECT KnowledgeArticleId FROM ' + CommunityArticleComponentCtrlTestHelper.getKnowledgeObjectNameWithNamespace());
        Topic test_topic = CommunityArticleComponentCtrlTestHelper.createTopic('TestTopic');

        CommunityArticleComponentCtrlTestHelper.createTopicAssignments(articles, test_topic);

        Test.startTest();
        List<ID> article_IDs = CommunityArticleComponentController.GetArticleIDsUsingTopicName('TestTopic');
        Test.stopTest();

        CommunityArticleComponentCtrlTestHelper.assertArticleIDsAreCorrect(articles, article_IDs);
    }

    @isTest static void GetArticleIDsUsingTopicName_NoArticles_Test() {
        Topic test_topic = CommunityArticleComponentCtrlTestHelper.createTopic('TestTopic');

        Test.startTest();
        List<ID> article_IDs = CommunityArticleComponentController.GetArticleIDsUsingTopicName('TestTopic');
        Test.stopTest();

        System.assertEquals(0, article_IDs.size());
    }

    @isTest static void GetArticleIDsUsingTopicName_WrongTopic_Test() {
        Integer number_of_articles = 5;
        CommunityArticleComponentCtrlTestHelper.createValidArticlesAndPublish(number_of_articles);
        List<SObject> articles = Database.query('SELECT KnowledgeArticleId FROM ' + CommunityArticleComponentCtrlTestHelper.getKnowledgeObjectNameWithNamespace());
        Topic test_topic = CommunityArticleComponentCtrlTestHelper.createTopic('TestTopic');
        Topic wrong_topic = CommunityArticleComponentCtrlTestHelper.createTopic('WrongTopic');
        CommunityArticleComponentCtrlTestHelper.createTopicAssignments(articles, wrong_topic);

        Test.startTest();
        List<ID> article_IDs = CommunityArticleComponentController.GetArticleIDsUsingTopicName('TestTopic');
        Test.stopTest();

        System.assertEquals(0, article_IDs.size());
    }

    @isTest static void GetArticleIDsUsingTopicName_SomeArticlesFound_Test() {
        Integer number_of_articles = 2;
        CommunityArticleComponentCtrlTestHelper.createValidArticlesAndPublish(number_of_articles);
        List<SObject> articles = Database.query('SELECT KnowledgeArticleId FROM ' + CommunityArticleComponentCtrlTestHelper.getKnowledgeObjectNameWithNamespace());
        Topic first_topic = CommunityArticleComponentCtrlTestHelper.createTopic('FirstTopic');
        Topic second_topic = CommunityArticleComponentCtrlTestHelper.createTopic('SecondTopic');
        CommunityArticleComponentCtrlTestHelper.createTopicAssignment(articles[0], first_topic);
        CommunityArticleComponentCtrlTestHelper.createTopicAssignment(articles[1], second_topic);

        Test.startTest();
        List<ID> article_IDs = CommunityArticleComponentController.GetArticleIDsUsingTopicName('FirstTopic');
        Test.stopTest();

        CommunityArticleComponentCtrlTestHelper.assertArticleIDsAreCorrect(new List<SObject>{articles[0]}, article_IDs);
    }

    @isTest static void GetTopicFromName_Test() {
        Topic test_topic =  new Topic(Name = 'TestTopic');
        Database.SaveResult result = Database.insert(test_topic);
        System.assert(result.isSuccess());

        Test.startTest();
        Id topic_ID = CommunityArticleComponentController.getTopicFromName('TestTopic');
        Test.stopTest();

        System.assertEquals(test_topic.Id, topic_ID);
    }

    @isTest static void GetTopicFromName_Fail_Test() {
        Topic test_topic =  new Topic(Name = 'TestTopic');
        Database.SaveResult result = Database.insert(test_topic);
        System.assert(result.isSuccess());

        Test.startTest();
        Id topic_ID = CommunityArticleComponentController.getTopicFromName('WrongTest');
        Test.stopTest();

        System.assertEquals(null, topic_ID);
    }

    @isTest static void GetArticlesIDListFromTopicID_Test() {
        CommunityArticleComponentCtrlTestHelper.createValidArticlesAndPublish(5);
        List<SObject> articles = Database.query('SELECT KnowledgeArticleId FROM ' + CommunityArticleComponentCtrlTestHelper.getKnowledgeObjectNameWithNamespace() + ' ORDER BY KnowledgeArticleId ASC');
        Topic test_topic = CommunityArticleComponentCtrlTestHelper.createTopic('TestTopic');
        CommunityArticleComponentCtrlTestHelper.createTopicAssignments(articles, test_topic);

        Test.startTest();
        List<ID> article_IDs = CommunityArticleComponentController.getArticlesIDListFromTopicID(test_topic.Id);
        Test.stopTest();

        CommunityArticleComponentCtrlTestHelper.assertArticleIDsAreCorrect(articles, article_IDs);
    }

    @isTest static void GetArticlesIDListFromTopicID_Single_Test() {
        CommunityArticleComponentCtrlTestHelper.createValidArticlesAndPublish(1);
        List<SObject> articles = Database.query('SELECT KnowledgeArticleId FROM ' + CommunityArticleComponentCtrlTestHelper.getKnowledgeObjectNameWithNamespace() + ' LIMIT 1');
        Topic test_topic = CommunityArticleComponentCtrlTestHelper.createTopic('TestTopic');
        CommunityArticleComponentCtrlTestHelper.createTopicAssignments(articles, test_topic);

        Test.startTest();
        List<ID> article_IDs = CommunityArticleComponentController.getArticlesIDListFromTopicID(test_topic.Id);
        Test.stopTest();

        CommunityArticleComponentCtrlTestHelper.assertArticleIDsAreCorrect(articles, article_IDs);
    }

    @isTest static void GetArticlesIDListFromTopicID_NoArticles_Test() {
        Topic test_topic = CommunityArticleComponentCtrlTestHelper.createTopic('TestTopic');

        Test.startTest();
        List<ID> article_IDs = CommunityArticleComponentController.getArticlesIDListFromTopicID(test_topic.Id);
        Test.stopTest();

        System.assertEquals(0, article_IDs.size());
    }

    @isTest static void GetArticlesIDListFromTopicID_WrongTopic_Test() {
        CommunityArticleComponentCtrlTestHelper.createValidArticlesAndPublish(5);
        List<SObject> articles = Database.query('SELECT KnowledgeArticleId FROM ' + CommunityArticleComponentCtrlTestHelper.getKnowledgeObjectNameWithNamespace());
        Topic test_topic = CommunityArticleComponentCtrlTestHelper.createTopic('TestTopic');
        Topic wrong_topic = CommunityArticleComponentCtrlTestHelper.createTopic('WrongTopic');
        CommunityArticleComponentCtrlTestHelper.createTopicAssignments(articles, wrong_topic);

        Test.startTest();
        List<ID> article_IDs = CommunityArticleComponentController.getArticlesIDListFromTopicID(test_topic.Id);
        Test.stopTest();

        System.assertEquals(0, article_IDs.size());
    }

    @isTest static void GetArticlesIDListFromTopicID_SomeArticlesFound_Test() {
        CommunityArticleComponentCtrlTestHelper.createValidArticlesAndPublish(2);
        List<SObject> articles = Database.query('SELECT KnowledgeArticleId FROM ' + CommunityArticleComponentCtrlTestHelper.getKnowledgeObjectNameWithNamespace());
        Topic first_topic = CommunityArticleComponentCtrlTestHelper.createTopic('FirstTopic');
        Topic second_topic = CommunityArticleComponentCtrlTestHelper.createTopic('SecondTopic');
        CommunityArticleComponentCtrlTestHelper.createTopicAssignment(articles[0], first_topic);
        CommunityArticleComponentCtrlTestHelper.createTopicAssignment(articles[1], second_topic);

        Test.startTest();
        List<ID> article_IDs = CommunityArticleComponentController.getArticlesIDListFromTopicID(first_topic.Id);
        Test.stopTest();

        CommunityArticleComponentCtrlTestHelper.assertArticleIDsAreCorrect(new List<SObject>{articles[0]}, article_IDs);
    }

    @isTest static void GetTopicsAssignedToArticle_Test() {
        List<SObject> list_of_articles = CommunityArticleComponentCtrlTestHelper.createValidArticlesAndPublish(1);

        Topic topic_one = new Topic(Name = 'TestTopic');
        Topic topic_two = new Topic(Name = 'SecondaryTopic');
        Database.SaveResult[] topic_result = Database.insert(new List<Topic>{topic_one, topic_two});
        for (Integer i = 0; i < topic_result.size(); i++) {
            System.assert(topic_result[i].isSuccess());
        }

        CommunityArticleComponentCtrlTestHelper.createTopicAssignment(list_of_articles[0], topic_one);
        CommunityArticleComponentCtrlTestHelper.createTopicAssignment(list_of_articles[0], topic_two);

        Test.startTest();
        List<String> returned_topics = CommunityArticleComponentController.getTopicsAssignedToArticle(list_of_articles[0].Id);
        Test.stopTest();

        System.assertEquals(2, returned_topics.size());
        System.assertEquals('TestTopic', returned_topics[0]);
        System.assertEquals('SecondaryTopic', returned_topics[1]);
    }

    @isTest static void GetTopicsAssignedToArticle_NoTopics_Test() {
        List<SObject> list_of_articles = CommunityArticleComponentCtrlTestHelper.createValidArticlesAndPublish(1);

        Test.startTest();
        List<String> returned_topics = CommunityArticleComponentController.getTopicsAssignedToArticle(list_of_articles[0].Id);
        Test.stopTest();

        System.assertEquals(0, returned_topics.size());
    }

    @isTest static void GetTopicsFromTopicIDs_Test() {
        Topic topic_one = new Topic(Name = 'TestTopic');
        Topic topic_two = new Topic(Name = 'SecondaryTopic');
        Database.SaveResult[] topic_result = Database.insert(new List<Topic>{topic_one, topic_two});
        for (Integer i = 0; i < topic_result.size(); i++) {
            System.assert(topic_result[i].isSuccess());
        }

        Test.startTest();
        List<Topic> returned_topics = CommunityArticleComponentController.getTopicsFromTopicIDs(new List<ID>{topic_one.Id, topic_two.Id});
        Test.stopTest();

        System.assertEquals(2, returned_topics.size());
        System.assertEquals('TestTopic', returned_topics[0].Name);
        System.assertEquals(topic_one.Id, returned_topics[0].Id);
        System.assertEquals('SecondaryTopic', returned_topics[1].Name);
        System.assertEquals(topic_two.Id, returned_topics[1].Id);
    }

    @isTest static void GetTopicsFromTopicIDs_NoTopics_Test() {
        Test.startTest();
        List<Topic> returned_topics = CommunityArticleComponentController.getTopicsFromTopicIDs(new List<ID>());
        Test.stopTest();

        System.assertEquals(0, returned_topics.size());
    }

    @isTest static void CreateTitleSummaryAndDatePartOfQuery_TestTitleAndSummaryAreUnique_Test() {
        Test.startTest();
        String result = CommunityArticleComponentController.createTitleSummaryAndDatePartOfQuery('Title', 'Summary', 'FirstPublishedDate', [SELECT NamespacePrefix FROM Organization].NamespacePrefix);
        Test.stopTest();
        System.assertEquals('Title, Summary, FirstPublishedDate', result);
    }

    @isTest static void CreateTitleSummaryAndDatePartOfQuery_TestTitleAndSummaryMatch_Test() {
        Test.startTest();
        String result = CommunityArticleComponentController.createTitleSummaryAndDatePartOfQuery('Title', 'Title', 'FirstPublishedDate', [SELECT NamespacePrefix FROM Organization].NamespacePrefix);
        Test.stopTest();
        System.assertEquals('Title, FirstPublishedDate', result);
    }

    @isTest static void CreateTitleSummaryAndDatePartOfQuery_TestTitleAndSummaryAreUniqueNoDate_Test() {
        Test.startTest();
        String result = CommunityArticleComponentController.createTitleSummaryAndDatePartOfQuery('Title', 'Summary', 'None', [SELECT NamespacePrefix FROM Organization].NamespacePrefix);
        Test.stopTest();
        System.assertEquals('Title, Summary', result);
    }

    @isTest static void CreateTitleSummaryAndDatePartOfQuery_TestTitleAndSummaryMatchNoDate_Test() {
        Test.startTest();
        String result = CommunityArticleComponentController.createTitleSummaryAndDatePartOfQuery('Title', 'Title', 'None', [SELECT NamespacePrefix FROM Organization].NamespacePrefix);
        Test.stopTest();
        System.assertEquals('Title', result);
    }

    @isTest static void CreateTitleSummaryAndDatePartOfQuery_OnlyDateIsValid_Test() {
        Test.startTest();
        String result = CommunityArticleComponentController.createTitleSummaryAndDatePartOfQuery('InvalidTitle', 'InvalidSummary', 'FirstPublishedDate', [SELECT NamespacePrefix FROM Organization].NamespacePrefix);
        Test.stopTest();
        System.assertEquals('FirstPublishedDate', result);
    }

    @isTest static void CreateTitleSummaryAndDatePartOfQuery_NoValidFields_Test() {
        Test.startTest();
        String result = CommunityArticleComponentController.createTitleSummaryAndDatePartOfQuery('InvalidTitle', 'InvalidSummary', 'None', [SELECT NamespacePrefix FROM Organization].NamespacePrefix);
        Test.stopTest();
        System.assertEquals('', result);
    }

    @isTest static void GetTopicsAssignedToAllArticles_Test() {
        Integer number_of_articles = 5;
        List<SObject> articles = CommunityArticleComponentCtrlTestHelper.createValidArticlesAndPublish(number_of_articles);
        List<SObject> knowledge_articles = Database.query('SELECT Id FROM ' + CommunityArticleComponentCtrlTestHelper.getKnowledgeObjectNameWithNamespace());
        List<Topic> topics = CommunityArticleComponentCtrlTestHelper.createTopics(new List<String>{'TopicOne', 'TopicTwo'});
        CommunityArticleComponentCtrlTestHelper.createTopicAssignments(articles, topics[0]);
        CommunityArticleComponentCtrlTestHelper.createTopicAssignments(articles, topics[1]);

        Test.startTest();
        Map<ID, Set<String>> returned_map = CommunityArticleComponentController.getTopicsAssignedToAllArticles(knowledge_articles);
        Test.stopTest();

        CommunityArticleComponentCtrlTestHelper.assertTopicArticleMapIsCorrect(returned_map, knowledge_articles);
    }

    @isTest static void GetTopicsAssignedToAllArticles_NoArticles_Test() {
        List<SObject> knowledge_articles = new List<SObject>();
        List<Topic> topics = CommunityArticleComponentCtrlTestHelper.createTopics(new List<String>{'TopicOne', 'TopicTwo'});

        Test.startTest();
        Map<ID, Set<String>> returned_map = CommunityArticleComponentController.getTopicsAssignedToAllArticles(knowledge_articles);
        Test.stopTest();

        System.assert(returned_map.isEmpty());
    }

    @isTest static void GetTopicsAssignedToAllArticles_NoTopics_Test() {
        Integer number_of_articles = 5;
        List<SObject> articles = CommunityArticleComponentCtrlTestHelper.createValidArticlesAndPublish(number_of_articles);
        List<SObject> knowledge_articles = Database.query('SELECT Id FROM ' + CommunityArticleComponentCtrlTestHelper.getKnowledgeObjectNameWithNamespace());

        Test.startTest();
        Map<ID, Set<String>> returned_map = CommunityArticleComponentController.getTopicsAssignedToAllArticles(knowledge_articles);
        Test.stopTest();

        System.assert(returned_map.isEmpty());
    }

    @isTest static void GetMapOfTopicIDsAndNames_Test() {
        Integer number_of_articles = 5;
        List<SObject> articles = CommunityArticleComponentCtrlTestHelper.createValidArticlesAndPublish(number_of_articles);
        List<SObject> knowledge_articles = Database.query('SELECT Id FROM ' + CommunityArticleComponentCtrlTestHelper.getKnowledgeObjectNameWithNamespace());
        List<Topic> topics = CommunityArticleComponentCtrlTestHelper.createTopics(new List<String>{'TopicOne', 'TopicTwo'});
        CommunityArticleComponentCtrlTestHelper.createTopicAssignments(articles, topics[0]);
        CommunityArticleComponentCtrlTestHelper.createTopicAssignments(articles, topics[1]);

        Test.startTest();
        Map<Id, String> returned_map = CommunityArticleComponentController.getMapOfTopicIDsAndNames([SELECT TopicId FROM TopicAssignment ORDER BY EntityId]);
        Test.stopTest();

        CommunityArticleComponentCtrlTestHelper.assertMapOfTopicIDsAndNamesIsCorrect(returned_map, topics);
    }

    @isTest static void GetMapOfTopicIDsAndNames_NoTopics_Test() {
        Integer number_of_articles = 5;
        List<SObject> articles = CommunityArticleComponentCtrlTestHelper.createValidArticlesAndPublish(number_of_articles);
        List<SObject> knowledge_articles = Database.query('SELECT Id FROM ' + CommunityArticleComponentCtrlTestHelper.getKnowledgeObjectNameWithNamespace());

        Test.startTest();
        Map<Id, String> returned_map = CommunityArticleComponentController.getMapOfTopicIDsAndNames([SELECT TopicId FROM TopicAssignment ORDER BY EntityId]);
        Test.stopTest();

        System.assert(returned_map.isEmpty());
    }

    @isTest static void CreateListOfArticleInfo_Test() {
        Integer number_of_articles = 5;
        List<SObject> articles = CommunityArticleComponentCtrlTestHelper.createValidArticlesAndPublish(number_of_articles);
        List<SObject> knowledge_articles = Database.query('SELECT Title, Summary, FirstPublishedDate FROM ' + CommunityArticleComponentCtrlTestHelper.getKnowledgeObjectNameWithNamespace() + ' ORDER BY Title');

        Test.startTest();
        List<CommunityArticleComponentController.SingleArticleInfo> returned_article_info = CommunityArticleComponentController.createListOfArticleInfo(knowledge_articles, 'FirstPublishedDate', 'Title', 'Summary');
        Test.stopTest();

        CommunityArticleComponentCtrlTestHelper.assertArticlesAreCorrect(number_of_articles, returned_article_info);
    }

    @isTest static void CreateListOfArticleInfo_WithTopics_Test() {
        Integer number_of_articles = 5;
        List<SObject> articles = CommunityArticleComponentCtrlTestHelper.createValidArticlesAndPublish(number_of_articles);
        List<SObject> knowledge_articles = Database.query('SELECT Title, Summary, FirstPublishedDate FROM ' + CommunityArticleComponentCtrlTestHelper.getKnowledgeObjectNameWithNamespace() + ' ORDER BY Title');
        List<Topic> topics = CommunityArticleComponentCtrlTestHelper.createTopics(new List<String>{'TopicOne', 'TopicTwo'});
        CommunityArticleComponentCtrlTestHelper.createTopicAssignments(articles, topics[0]);
        CommunityArticleComponentCtrlTestHelper.createTopicAssignments(articles, topics[1]);

        Test.startTest();
        List<CommunityArticleComponentController.SingleArticleInfo> returned_article_info = CommunityArticleComponentController.createListOfArticleInfo(knowledge_articles, 'FirstPublishedDate', 'Title', 'Summary');
        Test.stopTest();

        CommunityArticleComponentCtrlTestHelper.assertArticlesAreCorrect(number_of_articles, returned_article_info);
        CommunityArticleComponentCtrlTestHelper.assertArticleInfoHasCorrectTopics(returned_article_info, topics);
    }

    @isTest static void CreateListOfArticleInfo_MissingFields_Test() {
        Integer number_of_articles = 5;
        List<SObject> articles = CommunityArticleComponentCtrlTestHelper.createValidArticlesAndPublish(number_of_articles);
        List<SObject> knowledge_articles = Database.query('SELECT Summary, FirstPublishedDate FROM ' + CommunityArticleComponentCtrlTestHelper.getKnowledgeObjectNameWithNamespace());
        List<Topic> topics = CommunityArticleComponentCtrlTestHelper.createTopics(new List<String>{'TopicOne', 'TopicTwo'});
        CommunityArticleComponentCtrlTestHelper.createTopicAssignments(articles, topics[0]);
        CommunityArticleComponentCtrlTestHelper.createTopicAssignments(articles, topics[1]);

        Test.startTest();
        List<CommunityArticleComponentController.SingleArticleInfo> returned_article_info = CommunityArticleComponentController.createListOfArticleInfo(knowledge_articles, 'FirstPublishedDate', 'Title', 'Summary');
        Test.stopTest();

        CommunityArticleComponentCtrlTestHelper.assertMissingFieldErrorMessageIsCorrect(number_of_articles, returned_article_info);
    }
    
    @isTest static void GetKnowledgeObjectNameWithNamespace() {
        Test.startTest();
        String knowledge_object_name = CommunityArticleComponentController.getKnowledgeObjectNameWithNamespace('Pexlify_Article');
        Test.stopTest();
        System.assertEquals('Pexlify_Article__Knowledge__kav', knowledge_object_name);
    }
    
    @isTest static void GetKnowledgeObjectNameWithNamespace_WithoutNamespace() {
        Test.startTest();
        String knowledge_object_name = CommunityArticleComponentController.getKnowledgeObjectNameWithNamespace('');
        Test.stopTest();
        System.assertEquals('Knowledge__kav', knowledge_object_name);
    }
}