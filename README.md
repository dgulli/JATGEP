# Just another Terraform GCP Example Project (JATGEP)
Hi All, 

This is a sample repo to get people started with Terraform and GCP. Nothing too ground breaking here, but a good place to check out some basics in combination with rough as guts ideas. there's some points against DRY here (and im sorry!) but itll get better over time. 

Using Terraform 0.13 for this, so please double check you're on the same version if so.

# Projects
Here are the projects within
## Global/Storage
Just a simple example of a GCP Bucket

## Examples/Dev/Services
Just a folder example to show people how to do environments by folder
### CAS
Demonstrates how to use the new GCP CAS service by deploying a Root CA in Ubuntu and creating a sub-ca in CAS, complete with IAP for remote access via 3389 tunneling.  Variables.example provides a template to use for the variables.tf file. 

CAsetup.sh will install all the required components to install a root standalone CA for testing.

Alternatively, there's a pure cloud version that just uses CAS for the root and the sub CA

## Tags
Demo tf to demonstrate how to create tags and affect org policies with them. will require knowledge of the gcloud commands to apply org policies due to the terraform resource for org policies and conditions not being GA yet.
### GCE
Just a sample GCE instance running some basic stuff
### Operations Suite Monitoring (Formally Stackdriver) and Notification Channels
Just a sample way of getting slack automated as a notification channel into Stackdriver (AKA Operations Suite Monitoring, but lets face it StackDriver sounded cooler). 

The idea with this one is simple: 
1. Slack uses Oauth, so scrape a valid token by doing a dummy request and then look at the network traffic in the browser (thanks to https://stackoverflow.com/questions/54884815/obtain-slack-auth-token-for-terraform-google-monitoring-notification-channel-res) for that one. if there's a more elegant way of doing this let me know. 
2. your build server (heaven forbid you use this in prod...) or laptop then uses that value to fill in the terraform token variable needed to run this.
#### Requirements
1. Needs a little bit of manual intervention to get the token, but then thats a one off. Store the token in your secrets manager (GCP secret manager for a great native solution), Harshicorp Vault or tfvars file.
2. You need to actually already have a workspace and project created like all other GCP automation things. This is due to the Operations Suite API not currently having a create workspace command just yet.
