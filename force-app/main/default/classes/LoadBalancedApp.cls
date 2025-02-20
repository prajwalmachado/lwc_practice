@InvocableMethod(label='Assign objects')
public static void assign(List<RoundRobinAssignment> rras) {
    List<RoundRobin__c> RRSettings = [SELECT Id, GroupName__c, FieldName__c, ObjectName__c, IndexOfLastUsed__c FROM RoundRobin__c];
    Map<String, List<GroupMember>> usersByGroup = new Map<String, List<GroupMember>>();
    List<SObject> objectList = new List<SObject>();
    Set<Id> userIds = new Set<Id>();

    // Step 1: Get the records and prepare the usersByGroup map
    for (RoundRobinAssignment rra : rras) {
        if (rra.fieldName == null) {
            rra.fieldName = 'OwnerId';
        }

        List<GroupMember> groupUsers = new List<GroupMember>();
        if (!usersByGroup.containsKey(rra.groupName)) {
            groupUsers = [SELECT Group.Name, GroupId, UserOrGroupId FROM GroupMember WHERE Group.Name = :rra.groupName];
            usersByGroup.put(rra.groupName, groupUsers);
        } else {
            groupUsers = usersByGroup.get(rra.groupName);
        }
        
        // Collect all user IDs
        for (GroupMember gm : groupUsers) {
            userIds.add(gm.UserOrGroupId);
        }
    }

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

    // Step 3: Iterate through the assignments and assign leads
    for (RoundRobinAssignment rra : rras) {
        Id rId = Id.valueOf(rra.recordId);
        String obj = rId.getSObjectType().getDescribe().getName();
        RoundRobin__c matchingRR = recordMatcher(RRSettings, rra.fieldName, obj, rra.groupName);

        // Find the user with the least number of leads assigned
        Id selectedUserId;
        Integer minLeadCount = Integer.MAX_VALUE;

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

        if (allUsersSameCount) {
            Integer nextIndex = getNextIndex(matchingRR, usersByGroup.get(rra.groupName));
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
