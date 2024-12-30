public with sharing class withSharingClass {
    public List<account> callwithoutSharing() {
        WithoutSharingClass withoutSharing = new WithoutSharingClass();
        return withoutSharing.getAccounts();
    }
    public list<Account> getAccounts(){
        return [select id,name from Account];
    }

}