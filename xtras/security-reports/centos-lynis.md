[ Lynis 2.5.5 ]

################################################################################
  Lynis comes with ABSOLUTELY NO WARRANTY. This is free software, and you are
  welcome to redistribute it under the terms of the GNU General Public License.
  See the LICENSE file for details about using this software.

  2007-2017, CISOfy - https://cisofy.com/lynis/
  Enterprise support available (compliance, plugins, interface and tools)
################################################################################


[+] Initializing program
------------------------------------
  - Detecting OS...                                           [ DONE ]
  - Checking profiles...                                      [ DONE ]

  ---------------------------------------------------
  Program version:           2.5.5
  Operating system:          Linux
  Operating system name:     CentOS
  Operating system version:  CentOS Linux release 7.4.1708 (Core) 
  Kernel version:            3.10.0
  Hardware platform:         x86_64
  Hostname:                  demo-swarm-m1
  ---------------------------------------------------
  Profiles:                  /etc/lynis/default.prf
  Log file:                  /var/log/lynis.log
  Report file:               /var/log/lynis-report.dat
  Report version:            1.0
  Plugin directory:          /usr/share/lynis/plugins
  ---------------------------------------------------
  Auditor:                   [Not Specified]
  Test category:             all
  Test group:                all
  ---------------------------------------------------
  - Program update status...                                  [ SKIPPED ]

[+] System Tools
------------------------------------
  - Scanning available tools...
  - Checking system binaries...

[+] Plugins (phase 1)
------------------------------------
 Note: plugins have more extensive tests and may take several minutes to complete
  
  - Plugins enabled                                           [ NONE ]

[+] Boot and services
------------------------------------
  - Service Manager                                           [ systemd ]
  - Checking UEFI boot                                        [ DISABLED ]
  - Checking presence GRUB2                                   [ FOUND ]
    - Checking for password protection                        [ OK ]
  - Check running services (systemctl)                        [ DONE ]
        Result: found 21 running services
  - Check enabled services at boot (systemctl)                [ DONE ]
        Result: found 24 enabled services
  - Check startup files (permissions)                         [ OK ]

[+] Kernel
------------------------------------
  - Checking default runlevel                                 [ runlevel 3 ]
  - Checking CPU support (NX/PAE)
    CPU support: PAE and/or NoeXecute supported               [ FOUND ]
  - Checking kernel version and release                       [ DONE ]
  - Checking kernel type                                      [ DONE ]
  - Checking loaded kernel modules                            [ DONE ]
      Found 114 active modules
  - Checking Linux kernel configuration file                  [ FOUND ]
  - Checking default I/O kernel scheduler                     [ FOUND ]
  - Checking core dumps configuration                         [ DISABLED ]
    - Checking setuid core dumps configuration                [ DEFAULT ]
  - Check if reboot is needed                                 [ NO ]

[+] Memory and Processes
------------------------------------
  - Checking /proc/meminfo                                    [ FOUND ]
  - Searching for dead/zombie processes                       [ OK ]
  - Searching for IO waiting processes                        [ OK ]

[+] Users, Groups and Authentication
------------------------------------
  - Administrator accounts                                    [ OK ]
  - Unique UIDs                                               [ OK ]
  - Consistency of group files (grpck)                        [ OK ]
  - Unique group IDs                                          [ OK ]
  - Unique group names                                        [ OK ]
  - Password file consistency                                 [ OK ]
  - Query system users (non daemons)                          [ DONE ]
  - NIS+ authentication support                               [ NOT ENABLED ]
  - NIS authentication support                                [ NOT ENABLED ]
  - sudoers file                                              [ FOUND ]
    - Check sudoers file permissions                          [ OK ]
  - PAM password strength tools                               [ OK ]
  - PAM configuration file (pam.conf)                         [ NOT FOUND ]
  - PAM configuration files (pam.d)                           [ FOUND ]
  - PAM modules                                               [ FOUND ]
  - Checking user password aging (minimum)                    [ DISABLED ]
  - User password aging (maximum)                             [ DISABLED ]
  - Checking expired passwords                                [ OK ]
  - Checking Linux single user mode authentication            [ OK ]
  - Determining default umask
    - umask (/etc/profile and /etc/profile.d)                 [ SUGGESTION ]
    - umask (/etc/login.defs)                                 [ OK ]
    - umask (/etc/init.d/functions)                           [ SUGGESTION ]
  - LDAP authentication support                               [ NOT ENABLED ]
  - Logging failed login attempts                             [ DISABLED ]

