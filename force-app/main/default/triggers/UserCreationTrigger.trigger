trigger UserCreationTrigger on Contact (after insert) {
    List<Id> accContactIds = new List<Id>();
    for(Contact con : Trigger.new){
        accContactIds.add(con.Id);
    }
    UserHandler.createUserAssignment(accContactIds);
}