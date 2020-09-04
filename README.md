# AUSPOST
Assignment

Implementation : 
1.) A batch is implemented to query all the case which is closed and secret key is not available.[CaseClosure_Batch]
2.) This batch is scheduled to execute every hour using [CaseClosure_Scheduler] 
3.) The batch will query records which satisfies below criteria : 
    a.) Status is Closed
    b.) Secret Key field in SF is empty
    c.) retry Attempt is less than what mentioned in custom Label[MAX_RETRY_ATTEMPT]
4.) After Max Retry Attempt the batch won't pick the cases for processing. We can create a report for admin for further analysis
5.) Max Batch size shouldn't exceed 100 because of apex callout limit in one transaction. The batch size is configurable using custom label [CASE_CLOSURE_BATCH_SIZE]
6.) Whenever a Case is being closed the process builder will stamp [Closed By] field which further being set as agentId in callout.
7.) Class Comments added for further information
8.) Test class to cover unit tests.[CaseClosure_Test]

Script to execute in order to schedule the hourly batch job
System.schedule('Hourly_CaseClosure', '0 0 * * * ?', new CaseClosure_Scheduler());