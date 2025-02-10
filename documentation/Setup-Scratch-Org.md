## Scratch Org Setup Instructions

Here are step-by-step instructions on how to Setup a Scratch Org, Install this Repo's Metadata, and Seed it with Data.

1. Setup VS Code (or Similiar IDE) (If Needed)
     1. [Download VS Code](https://code.visualstudio.com/Download) 
     1. [Install latest Salesforce CLI](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_install_cli.htm) for `SF` Commands
     1. [Download this Repository to Local Machine](https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository)
1. Connect to DevHub Enabled Org
     1. [Request New Developer Org](https://developer.salesforce.com/signup) (If Needed)
     1. [Enable DevHub in Developer Org](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_setup_enable_devhub.htm)
     1. [Authorize DevHub Org](https://medium.com/@mariano.padularrosa/how-to-authorize-a-salesforce-org-from-vscode-178e17d73acc)
          1. **Org Alias**: DevHub
1. Create Scratch Org from DevHub for 30 Days

     ```
     sf org create scratch -f config/project-scratch-def.json -a MyScratchOrg -d -v DevHub -y 30
     ```

1. Install Unmanaged Package Dependencies 

     ```
     sf package install -p 04t8b00000170r5AAA -w 30 -o MyScratchOrg
     sf package install -p 04t5G000004fzAgQAI -w 30 -o MyScratchOrg
     ```

1. Deploy all Metadata to Scratch Org

     ```
     sf project deploy start -d force-app -o MyScratchOrg -c
     ```

1. Assign Permission Set to User

     ```
     sf org assign permset -n BoardGamePS -o MyScratchOrg
     ```

1. Populate Data Using Plan

     ```
     sf data import tree -p ./data/Import-plan.json
     ```