---
layout: post
title:  "Bug Report #1: Az CLI always creating a Public IP when non-interactive"
date:   2024-08-06 19:00:00 -0700
categories: bug-report
---

In today's bug report, we have an issue with the Az CLI extension `vm-repair`.

**Affected Repo:** [https://github.com/Azure/azure-cli-extensions](https://github.com/Azure/azure-cli-extensions)

## The Issue
When creating a repair VM via the Az CLI command `az vm repair create` both options to bypass the Public-IP address prompt always create a public IP. No option to avoid creating a public IP.

As documented [here](https://learn.microsoft.com/en-us/cli/azure/vm/repair?view=azure-cli-latest), this command has 2 parameters related to Public IPs.

- `--yes` Will create a public IP address for the VM.
- `--associate-public-ip` Will *also* create a public IP address for the VM.

However there is no way to create a repair VM non-interactively without also creating a public IP. When these parameters are used, they create Public IPs that are not within the common naming convention for VM resources.

## Reproduction steps

1. Open Az CLI in a shell session of some kind.
2. Add the `vm-repair` extension to the Az CLI.
   - `az extension add --name vm-repair`
3. Then create a repair VM using one of the following commands.

{% highlight bash %}
# uses --yes and creates a public IP address named 'False'
az vm repair create -g cloudj -n cloudj --yes --repair-username *********** --repair-password '***********' 

# uses --associate-public-ip set to '$False' and creates a public IP address named 'True'
az vm repair create -g cloudj -n cloudj --associate-public-ip $false --repair-username *********** --repair-password '***********' 

# uses --associate-public-ip set to '$True' and creates a public IP address named 'True'
az vm repair create -g cloudj -n cloudj --associate-public-ip $True --repair-username *********** --repair-password '***********' 
{% endhighlight %}

### Notes

- Using the interactive methods does deliver the expected results. `y` will create a public IP named `repair-cloudj_PublicIP`. Using 'n' will not create an IP.
- Even if IP is being created as expected, i.e. `--yes` or `--associate-public-ip`, it should still be in the proper naming convention `repair-<VM_Name>_<Resource>`.


## The fix

**Affected Repo:** [https://github.com/Azure/azure-cli-extensions](https://github.com/Azure/azure-cli-extensions)

In line 96 of `src/vm-repair/azext_vm_repair/custom.py` we can see the first call of `az vm create`.

{% highlight python %}
create_repair_vm_command = 'az vm create -g {g} -n {n} --tag {tag} --image {image} --admin-username {username} --admin-password {password} --public-ip-address {option} --custom-data {cloud_init_script}' \
.format(g=repair_group_name, n=repair_vm_name, tag=resource_tag, image=os_image_urn, username=repair_username, password=repair_password, option=associate_public_ip, cloud_init_script=_get_cloud_init_script())
{% endhighlight %}

According to the [documentation for `az vm create`](https://learn.microsoft.com/en-us/cli/azure/vm?view=azure-cli-latest#az-vm-create), the input for `--public-ip-address` will be the name of the new IP address. If the input is `'""'` then no public IP address is created.

Based on how the variable `associate_public_ip` is a boolean, whatever boolean value provided will be the new name of the Public IP.

The fix *should* simple. Check the variable `associate_public_ip` and then create a new variable containing a compliant naming scheme. This fixes the issue with the Public IP naming, but shows a second problem. There is no argument to non-interactively create the repair VM without a Public IP.

Still I fixed the naming issue and created the pull request.

{% highlight python %}
public_ip_name = '""'
if associate_public_ip or yes:
    public_ip_name = ('repair-' + vm_name + '_PublicIP')

# Set up base create vm command
if is_linux:
    create_repair_vm_command = 'az vm create -g {g} -n {n} --tag {tag} --image {image} --admin-username {username} --admin-password {password} --public-ip-address {option} --custom-data {cloud_init_script}' \
        .format(g=repair_group_name, n=repair_vm_name, tag=resource_tag, image=os_image_urn, username=repair_username, password=repair_password, option=public_ip_name, cloud_init_script=_get_cloud_init_script())
{% endhighlight %}

### The second issue

To fix the second issue, we need to create a new input parameter for the command. `--no` seems to make the most sense here. So that is what I went with.

To make a new parameter, we needed to edit the `_params.py` file. Specifically *fn* `load_arguments()`. *File path: src/vm-repair/azext_vm_repair/_params.py*

{% highlight python %}
with self.argument_context('vm repair create') as c:
    c.argument('repair_username', help='Admin username for repair VM.')
    c.argument('repair_password', help='Admin password for the repair VM.')
    c.argument('repair_vm_name', help='Name of repair VM.')
    c.argument('copy_disk_name', help='Name of OS disk copy.')
    c.argument('repair_group_name', help='Name for new or existing resource group that will contain repair VM.')
    c.argument('unlock_encrypted_vm', help='Option to auto-unlock encrypted VMs using current subscription auth.')
    c.argument('enable_nested', help='enable nested hyperv.')
    c.argument('associate_public_ip', help='Option to create repair vm with public ip')
    c.argument('distro', help='Option to create repair vm from a specific linux distro (rhel7|rhel8|suse12|ubuntu20|centos7|oracle7)')
    c.argument('yes', help='Option to skip prompt for associating public ip and confirm yes to it in no Tty mode')
    c.argument('no', help='Option to skip prompt for associating public ip and confirm no to it in no Tty mode')
{% endhighlight %}

Then we needed to ensure we would avoid the prompt for a Public Ip when we provided the new parameter. For this, we would have to edit *fn* `validate_create()` in the file. `_validators.py`

{% highlight python %}
# Prompt input for public ip usage
if (not namespace.associate_public_ip) and (not namespace.yes) and (not namespace.no):
    _prompt_public_ip(namespace)
{% endhighlight %}

Only change needed was ` and (not namespace.no)`.

## Conclusion

Once this fix was pushed. Public IPs in non-interactive mode were being created in the proper naming scheme. The best part; when we don't want a Public IP, we are no longer required to have one.

***Link to branch:** [https://github.com/jimurrito/azure-cli-extensions/tree/noPip-in-notty-mode](https://github.com/jimurrito/azure-cli-extensions/tree/noPip-in-notty-mode)*

<br>

---

<br>

<img src="https://avatars.githubusercontent.com/u/77898354?v=4" alt="Profile_Pic_Git" width="100" height="100"/>

Written by [James Immer](/bio)