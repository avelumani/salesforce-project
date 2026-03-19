@isTest
private class EventSpeakerTriggerTest {

    @TestSetup
    static void setupTestData() {
        // Create test Event record
        Event__c testEvent = new Event__c(
            Name = 'Test Event'
        );
        insert testEvent;

        // Create test Speaker/Contact record
        // Adjust field names to match your actual object schema
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Speaker',
            AccountId = testAccount.Id
        );
        insert testContact;
    }

    @isTest
    static void testInsertEventSpeaker() {
        Event__c testEvent = [SELECT Id FROM Event__c LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];

        Test.startTest();
        EventSpeakers__c speaker = new EventSpeakers__c(
            Event__c = testEvent.Id,
            Contact__c = testContact.Id
        );
        insert speaker;
        Test.stopTest();

        List<EventSpeakers__c> inserted = [
            SELECT Id FROM EventSpeakers__c WHERE Event__c = :testEvent.Id
        ];
        System.assertEquals(1, inserted.size(), 'One EventSpeaker should be inserted');
    }

    @isTest
    static void testUpdateEventSpeaker() {
        Event__c testEvent = [SELECT Id FROM Event__c LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];

        EventSpeakers__c speaker = new EventSpeakers__c(
            Event__c = testEvent.Id,
            Contact__c = testContact.Id
        );
        insert speaker;

        Test.startTest();
        speaker.Name = 'Updated Speaker';
        update speaker;
        Test.stopTest();

        EventSpeakers__c updated = [
            SELECT Id, Name FROM EventSpeakers__c WHERE Id = :speaker.Id
        ];
        System.assertNotEquals(null, updated, 'Speaker should exist after update');
    }

    @isTest
    static void testDeleteEventSpeaker() {
        Event__c testEvent = [SELECT Id FROM Event__c LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];

        EventSpeakers__c speaker = new EventSpeakers__c(
            Event__c = testEvent.Id,
            Contact__c = testContact.Id
        );
        insert speaker;

        Test.startTest();
        delete speaker;
        Test.stopTest();

        List<EventSpeakers__c> remaining = [
            SELECT Id FROM EventSpeakers__c WHERE Id = :speaker.Id
        ];
        System.assertEquals(0, remaining.size(), 'Speaker should be deleted');
    }
}
