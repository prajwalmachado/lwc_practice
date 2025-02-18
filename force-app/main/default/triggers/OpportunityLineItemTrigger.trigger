/*
trigger OpportunityLineItemTrigger on OpportunityLineItem (after insert) {
    for (OpportunityLineItem currOLI : Trigger.new) {
        
        
        opportunity associatedOpportunity = [SELECT Id, AccountId FROM Opportunity WHERE Id = :currOLI.OpportunityId];

        Account associatedAccount = [SELECT Id, No_of_OppLineItem__c FROM Account WHERE Id = :associatedOpportunity.AccountId];

        list<Opportunity> RelatedOpportunities = [Select Id, OpportunityId FROM Opportunity WHERE accountId = :associatedAccount.Id];

        Decimal count = 0;

        for(Opportunity currOpp : RelatedOpportunities){
            List<OpportunityLineItem> OLIPerOpprtunity = [SELECT count() FROM OpportunityLineItem WHERE OpportunityId = :currOpp.Id];
            count += OLIPerOpprtunity.size();

        }
        associatedAccount.No_of_OppLineItem__c = count;
        update associatedAccount;
    }
}

*/


//approach 2

/*
trigger OLITrigger on OpportunityLineItem (after insert) {

    set<id> OppsIds = new set<id>();
    for(OpportunityLineItem oli : Trigger.new){
        OppsIds.add(oli.OpportunityId);
    }

    List<Opportunity> Opps = [SELECT Id, AccountId FROM Opportunity WHERE Id IN :OppsIds];

    set<id> AccIds = new set<id>();
    for(Opportunity opp : Opps){
        AccIds.add(opp.accountId);
    }

    list<Opportunities> allOpporunities = [Select Id, AccountId FROM Opportunity WHERE accountId IN :AccIds];

    list<OpportunityLineItem> allOLI = [Select Id, OpportunityId FROM OpportunityLineItem WHERE OpportunityId IN :allOpporunities];

    map<id, List<Opportunity>> accToOppListMap = new map<id, List<Opportunity>>();

    for (Opportunity variable : allOpporunities) {
        if(accToOppListMap.containsKey(variable.AccountId)){
            accToOppListMap.get(variable.AccountId).add(variable);
        }else{
            accToOppListMap.put(variable.AccountId, new List<Opportunity>{variable});
        }
    }

    Map<Id, List<OpportunityLineItem>> opptyToOLIItemMap = new Map<Id, List<OpportunityLineItem>>();

    for (OpportunityLineItem oli : allOLI) {
        if(opptyToOLIItemMap.containsKey(oli.OpportunityId)){
            opptyToOLIItemMap.get(oli.OpportunityId).add(oli);
        }else{
            opptyToOLIItemMap.put(oli.OpportunityId, new List<OpportunityLineItem>{oli});
        }
    }
    list<Account> accToUpdate = new list<Account>();

    for(id accountId : accToOppListMap.keySet()){
        Decimal count = 0;
        for(Opportunity opp : accToOppListMap.get(accountId)){
            if(opptyToOLIItemMap.get(opp.Id) != null){
                count += opptyToOLIItemMap.get(opp.Id).size();
            }
        }
        Account acc = new Account(Id = accountId, No_of_OppLineItem__c = count);
        accToUpdate.add(acc);
    }
}

*/

