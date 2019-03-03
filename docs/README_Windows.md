# Windows Setup

## On the Windows System

It is assumed that all of the VMware Workstation core tools already resolve from the Windows CMD shell.

Specifically, two are required to be in the path:

* vmware-vdiskmanager
* ovftool

With some specific requirements listed below for ovftool.

### 1. Install Packer 1.04 or Later
 
Packer is a simple install of a single binary distributed as a zip.

    curl https://releases.hashicorp.com/packer/1.0.4/packer_1.0.3_linux_amd64.zip?_ga=2.23882047.446646880.1502219790-1461564689.1499739058

Installed at C:\Packer and added to the Windows PATH.  Open a Windows CMD prompt and type:

    packer

If you get packer, you are set.

### 2. Install the Linux Subsystem for Windows

Ensure it is the latest possible version.


### 3. Install OVFTool 4.2 or Later

Download and install the [Windows version of VMware OVFTool 4.2](https://my.vmware.com/web/vmware/details?productId=614&downloadGroup=OVFTOOL420) and install it.

### 3a. OPTIONAL: Install VNC Viewer

For viewing the kickstart phase of the packer builds, it is handy to be able to VNC into the packer VM build.
Download and install the [RealVNC Viewer](https://www.realvnc.com/en/connect/download/viewer/)

## Within the Linux Subsystem

With the windows side dependencies installed, it is time to fire up the WSL Bash shell.

### 4. Create a Symlink to OVFTool

Wherever the ovftool.exe is located, Create a symlink to the folder where the __ovftool.exe__ resides, linked within the Linux Subsystem as  __/mnt/vmware-tools__:

    sudo ln -s /mnt/c/Program\ Files/VMware/VMware\ OVF\ Tool /mnt/vmware-tools

This makes it easier for the alias reference required to the windows executable from within the WSL.

### 5. Checkout cluster-builder on the Windows Filesystem

Make sure to put the cluster-builder repo in a workspace on the Windows side (i.e. don't use the home directory within the windows subsystem).  From within WSL, the Windows user home directory is at __/mnt/c/Users/xxx___.

    cd /mnt/c/Users/<me>/Workspace
    git clone git@github.com:/ids/cluster-builder.git

### 6. Install Ansible (2.3.2+)

    sudo apt-get update
    sudo apt-get install software-properties-common
    sudo apt-add-repository ppa:ansible/ansible
    sudo apt-get update
    sudo apt-get install ansible

### 7. Install realpath

This helps with the translations between environments, and lets VS Code launch from within the WSL, as long as the folder is located on the Windows side:

    sudo apt-get install realpath

And then when you are in your Windows workspace, typing:

    code .

Will open up VS Code in the expected folder.

### 8. Turn off git file mode checking

This is very important as the Windows filesystem views all files as mode 777 within the WSL, which trips up git.

    git config core.fileMode false


## Good to GO!

That should do it... make sure to use the WSL Bash shell.  It will call on CMD as required.

> CRLF Alert!  When you create files in VS Code you are doing it from Windows perspective, and they will likely default to CRLF, which is problematic within the WSL Bash.  Make sure to default your settings to LF.

> If your terminal looks like I think it does, which is to say, the default, you seriously need to read [this](http://blog.programster.org/fix-font-colors-in-windows-10-bash).  

;)