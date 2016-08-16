# dataImportScripts
currently supports Mambu -> Mifos


How to do Philippines Migration:

Set up Mifos and Databases

 - Start by getting Mifos running. Use the server from the 0.1.0-incubating branch of the repo at https://github.com/apache/incubator-fineract.git and the community-app on the 0.1.0-incubating branch at https://github.com/openmf/community-app.git.
 - At this point, as part of the set up of Mifos, you should already have MySQL set up. If you did not use MySQL Workbench for that, you will need to use it now. Download and install the MySQL Workbench that is the same version as your MySQL server.
 - Get a backup of the Mambu data. Use the retrieval tool aws (http://timkay.com/aws/). Get the awssecret from someone who knows it. Extract the backup once it downloads.
 - Open Workbench and open the connection that has mifostenant-default.
 - Import the mambu data from the backup.
 ![alt tag](http://url/to/img.png)


Create Basic Info in Mifos

 - Run Mifos and log in.
 - Go to System / Admin / .. and turn all the settings to "Disable".
 - Manually add all the offices, staff, centers, loan products, and savings products.
 - You can close Mifos now and stop the server.

Do First Section of MySQL Script

 - In Workbench, open the dbMigrationScript_manila3.sql **If possible, keep Workbench open the whole time so that the session has the same settings (safe updates, read timeout, etc.) the whole time. If that slows down the computer too much, just run these lines when you open it again `SET SQL_SAFE_UPDATES = 0; set global connect_timeout=60000;`
 - Hightlight from the beginning down to where it says STOP, like the comments tell you to.
 - Click the lightning button to run the highlighted parts.

Do First Python Script

 - You need python 3 set up on your computer.
 - Follow the instructions in the comments after the STOP.
 - You need to have the backend server of Mifos running.
 - When you run the loan_transacitons.py from the command line, this will be the command in Linux `python3 loan_transactions.py`
 - You might need to install modules. You can do that from the command line like this: `pip3 install requests` if you need to install the module requests. Or for simplejson: `pip3 install simplejson`, etc.
 - In Windows the commands will be the same but without the 3. So: `pip install ...` or `python loan_transaction.py`

Do Second Section of MySQL Script

 - Do this just like the first section of MySQL, but highlight from START to STOP 2.


Do Second Python Script

 - Do this just like the first script, following the instructions after STOP 2.

Follow this pattern until you reach the end of the SQL file.

After that, restart Mifos, open the frontend and log in. If you look at a loan's transactions, they will not add up correctly to the loan balance. You need to click the button to update the laon balances. It's in System/Admin/ like the end of the dbMigrationScripts_manila3.sql file says.