//approach 3
trigger OpportunityLineItemTrigger on OpportunityLineItem (after insert) {
    Set<Id> opportunityIds = new Set<Id>();
    for (OpportunityLineItem oli : Trigger.new) {
        opportunityIds.add(oli.OpportunityId);
    }

    Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>([
        SELECT Id, AccountId 
        FROM Opportunity 
        WHERE Id IN :opportunityIds
    ]);

    Set<Id> accountIds = new Set<Id>();
    for (Opportunity opp : opportunityMap.values()) {
        accountIds.add(opp.AccountId);
    }

    Map<Id, Account> accountMap = new Map<Id, Account>([
        SELECT Id, No_of_OppLineItem__c 
        FROM Account 
        WHERE Id IN :accountIds
    ]);

    Map<Id, Integer> accountToOLICountMap = new Map<Id, Integer>();
    for (Id accountId : accountIds) {
        accountToOLICountMap.put(accountId, 0);
    }

    for (OpportunityLineItem oli : [
        SELECT Opportunity.AccountId 
        FROM OpportunityLineItem 
        WHERE OpportunityId IN :opportunityIds
    ]) {
        Id accountId = oli.Opportunity.AccountId;
        if (accountToOLICountMap.containsKey(accountId)) {
            accountToOLICountMap.put(accountId, accountToOLICountMap.get(accountId) + 1);
        }
    }

    List<Account> accountsToUpdate = new List<Account>();
    for (Id accountId : accountToOLICountMap.keySet()) {
        Account acc = accountMap.get(accountId);
        acc.No_of_OppLineItem__c = accountToOLICountMap.get(accountId);
        accountsToUpdate.add(acc);
    }

    if (!accountsToUpdate.isEmpty()) {
        update accountsToUpdate;
    }


}


//approach 4
trigger OLITrigger on OpportunityLineItem (after insert) {
    set<id> OppsIds = new set<id>();
    for(OpportunityLineItem oli : Trigger.new){
        OppsIds.add(oli.OpportunityId);
    }

    List<Opportunity> Opps = [SELECT Id, AccountId FROM Opportunity WHERE Id IN :OppsIds];

    set<id> AccIds = new set<id>();
    for(Opportunity opp : Opps){
        AccIds.add(opp.accountId);
    }

    List<account> accList = [SELECT id, No_of_OppLineItem__c, (SELECT Id from Opportunity) FROM Account WHERE Id IN :AccIds];
    list<Opportunity> allOpporunities = [Select Id, (Select Id from OpportunityLineItem) FROM Opportunity WHERE accountId IN :AccIds];

    map<id, Decimal> oppToOLINoMap = new map<id, Decimal>();
    for(Opportunity opp : allOpporunities){
        oppToOLINoMap.put(opp.Id, Decimal.valueOf(opp.OpportunityLineItems.size()));
    }

    list<Account> accToUpdate = new list<Account>();
    for(Account acc : accList){
        for (Opportunity opp : acc.Opportunities) {

            acc.No_of_OppLineItem__c += oppToOLINoMap.get(opp.Id);
        }
        AccToUpdate.add(acc);
    }
    update  accToUpdate;
}

//aggregate query approach

trigger OLITrigger on OpportunityLineItem(after insert){
    set<id> OppsIds = new set<id>();
    for(OpportunityLineItem oli : Trigger.new){
        OppsIds.add(oli.OpportunityId);
    }

    List<Opportunity> OppList = [SELECT Id, AccountId FROM Opportunity WHERE Id IN :OppsIds];

    set<id> AccIds = new set<id>();
    for(Opportunity opp : Opps){
        AccIds.add(opp.accountId);
    }

    
    list<Opportunity> allOpporunities = [Select Id, AccountId FROM Opportunity WHERE accountId IN :AccIds];
    Map<Id, Decimal> accToOLICount = new Map<Id, Decimal>();

    list<AggregateResult> ARResult = [SELECT Opportunity.AccountId, Count(Id) oliCount 
                                        FROM  OpportunityLineItem WHERE OpportunityId IN :allOpporunities
                                        GROUP BY Opportunity.AccountId];

    for(AggregateResult ar : ARResult){
        accToOLICount.put((Id)ar.get('AccountId'), (Decimal)ar.get('oliCount'));
    }

    System.debug('accToOLICount: ' + accToOLICount);

    list<Account> accToListUpdate = new list<Account>();
    for (id AccountId : AccIds) {
        Decimal count = 0;
        account currAcc = new Account(Id = AccountId);
        if(accToOLICount.containsKey(AccountId)){
            currAcc.No_of_OppLineItem__c = accToOLICount.get(AccountId);
            accToListUpdate.add(currAcc);
        }
    }
    update accToListUpdate;
}   