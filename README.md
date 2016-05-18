# On the Map
On the Map is an iOS app that lets you share a location and webpage with other Udacity students from around the world.

This app is a portfolio project from Udacity's "iOS Networking with Swift" course.

Both Udacity and Facebook account logins are supported.

![alt tag](Screenshots/login.png)

Logging in brings the user to a map showing where students have already placed pins.

![alt tag](Screenshots/map.png)

Tapping a pin displays the student's name and the webpage they provided. Clicking the popup opens a browser to the URL.

![alt tag](Screenshots/pin_detail.png)

Student locations can also be viewed in a list format. Tapping a student's name opens the linked URL.

![alt tag](Screenshots/list.png)

From either the map or the list the user has access to buttons for logging out, adding a new pin, and getting the most up-to-date student locations.

If a student location is already posted for the user, the app will ask if you want to overwrite it:

![alt tag](Screenshots/overwrite.png)

When creating a new location, the app will geocode the location into a coordinate on the map.

![alt tag](Screenshots/new.png)

Then the user specifies the URL and submits the new entry.

![alt tag](Screenshots/submit.png)
