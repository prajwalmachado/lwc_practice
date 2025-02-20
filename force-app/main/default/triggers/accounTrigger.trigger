trigger accounTrigger on Account (before delete) {
	Set<Id> accountIds = Trigger.oldMap.keySet();
    System.debug(accountIds);
    
    Map<Id, Account> accountWithOpportunities = new Map<Id, Account>(
        [SELECT Id FROM Account WHERE Id IN 
            (SELECT AccountId FROM Opportunity WHERE AccountId IN :accountIds)
        ]
    );
    
    for(Id recordId: accountWithOpportunities.keySet()) {
    	Trigger.oldMap.get(recordId).addError('Cannot delete');
  	}

}