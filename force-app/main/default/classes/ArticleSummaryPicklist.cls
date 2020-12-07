global with sharing class ArticleSummaryPicklist extends VisualEditor.DynamicPicklist {

    global Map<String, String> getOtherPicklistsOnKnowledgeArticles() {
        DescribeSObjectResult knowledgeObject = Knowledge__kav.getSObjectType().getDescribe();
        Map<String, Schema.SObjectField> fieldMap = knowledgeObject.fields.getMap();
        Map<String, String> fieldNameMap = new Map<String, String>();

        for (Schema.SObjectField field : fieldMap.values()) {
            Schema.DescribeFieldResult fieldResult = field.getDescribe();
            if (fieldResult.getType() == Schema.DisplayType.Email ||
                fieldResult.getType() == Schema.DisplayType.String ||
                fieldResult.getType() == Schema.DisplayType.URL ||
                fieldResult.getType() == Schema.DisplayType.TextArea) {
                fieldNameMap.put(fieldResult.getLabel(), fieldResult.getName());
            }
        }
        return fieldNameMap;
    }

    global override VisualEditor.DataRow getDefaultValue() {
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('Summary', 'Summary');
        return defaultValue;
    }

    global override VisualEditor.DynamicPicklistRows getValues() {

        Map<String, String> otherPicklists = getOtherPicklistsOnKnowledgeArticles();

        VisualEditor.DynamicPickListRows myValues = new VisualEditor.DynamicPickListRows();
        for (String picklistName : otherPicklists.keySet()) {
            System.debug(picklistName + ' - ' + otherPicklists.get(picklistName));
            VisualEditor.DataRow newPicklist = new VisualEditor.DataRow(picklistName, otherPicklists.get(picklistName));
            myValues.addRow(newPicklist);
        }
        return myValues;
    }
}
