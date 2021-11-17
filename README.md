# gcloud-node-executor

### Rundeck plugin wrapper for Accessing Gcloud.



*Setup.*

Simply copy the zip file from the releases folder, and move to the /libext directory on your rundeck server.

- A server restart will make the plugin available.
- Plugin will exist at a server or project level under 
- Project settings > Default Configuration > Default Node executor



*Configuration*

You will need to set the following attributes for the plugin to function.

| Name                         | Attribute                 | Notes                                             |
| ---------------------------- | :------------------------ | ------------------------------------------------- |
| GCloud Service Account Token | gcp_service_account_token | Json format token. Should be location in keystore |
| IAP Tunnelling               | gcp_iaptunnelling         | Utilise IAP tunnelling                            |
| Additional command line      | gcp_additionalcli         | Any additional CLI options                        |
| Zone                         | gcp_zone                  | The Zone of the project eg us-central-1           |
| Project                      | gcp_project               | GCP Project name                                  |
| Temp Directory               | gcp_tmpdir                | Directory for temp file processing                |
| Cloud executable             | gcp_gcloud                | Path location for gcloud binary                   |



The plugin will utilise a service account token, and run the following steps:-

- Gcloud auth Activate-service account
- Generate SSH keys
- Add keys via OSLOGIN
- Run SSH Command with above parameters
- Remove keys
- Tidy up



Any feedback is welcome.



