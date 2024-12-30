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


//approach 2

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
            accToOppListMap.put(variable.AccountId, new List<OpportunityLineItem>{variable});
        }
    }

}