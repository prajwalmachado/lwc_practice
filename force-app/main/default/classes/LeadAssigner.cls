public class LeadAssigner {

    // Invocable method for flows or process builder use
    @InvocableMethod(label='Balanced Lead Assignment')
    public static void assignLeads(List<Id> leadIds) {
        
        // Fetch all active users in the queue and their workload
        List<User> activeUsers = [SELECT Id, Name FROM User WHERE IsActive = true];
        
        // Get each user's current workload (number of open leads)
        Map<Id, Integer> userLeadCounts = new Map<Id, Integer>();
        for (AggregateResult result : [
                SELECT OwnerId, COUNT(Id) LeadCount
                FROM Lead
                WHERE Status != 'Closed'
                GROUP BY OwnerId
            ]) {
            userLeadCounts.put((Id) result.get('OwnerId'), (Integer) result.get('LeadCount'));
        }

        // Initialize a list of leads to update
        List<Lead> leadsToUpdate = new List<Lead>();

        // Loop over each lead and assign to the user with the lowest load
        for (Id leadId : leadIds) {
            Lead lead = new Lead(Id = leadId);

            // Find the user with the least workload
            Integer minLoad = Integer.MAX_VALUE;
            Id selectedUser = null;

            for (User user : activeUsers) {
                Integer currentLoad = userLeadCounts.get(user.Id) != null ? userLeadCounts.get(user.Id) : 0;

                if (currentLoad < minLoad) {
                    minLoad = currentLoad;
                    selectedUser = user.Id;
                }
            }

            // Assign the lead to the selected user
            lead.OwnerId = selectedUser;
            leadsToUpdate.add(lead);

            // Update the selected user's workload count in the map
            userLeadCounts.put(selectedUser, userLeadCounts.get(selectedUser) + 1);
        }

        // Update lead assignments
        if (!leadsToUpdate.isEmpty()) {
            update leadsToUpdate;
        }
    }
}
