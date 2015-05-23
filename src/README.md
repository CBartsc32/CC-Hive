#To Do List

####Turtle Stuff
* [x] Update lama (last forum post said that it was buggy/not working in CC1.63)
* [ ] Combine lama with starNav?
* [ ] turtle movement api - make it emit turtle_moved event?
* [ ] turtle task requester
* [ ] tracking reporter
* [ ] tasks run in a sandbox, file access is done in a folder (some tasks may need to see rom, so we will have to emulate it) https://github.com/lupus590/CC-Hive/issues/23
* [ ] sudo mode to escape sandbox (I have no idea where scripts may need this "super user" access, but someone may want to escape the sandbox and this will provide a way that is plesent for both the turtle and user)

####Server Stuff
* [ ] task master
* [ ] turtle watcher

####Client
* [ ] API
* [ ] Command Line Interface (should use api) Bonus, if api is ran as a program it provides the command line
* [ ] Graphical User Interface (should use the api)

####Shared
* [ ] remote connect - control computers like you are there, using Lyquds' nsh and vncd, still have to get the luancher to use this thing
* [ ] lua table for storing user settings
* [ ] an issue is opened on github when Hive crashes [github api reference](https://developer.github.com/v3/issues/#create-an-issue)

####Installer
* [ ] choose a directory to install too (based of location of installer?)
* [ ] package system
* [x] independent from repo folder structure (currently under testing)
* [ ] updater option (depends on package manager)

####Help Docs
* [ ] help docs are "registered" with the default help program
* [ ] make wiki on github repo? add one on CC wiki?
* [ ] BONUS: if a printer is detected, offer to print a manual
