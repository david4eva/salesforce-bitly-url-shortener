/**
 * Handler class to process Contacts with Survey URLs that need shortening via Bitly.
 * Instead of performing the shortening directly, we enqueue a Queueable job for bulk-safe processing.
 */
public class ContactSurveyLinkHandler {

    /**
     * Detects which contacts have a new or changed Survey_Link_URL__c and queues them for shortening.
     *
     * @param newContacts The list of new or updated Contact records.
     * @param oldMap The map of previous Contact records for detecting changes (null for insert).
     */
    public static void handleSurveyLinkShortening(List<Contact> newContacts, Map<Id, Contact> oldMap) {
        // Map to hold records that need URL shortening
        Map<Id, String> contactsToShorten = new Map<Id, String>();

        for (Contact c : newContacts) {
            String oldUrl = oldMap != null && oldMap.containsKey(c.Id) ? oldMap.get(c.Id).Survey_Link_URL__c : null;
            String newUrl = c.Survey_Link_URL__c;

            // Only process if the URL is present and has changed
            if (String.isNotBlank(newUrl) && newUrl != oldUrl) {
                contactsToShorten.put(c.Id, newUrl);
            }
        }

        // If there are any URLs to shorten, enqueue the BitlyQueueable job
        if (!contactsToShorten.isEmpty()) {
            System.enqueueJob(new BitlyQueueable(contactsToShorten));
        }
    }
}