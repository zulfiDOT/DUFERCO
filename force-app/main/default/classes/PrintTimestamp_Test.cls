@isTest
public with sharing class PrintTimestamp_Test {
    @isTest
    public static void PrintTimestamp_Test() {
        PrintTimestamp.print(new List<List<String>> {new List<String>{'Test1','Test1'}});
    }
}