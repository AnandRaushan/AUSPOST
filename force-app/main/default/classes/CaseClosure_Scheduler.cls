/*
    * @author RANAND
    * @date 04/09/2020
    * @group Case Closed
    * @description This scheduler is used to schedule the batch to execute every hour
 
 */
public class CaseClosure_Scheduler implements Schedulable{
    public void execute(SchedulableContext sc){
        //Execute Batch in size of 100 to avoid Callout limits in one transaction
        Integer batchSize = Integer.valueOf(Label.CASE_CLOSURE_BATCH_SIZE);
        Database.executeBatch(new CaseClosure_Batch(null), batchSize);
    }
}
