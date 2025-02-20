public class SampleQueueable2 implements Queueable{
    // public SampleQueueable2() {

    // }

    public void execute(QueueableContext context){
        // Callout to external service
        // string cronExpression = '0 0 0 15 3 ? 2022';
        // SampleSchedulable schedulable = new SampleSchedulable();
        System.debug('Calling Queueable Apex Job 2');
    }
}