global with sharing class ArticleSortFieldPicklist extends VisualEditor.DynamicPicklist {

    global Map<String, String> getOtherPicklistsOnKnowledgeArticles() {
        DescribeSObjectResult knowledgeObject = PexlifyArticle__Knowledge__kav.getSObjectType().getDescribe();
        Map<String, Schema.SObjectField> fieldMap = knowledgeObject.fields.getMap();
        Map<String, String> fieldNameMap = new Map<String, String>();

        for (Schema.SObjectField field : fieldMap.values()) {
            Schema.DescribeFieldResult fieldResult = field.getDescribe();
            fieldNameMap.put(fieldResult.getLabel(), fieldResult.getName());
        }

        return fieldNameMap;
    }

    global override VisualEditor.DataRow getDefaultValue() {
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('First Published Date', 'FirstPublishedDate');
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
