/**
 * @TestClass: Get_Picklist_values_Test
 */
public class Get_Picklist_values {

    @InvocableMethod
    public static List<list<String>> Get_Picklist_values(List<list<String>> InputData){
        
        list<String> DataList = new list<String>(InputData.get(0)); 
        String objectName = DataList.get(0);
        String fieldName = DataList.get(1);
        
        List<list<String>> result = new List<list<String>>();
        list<String> PicklistValue = new list<String>();
        
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult r = s.getDescribe();
        Map<String,Schema.SObjectField> fields = r.fields.getMap();
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            System.debug(pickListVal.getLabel() +' '+pickListVal.getValue());
            PicklistValue.add(pickListVal.getValue());
        }   
        result.add(PicklistValue);
        
        return result;
    }
}