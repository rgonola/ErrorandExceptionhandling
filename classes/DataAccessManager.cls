/**
 * @description       : 
 * @author            : Raj Gonola 
 * @group             : 
 * @last modified on  : 11-07-2022
 * @last modified by  : Raj Gonola 
**/
public class DataAccessManager {

    public enum DmlType{DML_INSERT,DML_UPDATE,DML_UPSERT,DML_DELETE}

    public static resultMap ProcessRecords(string className, string methodName, DataAccessManager.DmlType dmlType, List<SObject> recordsToProcess, Boolean allowPartialCommits, Boolean logErrors){
        resultMap vErrors = new resultMap();
        switch on dmlType {
            when DML_INSERT {
                Database.SaveResult[] sr = System.Database.insert(recordsToProcess, allowPartialCommits);
                if (logErrors){
                    vErrors = LogErrors(className, methodName, string.valueOf(DataAccessManager.DmlType.DML_INSERT), sr,recordsToProcess);
                }
            }
            when DML_UPDATE {
                Database.SaveResult[] sr =  System.Database.update(recordsToProcess, allowPartialCommits);
                if (logErrors){
                    vErrors = LogErrors(className, methodName, string.valueOf(DataAccessManager.DmlType.DML_UPDATE), sr,recordsToProcess);
                }
            }
            when DML_UPSERT {
                Database.UpsertResult[] ur = System.Database.upsert(recordsToProcess, allowPartialCommits);
                if (logErrors){
                    vErrors = LogErrors(className, methodName, ur,recordsToProcess);
                }
            }
            when DML_DELETE {
                Database.DeleteResult[] dr =  System.Database.delete(recordsToProcess, allowPartialCommits);
                if (logErrors){
                    vErrors = LogErrors(className, methodName, dr,recordsToProcess);
                }
            }
        }
        return vErrors;
    }

    private static resultMap LogErrors(string className, string methodName, string dmlOperation, Database.SaveResult[] saveResults,List<SObject> recordsToProcess){
        List<Database.Error> ret = null;
        List<Apex_Log__c> lsttoinsert = new List<Apex_Log__c>();
        resultMap rs = new resultMap();
        if (saveResults != null){
            ret = new List<Database.Error>();
            for(Integer i = 0; i < saveResults.size(); i++){
                Database.SaveResult sr =saveResults[i] ;
                if (!sr.isSuccess()){
                    Database.Error[] errors = sr.getErrors();
                    ret.addAll(errors);
                    Apex_Log__c apexLog =ApexLogger.LogDMLErrors(className, methodName, dmlOperation, errors,recordsToProcess[i]);
                    lsttoinsert.add(apexLog);
                }
            }
            if(lsttoinsert.size() >0) Database.insert(lsttoinsert,false);
            rs.apexlog = lsttoinsert;
            rs.ret = ret;
        }
        return rs;
    }

    private static resultMap LogErrors(string className, string methodName, Database.UpsertResult[] upsertResults,List<SObject> recordsToProcess){
        List<Database.Error> ret = null;
        List<Apex_Log__c> lsttoinsert = new List<Apex_Log__c>();
        resultMap rs = new resultMap();
        if (upsertResults != null){
            ret = new List<Database.Error>();
            for(Integer i = 0; i < upsertResults.size(); i++){
                Database.UpsertResult ur =upsertResults[i] ;
                if (!ur.isSuccess()){
                    Database.Error[] errors = ur.getErrors();
                    ret.addAll(errors);
                    Apex_Log__c apexLog =ApexLogger.LogDMLErrors(className, methodName, string.valueOf(DataAccessManager.DmlType.DML_UPSERT), errors,recordsToProcess[i]);
                    lsttoinsert.add(apexLog);
                }
            }
            if(lsttoinsert.size() >0) Database.insert(lsttoinsert,false);
            rs.apexlog = lsttoinsert;
            rs.ret = ret;
        }
        return rs;
    }

    private static resultMap LogErrors(string className, string methodName, Database.DeleteResult[] deleteResults,List<SObject> recordsToProcess){
        List<Database.Error> ret = null;
        List<Apex_Log__c> lsttoinsert = new List<Apex_Log__c>();

        resultMap rs = new resultMap();
        if (deleteResults != null){
            ret = new List<Database.Error>();
            for(Integer i = 0; i < deleteResults.size(); i++){
                Database.DeleteResult dr =deleteResults[i] ;
                if (!dr.isSuccess()){
                    Database.Error[] errors = dr.getErrors();
                    ret.addAll(errors);
                    Apex_Log__c apexLog =ApexLogger.LogDMLErrors(className, methodName, string.valueOf(DataAccessManager.DmlType.DML_DELETE), errors,recordsToProcess[i]);
                    lsttoinsert.add(apexLog);
                }
            }
            if(lsttoinsert.size() >0) Database.insert(lsttoinsert,false);
            rs.apexlog = lsttoinsert;
            rs.ret = ret;
        }
        return rs;
    }

    public class resultMap {
        public List<Database.Error> ret{ get; set; }
        public List<Apex_Log__c> apexlog{ get; set; }
    }
}
