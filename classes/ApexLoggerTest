@isTest
public class ApexLoggerTest {

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
        
        ApexLogger.LogException('TestClase','method',ex );
        ApexLogger.LogDMLErrors('TestClase', 'method','DML_INSERT',  errors);
        ApexLogger.createErrorDetailMap('4545wfwwwdw', 'string statusCode', 'string message');
    }
}
