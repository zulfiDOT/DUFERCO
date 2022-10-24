public class PrintTimestamp {
    
    @InvocableMethod(label='Print Timestamp' description='Print timestamp in debug logs')
    public static void print(List<List<String>> params) {
        System.debug('now='+System.now());
        System.debug('time='+System.now().time());
        System.debug('flow='+params[0][0]);
        System.debug('action='+params[0][1]);
    }
    
}