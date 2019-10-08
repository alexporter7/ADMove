# ADMove
 Moves lists of computers into specified ad groups. Was made while setting up UCF downtown campus as hundreds of computers needed to be added in different groups and point and click is orders of magnitude slower then running a script. Lists can be obtained by using either a text editor to make a list or a barcode scanner app which is what I have done.
 
 # Usage
 There are a couple of configuration options inside the source code. The program will create three directories. "Logs", "Unprocessed", and "Processed". All logs are time stamped when the program begins and everything that happens in that instance will be logged and time stamped as well. After setting your options any lists of machines can be placed in the unprocessed directory. The program will run and if the amount of computers in the list you chose is equal to the change in the machines in active directory in that OU, the program will move the list to processed.
 
 # Configuration
 
 Line 46: $Prefix is what you would like the machines to be prefixed with. Will prepend automatically if computers in list don't have it
 Line 51: $Change_Description is a boolean which is if you would like to change description along with machine being moved
 Line 52: $Use_Manual_File instead of having it check a directory you can set $Computer_List in Line 80 to the path needed
 Line 53: $Use_Manual_Location This must be set to true as automatic location has not been implemented yet
 Line 77: $Location is where you select the location where the computers will be moved
 *Currently there is an array list in Line 70 where you can add commonly used Distingused Names and select the location through the array's index.

** This program although is working reliably is still under development and is more of a tool that you can script to fit your needs, however eventually a more stable version will be available. ***

# Version

======= 0.5.0 =======
Commited to Git

# To-Do
Check for duplicates
Dont count moves if computer ends up in same OU
Add wildcard location select && confirmation
Add Location from file
Improve before and after to check for list
Add automatic name csv implementation at head of file
