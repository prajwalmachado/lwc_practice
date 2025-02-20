public without sharing class roundRobinAssigner {
 
    @InvocableMethod(label='Assign objects')
	public static void assign(list<RoundRobinAssignment> rras) {
 
        list<RoundRobin__c> RRSettings = [select id,
                                          GroupName__c,
                                         	FieldName__c, 
                                          ObjectName__c, 
                                          IndexOfLastUsed__c 
                                          from RoundRobin__c];
 
        map<string, list<GroupMember>> usersByGroup = new map<string, list<GroupMember>>();
        List<SObject> objectList = new List<SObject>();
 		Set<Id> userIds = new Set<id>();
        
        for (RoundRobinAssignment rra:rras){
            // optional field
            if (rra.fieldName == null){
                rra.fieldName = 'OwnerId';
            }
 
            list<groupMember> groupUsers = new list<groupMember>();
            
            if (usersByGroup.get(rra.groupName) == null){
                groupUsers = [select Group.Name, GroupId, UserOrGroupId from GroupMember where Group.Name =: rra.groupName];
                //store in the map
                usersByGroup.put(rra.groupName, groupUsers);
            } else {
                groupUsers = usersByGroup.get(rra.groupName);
            }
            
            // Collect all user IDs
            for (GroupMember gm : groupUsers) {
                userIds.add(gm.UserOrGroupId);
            }
        }   
            // 1.query all leads where owner is in groupUsers and status not in Closed-converted - list name: listOfLeadsAssigned
            // 2. Form a map -> user, number of leads count
            // for (Lead lead: listOfLeadsAssigned) {
            	//Map.put(lead.owner, 0)
            	//check if lead owner already in map, then increase count
        	//}
            // 3.iterate through map, then check who has less count, then assign lead owner to him
            // 4. if all users have same count, then continue existin logic
            // 
            // 
                       
              // Step 2: Query existing leads assigned to users in group
    		List<Lead> listOfLeadsAssigned = [SELECT Id, OwnerId FROM Lead WHERE OwnerId IN :userIds AND Status != 'Closed - Converted'];

            // Step 2.5: Form a map -> userId, number of leads count
            Map<Id, Integer> userLeadCountMap = new Map<Id, Integer>();
            for (Lead lead : listOfLeadsAssigned) {
                if (!userLeadCountMap.containsKey(lead.OwnerId)) {
                    userLeadCountMap.put(lead.OwnerId, 1);
                } else {
                    userLeadCountMap.put(lead.OwnerId, userLeadCountMap.get(lead.OwnerId) + 1);
                }
            }

            for (Id userId : userIds) {
                if (!userLeadCountMap.containsKey(userId)) {
                    userLeadCountMap.put(userId, 0);
                }
            }
        
 			//Iterate through the assignments and assign leads
    	for (RoundRobinAssignment rra : rras) {
        Id rId = Id.valueOf(rra.recordId);
        String obj = rId.getSObjectType().getDescribe().getName();
        RoundRobin__c matchingRR = recordMatcher(RRSettings, rra.fieldName, obj, rra.groupName);

        // Find the user with the least number of leads assigned
        Id selectedUserId;
        Integer minLeadCount = 2147483647;

        for (Id userId : userLeadCountMap.keySet()) {
            Integer currentCount = userLeadCountMap.get(userId);
            if (currentCount < minLeadCount) {
                minLeadCount = currentCount;
                selectedUserId = userId;
            }
        }

        Boolean allUsersSameCount = true;
        for (Integer count : userLeadCountMap.values()) {
            if (count != minLeadCount) {
                allUsersSameCount = false;
                break;
            }
        }
		 Integer nextIndex = getNextIndex(matchingRR, usersByGroup.get(rra.groupName));
        if (allUsersSameCount) {
           
            selectedUserId = usersByGroup.get(rra.groupName)[nextIndex].UserOrGroupId;
        }

        SObject so = rId.getSObjectType().newSObject(rId);
        so.put(rra.fieldName, selectedUserId);

        matchingRR.IndexOfLastUsed__c = nextIndex;
        Boolean isNew = true;

        for (RoundRobin__c rr : RRSettings) {
            if (rr.Id == matchingRR.Id) {
                rr.IndexOfLastUsed__c = matchingRR.IndexOfLastUsed__c;
                isNew = false;
            }
        }

        if (isNew) {
            RRSettings.add(matchingRR);
        }

        // Increment the user's lead count
        userLeadCountMap.put(selectedUserId, userLeadCountMap.get(selectedUserId) + 1);

        objectList.add(so);
    }

    update objectList;
    update RRSettings;
	}
 
    public static integer getNextIndex(RoundRobin__c match, list<GroupMember> groupUsers){
        if (match.IndexOfLastUsed__c == null){
            return 0; //first element of queue
        } else if (match.IndexOfLastUsed__c >= groupUsers.size()-1){
            system.debug(match.IndexOfLastUsed__c + ' is the last match, which is >= the group size of '
                         + groupUsers.size() + 'so we are going back to 0' );
            return 0; //exhausted size of queue
        } else {
            return (Integer)match.IndexOfLastUsed__c + 1;//next element of queue
        }
    }
 
    public static RoundRobin__c recordMatcher(list<RoundRobin__c> records, string FieldName, string Obj, string GroupName){
 
        for (RoundRobin__c rr:records){
            if (rr.FieldName__c == FieldName && rr.ObjectName__c == Obj && rr.GroupName__c == GroupName){
                return rr;
            }
        }
 
        // we never found it, so create one
        RoundRobin__c rrNew = new RoundRobin__c();
        rrNew.FieldName__c = FieldName;
        rrNew.ObjectName__c = Obj;
        rrNew.GroupName__c = GroupName;
        // because name is required
        rrNew.Name = Obj + '-' + FieldName + '-' + GroupName;
        insert rrNew;
        return rrNew;
    }
 
    //what Process Builder/Flow Builder can reference for the input variables
	public class RoundRobinAssignment {
		@InvocableVariable(required=true label='group name')
		public string groupName;
 
        @InvocableVariable(required=true label='recordId')
		public ID recordId;
 
		@InvocableVariable(required=false label='field name (default = ownerId)')
		public string fieldName;
	}
}