[+] Shells
------------------------------------
  - Checking shells from /etc/shells
    Result: found 6 shells (valid shells: 6).
    - Session timeout settings/tools                          [ NONE ]
  - Checking default umask values
    - Checking default umask in /etc/bashrc                   [ WEAK ]
    - Checking default umask in /etc/csh.cshrc                [ WEAK ]
    - Checking default umask in /etc/profile                  [ WEAK ]

[+] File systems
------------------------------------
  - Checking mount points
    - Checking /home mount point                              [ OK ]
    - Checking /tmp mount point                               [ SUGGESTION ]
    - Checking /var mount point                               [ SUGGESTION ]
  - Checking LVM volume groups                                [ FOUND ]
    - Checking LVM volumes                                    [ FOUND ]
  - Query swap partitions (fstab)                             [ OK ]
  - Testing swap partitions                                   [ OK ]
  - Testing /proc mount (hidepid)                             [ SUGGESTION ]
  - Checking for old files in /tmp                            [ OK ]
  - Checking /tmp sticky bit                                  [ OK ]
  - ACL support root file system                              [ ENABLED ]
  - Mount options of /                                        [ OK ]
  - Mount options of /boot                                    [ NON DEFAULT ]
  - Mount options of /home                                    [ NON DEFAULT ]
  - Disable kernel support of some filesystems
    - Discovered kernel modules: cramfs squashfs udf 

[+] Storage
------------------------------------
  - Checking usb-storage driver (modprobe config)             [ NOT DISABLED ]
  - Checking USB devices authorization                        [ DISABLED ]
  - Checking firewire ohci driver (modprobe config)           [ NOT DISABLED ]

[+] NFS
------------------------------------
  - Check running NFS daemon                                  [ NOT FOUND ]

[+] Name services
------------------------------------
  - Checking search domains                                   [ FOUND ]
  - Searching DNS domain name                                 [ UNKNOWN ]
  - Checking /etc/hosts
    - Checking /etc/hosts (duplicates)                        [ OK ]
    - Checking /etc/hosts (hostname)                          [ OK ]
    - Checking /etc/hosts (localhost)                         [ OK ]
    - Checking /etc/hosts (localhost to IP)                   [ OK ]

[+] Ports and packages
------------------------------------
  - Searching package managers
    - Searching RPM package manager                           [ FOUND ]
      - Querying RPM package manager
  - YUM package management consistency                        [ OK ]
  - Checking package database duplicates                      [ OK ]
  - Checking package database for problems                    [ OK ]
  - Checking missing security packages                        [ OK ]
  - Checking GPG checks (yum.conf)                            [ OK ]
  - Checking package audit tool                               [ INSTALLED ]
    Found: yum-security

[+] Networking
------------------------------------
  - Checking IPv6 configuration                               [ ENABLED ]
      Configuration method                                    [ AUTO ]
      IPv6 only                                               [ NO ]
  - Checking configured nameservers
    - Testing nameservers
      Nameserver: 8.8.8.8                                     [ SKIPPED ]
      Nameserver: 8.8.4.4                                     [ SKIPPED ]
    - Minimal of 2 responsive nameservers                     [ SKIPPED ]
  - Checking default gateway                                  [ DONE ]
  - Getting listening ports (TCP/UDP)                         [ DONE ]
      * Found 18 ports
  - Checking promiscuous interfaces                           [ OK ]
  - Checking waiting connections                              [ OK ]
  - Checking status DHCP client                               [ RUNNING ]
  - Checking for ARP monitoring software                      [ NOT FOUND ]

[+] Printers and Spools
------------------------------------
  - Checking cups daemon                                      [ NOT FOUND ]
  - Checking lp daemon                                        [ NOT RUNNING ]

[+] Software: e-mail and messaging
------------------------------------
  - Postfix status                                            [ RUNNING ]
    - Postfix configuration                                   [ FOUND ]

