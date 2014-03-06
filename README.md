# Cloudstack Nagios

Cloudstack Nagios helps you monitoring your Cloudstack environment with Nagios.
Cloudstack Nagios uses the Cloudstack API to collect information about system vm's and ressources.

The following checks are supported:
  * system and network checks for virtual routers
  * storage pool capacity checks
  * global zone capacities

## Prerequisites

  * Cloudstack Root Admin keys have to be used.
  * In order to connect to system VMs the private ssh key found on the Cloudstack management server under /var/lib/cloud/management/.ssh/id_rsa are required.
  * The system vms must be reachable over SSH (default port 3922) from the nagios server executing the checks (check with 'ssh -i /var/lib/cloud/management/.ssh/id_rsa -p 3922 <router_mgmt_ip>').

## Installation

Install the cloudstack-cli gem:

```bash
$ gem install cloudstack-nagios
```

## Setup

Create the initial configuration:

```bash
$ cs-nagios setup
```

cloudstack-nagios expects to find a configuartion file with the API URL and your CloudStack credentials in your home directory named .cloudstack-cli.yml. If the file is located elsewhere you can specify the loaction using the --config option.

cloudstack-nagios supports multiple environments using the --environment option.

Example content of the configuration file:

```yaml
:url:         "https://my-cloudstack-server/client/api/"
:api_key:     "cloudstack-api-key"
:secret_key:  "cloudstack-api-secret"

test:
  :url:         "http://my-cloudstack-testserver/client/api/"
  :api_key:     "cloudstack-api-key"
  :secret_key:  "cloudstack-api-secret"
```

## Usage

### Basics

See the help screen:

```bash
$ cs-nagios
```

### Generate Nagios configuration files

Note that you can also use your own ERB templates using the '--template' option to generate the nagios confifuration files.

Generate nagios host configuration for virtual routers:

```bash
$ cs-nagios nagios_config router_hosts
```

Generate nagios host configuration for virtual routers:

```bash
$ cs-nagios nagios_config router_services
```

Generate nagios host configuration api hosts (one pseudo host per Cloudstack zone):

```bash
$ cs-nagios nagios_config api_hosts
```

Generate nagios service configuration for storage pool checks:

```bash
$ cs-nagios nagios_config storage_pool_services
```

Generate nagios service configuration for capacity checks:

```bash
$ cs-nagios nagios_config capacity_services
```

### System VM checks

For all vm checks access to the cloudstack management network is required in order to run the ckecks via ssh or snmp.

#### Check system vms over ssh

The following checks are available:
  
   * memory - measure memory usage in percents
   * cpu - measure cpu usage in percent
   * network - measure network usage
   * rootfs_rw - check if the root file system is writeable
   * disk_usage - check the diks space usage of the root volume

Example:

```bash
$ cs-nagios check system_vm network --host 10.100.9.161
```

#### Enabling snmpd checks for system vms

If you want to check your system vms with standard Nagios snmp checks instead of checking over SSH, there are commands to configure snmpd on the machines and open the firewall.

   * snmpd_config enable - goes to all the routers and configure snmpd
   * snmpd_config check - test if port TCP 161 is reachable on routers

Note: If you want to use snmp checks, you have to adapt the nagios configuration files accordingly.

### Capacity checks

Checks various global capacity values.

Example:

```bash
$ cs-nagios check capacity memory --zone ZUERICH_IX
```

### Storage Pool checks

Checks the available disk space on Cloudstack storage pools.

Example:

```bash
$ cs-nagios check storage_pool --pool_name fs_cs_zone01_pod01
```

## References

  * [Cloudstack API documentation](http://cloudstack.apache.org/docs/api/apidocs-4.2/TOC_Root_Admin.html)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

Released under the MIT License. See the [LICENSE](https://bitbucket.org/swisstxt/cloudstack-cli/raw/master/LICENSE.txt) file for further details.
