sysctl2 Cookbook
====================
A cookbook to configure kernel parameters on a system.  It supports configuring files in /etc/sysctl.d, and in /etc/sysctl.conf directly (mainly to support RHEL/CentOS 5 & 6).

Requirements
------------
Should support any linux platform, but has been tested successfully on:

  - rhel >= 5.0
  - centos >= 5.0
  - ubuntu >= 12.04
  - fedora >= 17.0

Attributes
----------
#### sysctl::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['sysctl']['conf_dir']</tt></td>
    <td>String</td>
    <td>The directory where the config file is located</td>
    <td><tt>/etc/sysctl.d</tt></td>
  </tr>
  <tr>
    <td><tt>['sysctl']['conf_file']</tt></td>
    <td>String</td>
    <td>The config file name</td>
    <td><tt>999-chef-sysctl.conf</tt></td>
  </tr>
</table>

Usage
-----
#### sysctl::default
Set attributes in the sysctl/params namespace to configure kernel parameters.  Example values:

    node.set['sysctl']['params']['kernel.sysrq'] = 0
    node.set['sysctl']['params']['net.ipv4.ip_local_port_range'] = '30000 65000'

Then, just include `sysctl` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[sysctl]"
  ]
}
```

For platforms that don't support setting parameters via files in the /etc/sysctl.d directory (RHEL/CentOS 6 and lower), setting the sysctl/conf\_dir attribute to '/etc' and the sysctl/conf\_file attribute to 'sysctl.conf' will allow you to set kernel parameters in the correct/expected location for that platform.  Unfortunatly, that also means that you'll need to be aware of kernel parameter changes in other recipies, and be sure to include them in your attribute list, in order to not miss them.

The default sysctl/conf\_file attribute value gives us a reasonable chance of being the last config file applied.  The files are processed according to their ASCII sort order, so there is still room to add more files to be processed after the recipe default file by naming the config file with leading character prefixes (ex. zzz-last.conf).

License and Authors
-------------------
Authors: Michael Morris

License: 3-clause BSD
