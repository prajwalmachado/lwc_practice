//when an opportunity is created, i want the related account active 
//field to be true.

trigger oppTrigger on Opportunity (after insert) {
    Set<Id> accountIds = new Set<Id>();

    for(opportunity opp : Trigger.new){
        if(opp.AccountId != null){
            accountIds.add(opp.AccountId);
        }
    }

    List<Account> accountsToUpdate = [SELECT Id,Active__c FROM Account
                                        WHERE Id IN :accountIds AND Active__c = 'No'];

    for(Account acc : accountsToUpdate){
        acc.Active__c = 'Yes';
    }

    if (!accountsToUpdate.isEmpty()) {
        update accountsToUpdate;
    }
}