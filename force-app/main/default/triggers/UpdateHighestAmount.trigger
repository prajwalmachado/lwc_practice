trigger UpdateHighestAmount on Opportunity (after insert, after update, after delete, after undelete) {
    // Step 1: Collect all Account IDs from the relevant Opportunities
    Set<Id> accountIds = new Set<Id>();
    if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
        for (Opportunity opp : Trigger.new) {
            if (opp.AccountId != null) {
                accountIds.add(opp.AccountId);
            }
        }
    }
    if (Trigger.isDelete) {
        for (Opportunity opp : Trigger.old) {
            if (opp.AccountId != null) {
                accountIds.add(opp.AccountId);
            }
        }
    }

    // Step 2: Query all related Opportunities for the affected Accounts
    Map<Id, Decimal> accountToHighestAmountMap = new Map<Id, Decimal>();
    if (!accountIds.isEmpty()) {
        for (AggregateResult result : [
            SELECT AccountId, MAX(Amount) maxAmount
            FROM Opportunity
            WHERE AccountId IN :accountIds
            GROUP BY AccountId
        ]) {
            accountToHighestAmountMap.put((Id) result.get('AccountId'), (Decimal) result.get('maxAmount'));
        }
    }

    // Step 3: Update the Accounts with the highest opportunity amount
    List<Account> accountsToUpdate = new List<Account>();
    for (Id accountId : accountIds) {
        Decimal highestAmount = accountToHighestAmountMap.containsKey(accountId) ? accountToHighestAmountMap.get(accountId) : 0;
        accountsToUpdate.add(new Account(
            Id = accountId,
            Highest_Opportunity_Amount__c = highestAmount
        ));
    }

    if (!accountsToUpdate.isEmpty()) {
        update accountsToUpdate;
    }
}