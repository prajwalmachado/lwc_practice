trigger RollUpSummaryTrigger on Opportunity (before insert) {
    set<id> allAccIds = new Set<id>();
    for(Opportunity currentOpp : Trigger.new){
        allAccIds.add(currentOpp.AccountId);
    }

    list<Account> allAccounts = [SELECT id,name,No_of_Child_Opportunities__c from Account where id IN:allAccIds];

    Map<id,List<Opportunity>> accToOpptiesMap = new map<id,list<opportunity>>();

    list<Opportunitt> allOppty = [SELECT id, AccountId from Opportunity where AccountId IN:allAccIds];

    for(opportunity oppty : allOppty){
        if(accToOpptiesMap.containsKey(oppty.accountId)){
            accToOpptiesMap.get(oppty.accountId).add(oppty);
        } else{
            accToOpptiesMap.put(oppty.accountId,new list<opportunity>{oppty});
        }
    }
    
    list<Account> tobeUpdated = new List<Account>();
    
    if(allAccounts.size() > 0){
        for(Account currAcc : allAccounts){
            if(accToOpptiesMap.containsKey(currAcc.id)){
                currAcc.No_of_Child_Opportunities__c = accToOpptiesMap.get(currAcc.id).size();
                tobeUpdated.add(currAcc);
            }
        }
    }
    update tobeUpdated;
}