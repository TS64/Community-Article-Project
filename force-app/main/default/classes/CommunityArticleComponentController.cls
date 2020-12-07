public with sharing class CommunityArticleComponentController {
	@AuraEnabled
    public static List<SingleArticleInfo> getArticles(String sort_order, String sort_field, String date_field, String title_field, String summary_field) {
        String fields_to_search = createTitleSummaryAndDatePartOfQuery(title_field, summary_field, date_field);
        if (fields_to_search != '') {
            String knowledge_object_name = getKnowledgeObjectNameWithNamespace();
            String sQuery = 'SELECT ' + fields_to_search + ' FROM ' + knowledge_object_name + ' WHERE PublishStatus = \'Online\' WITH SECURITY_ENFORCED ORDER BY ' + sort_field + ' ' + sort_order;
        	return makeQueryWithString(sQuery, null, null, date_field, title_field, summary_field);
        } else {
            return new List<SingleArticleInfo>{new SingleArticleInfo('You do not have the required field permissions.')};
        }
    }

    @AuraEnabled
    public static SingleArticleInfo getSingleArticle(String article_id, String date_field, String title_field, String summary_field) {
        List<String> topic_names = getTopicsAssignedToArticle(article_id);
        article_id = String.escapeSingleQuotes(article_id);
        String fields_to_search = createTitleSummaryAndDatePartOfQuery(title_field, summary_field, date_field);
        if (fields_to_search != '') {
            String knowledge_object_name = getKnowledgeObjectNameWithNamespace();
            String sQuery = 'SELECT ' + fields_to_search + ' FROM ' + knowledge_object_name +' WHERE PublishStatus = \'Online\' AND Id = \'' + article_id + '\' WITH SECURITY_ENFORCED LIMIT 1';
            System.debug('1- sQuery: ' + sQuery);
            SObject article;
            try {
                article = Database.query(sQuery);
                SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE, new List<SObject>{article}, true);
            } catch (QueryException e) {
                System.debug(e.getMessage());
                return new SingleArticleInfo(e.getMessage());
            }
            return new SingleArticleInfo(article, topic_names, date_field, title_field, summary_field);
        } else {
            return new SingleArticleInfo('You do not have the required field permissions.');
        }
    }

    @AuraEnabled
    public static List<SingleArticleInfo> getArticlesWithSearchTerm(String search_term, String sort_order, String fields_to_search, String sort_field, String date_field, String title_field, String summary_field) {
        String search_key = String.escapeSingleQuotes('%' + search_term + '%');
        String title_summary_date_fields = createTitleSummaryAndDatePartOfQuery(title_field, summary_field, date_field);
        List<String> fields = getFieldsToSearchBy(fields_to_search);
        if (title_summary_date_fields != '' && !fields.isEmpty()) {
            String sQuery = createSearchQuery(search_key, sort_order, fields, sort_field, date_field, null, title_summary_date_fields, false);
            return makeQueryWithString(sQuery, search_key, null, date_field, title_field, summary_field);
        } else {
            return new List<SingleArticleInfo>{new SingleArticleInfo('You do not have the required field permissions.')};
        }
    }

    @AuraEnabled
    public static List<SingleArticleInfo> getArticlesWithSearchTermAndTopic(String search_term, String sort_order, String fields_to_search, String sort_field, String date_field, String title_field, String summary_field, String topic_name) {
        String search_key = String.escapeSingleQuotes('%' + search_term + '%');
        String title_summary_date_fields = createTitleSummaryAndDatePartOfQuery(title_field, summary_field, date_field);
        List<String> fields = getFieldsToSearchBy(fields_to_search);
        if (title_summary_date_fields != '' && !fields.isEmpty()) {
            List<Id> article_IDs = getArticleIDsUsingTopicName(topic_name);
            String sQuery = createSearchQuery(search_key, sort_order, fields, sort_field, date_field, article_IDs, title_summary_date_fields, true);
            return makeQueryWithString(sQuery, search_key, article_IDs, date_field, title_field, summary_field);
        } else {
            return new List<SingleArticleInfo>{new SingleArticleInfo('You do not have the required field permissions.')};
        }
    }

    @AuraEnabled
    public static TopicInfo getTopics() {
        List<Topic> topics = new List<Topic>();
        List<String> topic_names = new List<String>();
        Set<String> accessible_fields = getAccessibleTopicFields();
        if (accessible_fields.contains('Name')) {
            try {
                if (Test.isRunningTest()) {
                    topics = [SELECT Name FROM Topic WITH SECURITY_ENFORCED ORDER BY Name ASC];
                } else {
                    String network_id = Network.getNetworkId();
                    topics = [SELECT Name FROM Topic WHERE NetworkId =: network_id WITH SECURITY_ENFORCED ORDER BY Name ASC];
                }
            } catch (QueryException e) {
                return new TopicInfo(e.getMessage());
            }
            SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE, topics, true);
            for (integer i = 0; i < topics.size(); i++) {
                topic_names.add(topics[i].Name);
            }
        }
        return new TopicInfo(topic_names);
    }

    @AuraEnabled
    public static List<SingleArticleInfo> searchByTopic(String topic_name, String sort_order, String sort_field, String date_field, String title_field, String summary_field) {
        List<Id> article_IDs = getArticleIDsUsingTopicName(topic_name);
        if (article_IDs.isEmpty()) {
            return new List<SingleArticleInfo>{new SingleArticleInfo('No articles found under this topic')};
        }

        String title_summary_date_fields = createTitleSummaryAndDatePartOfQuery(title_field, summary_field, date_field);
        if (title_summary_date_fields != '') {
            String knowledge_object_name = getKnowledgeObjectNameWithNamespace();
            String sQuery = 'SELECT ' + title_summary_date_fields + ' FROM ' + knowledge_object_name + ' WHERE PublishStatus = \'Online\' AND Id IN: article_IDs WITH SECURITY_ENFORCED ORDER BY ' + sort_field + ' ' + sort_order;
        	return makeQueryWithString(sQuery, null, article_IDs, date_field, title_field, summary_field);
        } else {
            return new List<SingleArticleInfo>{new SingleArticleInfo('You do not have the required field permissions.')};
        }
    }

    @TestVisible
    private static List<String> getFieldsToSearchBy(String terms) {
        Set<String> accessible_fields = getAccessibleKnowledgeFields();
        List<String> terms_list = new List<String>();
        terms_list.addAll(terms.split(','));
        Set<String> terms_set = new Set<String>();
        
        for (String str : terms_list) {
            if (accessible_fields.contains(str.trim())) {
                terms_set.add(str.trim());
            }
        }
        terms_list = new List<String>(terms_set);
        return terms_list;
    }

    @TestVisible
    private static Set<String> getAccessibleKnowledgeFields() {
        String knowledge_object_name = getKnowledgeObjectNameWithNamespace();
        try {
            Map<String, Schema.SObjectField> fields = Schema.getGlobalDescribe().get(knowledge_object_name).getDescribe().fields.getMap();
            Set<String> accessible_fields = new Set<String>();
            for(Schema.SObjectField field_reference : fields.values()) {
                Schema.DescribeFieldResult field_result = field_reference.getDescribe();
                if(field_result.isAccessible()) {
                    accessible_fields.add(field_result.getName());
                }
            }
            return accessible_fields;
        } catch (Exception e) {
            System.debug(e.getMessage());
            return new Set<String>();
        }
    }

    @TestVisible
    private static Set<String> getAccessibleTopicFields() {
        Map<String, Schema.SObjectField> fields = Schema.getGlobalDescribe().get('Topic').getDescribe().fields.getMap();
        Set<String> accessible_fields = new Set<String>();
        for(Schema.SObjectField field_reference : fields.values()) {
            Schema.DescribeFieldResult field_result = field_reference.getDescribe();
            if(field_result.isAccessible()) {
                accessible_fields.add(field_result.getName());
            }
        }
        return accessible_fields;
    }

    @TestVisible
    private static Set<String> getAccessibleTopicAssignmentFields() {
        Map<String, Schema.SObjectField> fields = Schema.getGlobalDescribe().get('TopicAssignment').getDescribe().fields.getMap();
        Set<String> accessible_fields = new Set<String>();
        for(Schema.SObjectField field_reference : fields.values()) {
            Schema.DescribeFieldResult field_result = field_reference.getDescribe();
            if(field_result.isAccessible()) {
                accessible_fields.add(field_result.getName());
            }
        }
        return accessible_fields;
    }

    @TestVisible
    private static String createSearchQuery(String search_key, String sort_order, List<String> fields, String sort_field, String date_field, List<Id> article_IDs, String title_summary_date_fields, Boolean search_by_topic) {
        String knowledge_object_name = getKnowledgeObjectNameWithNamespace();
        String sQuery = 'SELECT ' + title_summary_date_fields + ' FROM ' + knowledge_object_name + ' WHERE (';
        for (integer i = 0; i < fields.size() - 1; i++) {
            sQuery += fields[i] + ' LIKE: search_key OR ';
        }
        if (!search_by_topic) {
            sQuery += fields[fields.size() - 1] + ' LIKE: search_key) AND PublishStatus = \'Online\' WITH SECURITY_ENFORCED ORDER BY ' + sort_field + ' ' + sort_order;
        } else {
            sQuery += fields[fields.size() - 1] + ' LIKE: search_key) AND PublishStatus = \'Online\' AND Id IN: article_IDs WITH SECURITY_ENFORCED ORDER BY ' + sort_field + ' ' + sort_order;
        }
        
        return sQuery;
    }

    @TestVisible
    private static List<SingleArticleInfo> makeQueryWithString(String sQuery, String search_key, List<Id> article_IDs, String date_field, String title_field, String summary_field) {
        try {
            List<SObject> articles = Database.query(sQuery);
            SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE, articles, true);
            return createListOfArticleInfo(articles, date_field, title_field, summary_field);
        } catch (QueryException e) {
            System.debug(e.getMessage());
            return new List<SingleArticleInfo>{new SingleArticleInfo(e.getMessage())};
        }
    }

    @TestVisible
    private static List<ID> getArticleIDsUsingTopicName(String topic_name) {
        ID topic_ID = getTopicFromName(topic_name);
        List<ID> article_IDs = new List<ID>();

        try {
            article_IDs = getArticlesIDListFromTopicID(topic_ID);
        } catch (QueryException e) {
            System.debug(e.getMessage());
        }
        return article_IDs;
    }

    @TestVisible
    private static ID getTopicFromName(String topic_name) {
        Set<String> accessible_fields = getAccessibleTopicFields();
        Topic topic = new Topic();
        if (accessible_fields.contains('Name')) {
            try {
                if (Test.isRunningTest()) {
                    topic = [SELECT Name FROM Topic WHERE Name =: topic_name WITH SECURITY_ENFORCED LIMIT 1];
                } else {
                    String network_id = Network.getNetworkId();
                    topic = [SELECT Name FROM Topic WHERE NetworkId =: network_id AND Name =: topic_name WITH SECURITY_ENFORCED LIMIT 1];
                }
            } catch (QueryException e) {
                System.debug(e.getMessage());
            }
        }
        SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE, new List<Topic>{topic}, true);
        return topic.Id;
    }

    @TestVisible
    private static List<Id> getArticlesIDListFromTopicID(ID topic_ID) {
        List<ID> article_IDs = new List<ID>();
        Set<String> accessible_topicassignment_fields = getAccessibleTopicAssignmentFields();
        if (accessible_topicassignment_fields.contains('EntityId')) {
        	List<KnowledgeArticleVersion> articles = [SELECT Id FROM KnowledgeArticleVersion WHERE PublishStatus = 'Online' AND Id IN (SELECT EntityId FROM TopicAssignment WHERE TopicId =: topic_ID) WITH SECURITY_ENFORCED ORDER BY Id ASC];
            SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE, articles, true);
            for (KnowledgeArticleVersion ka : articles) {
                article_IDs.add(ka.Id);
            }
        }
        return article_IDs;
    }

    @TestVisible
    private static List<String> getTopicsAssignedToArticle(String article_id) {
        Set<String> accessible_topicassignment_fields = getAccessibleTopicAssignmentFields();
        List<String> topic_names = new List<String>();
        if (accessible_topicassignment_fields.contains('EntityId') && accessible_topicassignment_fields.contains('TopicId')) {
            List<TopicAssignment> topic_assignments = [SELECT EntityId, TopicId FROM TopicAssignment WHERE EntityId =: article_id WITH SECURITY_ENFORCED];
            SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE, topic_assignments, true);
            List<Id> topic_IDs = new List<Id>();
            for (TopicAssignment topic_assignment : topic_assignments) {
                topic_IDs.add(topic_assignment.TopicId);
            }
            List<Topic> topics = getTopicsFromTopicIDs(topic_IDs);
            
            for (Topic topic : topics) {
                topic_names.add(topic.Name);
            }
        }
        return topic_names;
    }

    @TestVisible
    private static List<Topic> getTopicsFromTopicIDs(List<ID> topic_IDs) {
        List<Topic> topics = new List<Topic>();
        Set<String> accessible_fields = getAccessibleTopicFields();
        if (accessible_fields.contains('Name')) {
            if (Test.isRunningTest()) {
                try {
                    topics = [SELECT Name FROM Topic WHERE Id IN: topic_IDs WITH SECURITY_ENFORCED];
                } catch (QueryException e) {
                    System.debug(e.getMessage());
                }
            } else {
                try {
                    String network_id = Network.getNetworkId();
                    topics = [SELECT Name FROM Topic WHERE Id IN: topic_IDs AND NetworkId =: network_id WITH SECURITY_ENFORCED];
                } catch (QueryException e) {
                    System.debug(e.getMessage());
                }
            }
        }
        SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE, topics, true);
        return topics;
    }

    @TestVisible
    private static String createTitleSummaryAndDatePartOfQuery(String title_field, String summary_field, String date_field) {
        String query_part = '';
        Set<String> accessible_fields = getAccessibleKnowledgeFields();

        if (accessible_fields.contains(title_field)) {
            query_part += title_field;
        }
        if (summary_field != title_field && accessible_fields.contains(summary_field)) {
            query_part += ', ' + summary_field;
        }
        if (date_field != '' && accessible_fields.contains(date_field)) {
            if (!accessible_fields.contains(title_field) && !accessible_fields.contains(summary_field)) {
                return date_field;
            } else {
                query_part += ', ' + date_field;
            }
        }
        return query_part;
    }

    @TestVisible
    private static Map<ID, Set<String>> getTopicsAssignedToAllArticles(List<SObject> all_articles) {
        Map<ID, Set<String>> map_of_topics_assigned_to_each_article = new Map<ID, Set<String>>();
        Set<String> accessible_topicassignment_fields = getAccessibleTopicAssignmentFields();
        if (accessible_topicassignment_fields.contains('EntityId') && accessible_topicassignment_fields.contains('TopicId')) {
            Set<Id> article_ids = new Set<Id>();
            for (SObject article : all_articles) {
                article_ids.add(article.Id);
            }

            List<TopicAssignment> topic_assignments = [SELECT EntityId, TopicId FROM TopicAssignment WHERE EntityId IN: article_ids WITH SECURITY_ENFORCED ORDER BY EntityId];
            SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE, topic_assignments, true);
            Map<Id, String> map_of_topic_ids_and_names = getMapOfTopicIDsAndNames(topic_assignments);

            for (SObject article : all_articles) {
                Set<String> topics_on_this_article = new Set<String>();
                for (TopicAssignment ta : topic_assignments) {
                    if (ta.EntityId == article.Id) {
                        topics_on_this_article.add(map_of_topic_ids_and_names.get(ta.TopicId));
                    }
                }
                if (!topics_on_this_article.isEmpty()) {
                    map_of_topics_assigned_to_each_article.put(article.Id, topics_on_this_article);
                }
            }
        }
        return map_of_topics_assigned_to_each_article;
    }

    @TestVisible
    private static Map<Id, String> getMapOfTopicIDsAndNames(List<TopicAssignment> topic_assignments) {
        Map<ID, Set<String>> map_of_topics_assigned_to_each_article = new Map<ID, Set<String>>();
        List<Topic> all_topics = new List<Topic>();
        Set<String> accessible_fields = getAccessibleTopicFields();

        Set<Id> topic_ids = new Set<Id>();
        for (TopicAssignment ta : topic_assignments) {
            topic_ids.add(ta.TopicId);
        }
        if (accessible_fields.contains('Name') && topic_ids.size() > 0) {
            if (!Test.isRunningTest()) {
                String network_id = Network.getNetworkId();
                all_topics = [SELECT Name FROM Topic WHERE Id IN: topic_ids AND NetworkId =: network_id WITH SECURITY_ENFORCED];
            } else {
                all_topics = [SELECT Name FROM Topic WHERE Id IN: topic_ids WITH SECURITY_ENFORCED];
            }
        }
        SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE, all_topics, true);
        Map<Id, String> map_of_topic_ids_and_names = new Map<Id, String>();
        for (Topic t : all_topics) {
            map_of_topic_ids_and_names.put(t.Id, t.Name);
        }
        return map_of_topic_ids_and_names;
    }

    @TestVisible
    private static List<SingleArticleInfo> createListOfArticleInfo(List<SObject> all_articles, String date_field, String title_field, String summary_field) {
        List<SingleArticleInfo> all_article_info = new List<SingleArticleInfo>();
        Map<ID, Set<String>> map_of_topics_assigned_to_each_article = getTopicsAssignedToAllArticles(all_articles);
        for (SObject article : all_articles) {
            List<String> topic_names = new List<String>(map_of_topics_assigned_to_each_article.get(article.Id));
            all_article_info.add(new SingleArticleInfo(article, topic_names, date_field, title_field, summary_field));
        }
        return all_article_info;
    }
    
    @TestVisible
    private static string getKnowledgeObjectNameWithNamespace() {
        String object_name = '';
        for (String str : Schema.getGlobalDescribe().keySet()) {
            if (str.endsWith('knowledge__kav')) {
                object_name = str;
                break;
            }
        }
        return object_name;
    }

    public class TopicInfo {
        @AuraEnabled public List<String> Topics;
        @AuraEnabled public String ErrorMessage;

        public TopicInfo(List<String> all_topics) {
            Topics = all_topics;
        }

        public TopicInfo(String error) {
            ErrorMessage = error;
        }
    }

    public class SingleArticleInfo {
        @AuraEnabled public SObject Article;
        @AuraEnabled public String TitleField;
        @AuraEnabled public String SummaryField;
        @AuraEnabled public DateTime DateField;
        @AuraEnabled public String DateString;
        @AuraEnabled public List<String> Topics = new List<String>();
        @AuraEnabled public String ErrorMessage;

        public SingleArticleInfo(SObject single_article, List<String> topic_names, String date_field, String title_field, String summary_field) {
            Article = single_article;
            Topics = topic_names;
            try {
                TitleField = (String)single_article.get(title_field);
                SummaryField = (String)single_article.get(summary_field);
                if (date_field != '') {
                    DateField = (DateTime)Article.get(date_field);
                    DateString = DateField.format('d MMMM yyyy');
                }
            } catch (SObjectException e) {
                System.debug(e.getMessage());
                ErrorMessage = e.getMessage();
            }
        }

        public SingleArticleInfo(String error) {
            ErrorMessage = error;
        }
    }
}