@IsTest
public class Get_Picklist_values_Test {

    @IsTest
    static void Get_Picklist_values_Test() {
        
        List<list<String>> InputData = new List<list<String>>();
        list<String> DataList = new list<String>();
        DataList.add('PpuPricebookEntry__c');
        DataList.add('CPO__c');
        InputData.add(DataList);
        List<list<String>> result = Get_Picklist_values.Get_Picklist_values(InputData);
        system.debug(result);

    }
}