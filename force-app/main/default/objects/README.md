# Data Structure

For this example, I put together a small Application in Salesforce based on what I know best: Board Game Conventions.

![Data Schema](/images/Schema.png)

- **Event** is a Board Game Convention with a __Start__ and __End Date__.
- **Event Attendee** is a Person Attending the Event with a __Name__ and __Email__.
- **Board Game** is a Board Game with various attributes.
- **Event Board Game** is a concat table for **Board Game** and **Event**
- **Board Game Rating** is a list of reviews of **Board Games** by **Event Attendees**
- **Board Game Checkout Log** is a log of when a **Board Game** is checked out by an **Event Attendee** at an **Event**
