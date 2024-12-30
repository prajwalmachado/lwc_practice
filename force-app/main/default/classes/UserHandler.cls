public with sharing class UserHandler {
    public UserHandler() {

    }
    @future
    public static void createUserAssignment(list<Id> allContactIds) {
        list<Contact> allContacts = [SELECT Id, email, lastname FROM Contact WHERE Id IN :allContactIds];
        Profile communityUserProfile = [SELECT Id FROM Profile WHERE Name = 'Customer Community Plus User'];
        list<User> usersToBeCreated = new list<User>();
        for (Contact currContact : allContacts) {
            User newUser = new User();
            newUser.FirstName = 'Community';
            newUser.LastName = currContact.LastName;
            newUser.Email = currContact.Email;
            newUser.Username = currContact.Email;
            newUser.CommunityNickname = currContact.Email;
            newUser.ProfileId = communityUserProfile.Id;
            newUser.LanguageLocaleKey = 'en_US';
            newUser.EmailEncodingKey = 'UTF-8';
            newUser.TimeZoneSidKey = 'America/Los_Angeles';
            newUser.LocaleSidKey = 'en_US';
            newUser.ContactId = currContact.Id;

            usersToBeCreated.add(newUser);
        }
        insert usersToBeCreated;

        List<groupMember> gmToInsert = new List<groupMember>();
        group publicGroupAssign = [SELECT Id FROM group WHERE Name = 'Sales Team' LImit 1]; 
        for (user currUser : usersToBeCreated) {
            groupMember gm = new groupMember();
            gm.UserOrGroupId = currUser.Id;
            gm.GroupId = publicGroupAssign.Id;
            gmToInsert.add(gm);
            
        }  
        insert gmToInsert;
    }
}