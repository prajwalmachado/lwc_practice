trigger AggregateRollUpSummary on Opportunity (after insert) {
    set<id> allAccIds = new Set<id>();
    for(Opportunity currentOpp : Trigger.new){
        allAccIds.add(currentOpp.AccountId);
    }

    list<Account> allAccounts = [SELECT id,name,No_of_Child_Opportunities__c from Account where id IN:allAccIds];

    Map<id,Decimal> accToOpptiesMap = new map<id,Decimal>();

    List<AggregateResult> totalOppty = [SELECT AccountId, COUNT(Id) total FROM Opportunity WHERE AccountId IN :allAccIds GROUP BY AccountId];

    for (AggregateResult ar : totalOppty) {
        String accId = (String)ar.get('AccountId');
        Decimal total = (Decimal)ar.get('total');
        accToOpptiesMap.put(accId, total);
    }
    List<Account> updateAcc = new List<Account>();
    for (Account acc : updateAcc) {
        if (accToOpptiesMap.containsKey(acc.Id)) {
            acc.No_of_Child_Opportunities__c = accToOpptiesMap.get(acc.Id);
            updateAcc.add(acc);
        }
    }

    update updateAcc;

}