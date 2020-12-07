global with sharing class CommunityCategoryPicklist extends VisualEditor.DynamicPickList {

    global Map<String, String> getOtherPicklistsOnKnowledgeArticles() {
        DescribeSObjectResult knowledgeObject = KnowledgeArticle.getSObjectType().getDescribe();
        Map<String, Schema.SObjectField> fieldMap = knowledgeObject.fields.getMap();
        Map<String, String> fieldNameMap = new Map<String, String>();

        for (Schema.SObjectField field : fieldMap.values()) {
            Schema.DescribeFieldResult fieldResult = field.getDescribe();
            if (fieldResult.getType() == Schema.DisplayType.Picklist) {
                fieldNameMap.put(fieldResult.getLabel() ,fieldResult.getName());
            }
        }

        return fieldNameMap;
    }

    global override VisualEditor.DataRow getDefaultValue() {
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('Topics', 'Topic');
        return defaultValue;
    }

    global override VisualEditor.DynamicPicklistRows getValues() {

        Map<String, String> otherPicklists = getOtherPicklistsOnKnowledgeArticles();

        VisualEditor.DataRow value1 = new VisualEditor.DataRow('Topics', 'Topic');
        VisualEditor.DataRow value2 = new VisualEditor.DataRow('Article Types', 'ArticleType');
        VisualEditor.DynamicPickListRows myValues = new VisualEditor.DynamicPickListRows();
        myValues.addRow(value1);
        myValues.addRow(value2);
        for (String picklistName : otherPicklists.keySet()) {
            VisualEditor.DataRow newPicklist = new VisualEditor.DataRow(picklistName, otherPicklists.get(picklistName));
            myValues.addRow(newPicklist);
        }
        return myValues;
    }
}
