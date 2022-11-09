@isTest
public class ApexLoggerTest {
	
    @isTest
    static void dataaccess(){
        List<Apex_Log__c> lstapexLog = new List<Apex_Log__c>();
         Apex_Log__c apexLog = new Apex_Log__c (
                Class_Name__c = 'className', 
                Method_Name__c = 'methodName', 
                Exception_Message__c = 'e.getMessage()',
                Exception_Stack_Trace__c = 'e.getStackTraceString()',
                Exception_Type__c = 'e.getTypeName()',
                Date_Time_Stamp__c = Datetime.now()
            );
        lstapexLog.add(apexLog);
        
        Test.startTest();
        DataAccessManager.ProcessRecords('Renewal_SPL_Process','createOpps', DataAccessManager.DmlType.DML_INSERT, lstapexLog, True, True);
       
        DataAccessManager.ProcessRecords('Renewal_SPL_Process','createOpps', DataAccessManager.DmlType.DML_UPDATE, lstapexLog, True, True);
        
        DataAccessManager.ProcessRecords('Renewal_SPL_Process','createOpps', DataAccessManager.DmlType.DML_UPSERT, lstapexLog, True, True);
       
        DataAccessManager.ProcessRecords('Renewal_SPL_Process','createOpps', DataAccessManager.DmlType.DML_DELETE, lstapexLog, True, True);
        Test.stopTest();
    }
    
    @isTest
    static void runSuccessTest(){
         Exception ex ;
        List<Database.Error> errors ;
        try{
            throw new NullPointerException();
        }catch(Exception e){
            ex = e;
        }
        
        try{
            List<contact> toinsert = new List<contact>();
            contact c = new contact();
            c.firstname = '';
            toinsert.add(c);
            
            List<Database.SaveResult> err = Database.insert(toinsert,false); 
            errors = err[0].getErrors();
        }catch(Exception e){
            ex = e;
        }
         contact c = new contact();
            c.firstname = '';
        ApexLogger.LogException('TestClase','method',ex );
        ApexLogger.LogDMLErrors('TestClase', 'method','DML_INSERT',  errors,c);
        ApexLogger.createErrorDetailMap('4545wfwwwdw', 'string statusCode', 'string message');
    }
}
