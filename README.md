# md_final


# Youtube videos

Jacob's Video
https://youtu.be/dFsSgRhnrGg


Aaron's Video
https://youtu.be/y3QyRuAlYaM

Mobile Devices Final Project

This application was designed to be a fitness application that enables users of all kinds to improve their physical health through workout routines, nutritional guides, and association with their friends. There are many thought out features within this application that allow individuals to achieve their fitness goals throughout each and every feature. While not all features of the application are fully built out at his point, we have the fundamentals down as follows,

# Requirements

### Multiple screens / navigation
Implemented with a BottomNavigationBar widget

### Dialogs and Pickers
There are multiple user interactions throughout the app. A picker is used in workout creation.
The nutrition page uses a dialog to set the nutritional goals

### Notifications
A notification is sent when a user logs in
A notification is sent when a user creates, changes or deletes a goal in the nutrition page

### Snackbars
A snackbar is placed on the login screen
Another snackbar is done when a user deletes a workout

### Local Storage
Local storage is used to store user settings such as whether or not they have dark mode  

### Cloud Storage
Cloud storage is used to store the foods created in the nutrition portion of the app
Cloud storage is also used store the meals the user creates in the nutrition portion of the app 

### HTTP Requests
An HTTP request is made to get a quote from: https://zenquotes.io/api/today/
The quote is retrieved as a JSON object and is parsed for both the Quote and the Author.




## We have fully implemented login functionality that promotes user security:

We allow users to create an account with their email address and password which enables them to track all of their fitness progress securely. During the signup process, there is a lot of helpful feedback which is given to users to help guide them in successfully registering for an account.  If a user happens to forget their password, they can easily reset it by entering the valid email address that is associated with their account0. Once logged on, the users will receive a notification informing them they have successfully logged in and they will remain logged in until they choose to log out on their profile. This allows for the most user convenience throughout daily use. All accounts are able to be managed by administrators using FireBase, which is an easy to use and secure database application. 

## The home page:

When a user successfully logs into their account, they are immediately greeted by our welcoming home screen. It greets the user with a motivational quote for the day, using http requests, which helps inspire them to better themselves through their journey. From the home screen, they are able to select one of 4 different options which is Nutrition, Workout, Social and profile.



## We have a strong start to the nutrition functionality: 

So far the users are able to track what nutrients they are consuming for every meal. This is done by getting the users to create the food themselves with as much information as they can enter (e.g. calories, protein, fats, sugar…) which is then saved to our Firebase cloud storage. Once saved the user can add it to their current meal and any future meal. Once a food is added to a meal it will be displayed on the Log page as well as how many calories the food has and it will update the total calorie consumption for that meal. The meals are also saved on our Firebase cloud storage. The second feature implemented is our goal setting, this feature lets the user choose what they want to track and then be able to set the goal. Creating, changing, or deleting a goal will send a notification to the user informing them that the goal has been created, changed, or deleted. 




## Proof of concept cloud storage for user workouts
Users are able to add and delete workouts (planned edit functionality later). The app will also group workouts by the workout name, to allow easier viewing. This is done through a Card and ExpansionTile widget. All user data is stored under their own user collection in firebase. 

## The social element of the application:

This feature is yet to be implemented, but will include users ability to post their progress, and compare themselves to each other in order to drive competition if they so choose.

## The profile:

The user is able to access their profile at any time which contains key information about their account, and in the future it will give them personalized results regarding their progress. From this personalized progress, they can share it with their friends through their social profile yet to come.

