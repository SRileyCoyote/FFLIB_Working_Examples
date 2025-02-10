# Data Structure

## Custom Objects

- **Event** is a Board Game Convention with a __Start__ and __End Date__.
     - Link to __Images__ pulled from [Static Resources](/force-app/main/default/staticresources)
- **Event Attendee** is a Person Attending the Event with a __Name__ and __Email__.
- **Board Game** is a Board Game with various attributes such as __Rating__, __Complexity__, and __Description__.
     - Contains links to __Images__ for Board Games pulled from BoardGameGeek Website.

     - Link added to [Trusted Sites](/force-app/main/default/cspTrustedSites/BGG_Images.cspTrustedSite-meta.xml)

- **Board Game Library Entry** is a concat table for **Board Game** and **Event**
     - Contains Forumla Fields to show if __Board Game__ is Available For Check Out
- **Board Game Rating** is a list of reviews of **Board Games** by **Event Attendees**
- **Board Game Checkout Log** is a log of when a **Board Game** is checked out by an **Event Attendee** at an **Event**
---
Following Image Shows the Schema Relationships between the SObjects but might not contain all of the fields and formula fields for the SObject:

![Data Schema](/images/Schema.png)
---
## Custom Metadata Types

We will use Custom Metadata Types to control certain aspects of the DOMAIN and SERVICE Layer

- **Domain Config**: This Custom MDT allows us to toggle the following settings on the SObject's Trigger:
     - Bypass Error Handling
     - Bypass Triggers 
     - Prevent Recursion
- **Services Config**: This Custom MDT has a MetaData Relaionship to the **Domain Config** Record and allows us to toggle the following settings for a Method on the Service Class:
     - Enable/Disable Service Method.


