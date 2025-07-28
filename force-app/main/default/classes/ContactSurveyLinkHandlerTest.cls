@IsTest
private class ContactSurveyLinkHandlerTest {
    
    // ------------------------------------------------------------------------
    // Mock for Bitly HTTP callouts
    // ------------------------------------------------------------------------
    private class MockBitlyCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type','application/json');
            res.setStatusCode(200);
            // Always return this mock short URL
            res.setBody('{"link":"https://bit.ly/mock"}');
            return res;
        }
    }
    
    // ------------------------------------------------------------------------
    // Helper to build a valid Contact with required fields
    // ------------------------------------------------------------------------
    private static Contact makeTestContact(String url) {
        return new Contact(
            FirstName               = 'Test',
        LastName                = 'User',
        Mailing_Address_Type__c = 'Home',       // valid picklist value
        Join_Date__c            = Date.today(), // required date
        Survey_Link_URL__c      = url
            );
    }
    
    @IsTest
    static void testHandleOnInsert() {
        // Register our HTTP mock so callouts inside the queued job return predictable data
        Test.setMock(HttpCalloutMock.class, new MockBitlyCallout());
        
        // Insert a Contact (simulating AFTER_INSERT in the trigger)
        Contact c = makeTestContact('https://example.com/insert');
        insert c;
        
        // Now invoke the handler as if AFTER_INSERT (oldMap = null)
        Test.startTest();
        ContactSurveyLinkHandler.handleSurveyLinkShortening(
        new List<Contact>{ c },
        null
            );
        Test.stopTest();
        
        // Re-query and assert the URL was shortened and no error was flagged
        c = [SELECT Survey_Link_URL__c, Bitly_Error__c
             FROM Contact
             WHERE Id = :c.Id];
        System.assertEquals(
            'https://bit.ly/mock',
        c.Survey_Link_URL__c,
        'After insert, Survey_Link_URL__c should be replaced by the mocked short URL'
            );
        System.assertEquals(
            false,
        c.Bitly_Error__c,
        'After insert, Bitly_Error__c should be false'
            );
    }
    
    @IsTest
    static void testHandleOnUpdate() {
        // Register mock again for this test context
        Test.setMock(HttpCalloutMock.class, new MockBitlyCallout());
        
        // Insert initial contact
        Contact original = makeTestContact('https://example.com/original');
        insert original;
        
        // Prepare an oldMap for BEFORE_UPDATE
        Contact beforeUpdate = [SELECT Survey_Link_URL__c FROM Contact WHERE Id = :original.Id];
        Map<Id, Contact> oldMap = new Map<Id, Contact>{ original.Id => beforeUpdate };
        
        // Change the URL and call the handler
        original.Survey_Link_URL__c = 'https://example.com/updated';
        Test.startTest();
        ContactSurveyLinkHandler.handleSurveyLinkShortening(
        new List<Contact>{ original },
        oldMap
            );
        Test.stopTest();
        
        // Re-query and assert the URL was shortened and no error was flagged
        Contact updated = [SELECT Survey_Link_URL__c, Bitly_Error__c
                           FROM Contact
                           WHERE Id = :original.Id];
        System.assertEquals(
            'https://bit.ly/mock',
        updated.Survey_Link_URL__c,
        'After update, Survey_Link_URL__c should be replaced by the mocked short URL'
            );
        System.assertEquals(
            false,
        updated.Bitly_Error__c,
        'After update, Bitly_Error__c should be false'
            );
    }
}