[+] Software: firewalls
------------------------------------
  - Checking iptables kernel module                           [ FOUND ]
    - Checking iptables policies of chains                    [ FOUND ]
      - Checking chain INPUT (table: nfilter, policy ACCEPT)  [ ACCEPT ]
    - Checking for empty ruleset                              [ OK ]
    - Checking for unused rules                               [ FOUND ]
  - Checking host based firewall                              [ ACTIVE ]

[+] Software: webserver
------------------------------------
  - Checking Apache                                           [ NOT FOUND ]
  - Checking nginx                                            [ NOT FOUND ]

[+] SSH Support
------------------------------------
  - Checking running SSH daemon                               [ FOUND ]
    - Searching SSH configuration                             [ FOUND ]
    - SSH option: AllowTcpForwarding                          [ OK ]
    - SSH option: ClientAliveCountMax                         [ OK ]
    - SSH option: ClientAliveInterval                         [ OK ]
    - SSH option: Compression                                 [ OK ]
    - SSH option: FingerprintHash                             [ OK ]
    - SSH option: GatewayPorts                                [ OK ]
    - SSH option: IgnoreRhosts                                [ OK ]
    - SSH option: LoginGraceTime                              [ OK ]
    - SSH option: LogLevel                                    [ OK ]
    - SSH option: MaxAuthTries                                [ OK ]
    - SSH option: MaxSessions                                 [ OK ]
    - SSH option: PermitRootLogin                             [ OK ]
    - SSH option: PermitUserEnvironment                       [ OK ]
    - SSH option: PermitTunnel                                [ OK ]
    - SSH option: Port                                        [ SUGGESTION ]
    - SSH option: PrintLastLog                                [ OK ]
    - SSH option: Protocol                                    [ NOT FOUND ]
    - SSH option: StrictModes                                 [ OK ]
    - SSH option: TCPKeepAlive                                [ OK ]
    - SSH option: UseDNS                                      [ OK ]
    - SSH option: VerifyReverseMapping                        [ NOT FOUND ]
    - SSH option: X11Forwarding                               [ OK ]
    - SSH option: AllowAgentForwarding                        [ OK ]
    - SSH option: AllowUsers                                  [ NOT FOUND ]
    - SSH option: AllowGroups                                 [ NOT FOUND ]

[+] SNMP Support
------------------------------------
  - Checking running SNMP daemon                              [ NOT FOUND ]

[+] Databases
------------------------------------
    No database engines found

[+] LDAP Services
------------------------------------
  - Checking OpenLDAP instance                                [ NOT FOUND ]

[+] PHP
------------------------------------
  - Checking PHP                                              [ NOT FOUND ]

[+] Squid Support
------------------------------------
  - Checking running Squid daemon                             [ NOT FOUND ]

[+] Logging and files
------------------------------------
  - Checking for a running log daemon                         [ OK ]
    - Checking Syslog-NG status                               [ NOT FOUND ]
    - Checking systemd journal status                         [ FOUND ]
    - Checking Metalog status                                 [ NOT FOUND ]
    - Checking RSyslog status                                 [ FOUND ]
    - Checking RFC 3195 daemon status                         [ NOT FOUND ]
    - Checking minilogd instances                             [ NOT FOUND ]
  - Checking logrotate presence                               [ OK ]
  - Checking log directories (static list)                    [ DONE ]
  - Checking open log files                                   [ SKIPPED ]

[+] Insecure services
------------------------------------
  - Checking inetd status                                     [ NOT ACTIVE ]

[+] Banners and identification
------------------------------------
  - /etc/issue                                                [ FOUND ]
    - /etc/issue contents                                     [ WEAK ]
  - /etc/issue.net                                            [ FOUND ]
    - /etc/issue.net contents                                 [ WEAK ]

[+] Scheduled tasks
------------------------------------
  - Checking crontab/cronjob                                  [ DONE ]

[+] Accounting
------------------------------------
  - Checking accounting information                           [ NOT FOUND ]
  - Checking sysstat accounting data                          [ NOT FOUND ]
  - Checking auditd                                           [ ENABLED ]
    - Checking audit rules                                    [ OK ]
    - Checking audit configuration file                       [ OK ]
    - Checking auditd log file                                [ FOUND ]

[+] Time and Synchronization
------------------------------------
  - NTP daemon found: chronyd                                 [ FOUND ]
  - Checking for a running NTP daemon or client               [ OK ]

