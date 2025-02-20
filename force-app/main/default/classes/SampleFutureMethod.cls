public with sharing class SampleFutureMethod {
    @future(callout = true)
    public static void SampleFutureMethod() {
        // Callout to external service
        string cronExpression = '0 0 0 15 3 ? 2022';
        SampleSchedulable schedulable = new SampleSchedulable();
        System.schedule('SampleSchedulable', cronExpression, schedulable);
    }   
}