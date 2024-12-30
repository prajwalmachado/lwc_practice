public with sharing class nestMaps {
    public static void nestedMapMethod(){
        list<Account> accList = [select Id from Account];
        system.debug('Acc List'+acclist);
        // create a map of account id and on the value side we will have another
        // opportunity id on the key side and opportunitylineItems on 
        // the values side 
        //Map<Id, Map<id> mapName = new Map<Id, Map<id>();
        map<Id,map<Id,List<OpportunityLineItem>>> AccountOppLineItmsMap = new map<Id,Map<Id,List<OpportunityLineItem>>>();
    
        List<Opportunity> oppList = [select Id,AccountId from Opportunity where AccountId
                                        IN: accList];
        system.debug('Oppotunity List'+oppList);
        List<OpportunityLineItem> oppListItemList = [select id,OpportunityId from opportunityLineItem
                                                    where OpportunityId IN:oppList];
        system.debug('oppListItem List'+oppListItemList);
        Map<Id,List<OpportunityLineItem>> oppToOLIMap = new Map<Id,List<OpportunityLineItem>>();
    
        for (opportunityLineItem currOLI : oppListItemList) {
            if(oppToOLIMap.containsKey(currOLI.OpportunityId)){
                oppToOLIMap.get(currOLI.OpportunityId).add(currOLI);
            }
            else{
                oppToOLIMap.put(currOLI.OpportunityId,new List<opportunityLineItem>{currOLI});
            }
        }
    
        for(opportunity currentOpp : oppList){
            if(AccountOppLineItmsMap.containsKey(currentOpp.AccountId)){
                AccountOppLineItmsMap.get(currentOpp.AccountId).put(currentOpp.Id,oppToOLIMap.get(currentOpp.id));
            }else{
                AccountOppLineItmsMap.put(currentOpp.AccountId,new Map<id,List<OpportunityLineItem>>
                                                                    {currentOpp.id => oppToOLIMap.get(currentOpp.id)});
            }
        }
    
        system.debug('oppToOpportunity Line ItemMap'+oppToOLIMap);
    
    }
}