function RU_manual_check_summary(){var a=document.forms[0];if(parent.welcome_wan_type==1){a.ether_ipaddr.value=parent.static_ip;a.ether_subnet.value=parent.static_subnet;a.ether_gateway.value=parent.static_gateway;a.ether_dnsaddr1.value=parent.static_dns1;a.ether_dnsaddr2.value=parent.static_dns2;a.DNSAssign.value="1";a.domain_name.value="";a.WANAssign.value="static"}else{if(parent.welcome_wan_type==2){a.ether_ipaddr.value=parent.static_ip;a.ether_subnet.value=parent.static_subnet;a.ether_gateway.value=parent.static_gateway;a.ether_dnsaddr1.value=parent.static_dns1;a.ether_dnsaddr2.value=parent.static_dns2;if(parent.static_dns1==""&&parent.static_dns2==""){a.DNSAssign.value="0"}else{a.DNSAssign.value="1"}a.domain_name.value="";a.WANAssign.value="dhcp"}else{if(parent.welcome_wan_type==3){a.pppoe_username.value=parent.pppoe_username;a.pppoe_passwd.value=parent.pppoe_password;a.pppoe_servername.value=parent.pppoe_server;a.pppoe_ipaddr.value=parent.pppoe_static_ip;a.dual_access.value=parent.dual_access;a.pppoe_dod.value="0";a.pppoe_dual_ipaddr.value=parent.pppoe_eth_ip;a.pppoe_dual_subnet.value=parent.pppoe_eth_netmask;a.pppoe_dual_gateway.value="";a.pppoe_dual_assign.value=parent.pppoe_dual_assign;a.hidden_pppoe_idle_time.value="5";a.pppoe_dnsaddr1.value=parent.pppoe_dns1;a.pppoe_dnsaddr2.value=parent.pppoe_dns2;if(parent.pppoe_dns1==""&&parent.pppoe_dns2==""){a.DNSAssign.value="0"}else{a.DNSAssign.value="1"}if(parent.pppoe_wan_assign=="0"){a.WANAssign.value="Dynamic"}else{a.WANAssign.value="Fixed"}}else{if(parent.welcome_wan_type==4){a.pptp_username.value=parent.pptp_username;a.pptp_passwd.value=parent.pptp_password;a.pptp_myip.value=parent.pptp_local_ipaddr;a.pptp_mynetmask.value=parent.pptp_local_netmask;a.pptp_serv_ip.value=parent.pptp_server_ipaddr;a.pptp_gateway.value=parent.pptp_local_gateway;a.pptp_conn_id.value="";a.pptp_dnsaddr1.value=parent.pptp_dns1;a.pptp_dnsaddr2.value=parent.pptp_dns2;a.pptp_dod.value="0";if(parent.pptp_dns1==""&&parent.pptp_dns2==""){a.DNSAssign.value="0"}else{a.DNSAssign.value="1"}a.WANAssign.value=parent.pptp_wan_assign;a.STATIC_DNS.value=parent.STATIC_DNS;a.hidden_pptp_idle_time.value="5"}else{if(parent.welcome_wan_type==5){a.l2tp_username.value=parent.l2tp_username;a.l2tp_passwd.value=parent.l2tp_password;a.l2tp_myip.value=parent.l2tp_local_ipaddr;a.l2tp_mynetmask.value=parent.l2tp_local_netmask;a.l2tp_serv_ip.value=parent.l2tp_server_ipaddr;a.l2tp_gateway.value=parent.l2tp_local_gateway;a.l2tp_conn_id.value="";a.l2tp_dnsaddr1.value=parent.l2tp_dns1;a.l2tp_dnsaddr2.value=parent.l2tp_dns2;a.l2tp_dod.value="0";if(parent.l2tp_dns1==""&&parent.l2tp_dns2==""){a.DNSAssign.value="0"}else{a.DNSAssign.value="1"}a.WANAssign.value=parent.l2tp_wan_assign;a.STATIC_DNS.value=parent.STATIC_DNS;a.hidden_l2tp_idle_time.value="5"}}}}}a.welcome_wan_type.value=parent.welcome_wan_type;a.MACAssign.value=parent.mac_spoof;a.Spoofmac.value=parent.Spoofmac;a.conflict_wanlan.value=parent.conflict_wanlan;a.change_wan_type.value="0";a.run_test.value="no";parent.RU_manual_flag="1";a.submit()};