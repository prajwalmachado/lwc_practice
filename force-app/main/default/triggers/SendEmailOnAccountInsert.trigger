trigger SendEmailOnAccountInsert on Account (after insert) {
    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
    for (Account acc : Trigger.new) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject('New Account Created');
        email.setPlainTextBody('A new account has been created with the name ' + acc.Name);
        email.setTargetObjectId('0052w00000C5Z3z');
        email.setSaveAsActivity(false);
        emails.add(email);
    }
   // Send all the emails
   if (!emails.isEmpty()) {
        Messaging.sendEmail(emails);
    }
}