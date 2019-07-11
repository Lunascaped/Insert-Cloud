## What does it do?
This new service allows you to insert any uncopylocked roblox model without any restrictions. It also sandboxes the models inserted to make sure they are safe and will not harm your game. It utilizes GoLang, Lua, and Python to achieve this.

## How does it work?
As you may know, creators can only insert models owned by them, which is one of the biggest hurdles when it comes to insert service. This bypasses this issue by setting up a web server that fetches the rbxm file of a model. The model has to be uncopylocked to do this, otherwise it will fail. The web server will then parse that rbxm file into JSON by using Anaminus' rbxfile, and send the JSON as a response to an http request sent by the lua module. The lua module will convert the JSON table to a standard lua table, and using that information will construct and compile it into a model. It will also sandbox the scripts in the model, ensuring no viruses or malicious scripts are in the virus.
![alt text](https://raw.githubusercontent.com/Robuyasu/Insert-Cloud/master/InsertCloudDiagram.png)
The web server is used by Heroku, which is a free application deployment platform.

## Packages
You will need Heroku CLI to use set up the server and a heroku account.

Installation Guide: https://devcenter.heroku.com/articles/heroku-cli
Mac Installation: ```brew tap heroku/brew && brew install heroku```
Ubuntu 16+ Installation: ```sudo snap install --classic heroku```

## Installing
Download the repo using git, or download as ZIP.

```git pull https://github.com/Robuyasu/Insert-Cloud.git --allow-unrelated-histories```

Navigate to insertserver directory. Then, use command ```heroku create```.
On the heroku dashboard website, navigate to your application and use the heroku/go buildpack in settings.
Go to Config Vars, and set up your environment variables there.

After setting the server up, test it by sending a get request. 
Then, and set up a server script and requiring the InsertCloud in one of your roblox places.

```lua
local InsertCloud = require(2988483384);
local Key = 'APIKEY';
local URL = 'https://appname.herokuapp.com/assets/';

local Model = InsertCloud:LoadAsset(URL, KEY, RBXID);
```
InsertCloud also comes with most of the InsertService functions, and a built in Sandbox which helps sandbox your scripts.

## ENV Variables
HEROKU_APP_NAME : The name of your heroku app
HEROKU_KEY : The API key for your heroku account
USRNAME : The username or email of your heroku account
KEY : The API key for your application. Make sure it is secure

## Usages
You can parse a RBXM file into JSON using this by doing
```https://herokuappname.herokuapp.com/assets/apikey/rbxid```
You can also use the lua module to parse the JSON and compile that into a model, and having that as a replacement for InsertService.
