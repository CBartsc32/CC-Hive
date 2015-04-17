##### Hive System: Server API


This is the API and what I will be building into the server's core functions, please note if you want to add something just add it in and I shall look at how to implement it.

Functions are split into core, jobs, turtles, destinations, clients, servers, gps, sos, ssh, etc.

Protocols are used via pocket computers, and some clients and don't always use the following, the below is just a display to see your ideas.

##### PROTOCOL NAME -> Name -> DESCRIPTION

* COR -> Core -> These are core functions and are built straight into the base code of the hive server.
* RQT -> Requests -> These are request functions and are what is used to actually ask for a job to be completed.
* JOB -> Jobs -> These are for jobs, this could be assigning, adding, deleting, etc.
* TRT -> Turtles -> This is for interacting with turtles, and getting statuses.
* DST -> Destinations -> This is for interacting with destinations and getting, adding, deleting and editing.
* CLT -> Clients -> This for connecting to clients that are around, and getting information about them.
* SRV -> Servers -> This is for connectivity with servers.
* GPS -> Global Positioning System -> This is for the GPS system and for turtles to get around.
* SOS -> Save Our Souls (HELP) -> This is the help mode and will be talked to as soon as a problem arises.
* SSH -> Secure Shell -> This is for connecting to turtles securely.

##### Format: function name -> arguments -> return

##### Glossary:

* hivecode -> This is the code for your private hive, a public hive will assign a private hive one.
* streamid -> This is the protocol and passkey your client will use to talk to the server when you start assigning tasks.
* username -> This is a username that you will set on startup to allow only you access to high level commands.
* password -> This is a password that you will set on startup to allow only you access to high level commands.
* protocol -> This is a protocol that we use as normal rednet is too open therefore we have to restrict access for other computers to hack in.
* jobpcsid -> This is a job process id and will be the id that you get when you request a job


##### API FUNCTIONS:

(FORMAT: function - arguments - return) (All functions will return false if failed, nothing else, check server log for details)

###### Core:
* hive_core_connect -> "ping" -> "serverid"
* hive_core_disconnect -> connection code -> "true" or "false"
* hive_core_requestpair -> username, password, hivecode -> "streamid"
* hive_core_requestunpair -> username, password, hivecode, streamid -> "true"

###### Request:
* hive_request_query -> Destination -> "true" or "false"
* hive_request_job -> Job name or id, destination name or id -> "jobprocessid"
* hive_request_cancel -> jobprocessid -> "true" or "false"

###### Jobs:
* hive_jobs_add -> name, job_description, job_code -> "true"
* hive_jobs_edit -> name or id, job_description, job_code -> "true"
* hive_jobs_delete -> name or id -> "true"
* hive_jobs_list -> nil -> {{All jobs in two dimensional table}}

###### Destinations:
* hive_dest_add -> name, dest_description, {X,Y,Z} -> "true"
* hive_dest_edit -> name or id, dest_description, {X,Y,Z} -> "true"
* hive_dest_delete -> name or id -> "true"
* hive_dest_list -> nil -> {{All destinations in two dimensional table}}

###### SSH:
* hive_ssh_connect -> turtlename -> id
