public class SampleQueueable implements Queueable{
   public void execute(QueueableContext context){
      // Callout to external service
    //   string cronExpression = '0 0 0 15 3 ? 2022';
    //   SampleSchedulable schedulable = new SampleSchedulable();
      System.debug('Calling Queueable Apex');
      SampleQueueable2 sampleQueueable2 = new SampleQueueable2();
      system.enqueueJob(sampleQueueable2);

      
   }
}