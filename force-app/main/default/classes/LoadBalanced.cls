if (usersByGroup.get(rra.groupName) == null){
                groupUsers = [select Group.Name, GroupId, UserOrGroupId from GroupMember where Group.Name =: rra.groupName];
                //store in the map
                usersByGroup.put(rra.groupName, groupUsers);
            } else {
                groupUsers = usersByGroup.get(rra.groupName);
            }
            
            // 1.query all leads where owner is in groupUsers and status not in Closed-converted - list name: listOfLeadsAssigned
            // Query Leads where the OwnerId is in the userIds set and Status is not 'Closed - Converted'

                Set<Id> userIds = new Set<id>();
                List<Lead> listOfLeadsAssigned = [SELECT Id, OwnerId, Status 
                FROM Lead 
                WHERE OwnerId IN :userIds 
                AND (Status != 'Closed - Converted' OR Status != 'Closed - Not Converted')];

                // /Map<Id, Integer> leadCountMap = new Map<Id,Inetger>();
                Map<Id, Integer> userLeadCountMap = new Map<Id, Integer>();


                for (Lead lead : listOfLeadsAssigned) {
                    // Check if the lead owner is already in the map
                    if (userLeadCountMap.containsKey(lead.OwnerId)) {
                        // Increment the count if the owner is already in the map
                        userLeadCountMap.put(lead.OwnerId, userLeadCountMap.get(lead.OwnerId) + 1);
                    } else {
                        // Initialize the count to 1 if the owner is not yet in the map
                        userLeadCountMap.put(lead.OwnerId, 1);
                    }
                }
               
            // 2. Form a map -> user, number of leads count
            // for (Lead lead: listOfLeadsAssigned) {
            	//Map.put(lead.owner, 0)
            	//check if lead owner already in map, then increase count
        	//}
            // 3.iterate through map, then check who has less count, then assign lead owner to him
            // 4. if all users have same count, then continue existin logic
            // 

            // Find the user with the least number of leads assigned
            Id selectedUserId;
            Integer minLeadCount = Integer.MAX_VALUE;

            // Step 3: Iterate through userLeadCountMap to find the user with the minimum count
            for (Id userId : userLeadCountMap.keySet()) {
                Integer currentCount = userLeadCountMap.get(userId);
                
                if (currentCount < minLeadCount) {
                    minLeadCount = currentCount;
                    selectedUserId = userId;
                }
            }

            // Step 4: Check if all users have the same lead count
            Boolean allUsersSameCount = true;
            for (Integer count : userLeadCountMap.values()) {
                if (count != minLeadCount) {
                    allUsersSameCount = false;
                    break;
                }
            }

            // Assign the lead
            if (allUsersSameCount) {
                // If all users have the same count, use the existing round-robin logic
                Integer nextIndex = getNextIndex(matchingRR, groupUsers);
                selectedUserId = groupUsers[nextIndex].UserOrGroupId;
            }

            SObject so = rId.getSObjectType().newSObject(rId);
            so.put(rra.fieldName, selectedUserId);

            matchingRR.IndexOfLastUsed__c = nextIndex;
            Boolean isNew = true;

            
            Id rId = rra.recordId;
			string Obj = rId.getSObjectType().getDescribe().getName();
 
            RoundRobin__c matchingRR = recordMatcher(RRSettings, rra.fieldName, Obj, rra.groupName);