function check_vlan_input(cf,flag){cf.vlan_name.disabled=false;cf.vlan_id.disabled=false;cf.vlan_priority.disabled=false;if(cf.vlan_name.value=="Orange France TV"){cf.vlan_name.value="OrangeIPTV"}if(!(flag=="edit"&&default_internet==1)){if(cf.vlan_name.value.length>10||cf.vlan_name.value.length==0){alert("$vlan_error11");return false}for(i=0;i<cf.vlan_name.value.length;i++){if(isValidChar(cf.vlan_name.value.charCodeAt(i))==false){alert("$vlan_error11");return false}}for((is_for_RU==1)?i=0:i=1;i<=array_num;i++){var str=eval("vlanArray"+i);var str_info=str.split(" ");var str_name=str_info[1].replace(/&#92;/g,"\\").replace(/&lt;/g,"<").replace(/&gt;/g,">").replace(/&#40;/g,"(").replace(/&#41;/g,")").replace(/&#34;/g,'"').replace(/&#39;/g,"'").replace(/&#35;/g,"#").replace(/&#38;/g,"&");if(str_name==cf.vlan_name.value&&(!(flag=="edit"&&sel_num==i))){if(cf.vlan_name.value=="OrangeIPTV"){alert("$vlan_error4_1 Orange France TV $vlan_error4_2");cf.vlan_name.value="Orange France TV"}else{alert("$vlan_error4_1 "+cf.vlan_name.value+" $vlan_error4_2")}return false}}if(!_isNumeric(cf.vlan_id.value)){alert("$vlan_error3");return false}var str_tmp=parseInt(cf.vlan_id.value,10);if(str_tmp<1||str_tmp>4094){alert("$vlan_error3");return false}}if(cf.vlan_id.value.length==0){alert("$vlan_error1");return false}if(cf.vlan_priority.value==""){cf.vlan_priority.value="0"}if(!_isNumeric(cf.vlan_priority.value)){alert("$vlan_error2");return false}str_tmp=parseInt(cf.vlan_priority.value,10);if(str_tmp>7){alert("$vlan_error2");return false}if(!(flag=="edit"&&default_internet==1)){var wired=0;var wireless=0;if(cf.iptv_ports_2.checked==true){wired+=4}if(cf.iptv_ports_1.checked==true){wired+=2}if(cf.iptv_ports_0.checked==true){wired+=1}if(wired==15){alert("$vlan_error6");return false}if(wired==0&&cf.vlan_name.value!="OrangeIPTV"){alert("$vlan_error5");return false}cf.hid_wired_port.value=wired}var wifi_port_flag=0;var str_inter=eval("vlanArray1");var str_inter_info=str_inter.split(" ");for(i=1;i<=array_num;i++){var str_2=eval("vlanArray"+i);var str_info_2=str_2.split(" ");if(str_info_2[2]==cf.vlan_id.value&&str_info_2[3]==cf.vlan_priority.value&&(!(flag=="edit"&&sel_num==i))){alert("$vlan_id:"+cf.vlan_id.value+" / $qos_priority:"+cf.vlan_priority.value+" $vlan_error14");return false}}if(flag=="edit"){if(default_internet==1){cf.hid_vlan_name.value=each_info[1];if(!_isNumeric(cf.vlan_id.value)){alert("$vlan_error3");return false}var str_tmp=parseInt(cf.vlan_id.value,10);if(str_tmp<0||str_tmp>4094){alert("$vlan_error13");return false}if(str_tmp==0){cf.vlan_priority.value="0"}if(cf.vlan_type.value=="orange_dhcp"){cf.hid_vlan_orange.value="1"}else{if(cf.vlan_type.value=="orange_pppoe"){cf.hid_vlan_orange.value="2"}else{cf.hid_vlan_orange.value="3"}}}else{cf.hid_vlan_name.value=cf.vlan_name.value}}cf.vlan_id.value=parseInt(cf.vlan_id.value,10);return true}function click_add_btn(a){if(array_num>=10||(is_for_RU==1&&array_num>=9)){alert("$vlan_error9");return false}else{location.href="VLAN_add.htm";return true}}function check_iptv_input(c){var a=0;var b=0;if(c.iptv_ports_2.checked==true){a+=4;c.hid_bri_lan3.value="1"}else{c.hid_bri_lan3.value="0"}if(c.iptv_ports_1.checked==true){a+=2;c.hid_bri_lan2.value="1"}else{c.hid_bri_lan2.value="0"}if(c.iptv_ports_0.checked==true){a+=1;c.hid_bri_lan1.value="1"}else{c.hid_bri_lan1.value="0"}if(a==7){alert("$vlan_error6");return false}if(a==0){alert("$vlan_error5");return false}c.hid_iptv_mask.value=a;return true}function click_edit_btn(b){var a;var c=0;if(array_num==1&&is_for_RU!=1){if(b.ruleSelect.checked==true){c++;a=parseInt(b.ruleSelect.value)}}else{for(i=0;(is_for_RU==1)?i<=array_num:i<array_num;i++){if(b.ruleSelect[i].checked==true){c++;a=parseInt(b.ruleSelect[i].value)}}}if(c==0){alert("$port_edit");return false}else{b.select_edit_num.value=a;b.submit_flag.value="vlan_edit";b.action="/apply.cgi?/VLAN_edit.htm timestamp="+ts}b.submit();return true}function click_delete_btn(cf){var count_select=0;var select_num;if(array_num==1&&is_for_RU!=1){if(cf.ruleSelect.checked==true){count_select++;select_num=parseInt(cf.ruleSelect.value)}}else{for(i=0;(is_for_RU==1)?i<=array_num:i<array_num;i++){if(cf.ruleSelect[i].checked==true){count_select++;select_num=parseInt(cf.ruleSelect[i].value)}}}if(count_select==0){alert("$port_del");return false}else{var sel_str=eval("vlanArray"+select_num);var sel_info=sel_str.split(" ");if(confirm("$vlan_warn1"+(" ").toString()+sel_info[1]+"?")==false){return false}if(sel_info[1]=="Internet"||(sel_info[1]=="Intranet"&&is_for_RU==1)){alert(sel_info[1]+" $vlan_port_del_msg");return false}cf.select_del_num.value=select_num;cf.submit_flag.value="vlan_delete"}cf.submit();return true}function click_apply(cf){if(cf.vlan_iptv_enable.checked==true){if(cf.vlan_iptv_select[1].checked==true){var count_enable=0;var sel_list="";var port1=port2=port3=0;for(i=1;i<=array_num;i++){var boxName="vlan_check"+i;if(document.getElementById(boxName).checked==true){var sel_str=eval("vlanArray"+i);var sel_info=sel_str.split(" ");var lan_port=parseInt(sel_info[4],10);var wlan_port=parseInt(sel_info[5],10);if(lan_port>=4&&lan_port<=7){port3++}if(lan_port==7||lan_port==6||lan_port==3||lan_port==2){port2++}if(lan_port%2==1){port1++}sel_list+=i;sel_list+="#";count_enable++}}if(lan_ports_num>1&&array_num>1&&orange_note==0&&cf.hid_inter_lan1.value=="0"&&cf.hid_inter_lan2.value=="0"&&cf.hid_inter_lan3.value=="0"&&cf.hid_inter_wireless1.value=="0"&&cf.hid_inter_wireless2.value=="0"){alert("$vlan_error16");return false}if(port1>1||port2>1||port3>1){alert("$vlan_port_dup");return false}if(count_enable>6){alert("$vlan_error10");return false}else{cf.hid_enable_vlan.value="1";cf.hid_vlan_type.value="1";cf.hid_sel_list.value=sel_list;cf.hid_enabled_num.value=count_enable;cf.submit_flag.value="apply_vlan"}}else{if(check_iptv_input(cf)==false){return false}cf.hid_enable_vlan.value="1";cf.hid_vlan_type.value="0";cf.submit_flag.value="apply_iptv_edit"}if(parent.vlan_free_flag==1){clearNoNum(document.getElementById("vlan_id_input"));if(document.getElementById("enable_vlan_id").checked){var vlan_id_num=parseInt(document.getElementById("vlan_id_input").value);if(isNaN(vlan_id_num)||vlan_id_num<1||vlan_id_num>4094){alert("Invalid vlan id, it should be digital and under range of 1~4094");return false}cf.hid_vlan_id_input.value="1"}}}else{cf.hid_enable_vlan.value="0";cf.submit_flag.value="disable_vlan_iptv"}return true}function clearNoNum(a){return a.value=a.value.replace(/[^\d]/g,"")}function uncheckWlanOption(a){if(a.checked){document.getElementById("iptv_ports_10").checked=false;document.getElementById("iptv_ports_11").checked=false}}function uncheckVlanIDOption(a){if(a.checked){document.getElementById("enable_vlan_id").checked=false}};