[+] Cryptography
------------------------------------
  - Checking for expired SSL certificates [0/4]               [ NONE ]

[+] Virtualization
------------------------------------

[+] Containers
------------------------------------
    - Docker
      - Docker daemon                                         [ RUNNING ]
        - Docker info output (warnings)                       [ NONE ]
      - Containers
        - Total containers                                    [ 1 ]
          - Running containers                                [ 1 ]
        - Unused containers                                   [ 0 ]
    - File permissions                                        [ OK ]

[+] Security frameworks
------------------------------------
  - Checking presence AppArmor                                [ NOT FOUND ]
  - Checking presence SELinux                                 [ FOUND ]
    - Checking SELinux status                                 [ ENABLED ]
      - Checking current mode and config file                 [ OK ]
        Current SELinux mode: permissive
  - Checking presence grsecurity                              [ NOT FOUND ]
  - Checking for implemented MAC framework                    [ OK ]

[+] Software: file integrity
------------------------------------
  - Checking file integrity tools
  - Checking presence integrity tool                          [ NOT FOUND ]

[+] Software: System tooling
------------------------------------
  - Checking automation tooling
  - Automation tooling                                        [ NOT FOUND ]
  - Checking for IDS/IPS tooling                              [ NONE ]

[+] Software: Malware
------------------------------------

[+] File Permissions
------------------------------------
  - Starting file permissions check

[+] Home directories
------------------------------------
  - Checking shell history files                              [ OK ]

[+] Kernel Hardening
------------------------------------
  - Comparing sysctl key pairs with scan profile
    - fs.protected_hardlinks (exp: 1)                         [ OK ]
    - fs.protected_symlinks (exp: 1)                          [ OK ]
    - fs.suid_dumpable (exp: 0)                               [ OK ]
    - kernel.core_uses_pid (exp: 1)                           [ OK ]
    - kernel.ctrl-alt-del (exp: 0)                            [ OK ]
    - kernel.dmesg_restrict (exp: 1)                          [ DIFFERENT ]
    - kernel.kptr_restrict (exp: 2)                           [ DIFFERENT ]
    - kernel.randomize_va_space (exp: 2)                      [ OK ]
    - kernel.sysrq (exp: 0)                                   [ DIFFERENT ]
    - net.ipv4.conf.all.accept_redirects (exp: 0)             [ OK ]
    - net.ipv4.conf.all.accept_source_route (exp: 0)          [ OK ]
    - net.ipv4.conf.all.bootp_relay (exp: 0)                  [ OK ]
    - net.ipv4.conf.all.forwarding (exp: 0)                   [ DIFFERENT ]
    - net.ipv4.conf.all.log_martians (exp: 1)                 [ DIFFERENT ]
    - net.ipv4.conf.all.mc_forwarding (exp: 0)                [ OK ]
    - net.ipv4.conf.all.proxy_arp (exp: 0)                    [ OK ]
    - net.ipv4.conf.all.rp_filter (exp: 1)                    [ OK ]
    - net.ipv4.conf.all.send_redirects (exp: 0)               [ DIFFERENT ]
    - net.ipv4.conf.default.accept_redirects (exp: 0)         [ DIFFERENT ]
    - net.ipv4.conf.default.accept_source_route (exp: 0)      [ OK ]
    - net.ipv4.conf.default.log_martians (exp: 1)             [ DIFFERENT ]
    - net.ipv4.icmp_echo_ignore_broadcasts (exp: 1)           [ OK ]
    - net.ipv4.icmp_ignore_bogus_error_responses (exp: 1)     [ OK ]
    - net.ipv4.tcp_syncookies (exp: 1)                        [ OK ]
    - net.ipv4.tcp_timestamps (exp: 0)                        [ DIFFERENT ]
    - net.ipv6.conf.all.accept_redirects (exp: 0)             [ DIFFERENT ]
    - net.ipv6.conf.all.accept_source_route (exp: 0)          [ OK ]
    - net.ipv6.conf.default.accept_redirects (exp: 0)         [ DIFFERENT ]
    - net.ipv6.conf.default.accept_source_route (exp: 0)      [ OK ]

[+] Hardening
------------------------------------
    - Installed compiler(s)                                   [ FOUND ]
    - Installed malware scanner                               [ NOT FOUND ]

