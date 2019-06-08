## What does it do?
This new service allows you to insert any uncopylocked roblox model without any restrictions. It also sandboxes the models inserted to make sure they are safe and will not harm your game. It utilizes golang, lua, and python to achieve this.

## How does it work?
As you may know, creators can only insert models owned by them, which is one of the biggest hurdles when it comes to insert service. This bypasses this issue by setting up a web server that fetches the rbxm file of a model. The model has to be uncopylocked to do this, otherwise it will fail. The web server will then parse that rbxm file into JSON by using Anaminus' rbxfile, and send the JSON as a response to an http request sent by the lua module. The lua module will convert the JSON table to a standard lua table, and using that information will construct and compile it into a model. It will also sandbox the scripts in the model, ensuring no viruses or malicious scripts are in the virus.
![alt text](https://raw.githubusercontent.com/Robuyasu/Insert-Cloud/master/InsertCloudDiagram.png)
