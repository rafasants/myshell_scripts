# myshell_scripts
Shell Scripts Inside

[ MYSYNC.sh ] - Personal script **********************************************

  This script help me automating the process of upload or download my personal spend sheet. First, I installed 'INSYNC' program, and then I created my script to working whith the program. This is for Personal Use!
  
[ SIVCONTROL.sh ] - Professional script **************************************

  I created this Script to facilitate the management of SIVS (Sistema de Informação de Vôo), because we have around 215 Linux 
machines executing the SIV. This script allows to run a Shell command only once for all SIVs, instead, connect one by one executing
the command. For this scripts, I needed the 'SSHPASS' program [ $whatis sshpass: noninteractive ssh password provider ]


[ for_dns.sh ] ****************************************************************

<AUTHOR: RAFAEL SANTOS>

I created this script just for study the loop "for". With this shell script, it's possible to discover the best DNS Server based on Ping command.
For this, I made a list of DNS Servers IP's following a pattern.

___________________________________________
|( DNS  -  IP DNS)|         >> | LATENCY |
-------------------------------------------

(GOOGLE - 8.8.8.8)          >>   29.975
(GOOGLE2 - 8.8.4.4)         >>   29.338
(DNSWATCH - 84.200.69.80)   >>   303.588
(DNSWATCH2 - 84.200.70.40)  >>   257.792
(OPENDNS - 208.67.222.222)  >>   38.476
(OPENDNS2 - 208.67.220.220) >>   40.875
(GIGADNS - 189.38.95.95)    >>   53.382
(GIGADNS2 - 189.38.95.96)   >>   53.588
(CLOUDFLARE - 1.1.1.1)      >>   28.910
(CLOUDFLARE2 - 1.0.0.1)     >>   unreachable
(GTEILEVEL3 - 4.2.2.1)     >>   152.618
(GTEILEVEL3 - 4.2.2.2)     >>   148.627

-------------------------------------------
Best DNS Server: CLOUDFLARE 28.910 ms
-------------------------------------------



*configuring your environment:


2. Save and move the script (for_dns.sh) with the list to /usr/local/bin/
3. $ sudo chmod a+rwx /usr/local/bin/list /usr/local/bin/for_dns.sh
4. echo "alias fordns="for_dns.sh | tee $HOME/log"" >> $HOME/.bashrc
5. source $HOME/.bashrc
5. DONE!!
