var Africa=0;var Asia=1;var Australia=2;var Canada=3;var China=11;var Europe=4;var India=12;var Israel=5;var Japan=6;var Korea=7;var Malaysia=13;var Mexico=8;var Middle_East_Algeria_Syria_Yemen=14;var Middle_East_Iran_Lebanon_Qatar=15;var Middle_East_Turkey_Egypt_Tunisia_Kuwait=16;var Middle_East_Saudi_Arabia=17;var Middle_East_United_Arab_Emirates=18;var Middle_East=22;var Russia=19;var Singapore=20;var South_America=9;var Taiwan=21;var United_States=10;var qca_region_arr=new Array("za","none","au","ca","eu","il","jp","kr","mx","none","us","cn","none","my","none","none","tr","sa","ae","ru","sg","tw","");function getObj(a){if(document.getElementById){return document.getElementById(a)}else{if(document.all){return document.all[a]}else{if(document.layers){return document.layers[a]}}}}function setSecurity(a){var b=document.forms[0];b.wpa2_press_flag.value=0;b.wpas_press_flag.value=0;if(a==4){getObj("view").innerHTML=str_wpa2}else{if(a==5){getObj("view").innerHTML=str_wpas}else{getObj("view").innerHTML=str_none}}}function check_dfs(){var b=document.forms[0];var o=dfs_info.split(":");var n;var m=b.w_channel_an;var d=m.selectedIndex;var h=m.options[d].text;var l=m.options[d].value;var c=(top.support_ht160_flag==1&&enable_ht160=="1"&&((k==10||k==4)));if(h.indexOf("(DFS)")==-1&&!c){return true}if(top.dfs_radar_detect_flag==1){var f=wla_mode;var k=wl_get_countryA;var a;if(c){if(dfs_radar_160==undefined){return true}a=dfs_radar_160}else{if(9==f){if(dfs_radar_80==undefined){return true}a=dfs_radar_80}else{if(dfs_radar_40==undefined){return true}a=dfs_radar_40}}for(var g=0;g<a.length-1;g++){var m=a[g].channel;var e=a[g].expire/60;var j=a[g].expire%60;if(m==l){alert("$using_dfs_1"+e.toFixed(0)+"$using_dfs_2"+j+"$using_dfs_3");return false}}}else{for(g=0;g<o.length;g++){n=o[g].split(" ");var j=n[3]%60;var e=parseInt(n[3]/60);if((5000+5*(parseInt(l,10)))==parseInt(n[0],10)){alert("$using_dfs_1"+e+"$using_dfs_2"+j+"$using_dfs_3");return false}}}if(h.indexOf("(DFS)")!=-1&&confirm("$select_dfs")==false){return false}return true}function setChannel(){var f=document.forms[0];var b=region_index;if(netgear_region.toUpperCase()=="NA"||netgear_region.toUpperCase()=="US"){b="21"}if(netgear_region.toUpperCase()=="RU"){b="17"}if(netgear_region.toUpperCase()=="CA"){b="3"}if(netgear_region.toUpperCase()=="JP"){b="8"}b=parseInt(b)+1;var a=f.w_channel.selectedIndex;var e=wl_mode;var d;d=FinishChannel[b];if(FinishChannel[b]==14){f.w_channel.options.length=d-StartChannel[b]}else{f.w_channel.options.length=d-StartChannel[b]+2}f.w_channel.options[0].text="$auto_mark";f.w_channel.options[0].value=0;for(var c=StartChannel[b];c<=d;c++){if(c==14){continue}f.w_channel.options[c-StartChannel[b]+1].value=c;f.w_channel.options[c-StartChannel[b]+1].text=(c<10)?"0"+c:c}f.w_channel.selectedIndex=((a>-1)&&(a<f.w_channel.options.length))?a:0}function setBChannel(){var e=document.forms[0];var b=region_index;if(netgear_region.toUpperCase()=="NA"||netgear_region.toUpperCase()=="US"){b="21"}if(netgear_region.toUpperCase()=="RU"){b="17"}if(netgear_region.toUpperCase()=="CA"){b="3"}if(netgear_region.toUpperCase()=="JP"){b="8"}b=parseInt(b)+1;var a=e.w_channel.selectedIndex;var d;d=FinishChannelB[b];if(FinishChannelB[b]==14){e.w_channel.options.length=d-StartChannelB[b]}else{e.w_channel.options.length=d-StartChannelB[b]+2}e.w_channel.options[0].text="$auto_mark";e.w_channel.options[0].value=0;for(var c=StartChannelB[b];c<=d;c++){if(c==14){continue}e.w_channel.options[c-StartChannelB[b]+1].value=c;e.w_channel.options[c-StartChannelB[b]+1].text=(c<10)?"0"+c:c}e.w_channel.selectedIndex=((a>-1)&&(a<e.w_channel.options.length))?a:0}function chgChA(b){var a=document.forms[0];setAChannel(a.w_channel_an)}function setAChannel(l){var b=document.forms[0];var k=wl_get_countryA;var f=wla_mode;var h=document.getElementById("wireless_channel_an").options;var d=l.value;var m=0;var g,e=0,c;var a=ht40_array[k];if(1==f||2==f||7==f){a=ht20_array[k]}else{if(9==f){a=ht80_array[k]}}l.options.length=a.length+1;if(dfs_channel_router_flag==1){l.options[e].value=0;l.options[e].text="$auto_mark";e++}for(g=0;g<a.length;g++){if(0==hidden_dfs_channel&&(1==dfs_channel_router_flag||(dfs_canada_router_flag==1&&k==3)||(dfs_australia_router_flag==1&&k==2)||(dfs_europe_router_flag==1&&k==4)||(dfs_japan_router_flag&&k==6))){if(a[g].indexOf("(DFS)")>-1){c=a[g].split("(DFS)")[0];l.options[e].value=c;l.options[e].text=a[g];e++}else{l.options[e].value=l.options[e].text=a[g];e++}}else{if(a[g].indexOf("(DFS)")>-1){continue}if(f==9&&k==21){if(a[g]=="60"||a[g]=="64"){continue}}if((k==10||k==17)&&(a[g]=="149"||a[g]=="153"||a[g]=="157"||a[g]=="161")){continue}l.options[e].value=l.options[e].text=a[g];e++}}l.options.length=e;for(g=0;g<h.length;g++){if(h[g].value==d){m=1;l.selectedIndex=g;break}}if(m==0){for(g=0;g<h.length;g++){if(h[g].value==wla_get_channel){m=1;l.selectedIndex=g;break}}}if(m==0){l.selectedIndex=0}}function check_wlan(){if(check_dfs()==false){return false}var o=0;var n=0;var m=0;var d=document.forms[0];var f=document.forms[0].ssid.value;var p=0;var g=0;var h=document.forms[0].wla1ssid.value;var k=document.forms[0].wlg1ssid.value;var c=f.length;for(i=0;i<f.length;i++){if(f.charCodeAt(i)==32){c--}}if(f==""||c==0){alert("$ssid_null");return false}if(f==k){alert("$ssid_not_allowed_same");return false}if(have_byod_network==1){var b=document.forms[0].wlg2ssid.value;if(f==b){alert("$ssid_not_allowed_same");return false}}for(i=0;i<f.length;i++){if(isValidChar_space(f.charCodeAt(i))==false){alert("$ssid_not_allowed");return false}}d.wl_ssid.value=f;d.wl_apply_flag.value="1";if(wds_endis_fun==1){if(d.w_channel.selectedIndex==0){alert("$wds_auto_channel");return false}}d.wl_hidden_wlan_channel.value=d.w_channel.value;if(d.enable_coexist.checked==true){d.hid_enable_coexist.value="0"}else{d.hid_enable_coexist.value="1"}if(d.security_type[1].checked==true){if(checkpsk(d.passphrase,d.wl_sec_wpaphrase_len)==false){return false}d.wl_hidden_sec_type.value=4;d.wl_hidden_wpa_psk.value=d.passphrase.value}else{if(d.security_type[2].checked==true){if(checkpsk(d.passphrase,d.wl_sec_wpaphrase_len)==false){return false}d.wl_hidden_sec_type.value=5;d.wl_hidden_wpa_psk.value=d.passphrase.value;if(wl_simple_mode!="1"){if(confirm("$wlan_tkip_aes_300_150")==false){return false}}}else{d.wl_hidden_sec_type.value=1}}var j=false;if(parent.bgn_mode3_value>150&&d.enable_coexist.checked==true){j=true;alert(msg)}if(an_router_flag==1){document.forms[0].ssid_an.value=document.forms[0].ssid.value;var a=document.forms[0].ssid_an.value;if(a==""){alert("$ssid_null");return false}if(f==k||f==h||a==k||a==h){alert("$ssid_not_allowed_same");return false}for(i=0;i<a.length;i++){if(isValidChar_space(a.charCodeAt(i))==false){alert("$ssid_not_allowed");return false}}d.wla_ssid.value=a;d.wla_hidden_wlan_channel.value=d.w_channel_an.value;d.wla_hidden_sec_type.value=d.wl_hidden_sec_type.value;if(d.wla_hidden_sec_type.value=="3"||d.wla_hidden_sec_type.value=="4"||d.wla_hidden_sec_type.value=="5"){d.passphrase_an.value=d.passphrase.value;if(checkpsk(d.passphrase_an,d.wla_sec_wpaphrase_len)==false){return false}d.wla_hidden_wpa_psk.value=d.passphrase_an.value}var l=d.w_channel_an.value;var e=wl_get_countryA;wlan_txctrl(d,wl_txctrl_web,wla_txctrl_web,l,e)}if(endis_wl_radio==1&&(d.wl_hidden_sec_type.value=="2"||d.wl_hidden_sec_type.value=="3")||(an_router_flag==1&&endis_wla_radio==1&&(d.wla_hidden_sec_type.value=="2"||d.wla_hidden_sec_type.value=="3"))){if(p==0){if(!confirm("$wps_warning2")){return false}}}if(d.wl_hidden_sec_type.value=="1"||(an_router_flag==1&&d.wla_hidden_sec_type.value=="1")){if(!confirm("$wps_warning3")){return false}}if((endis_wl_radio==1&&d.wl_hidden_sec_type.value=="6")||(an_router_flag==1&&d.wla_hidden_sec_type.value=="6"&&endis_wla_radio==1)){if(p==0){if(!confirm("$wpae_or_wps")){return false}}}d.submit();return true}function check_wlan_guest(c){var f=document.forms[0];var g=document.forms[0].ssid.value;f.s_gssid.value=g;f.s_gssid_an.value=g;var b=document.forms[0].wlssid.value;var d=document.forms[0].wlassid.value;var a=0;if(g==""){alert("$ssid_null");return false}if(g==b){alert("$ssid_not_allowed_same");return false}for(i=0;i<g.length;i++){if(isValidChar_space(g.charCodeAt(i))==false){alert(g+"$ssid_not_allowed");return false}}if(f.enable_bssid.checked==true){f.hidden_enable_guestNet.value=1;f.hidden_enable_guestNet_an.value=1}else{f.hidden_enable_guestNet.value=0;f.hidden_enable_guestNet_an.value=0}if(f.enable_ssid_bc.checked==true){f.hidden_enable_ssidbro.value=1;f.hidden_enable_ssidbro_an.value=1}else{f.hidden_enable_ssidbro.value=0;f.hidden_enable_ssidbro_an.value=0}if(f.allow_access.checked==true){f.hidden_allow_see_and_access.value=1;f.hidden_allow_see_and_access_an.value=1}else{f.hidden_allow_see_and_access.value=0;f.hidden_allow_see_and_access_an.value=0}var e=0;f.wl_hidden_wlan_mode.value=wl_simple_mode;f.wl_hidden_wlan_mode_an.value=wl_simple_mode_an;if(f.security_type[1].checked==true){f.hidden_guest_network_mode_flag.value=0;f.hidden_guest_network_mode_flag_an.value=0;if(checkpsk(f.passphrase,f.sec_wpaphrase_len)==false){return false}f.passphrase_an.value=f.passphrase.value;f.sec_wpaphrase_len_an.value=f.sec_wpaphrase_len.value;f.hidden_sec_type.value=4;f.hidden_sec_type_an.value=4;f.hidden_wpa_psk.value=f.passphrase.value;f.hidden_wpa_psk_an.value=f.passphrase_an.value}else{if(f.security_type[2].checked==true){if(checkpsk(f.passphrase,f.sec_wpaphrase_len)==false){return false}f.passphrase_an.value=f.passphrase.value;f.sec_wpaphrase_len_an.value=f.sec_wpaphrase_len.value;if(wl_simple_mode!="1"){a=1;if(confirm("$wlan_tkip_aes_300_150")==false){f.hidden_guest_network_mode_flag.value=0;f.hidden_guest_network_mode_flag_an.value=0;return false}}f.hidden_guest_network_mode_flag.value=2;f.hidden_guest_network_mode_flag_an.value=2;f.wl_hidden_wlan_mode.value=wl_simple_mode;f.wl_hidden_wlan_mode_an.value=wl_simple_mode_an;f.hidden_sec_type.value=5;f.hidden_sec_type_an.value=5;f.hidden_wpa_psk.value=f.passphrase.value;f.hidden_wpa_psk_an.value=f.passphrase_an.value}else{f.hidden_sec_type.value=1;f.hidden_sec_type_an.value=1}}f.submit();return true}var ht20_array=new Array(new Array("36","40","44","48","52(DFS)","56(DFS)","60(DFS)","64(DFS)","100(DFS)","104(DFS)","108(DFS)","112(DFS)","116(DFS)","136(DFS)","140(DFS)"),new Array("36","40","44","48","52(DFS)","56(DFS)","60(DFS)","64(DFS)","100(DFS)","104(DFS)","108(DFS)","112(DFS)","116(DFS)","120(DFS)","124(DFS)","128(DFS)","132(DFS)","136(DFS)","140(DFS)","149","153","157","161","165"),new Array("36","40","44","48","52(DFS)","56(DFS)","60(DFS)","64(DFS)","100(DFS)","104(DFS)","108(DFS)","112(DFS)","116(DFS)","132(DFS)","136(DFS)","140(DFS)","149","153","157","161","165"),new Array("36","40","44","48","52(DFS)","56(DFS)","60(DFS)","64(DFS)","100(DFS)","104(DFS)","108(DFS)","112(DFS)","116(DFS)","136(DFS)","140(DFS)","149","153","157","161","165"),new Array("36","40","44","48","52(DFS)","56(DFS)","60(DFS)","64(DFS)","100(DFS)","104(DFS)","108(DFS)","112(DFS)","116(DFS)","120(DFS)","124(DFS)","128(DFS)","132(DFS)","136(DFS)","140(DFS)"),new Array("36","40","44","48","52(DFS)","56(DFS)","60(DFS)","64(DFS)"),new Array("36","40","44","48","52(DFS)","56(DFS)","60(DFS)","64(DFS)","100(DFS)","104(DFS)","108(DFS)","112(DFS)","116(DFS)","120(DFS)","124(DFS)","128(DFS)","132(DFS)","136(DFS)","140(DFS)"),new Array("36","40","44","48","52(DFS)","56(DFS)","60(DFS)","64(DFS)","100(DFS)","104(DFS)","108(DFS)","112(DFS)","116(DFS)","120(DFS)","124(DFS)","128(DFS)","149","153","157","161"),new Array("36","40","44","48","52(DFS)","56(DFS)","60(DFS)","64(DFS)","149","153","157","161","165"),new Array("36","40","44","48","52(DFS)","56(DFS)","60(DFS)","64(DFS)","100(DFS)","104(DFS)","108(DFS)","112(DFS)","116(DFS)","120(DFS)","124(DFS)","128(DFS)","132(DFS)","136(DFS)","140(DFS)","149","153","157","161","165"),new Array("36","40","44","48","52(DFS)","56(DFS)","60(DFS)","64(DFS)","100(DFS)","104(DFS)","108(DFS)","112(DFS)","116(DFS)","136(DFS)","140(DFS)","149","153","157","161","165"),new Array("149","153","157","161","165"),new Array("36","40","44","48","52(DFS)","56(DFS)","60(DFS)","64(DFS)","149","153","157","161","165"),new Array("36","40","44","48","52(DFS)","56(DFS)","60(DFS)","64(DFS)","149","153","157","161","165"),new Array(""),new Array("149","153","157","161","165"),new Array("36","40","44","48","52(DFS)","56(DFS)","60(DFS)","64(DFS)"),new Array("36","40","44","48","52(DFS)","56(DFS)","60(DFS)","64(DFS)","165"),new Array("36","40","44","48","52(DFS)","56(DFS)","60(DFS)","64(DFS)","100(DFS)","104(DFS)","108(DFS)","112(DFS)","116(DFS)","120(DFS)","124(DFS)","128(DFS)","132(DFS)","136(DFS)","140(DFS)"),new Array("36","40","44","48"),new Array("36","40","44","48","52(DFS)","56(DFS)","60(DFS)","64(DFS)","149","153","157","161","165"),new Array("56","60","64","100(DFS)","104(DFS)","108(DFS)","112(DFS)","116(DFS)","120(DFS)","124(DFS)","128(DFS)","132(DFS)","136(DFS)","140(DFS)","149","153","157","161","165"));var ht40_array=new Array(new Array(""),new Array("36","40","44","48","52(DFS)","56(DFS)","60(DFS)","64(DFS)","100(DFS)","104(DFS)","108(DFS)","112(DFS)","116(DFS)","120(DFS)","124(DFS)","128(DFS)","132(DFS)","136(DFS)","149","153","157","161"),new Array("36","40","44","48","52(DFS)","56(DFS)","60(DFS)","64(DFS)","100(DFS)","104(DFS)","108(DFS)","112(DFS)","132(DFS)","136(DFS)","149","153","157","161"),new Array("36","40","44","48","52(DFS)","56(DFS)","60(DFS)","64(DFS)","100(DFS)","104(DFS)","108(DFS)","112(DFS)","149","153","157","161"),new Array("36","40","44","48","52(DFS)","56(DFS)","60(DFS)","64(DFS)","100(DFS)","104(DFS)","108(DFS)","112(DFS)","116(DFS)","120(DFS)","124(DFS)","128(DFS)","132(DFS)","136(DFS)"),new Array(""),new Array("36","40","44","48","52(DFS)","56(DFS)","60(DFS)","64(DFS)","100(DFS)","104(DFS)","108(DFS)","112(DFS)","116(DFS)","120(DFS)","124(DFS)","128(DFS)","132(DFS)","136(DFS)"),new Array("36","40","44","48","52(DFS)","56(DFS)","60(DFS)","64(DFS)","100(DFS)","104(DFS)","108(DFS)","112(DFS)","116(DFS)","120(DFS)","124(DFS)","128(DFS)","149","153","157","161"),new Array("36","40","44","48","52(DFS)","56(DFS)","60(DFS)","64(DFS)","149","153","157","161"),new Array("36","40","44","48","52(DFS)","56(DFS)","60(DFS)","64(DFS)","100(DFS)","104(DFS)","108(DFS)","112(DFS)","116(DFS)","120(DFS)","124(DFS)","128(DFS)","132(DFS)","136(DFS)","149","153","157","161"),new Array("36","40","44","48","52(DFS)","56(DFS)","60(DFS)","64(DFS)","100(DFS)","104(DFS)","108(DFS)","112(DFS)","149","153","157","161"),new Array("149","153","157","161"),new Array("36","40","44","48","52(DFS)","56(DFS)","60(DFS)","64(DFS)","149","153","157","161"),new Array("36","40","44","48","52(DFS)","56(DFS)","60(DFS)","64(DFS)","149","153","157","161"),new Array(""),new Array("149","153","157","161"),new Array(""),new Array(""),new Array("36","40","44","48","52(DFS)","56(DFS)","60(DFS)","64(DFS)","100(DFS)","104(DFS)","108(DFS)","112(DFS)","116(DFS)","120(DFS)","124(DFS)","128(DFS)","132(DFS)","136(DFS)"),new Array("36","40","44","48"),new Array("36","40","44","48","52(DFS)","56(DFS)","60(DFS)","64(DFS)","149","153","157","161"),new Array("60","64","100(DFS)","104(DFS)","108(DFS)","112(DFS)","116(DFS)","120(DFS)","124(DFS)","128(DFS)","132(DFS)","136(DFS)","149","153","157","161"));var ht80_array=new Array(new Array("36","40","44","48"),new Array("36","40","44","48","52(DFS)","56(DFS)","60(DFS)","64(DFS)","100(DFS)","104(DFS)","108(DFS)","112(DFS)","116(DFS)","120(DFS)","124(DFS)","128(DFS)"),new Array("36","40","44","48","52(DFS)","56(DFS)","60(DFS)","64(DFS)","100(DFS)","104(DFS)","108(DFS)","112(DFS)"),new Array("36","40","44","48","52(DFS)","56(DFS)","60(DFS)","64(DFS)","100(DFS)","104(DFS)","108(DFS)","112(DFS)"),new Array("36","40","44","48","52(DFS)","56(DFS)","60(DFS)","64(DFS)"),new Array("36","40","44","48"),new Array("36","40","44","48","52(DFS)","56(DFS)","60(DFS)","64(DFS)","100(DFS)","104(DFS)","108(DFS)","112(DFS)","116(DFS)","120(DFS)","124(DFS)","128(DFS)"),new Array("36","40","44","48","52(DFS)","56(DFS)","60(DFS)","64(DFS)","100(DFS)","104(DFS)","108(DFS)","112(DFS)","116(DFS)","120(DFS)","124(DFS)","128(DFS)"),new Array("36","40","44","48","52(DFS)","56(DFS)","60(DFS)","64(DFS)"),new Array("36","40","44","48","52(DFS)","56(DFS)","60(DFS)","64(DFS)","100(DFS)","104(DFS)","108(DFS)","112(DFS)","116(DFS)","120(DFS)","124(DFS)","128(DFS)"),new Array("36","40","44","48","52(DFS)","56(DFS)","60(DFS)","64(DFS)","100(DFS)","104(DFS)","108(DFS)","112(DFS)"),new Array("36","40","44","48"),new Array("36","40","44","48","52(DFS)","56(DFS)","60(DFS)","64(DFS)"),new Array("36","40","44","48","52(DFS)","56(DFS)","60(DFS)","64(DFS)"),new Array("36","40","44","48"),new Array("36","40","44","48"),new Array("36","40","44","48"),new Array("36","40","44","48"),new Array("36","40","44","48","52(DFS)","56(DFS)","60(DFS)","64(DFS)","100(DFS)","104(DFS)","108(DFS)","112(DFS)","116(DFS)","120(DFS)","124(DFS)","128(DFS)"),new Array("36","40","44","48"),new Array("36","40","44","48","52(DFS)","56(DFS)","60(DFS)","64(DFS)"),new Array("36","40","44","48","100(DFS)","104(DFS)","108(DFS)","112(DFS)","116(DFS)","120(DFS)","124(DFS)","128(DFS)"));