/*
    * @author RANAND
    * @date 04/09/2020
    * @group Case Closed
    * @description Test class for Case Closure Batch and Scheduler
 
 */
@isTest(SeeAllData=false)
private class CaseClosure_Test {
    @testSetup private static void testDataSetup() {
        insert new Case(Subject='Test Case',
            Priority = 'Medium', 
            Status='Closed',
            Closed_By__c = UserInfo.getUserId());
    }
    @isTest static void testCaseClosure_BatchSuccess(){
        Test.setMock(HttpCalloutMock.class, new HTTPMockResponseGenerator(200, 'Success','{"success":true,"secretKey":"ABC123"}'));
        Test.startTest();

        Database.executeBatch(new CaseClosure_Batch(null), 100);

        Test.stopTest();
        System.assertEquals('ABC123', [SELECT Id, Secret_Key__c FROM Case LIMIT 1].Secret_Key__c,'Secret Key Mismatch');
    }
    @isTest static void testCaseClosure_BatchFailure(){
        Test.setMock(HttpCalloutMock.class, new HTTPMockResponseGenerator(500, 'Error','{"success":false,"error":"Error Message"}'));
        Test.startTest();
        Database.executeBatch(new CaseClosure_Batch(null), 100);
        Test.stopTest();
        System.assertEquals(null, [SELECT Id, Secret_Key__c FROM Case LIMIT 1].Secret_Key__c,'Blank Secret Key');
    }
    @isTest static void testCaseClosure_BatchBulk(){
        List<Case> caseList = new List<Case>();
        for(Integer i =0; i < 99; i++){
            caseList.add(new Case(Subject='Test Case'+i,
            Priority = 'Medium', 
            Status='New',
            Closed_By__c = UserInfo.getUserId()));
        }
        insert caseList;
        Test.setMock(HttpCalloutMock.class, new HTTPMockResponseGenerator(500, 'Error','{"success":false,"error":"Error Message"}'));
        Test.startTest();
        Database.executeBatch(new CaseClosure_Batch('SELECT Id, IsClosed, Closed_By__c, Retry_Attempt__c, Secret_Key__c FROM Case'), 100);
        Test.stopTest();
        System.assertEquals(null, [SELECT Id, Secret_Key__c FROM Case LIMIT 1].Secret_Key__c,'Blank Secret Key');
    }
    @isTest static void testCaseClosure_Scheduler(){
        String CRON_EXPR = '0 0 0 15 3 ? *';
        Test.startTest();

            String jobId = System.schedule('CaseClosureScheduleTest',  CRON_EXPR, new CaseClosure_Scheduler());
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            System.assertEquals(CRON_EXPR, ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);

        Test.stopTest();
    }
}