there-and-back-again
====================
**Technical Test for Algolia**

# Tech stack
- Xcode 7.0.1
- Cocoapods 0.39.0

# Third Party
- Masonry
- AFNetworking'
- AlgoliaSearch-Client
- ReactiveCocoa
- Reveal-iOS-SDK
- RESideMenu

# How to run
The Pods are added to the repository so simply cloning and opening Algolia.xcworkspace should do the trick. Select the Algolia target and choose an iPhone simulator.

# About the application
This application uses the best-buy demo dataset and previews some possibilities with the AlgoliaSearch-Client SDK such as:
- Indexing
- Instant search
- Highlighting
- Faceting

... and more!

Home ViewController
===================
Shows an inspiring image and three CTAs. The first one is implemented and leads the user to the Search ViewController.

Search ViewController
=====================
If the user was redirected to this ViewController from the Home ViewController, the application shows a list of categories. If the user simply tapped the Search tabbar after launch it directly makes the searchbar the first responder and allows the user to directly start typing. If no instant search results are found, the application shows a list of recent searches. When the user start typing all the instant results are displayed. The matching text is highlighted on the screen in blue. Selecting an instant search result should open a view with detailed information about the object however this is out of scope for this assignment. Pressing search on the keyboard pushes a new ViewController with more search results matching the query. A user can tap the filter button to filter the found results by category or price. The latter one isn't implemented.
If a user selected a category instead of searching, the application shows all search results, with pagination, belonging in that category. If the user goes to the filter button again the user will notice that the previously selected category is already checked.

My Account ViewController
=========================
Out of scope for this assignment and not implemened. How a possibility how this "webapp" could look like.