# Scratch Org Setup Instructions

1. Setup VS Code (or Similiar IDE) (If Needed)
     1. [Download VS Code](https://code.visualstudio.com/Download) 
     1. [Install latest Salesforce CLI](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_install_cli.htm) for `SF` Commands
     1. [Download this Repository to Local Machine](https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository)
1. Connect to DevHub Enabled Org
     1. [Request New Developer Org](https://developer.salesforce.com/signup) (If Needed)
     1. [Enable DevHub in Developer Org](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_setup_enable_devhub.htm)
     1. [Authorize DevHub Org](https://medium.com/@mariano.padularrosa/how-to-authorize-a-salesforce-org-from-vscode-178e17d73acc)
          1. **Org Alias**: DevHub

1. In VS Code, on the Terminal Tab, click the arrow next to the '+' sign and select "Git Bash"
1. In the Bash Terminal, enter the following command [^1]:
     ```
     ./bin/createScratchOrg.sh
     ```
     The script accepts the follow parameters (all are optional):
     - **Alias**: Name for Scratch Org
          - ```-a or -- alias < Scratch Org Name >```    
         - **Default:** myScratchOrg
     - **Duration**: Duration in days to keep Scratch Org Active
         - ```-d or --duration < Number of Days >```
         - **Default:** 4
     - **Config File Path**: File Path location of the Scratch Org Config JSON File
          - ```-f or --config-file < File Path >```
          - **Default:** config/project-scratch-def.json
     - **Clean**: Removes any existing Scratch Orgs of the same name, if found
          - ```-c or --clean ```
          - **Default:** false

---

[^1]: At first, I had this document list out all of the Salesforce CLI commands that needed to be run in order to setup the scratch org, add the metadata, and seed it will example data. I have since figured out how to create a Bash Shell script (with some help) that will automate the process. The downside is that, by automating, I lose out on learning / remembering / showing how to use the command line commands. So, to that effect, I will list out the instructions on how to run the script as well as break down each command. 

---

1. Create Scratch Org from DevHub for 7 Days

     ```
     sf org create scratch -f config/project-scratch-def.json -a MyScratchOrg -d -v DevHub -y 7
     ```

1. Deploy all Metadata to Scratch Org

     ```
     sf project deploy start -d sfdx-source -o MyScratchOrg -c
     ```

1. Assign Permission Set to User

     ```
     sf org assign permset -n BoardGamePS -o MyScratchOrg
     ```

1. Populate Data Using Plan

     ```
     sf data import tree -p ./data/Import-plan.json
     ```
