# Data Structure

## Custom Objects

- **Event** is a Board Game Convention with a **Start** and **End Date**.
     - Link to **Images** pulled from [Static Resources](/sfdx-source/fflib-working-examples/main/ui/staticresources)
- **Event Attendee** is a Person Attending the Event with a **Name** and **Email**.
- **Board Game** is a Board Game with various attributes such as **Rating**, **Complexity**, and **Description**.
     - Contains links to **Images** for Board Games pulled from BoardGameGeek Website.
     - Link added to [Trusted Sites](/sfdx-source/fflib-working-examples/main/remote/cspTrustedSites/BGG_Images.cspTrustedSite-meta.xml)
- **Board Game Library Entry** is a concat table for **Board Game** and **Event**
     - Contains Forumla Fields to show if **Board Game** is Available For Check Out
- **Board Game Rating** is a list of reviews of **Board Games** by **Event Attendees**
- **Board Game Checkout Log** is a log of when a **Board Game** is checked out by an **Event Attendee** at an **Event**
---
Following Image Shows the Schema Relationships between the SObjects but might not contain all of the fields and formula fields for the SObject:

![Data Schema](/images/Schema.png)



