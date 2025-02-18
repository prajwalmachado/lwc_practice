trigger conTrigger on Contact (before insert) {
    Set<Id> acctTds = new Set<Id>();
    
    if(trigger.isAfter && trigger.isUpdate){
        if(!trigger.new.isEmpty()){
            for(Contact con:trigger.new){
                if(con.AccountId != null && trigger.oldMap.get(con.Id).Description != con.Description){
                    acctTds.add(con.accountId);
                }
            }
        }
    }

    Map<Id,Account> acctMap = new Map<Id,Account>([SELECT Id,Description FROM Account WHERE Id IN:acctTds]);
    List<Account> listToUpdate = new List<Account>();
    if(!trigger.new.isEmpty()){
        for(Contact cont : trigger.new){
            Account acc = acctMap.get(cont.AccountId);
            acc.Description = cont.Description;
            listToUpdate.add(acc);
        }
    }

    if(!listToUpdate.isEmpty()){
        update listToUpdate;
    }
}