[+] Custom Tests
------------------------------------
  - Running custom tests...                                   [ NONE ]

[+] Plugins (phase 2)
------------------------------------

================================================================================

  -[ Lynis 2.5.5 Results ]-

  Great, no warnings

  Suggestions (20):
  ----------------------------
  * Configure minimum password age in /etc/login.defs [AUTH-9286] 
      https://cisofy.com/controls/AUTH-9286/

  * Configure maximum password age in /etc/login.defs [AUTH-9286] 
      https://cisofy.com/controls/AUTH-9286/

  * Default umask in /etc/profile or /etc/profile.d/custom.sh could be more strict (e.g. 027) [AUTH-9328] 
      https://cisofy.com/controls/AUTH-9328/

  * To decrease the impact of a full /tmp file system, place /tmp on a separated partition [FILE-6310] 
      https://cisofy.com/controls/FILE-6310/

  * To decrease the impact of a full /var file system, place /var on a separated partition [FILE-6310] 
      https://cisofy.com/controls/FILE-6310/

  * Disable drivers like USB storage when not used, to prevent unauthorized storage or data theft [STRG-1840] 
      https://cisofy.com/controls/STRG-1840/

  * Disable drivers like firewire storage when not used, to prevent unauthorized storage or data theft [STRG-1846] 
      https://cisofy.com/controls/STRG-1846/

  * Check DNS configuration for the dns domain name [NAME-4028] 
      https://cisofy.com/controls/NAME-4028/

  * Consider running ARP monitoring software (arpwatch,arpon) [NETW-3032] 
      https://cisofy.com/controls/NETW-3032/

  * Check iptables rules to see which rules are currently not used [FIRE-4513] 
      https://cisofy.com/controls/FIRE-4513/

  * Consider hardening SSH configuration [SSH-7408] 
    - Details  : Port (22 --> )
      https://cisofy.com/controls/SSH-7408/

  * Add a legal banner to /etc/issue, to warn unauthorized users [BANN-7126] 
      https://cisofy.com/controls/BANN-7126/

  * Add legal banner to /etc/issue.net, to warn unauthorized users [BANN-7130] 
      https://cisofy.com/controls/BANN-7130/

  * Enable process accounting [ACCT-9622] 
      https://cisofy.com/controls/ACCT-9622/

  * Enable sysstat to collect accounting (no results) [ACCT-9626] 
      https://cisofy.com/controls/ACCT-9626/

  * Install a file integrity tool to monitor changes to critical and sensitive files [FINT-4350] 
      https://cisofy.com/controls/FINT-4350/

  * Determine if automation tools are present for system management [TOOL-5002] 
      https://cisofy.com/controls/TOOL-5002/

  * One or more sysctl values differ from the scan profile and could be tweaked [KRNL-6000] 
      https://cisofy.com/controls/KRNL-6000/

  * Harden compilers like restricting access to root user only [HRDN-7222] 
      https://cisofy.com/controls/HRDN-7222/

  * Harden the system by installing at least one malware scanner, to perform periodic file system scans [HRDN-7230] 
    - Solution : Install a tool like rkhunter, chkrootkit, OSSEC
      https://cisofy.com/controls/HRDN-7230/

  Follow-up:
  ----------------------------
  - Show details of a test (lynis show details TEST-ID)
  - Check the logfile for all details (less /var/log/lynis.log)
  - Read security controls texts (https://cisofy.com)
  - Use --upload to upload data to central system (Lynis Enterprise users)

================================================================================

  Lynis security scan details:

  Hardening index : 79 [###############     ]
  Tests performed : 208
  Plugins enabled : 0

  Components:
  - Firewall               [V]
  - Malware scanner        [X]

  Lynis Modules:
  - Compliance Status      [?]
  - Security Audit         [V]
  - Vulnerability Scan     [V]

  Files:
  - Test and debug information      : /var/log/lynis.log
  - Report data                     : /var/log/lynis-report.dat

================================================================================

  Lynis 2.5.5

  Auditing, system hardening, and compliance for UNIX-based systems
  (Linux, macOS, BSD, and others)

  2007-2017, CISOfy - https://cisofy.com/lynis/
  Enterprise support available (compliance, plugins, interface and tools)

================================================================================