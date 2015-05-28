#This part of the project has been assigned to dannysmc

### New explainations here for you to see and read to explain what I have done:

Due to my slowness I apologise, have been very busy at work. BUT I have a successful plan for the code, as you may know it will run quite a bit all at once. So I have started implementing a thread manager, that will allow us to have up to 25 threads. This means we can wait for 25 different inputs, all via rednet, so in essence you can have say 2 clients, a few pocket PC's and up to 20 turtles that will be controlled constantly, now I know you will ask why would you set it to 25 and not more, well after testing, Lua isn't fast enough to be able to switch back and forth fast enough. By limiting drawing to screen and monitor, I have successfully allowed up to 25 threads to run before it gets unstable and the server will start missing stuff when running other functions. Please note why you guys have been keening over the turtle software you need to follow a set of rules that the server will accept, the server will never take messages as a plain string, every message has to be a serialized table. I also will be setting it to use my own key exchange mechanism I made that is based heavily off diffie hellman, this is trialed and tested and makes it pretty much impossible considering it does the maths then converts it to base64, then to binary then sends it. Now you may think that is silly, that would take too long, wrong, the turtles can be rogue and be controlled by others the way this system works, by sending and receiving data that is encrypted, it makes it less likely anyway can view the data and a hell of a lot more secure to send data like this. The turtle only has to do this once upon connection then they both share a key for encrypting and decrypting data. Please note that when I started implementing the system core functions it dawned that while the system runs I/O functions it will slow it down a lot which means, everything has to be stored in files because if the server restarts, it needs to be able to continue. I have also added support for plugins, things like when the server is about to restart it can use a chatbox to catch the message figure out what it is doing and switch off and save all the data before hand to limit loss of data. I have also added support for turtles exchanging contents.

Now on to the server messages. When you send a server it HAS to be in this format:
{
	"user_agent",
	"sys_command",
	"command",
	"data1",
	"data2",
	"data3",
	"etc",
}

Now the user agent will be "pocket", "turtle", "computer", "stats", the first 3 are obvious the 4th one allows support for a monitor and a computer that can talk and view stats on any monitor size. It will display the turtle name, and the status, clicking this will show a more in-depth summary and will allow you to view the messages sent to and from the turtle. It also supports the amount of clients connected and a nice big warning message when a turtle leaves rednet range or when it crashes! :D

sys_command is of course the type of command, whether you wish to use a client command and do something like {"pocket", "client", "list-all"}, to view all the currently connected devices or use {"computer", "turtle", "nsh"} to connect to a computer, all NSH based connections will through the server, encrypting data to and from.

command is the actual command so in the examples above I used "nsh" or "list-all" I have made a documentation and you can see it when I get round to finishing it.

data1 - to whatever is what ever content you NEED to send it, so if you wish to register a new turtle the data spaces can have the name, command, label etc, and they are not limited, it will take what it needs from it.

I have made it as small as possible, also I have made a way of communicating via redstone for a bit of fun which works very nicely! So if you really want to show off (I made this to show off how powerful the server software is) but it encrypts to binary so you can use two computers linked with a simple redstone current and it will send data via that channel as well. This is cool but like I said just to show off.

Now to explain the plugins:
+ As you would of known I said I would love to add plugins, well when the server initialises it loads all of its functions from files, and then the plugins load after, so you can overwrite functions with plugins to add more functionality. Also I made a patch system to patch files and even better the server uses a type of versioning so when it updates it will check a current table of all the files and what version they are and update them to the newest version. SO it doesn't re-install the whole thing.

Multi-Hive:
I got a luttle bored at one point and added a new thing called multi-hive which in fact allows you to exchange turtles etc using a turtle pool, we will not have a public turtle pool, but we can use other turtle pools when we need to, and when they finish the task it will come back to it's home. All turtles have a set of configuartions and hard data to explain where it comes from etc. Please NEVER edit this.

I have uploaded this to github, so you can view it.
