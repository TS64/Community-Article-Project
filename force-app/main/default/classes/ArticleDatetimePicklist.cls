global with sharing class ArticleDatetimePicklist extends VisualEditor.DynamicPickList {
    
    global Map<String, String> getDateTimeFieldsOnKnowledgeArticles() {
        DescribeSObjectResult knowledge_object = PexlifyArticle__Knowledge__kav.getSObjectType().getDescribe();
        Map<String, Schema.SObjectField> field_map = knowledge_object.fields.getMap();
        Map<String, String> field_labels_and_names_map = new Map<String, String>();

        for (Schema.SObjectField field : field_map.values()) {
            Schema.DescribeFieldResult field_result = field.getDescribe();
            if (field_result.getType() == Schema.DisplayType.DateTime ||
                field_result.getType() == Schema.DisplayType.Date) {
                field_labels_and_names_map.put(field_result.getLabel() ,field_result.getName());
            }
        }

        return field_labels_and_names_map;
    }

    global override VisualEditor.DataRow getDefaultValue() {
        return new VisualEditor.DataRow('First Published Date', 'FirstPublishedDate');
    }

    global override VisualEditor.DynamicPicklistRows getValues() {
        Map<String, String> all_article_datatime_fields = getDateTimeFieldsOnKnowledgeArticles();
        VisualEditor.DynamicPickListRows datatime_picklist_values = new VisualEditor.DynamicPickListRows();

        for (String picklist_name : all_article_datatime_fields.keySet()) {
            System.debug(picklist_name + ' - ' + all_article_datatime_fields.get(picklist_name));
            datatime_picklist_values.addRow(new VisualEditor.DataRow(picklist_name, all_article_datatime_fields.get(picklist_name)));
        }
        datatime_picklist_values.addRow(new VisualEditor.DataRow('None', 'None'));
        return datatime_picklist_values;
    }
}
