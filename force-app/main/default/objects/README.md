# Data Structure

## Custom Objects

![Data Schema](/images/Schema.png)

- **Event** is a Board Game Convention with a __Start__ and __End Date__.
- **Event Attendee** is a Person Attending the Event with a __Name__ and __Email__.
- **Board Game** is a Board Game with various attributes.
- **Event Board Game** is a concat table for **Board Game** and **Event**
- **Board Game Rating** is a list of reviews of **Board Games** by **Event Attendees**
- **Board Game Checkout Log** is a log of when a **Board Game** is checked out by an **Event Attendee** at an **Event**

## Custom Metadata Types

We will use Custom Metadata Types to control certain aspects of the DOMAIN and SERVICE Layer

- **Domain Config**: This Custom MDT allows us to toggle the following settings on the SObject's Trigger:
     - Bypass Error Handling
     - Bypass Triggers 
     - Prevent Recursion
- **Services Config**: This Custom MDT has a MetaData Relaionship to the **Domain Config** Record and allows us to toggle the following settings for a Method on the Service Class:
     - Enable/Disable Service Method.


