## 🔗 Salesforce Bitly URL Shortener (Experience Cloud Demo)

🎯 Project Purpose

The primary goal of this project is to automatically shorten long survey URLs saved on Salesforce Contact records. Often, survey links can be excessively long and unwieldy—making them hard to read, share, or embed. This integration solves that problem by:
	•	Detecting when a long URL is saved to the Survey Link field
	•	Calling the Bitly API to shorten the URL behind the scenes
	•	Replacing the original link with a clean, shortened Bitly link—automatically and instantly

This ensures users and stakeholders always have access to short, shareable links.

### 🚫 Bitly Account Optional

You can test a working Bitly integration without signing up for anything—no Bitly token, no developer key, and no Salesforce login required.  
This project is hosted on a Salesforce Experience Cloud site, exposing full functionality via a public-facing site.

However, if you notice that a Bitly link was not generated (e.g., due to usage limits), you can:

1. [Create a free Bitly account](https://bitly.com/pages/pricing)
2. [Generate a Generic Access Token](https://dev.bitly.com/docs/getting-started/authentication/)
3. Create a new contact and update the `Bitly_API_Access_Token__c` field on the Contact record with your token

### 🌐 Live Environment
• 👉 [Link to Experience Cloud Site](https://integration-experts-dev-ed.my.site.com/s/)
• Enter any long URL into the ‘Survey URL’ field on the Contact record, click save, and instantly get back a Bitly-shortened link. You may need to refresh <img width="26" height="24" alt="2025-07-28_23-41-57" src="https://github.com/user-attachments/assets/97c57235-ed97-432f-a065-68b2020c2890" /> the webpage.

⸻

💡 What This Project Demonstrates
	• Calling an external API (Bitly) from Salesforce using Named Credentials. 
	• Exposing Apex functionality to guest Experience Cloud site users
	• Handle API callouts and JSON parsing entirely in Apex
	• Automate URL shortening via Trigger and Queueable Apex

⸻
### 🧠 How It Works
1. User creates a contact and enters a long URL into the “Survey Link” field on the Contact record. <img width="1141" height="570" alt="2025-07-28_22-39-17" src="https://github.com/user-attachments/assets/e3d76af0-1547-493e-aedd-e4f9c3d79406" />
2. A before-insert/update Apex Trigger invokes the ContactSurveyLinkHandler class. <img width="875" height="279" alt="2025-07-28_23-25-02" src="https://github.com/user-attachments/assets/244694e7-e935-4ff7-ac63-85975b7c0fed" />
3. This handler:
	• Calls the Bitly API v4 via a Queueable Apex class using a Named Credential <img width="970" height="236" alt="2025-07-28_23-27-16" src="https://github.com/user-attachments/assets/8cd79c9e-8324-47c6-a9fd-8205dfa89404" />
	• Passes the long URL in a POST request. <img width="983" height="336" alt="2025-07-28_23-28-45" src="https://github.com/user-attachments/assets/45d188e5-89cb-4d0b-a4c3-70af66e51e08" />
	• Parses the shortened URL from Bitly’s JSON response. <img width="1254" height="299" alt="2025-07-28_23-31-25" src="https://github.com/user-attachments/assets/c0c298b8-b0fd-4038-95e1-87e6b10c6ce9" />
	• The shortened URL is then automatically saved into the custom field "Survey Link" on the Contact. <img width="1727" height="536" alt="2025-07-28_23-33-10" src="https://github.com/user-attachments/assets/2b7d0e86-517d-49fc-8909-d65c5d1d77d5" />
 	• Errors returned by the Bitly API are recorded in the designated Bitly error logging fields. <img width="1727" height="536" alt="2025-07-28_23-33-10 (1)" src="https://github.com/user-attachments/assets/374f9f00-0562-4b84-a7ef-b6c4c30b97ae" />
⸻

🔐 Token Security
	• Bitly token is stored securely using a Named Credential with a custom authorization header.
	• Public users never see the token, and no frontend exposure occurs.

⸻

### 🧱 Project Components

| Component                | Type             | Description                                 |
|--------------------------|------------------|---------------------------------------------|
| `BitlyQueueable`         | Apex Queueable   | Handles bulk-safe Bitly callouts            |
| `ContactSurveyLinkHandler` | Apex Class       | Detects when URLs need shortening           |
| `ContactTrigger`         | Trigger          | Kicks off processing during Contact insert/update |
| `Experience Site`        | Site Builder     | Public-facing site to test the integration  |


⸻

### 📄 Sample Apex Snippet

<pre lang="markdown">
```apex
HttpRequest req = new HttpRequest();
req.setEndpoint('callout:Bitly_API/shorten');
req.setMethod('POST');
req.setHeader('Content-Type', 'application/json');
req.setHeader('Authorization', 'Bearer ' + getToken());
req.setBody(JSON.serialize(new Map<String, String>{ 'long_url' => longUrl }));

HttpResponse res = new Http().send(req);
if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
    Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
    return (String)result.get('link');
}
```
</pre>

⸻

### 🧪 Use Cases
- Teaching aid for Salesforce API integrations
- Portfolio piece for devs showing real-world Apex usage
- Quick utility for shortening URLs in records like Contacts

⸻

### 📘 Related Docs
- [Bitly API Docs](https://dev.bitly.com/)
- [Salesforce Named Credentials](https://help.salesforce.com/s/articleView?id=xcloud.named_credentials_about.htm&type=5)
