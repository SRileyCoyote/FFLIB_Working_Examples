I have created a fork off each of the respective repos add them to our project using the `.gitmodules` file. This way intellisense should have access to all of our sourced fflib files which will allow us to be able to use the *Go To Definition* Menu option in VS Code. 

These are all pointing to my own forked copies so that I can make sure my code works with the committed versions that I have. However, it might be easier to change the submodules to point directly at the respective repos themselves instead. 

Either way, use the following command to sync all of the forked submodules to your repo
```
git submodule update --remote --recursive
``` 
Or run the following script in **Powershell**:
```
./bin/syncRepos.ps1
```
