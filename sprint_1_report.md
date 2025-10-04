Sprint x Report
Video Link: https://youtu.be/Yg9SyHv38SU 

What's New (User Facing)
 - Mock leaderboard feature
 - Gym Check-in geolocation feature
 - Workout social widget
 - UI Figma prepared

Work Summary (Developer Facing)
Our team created a barebones foundation for what minimal viable product functionality looks like in our application. We added a mock-leaderboard with currently hardcoded data to simulate users, a workout social widget to demonstrate how the social/sharing aspect of workouts will work, and a gym check-in feature to get users comfortable with that concept. The check-in button detects whether the user is within 200m of the gym (currently hardcoded to student recreation center), and if so, allows check-in to proceed. These features were our main focus for the first sprint, as we believed them to be our MVP features. On the user interface side, we developed a full-on user interface for all functionality in Figma, following color palettes and incorporating functionality derived from surveys conducted on numerous real gym-goers. We realized in the sprint that we overloaded too many resources (two people) on UI and had to overcome the barrier of duplicate work being done. Throughout the sprint, we learned how to work synchronously and asynchronously, and had to overcome the barrier of communicating the work being done by improving means of communication. We learned to harness Discord as a centralized means of communication with various logs to keep track of our work (paired with the Kanban board, of course). We also battled learning new frameworks like Flutter which none of us were familiar with, which took a long time, but through collaboration we overcame this problem.

Unfinished Work
We had a few issues that were not main priorities for sprint one, which can get pushed to sprint 2. These issues include User Login & Account Access, Streak Check-In, New User Account Setup, and hooking up a backend. We choose to focus on fleshing out our UI and refining the front-facing parts of the for this spring so that we would have a clear vision going forward.

Completed Issues/User Stories
Here are links to the issues that we completed in this sprint:

https://github.com/CharlesLiuCool/gymroyale/issues/7 
https://github.com/CharlesLiuCool/gymroyale/issues/11 
https://github.com/CharlesLiuCool/gymroyale/issues/2 

Incomplete Issues/User Stories
Here are links to issues we worked on but did not complete in this sprint:

https://github.com/CharlesLiuCool/gymroyale/issues/3 
https://github.com/CharlesLiuCool/gymroyale/issues/8 
https://github.com/CharlesLiuCool/gymroyale/issues/5 

Code Files for Review
Please review the following code files, which were actively developed during this sprint, for quality:

https://github.com/CharlesLiuCool/gymroyale/blob/b8aed3ffad1a044fd6a99472feff771611c9c7a9/lib/widgets/gym_checkin_button.dart 
https://github.com/CharlesLiuCool/gymroyale/blob/b8aed3ffad1a044fd6a99472feff771611c9c7a9/lib/widgets/leaderboard.dart 
https://github.com/CharlesLiuCool/gymroyale/blob/b8aed3ffad1a044fd6a99472feff771611c9c7a9/lib/widgets/leaderboard_row.dart 
https://github.com/CharlesLiuCool/gymroyale/blob/8ea686c56ef69f12e4a544996f29b817203ab3c0/lib/models/workoutActivity.dart 
https://github.com/CharlesLiuCool/gymroyale/blob/8ea686c56ef69f12e4a544996f29b817203ab3c0/lib/models/user.dart 
https://github.com/CharlesLiuCool/gymroyale/blob/8ea686c56ef69f12e4a544996f29b817203ab3c0/lib/widgets/workoutCard.dart 

Retrospective Summary

Here's what went well:

Changes to our workflow by communicating more and delegating work better helped a lot in streamlining the process.
Harnessing Discord to keep track of various things like AI-usage and key resources was helpful, especially as all of us are familiar with it.
Meetings at least twice weekly over Discord voice call helped a lot, and regrouping after lecture to discuss where our next direction is.

Here's what we'd like to improve:

We’d like to stay on pace even when midterms or personal events occur
We’d like to ensure everyone shows up on time to our meetings so we have a clear picture of production
We’d like to have clearer documentation/logging of work produced.
Preventing duplicate work by delegating better and having clearer communication.

Here are changes we plan to implement in the next sprint:

Planning around future unavoidable events like midterms and other personal events better would be helpful so we can consistently stay on pace.
Plan out meetings better, and make sure everyone shows up on time. This would help prevent time wasted waiting and ensure efficiency.
Document our work, changes, and media better for clearer logging of work produced and challenges faced.
Meet even more frequently, and allocate more resources to backend development instead of user interface development (especially crucial for prototyping phase).
