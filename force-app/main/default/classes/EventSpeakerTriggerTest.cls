@isTest
private class EventSpeakerTriggerTest {

    @TestSetup
    static void setupTestData() {
        // Event__c.Name is auto-number - do NOT set it
        Event__c testEvent = new Event__c();
        insert testEvent;
    }

    @isTest
    static void testInsertEventSpeaker() {
        Event__c testEvent = [SELECT Id FROM Event__c LIMIT 1];

        Test.startTest();
        // EventSpeakers__c.Name is auto-number - do NOT set it
        // Contact__c does not exist - only use Event__c lookup
        EventSpeakers__c speaker = new EventSpeakers__c(
            Event__c = testEvent.Id
        );
        insert speaker;
        Test.stopTest();

        List<EventSpeakers__c> inserted = [
            SELECT Id FROM EventSpeakers__c
            WHERE Event__c = :testEvent.Id
        ];
        System.assertEquals(1, inserted.size(),
            'One EventSpeaker should be inserted');
    }

    @isTest
    static void testUpdateEventSpeaker() {
        Event__c testEvent = [SELECT Id FROM Event__c LIMIT 1];

        EventSpeakers__c speaker = new EventSpeakers__c(
            Event__c = testEvent.Id
        );
        insert speaker;

        Test.startTest();
        // Trigger an update - just re-save the record
        update speaker;
        Test.stopTest();

        EventSpeakers__c updated = [
            SELECT Id FROM EventSpeakers__c WHERE Id = :speaker.Id
        ];
        System.assertNotEquals(null, updated,
            'Speaker should still exist after update');
    }

    @isTest
    static void testDeleteEventSpeaker() {
        Event__c testEvent = [SELECT Id FROM Event__c LIMIT 1];

        EventSpeakers__c speaker = new EventSpeakers__c(
            Event__c = testEvent.Id
        );
        insert speaker;

        Test.startTest();
        delete speaker;
        Test.stopTest();

        List<EventSpeakers__c> remaining = [
            SELECT Id FROM EventSpeakers__c WHERE Id = :speaker.Id
        ];
        System.assertEquals(0, remaining.size(),
            'Speaker should be deleted');
    }

    @isTest
    static void testBulkInsertEventSpeakers() {
        Event__c testEvent = [SELECT Id FROM Event__c LIMIT 1];

        List<EventSpeakers__c> speakers = new List<EventSpeakers__c>();
        for (Integer i = 0; i < 10; i++) {
            speakers.add(new EventSpeakers__c(
                Event__c = testEvent.Id
            ));
        }

        Test.startTest();
        insert speakers;
        Test.stopTest();

        List<EventSpeakers__c> inserted = [
            SELECT Id FROM EventSpeakers__c
            WHERE Event__c = :testEvent.Id
        ];
        System.assertEquals(10, inserted.size(),
            '10 EventSpeakers should be inserted');
    }
}
