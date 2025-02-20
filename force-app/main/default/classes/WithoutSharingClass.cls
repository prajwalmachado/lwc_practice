public without sharing class WithoutSharingClass {
    public List<Account> callwithSharing() {
        withSharingClass withSharing = new withSharingClass();
        return withSharing.getAccounts();
    }
    public list<Account> getAccounts(){
        return [select id,name from Account];
    }


}