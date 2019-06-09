# Decided to "fix" memory leaks by creating a python script that runs every x minutes to restart app.
# Although this can be fixed through ruby, I did this in python because I am a lazy bum rawr xd
# Anyone viewing this code, please inform me on how to properly set up ruby.
import heroku3
import time
import os

print(os.environ.get("HEROKU_KEY"))
account = heroku3.from_key(os.environ.get("HEROKU_KEY"))
print(account)
app = account.apps()[os.environ.get("HEROKU_APP_NAME")]

def restart_app():
    print("Restarting application")
    app.restart()   
    print("Restarted application")

# restart_app()
while True: #Restart application every 10 minutes
    print(os.environ.get("SCHEDULE"))
    time.sleep(int(os.environ.get("SCHEDULE")))
    restart_app()
