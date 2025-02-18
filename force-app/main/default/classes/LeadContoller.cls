public with sharing class LeadContoller {
    public LeadContoller() {

    }

    @AuraEnabled
    public static void rejectLeadStatus(Id leadId) {
        // Query the Lead record based on the passed Lead ID
        Lead leadRecord = [SELECT Id, Status FROM Lead WHERE Id = :leadId LIMIT 1];
        
        // Update the status of the lead to "Rejected" or "Disqualified"
        leadRecord.Status = 'Rejected'; // or "Disqualified" as needed
        update leadRecord;
    }
}