public class DataAccessManager {

    public enum DmlType{DML_INSERT,DML_UPDATE,DML_UPSERT,DML_DELETE}

    public static List<Database.Error> ProcessRecords(string className, string methodName, DataAccessManager.DmlType dmlType, List<SObject> recordsToProcess, Boolean allowPartialCommits, Boolean logErrors){
        List<Database.Error> vErrors = new List<Database.Error>();
        switch on dmlType {
            when DML_INSERT {
                Database.SaveResult[] sr = System.Database.insert(recordsToProcess, allowPartialCommits);
                if (logErrors){
                    LogErrors(className, methodName, string.valueOf(DataAccessManager.DmlType.DML_INSERT), sr);
                }
            }
            when DML_UPDATE {
                Database.SaveResult[] sr =  System.Database.update(recordsToProcess, allowPartialCommits);
                if (logErrors){
                    LogErrors(className, methodName, string.valueOf(DataAccessManager.DmlType.DML_UPDATE), sr);
                }
            }
            when DML_UPSERT {
                Database.UpsertResult[] ur = System.Database.upsert(recordsToProcess, allowPartialCommits);
                if (logErrors){
                    LogErrors(className, methodName, ur);
                }
            }
            when DML_DELETE {
                Database.DeleteResult[] dr =  System.Database.delete(recordsToProcess, allowPartialCommits);
                if (logErrors){
                    LogErrors(className, methodName, dr);
                }
            }
        }
        return vErrors;
    }

    private static List<Database.Error> LogErrors(string className, string methodName, string dmlOperation, Database.SaveResult[] saveResults){
        List<Database.Error> ret = null;
        if (saveResults != null){
            ret = new List<Database.Error>();
            for (Database.SaveResult sr : saveResults) {
                if (!sr.isSuccess()){
                    Database.Error[] errors = sr.getErrors();
                    ret.addAll(errors);
                    ApexLogger.LogDMLErrors(className, methodName, dmlOperation, errors);
                }
            }
        }
        return ret;
    }

    private static List<Database.Error> LogErrors(string className, string methodName, Database.UpsertResult[] upsertResults){
        List<Database.Error> ret = null;
        if (upsertResults != null){
            ret = new List<Database.Error>();
            for (Database.UpsertResult ur : upsertResults) {
                if (!ur.isSuccess()){
                    Database.Error[] errors = ur.getErrors();
                    ret.addAll(errors);
                    ApexLogger.LogDMLErrors(className, methodName, string.valueOf(DataAccessManager.DmlType.DML_UPSERT), errors);
                }
            }
        }
        return ret;
    }

    private static List<Database.Error> LogErrors(string className, string methodName, Database.DeleteResult[] deleteResults){
        List<Database.Error> ret = null;
        if (deleteResults != null){
            ret = new List<Database.Error>();
            for (Database.DeleteResult dr : deleteResults) {
                if (!dr.isSuccess()){
                    Database.Error[] errors = dr.getErrors();
                    ret.addAll(errors);
                    ApexLogger.LogDMLErrors(className, methodName, string.valueOf(DataAccessManager.DmlType.DML_DELETE), errors);
                }
            }
        }
        return ret;
    }
}