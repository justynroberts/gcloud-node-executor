# Google Cloud Node Executor for Rundeck

### Rundeck plugin wrapper for Accessing Google Cloud Platform via SSH



*Setup.*

## Getting the source

`git clone https://github.com/justynroberts/gcloud-node-executor`

## Building the plugin

  1. `make clean`
  2. `make build`
  3. The plugin will be available to the build/zip directory.

Copy this to the libext directory or use the UI to import

- A server restart will make the plugin available.
- Plugin will exist at a server or project level under Project settings > Default Configuration > Default Node executor



### *Configuration*

You will need to set the following attributes for the plugin to function.

| Name                         | Attribute                 | Notes                                             |
| ---------------------------- | :------------------------ | ------------------------------------------------- |
| GCloud Service Account Token | gcp_service_account_token | Json format token. Should be location in keystore |
| IAP Tunnelling               | gcp_iaptunnelling         | Utilise IAP tunnelling                            |
| Additional command line      | gcp_additionalcli         | Any additional CLI options (use with care)        |
| Zone                         | (*) zone                  | The Zone of the project eg us-central-1           |
| Project                      | (*) projectId             | GCP Project name.                                 |
| Temp Directory               | gcp_tmpdir                | Directory for temp file processing                |
| Cloud executable path        | gcp_gcloud_path           | PATH location for gcloud binary   (NEEDS /)       |


* Both projectId and zone are compatible with the GCP node source plugins

### Sample Node Source 

Node sources can be used to override individual attributes PER NODE (Managed endpoint). A full list of relevant parameters are below.

```
gcp-instance-1:
 nodename: gcp-instance-1
 hostname: rundeck-node-1
 osFamily: unix
 zone: us-central1-a
 projectId: rundeck-331117
 node-executor: GoogleCloudNodeExecutor
 file-copier: GoogleCloudFileCopier
 gcp_service_account_token: keys/project/key.json
 gcp_iaptunnelling: true
 gcp_additionalcli: --verbosity=debug
 gcp_tmpdir: /tmp/rundeck/
 gcp_gcloud: /opt/homebrew/bin/
```

Tip.
Consider nesting node enhancers to add top level attributes (eg node-executor,file-copier,gcloud path)
Then adding additional project specific attributes in an additional enhancer. eg  gcp_iaptunnelling or gcp_service_account_token)


### Info

The plugin will utilise a per project service account token, and run the following steps:-

- Gcloud auth Activate-service account
- Generate SSH keys
- Add keys via OSLOGIN
- Run SSH Command with above parameters
- Remove keys
- Tidy up



Any feedback is welcome.

Any problems with zip files you may have to build manually by extracting the src folder and rezipping to your platform.


