# Just another Terraform GCP Example Project (JATGEP)
Hi All, 

This is a sample repo to get people started with Terraform and GCP. Nothing too ground breaking here, but a good place to check out some basics in combination with rough as guts ideas. there's some points against DRY here (and im sorry!) but itll get better over time. 

Using Terraform 0.13 for this, so please double check you're on the same version if so.

Feel free to reach out to me on twitter (https://www.twitter.com/DavidGulli)

# Projects
Here are the projects within
## Global/Storage
Just a simple example of a GCP Bucket

## Environments/Dev/Services
Just a folder example to show people how to do environments by folder
### GCE
Just a sample GCE instance running some basic stuff
### Operations Suite Monitoring (Formally Stackdriver) and Notification Channels
Just a sample way of getting slack automated as a notification channel into Stackdriver (AKA Operations Suite Monitoring, but lets face it StackDriver sounded cooler). 

The idea with this one is simple: 
1. Slack uses Oauth, so scrape a valid token by doing a dummy request and then look at the network traffic in the browser (thanks to https://stackoverflow.com/questions/54884815/obtain-slack-auth-token-for-terraform-google-monitoring-notification-channel-res) for that one. if there's a more elegant way of doing this let me know. 
2. your build server (heaven forbid you use this in prod...) or laptop then uses that value to fill in the terraform token variable needed to run this.
#### Requirements
1. Needs a little bit of manual intervention to get the token, but then thats a one off. Store the token in your secrets manager (GCP secret manager!) or tfvars file. P
2. You need to actually already have a workspace and project created like all other GCP automation things.
