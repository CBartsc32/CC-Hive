#This part of the project has been assigned to dannysmc
-----

So for now, I have devised a good plan on how server requests work, and it will simply use serialised tables.

When I implement them I shall add the protocols here, current design idea for a powerful CC-Hive System:

	1 x Task Servers
	1 x Rednet Server
	1 x Client
	1 x Monitor Server
	1 x Disk Drive (With disk)

	(All of the above): Should be wired up to a LAN network using networking cable.

	8 x Turtles

The Task Server will deal with all task management, so generating all the new jobs to do, and giving them out, then the server will write to the disk. The Rednet Server will deal with all messages and save to disk to make sure it queues all content and broadcasts all responses / tasks in the buffer. The client will just allow you to control the server and set tasks etc etc. The monitor server will just allow you to connect a monitor to show on screen information. The turtles are the slaves.

I also think we shall use a plugin manager for the bulk of everything! So everything is a file that is all compiled when we run the Hive, meaning we can edit files easier. Make it all modular.

Thoughts?