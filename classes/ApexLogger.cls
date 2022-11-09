/**
 * @description       : 
 * @author            : Raj Gonola 
 * @group             : 
 * @last modified on  : 11-07-2022
 * @last modified by  : Raj Gonola 
**/
public class ApexLogger {
    
    public static void LogException(string className, string methodName, Exception e){
        if (string.isNotBlank(className) && string.isNotBlank(methodName) && e != null){
            Apex_Log__c apexLog = new Apex_Log__c (
                Class_Name__c = className, 
                Method_Name__c = methodName, 
                Exception_Message__c = e.getMessage(),
                Exception_Stack_Trace__c = e.getStackTraceString(),
                Exception_Type__c = e.getTypeName(),
                Date_Time_Stamp__c = Datetime.now()
            );
            List<Map<string, string>> errorDetails = extractErrorDetailsFromException(e);
            if (errorDetails != null && !errorDetails.isEmpty()){
                apexLog.Error_Details__c  = Json.serialize(errorDetails);
            }
            insert apexLog;
        }
    }

    public static Apex_Log__c LogDMLErrors(string className, string methodName, string dmlOperation, Database.Error[] errors,SObject rcd){
        Apex_Log__c apexLog = new Apex_Log__c ();
        if (string.isNotBlank(className) && string.isNotBlank(methodName) && errors != null && errors.size() > 0){
            
            apexLog.Class_Name__c = className; 
            apexLog.Method_Name__c = methodName;
            apexLog.DML_Operation__c = dmlOperation;
            apexLog.Date_Time_Stamp__c = Datetime.now();
            
            List<Map<string, string>> errorDetails = new List<Map<string, string>>();
            for (Database.Error error : errors) {
                Map<string, string> errorDetail = new Map<string, string>();
                errorDetail.put('statusCode', string.valueOf(error.getStatusCode()));
                errorDetail.put('message', error.getMessage());
                errorDetails.add(errorDetail);
            }
            apexLog.Error_Details__c  = Json.serialize(errorDetails);
            apexLog.RecordData__c  = Json.serialize(rcd);
        }
        return apexLog;
    }

    static List<Map<string, string>> extractErrorDetailsFromException(Exception e){
        List<Map<string, string>> ret = new List<Map<string, string>>();
        switch on e.getTypeName() {
            when 'System.DmlException' {
                DmlException de = (DmlException)e;
                Integer numFailedRows = de.getNumDml();
                for (Integer i = 0; i < numFailedRows; i++) 
                {
                    ret.add(createErrorDetailMap(de.getDmlId(i), de.getDmlStatusCode(i), de.getDmlStatusCode(i)));
                }
            }
            when 'System.EmailException' {
                EmailException ee = (EmailException)e;
                Integer numFailedRows = ee.getNumDml();
                for (Integer i = 0; i < numFailedRows; i++) {
                    ret.add(createErrorDetailMap(ee.getDmlId(i), ee.getDmlStatusCode(i), ee.getDmlStatusCode(i)));
                }
            }
        }
        return ret;
    }
    @Testvisible
    static Map<string, string> createErrorDetailMap(string recordId, string statusCode, string message){
        Map<string, string> ret = new Map<string, string>();
        ret.put('recordId', recordId);
        ret.put('statusCode', statusCode);
        ret.put('message', message);
        return ret;
    }
    
}
