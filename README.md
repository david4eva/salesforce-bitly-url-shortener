## 🔗 Salesforce Bitly URL Shortener (No-Setup Experience Cloud Demo)

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
3. Update the `Bitly_API_Access_Token__c` field on the Contact record with your token

### 🌐 Live Demo

### 👉 https://integration-experts-dev-ed.my.site.com/s/
Enter any long URL into the ‘Survey URL’ field on the Contact record, click save, and instantly get back a Bitly-shortened link.

⸻

### 💡 What This Project Demonstrates
	•	Calling an external API (Bitly) from Salesforce using Named Credentials
	•	Exposing Apex functionality to guest Experience Cloud site users
	•	Handle API callouts and JSON parsing entirely in Apex
	•	Automate URL shortening via Trigger and Queueable Apex

⸻

### 🧠 How It Works
	1.	User enters a long URL into the “Survey Link” field on the Contact record.
	2.	A before-insert/update Apex Trigger invokes the ContactSurveyLinkHandler class.
	3.	This handler:
		•	Calls the Bitly API v4 via a Queueable Apex class using a Named Credential
		•	Passes the long URL in a POST request
		•	Parses the shortened URL from Bitly’s JSON response
	4.	The shortened URL is then automatically saved into the custom field "Survey Link" on the Contact.

⸻

🔐 Token Security
	•	Bitly token is stored securely using a Named Credential with a custom authorization header.
	•	Public users never see the token, and no frontend exposure occurs.

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
if (res.getStatusCode() == 200) {
    Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
    return (String)result.get('link');
}
```
</pre>

⸻

### 🧪 Use Cases
	•	Demo for clients/stakeholders
	•	Teaching aid for Salesforce API integrations
	•	Portfolio piece for devs showing real-world Apex usage
	•	Quick utility for shortening URLs in records like Contacts

⸻

### 📘 Related Docs
	•	[Bitly API Docs](https://dev.bitly.com/)
	•	[Salesforce Named Credentials](https://help.salesforce.com/s/articleView?id=xcloud.named_credentials_about.htm&type=5)
