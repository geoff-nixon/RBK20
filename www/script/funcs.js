function check_DNS(d,b,a,c){if(d!="..."){if(checkipaddr(d)==false){alert(bh_invalid_primary_dns);return false}if(a==true&&isSameIp(d,c)){alert(bh_invalid_primary_dns);return false}}if(b!="..."){if(checkipaddr(b)==false){alert(bh_invalid_second_dns);return false}if(a==true&&isSameIp(b,c)){alert(bh_invalid_second_dns);return false}}if(d=="..."&&b=="..."){alert(bh_dns_must_specified);return false}return true}function check_three_DNS(d,b,e,a,c){if(d!="..."){if(checkipaddr(d)==false){alert(bh_invalid_primary_dns);return false}if(a==true&&isSameIp(d,c)){alert(bh_invalid_primary_dns);return false}}if(b!="..."){if(checkipaddr(b)==false){alert(bh_invalid_second_dns);return false}if(a==true&&isSameIp(b,c)){alert(bh_invalid_second_dns);return false}}if(e!="..."){if(checkipaddr(e)==false){alert(hb_invalid_third_dns);return false}if(a==true&&isSameIp(e,c)){alert(hb_invalid_third_dns);return false}}if(d=="..."&&b=="..."&&e=="..."){alert(bh_dns_must_specified);return false}return true}function SelectionTextLength(a){var b="";if(document.selection&&document.selection.createRange){b=document.selection.createRange().text}else{if(b==""&&a.selectionStart!=undefined){b=a.value.substring(a.selectionStart,a.selectionEnd)}}return b.length}function keydown(a,b){if((a.keyCode==190||a.keyCode==110)&&b.value.length!=0&&SelectionTextLength(b)==0){b.form[(getIndex(b)+1)%b.form.length].focus()}}function keyup(a,b){if(b.value.length==3&&((a.keyCode>47&&a.keyCode<58)||(a.keyCode>95&&a.keyCode<106))){b.form[(getIndex(b)+1)%b.form.length].focus()}}function getIndex(a){var b=-1;var c=0;var d=false;while(c<a.form.length&&b==-1){if(a.form[c]==a){b=c}else{c++}}return b}function get_browser(){if(navigator.userAgent.indexOf("MSIE")!=-1){return"IE"}else{if(navigator.userAgent.indexOf("Firefox")!=-1){return"Firefox"}else{if(navigator.userAgent.indexOf("Safari")!=-1){return"Safari"}else{if(navigator.userAgent.indexOf("Camino")!=-1){return"Camino"}else{if(navigator.userAgent.indexOf("Gecko/")!=-1){return"Gecko"}else{return""}}}}}}function _isNumeric(b){var a;for(a=0;a<b.length;a++){var d=b.substring(a,a+1);if("0"<=d&&d<="9"){continue}return false}return true}function isSameIp(a,b){var c=0;var d=a.split(".");var e=b.split(".");for(i=0;i<4;i++){num1=parseInt(d[i]);num2=parseInt(e[i]);if(num1==num2){c++}}if(c==4){return true}else{return false}}function is_sub_or_broad(d,e,a){addr_arr=d.split(".");var c=0;for(i=0;i<4;i++){addr_str=parseInt(addr_arr[i],10);c=c*256+parseInt(addr_str)}var b=isSub(e,a);var f=isBroadcast(e,a);if(c==b||c==f){return false}return true}function isGateway(d,f,b){gtw_arr=b.split(".");var a=0;for(i=0;i<4;i++){gtw_str=parseInt(gtw_arr[i],10);a=a*256+parseInt(gtw_str)}addr_arr=d.split(".");var e=0;for(i=0;i<4;i++){addr_str=parseInt(addr_arr[i],10);e=e*256+parseInt(addr_str)}var c=isSub(d,f);var g=isBroadcast(d,f);if((parseInt(c)<parseInt(a))&&(parseInt(a)<parseInt(g))){return true}else{return false}}function isSub(b,c){ip_arr=b.split(".");mask_arr=c.split(".");var a=0;for(i=0;i<4;i++){ip_str=parseInt(ip_arr[i],10);mask_str=parseInt(mask_arr[i],10);a=a*256+parseInt(ip_str&mask_str)}return(a)}function isBroadcast(a,b){ip_arr=a.split(".");mask_arr=b.split(".");var c=0;for(i=0;i<4;i++){ip_str=parseInt(ip_arr[i],10);mask_str=parseInt(mask_arr[i],10);n_str=~mask_str+256;c=c*256+parseInt(ip_str|n_str)}return(c)}function isSameSubNet(b,e,d,a){var c=0;lan1a=b.split(".");lan1m=e.split(".");lan2a=d.split(".");lan2m=a.split(".");for(i=0;i<4;i++){l1a_n=parseInt(lan1a[i],10);l1m_n=parseInt(lan1m[i],10);l2a_n=parseInt(lan2a[i],10);l2m_n=parseInt(lan2m[i],10);if((l1a_n&l1m_n)==(l2a_n&l2m_n)){c++}}if(c==4){return true}else{return false}}function checkipaddr(a){var e=document.forms[0];var c=a.split(".");var d=c[0]+c[1]+c[2]+c[3];var b=0;if((c[0]=="")||(c[0]<0)||(c[0]>255)||(c[1]=="")||(c[1]<0)||(c[1]>255)||(c[2]=="")||(c[2]<0)||(c[2]>255)||(c[3]=="")||(c[3]<0)||(c[3]>255)){return false}for(b=0;b<d.length;b++){if((d.charAt(b)!="0")&&(d.charAt(b)!="1")&&(d.charAt(b)!="2")&&(d.charAt(b)!="3")&&(d.charAt(b)!="4")&&(d.charAt(b)!="5")&&(d.charAt(b)!="6")&&(d.charAt(b)!="7")&&(d.charAt(b)!="8")&&(d.charAt(b)!="9")){return false}}if(c[0]>223||c[0]==0){return false}if(a=="0.0.0.0"||a=="255.255.255.255"){return false}var f=a.split(".");if(f[0]=="127"){return false}if(!c||c.length!=4){return false}else{for(b=0;b<4;b++){thisSegment=c[b];if(thisSegment!=""){if(b==3){if(!((c[3]>0)&&(c[3]<255))){return false}}else{if(!(thisSegment>=0&&thisSegment<=255)){return false}}}else{return false}}}return true}function checksubnet(b){var f=b.split(".");var e=f[0]+f[1]+f[2]+f[3];var c=0;var a=0;var d=true;if((f[0]=="")||(f[0]<0)||(f[0]>255)||(f[1]=="")||(f[1]<0)||(f[1]>255)||(f[2]=="")||(f[2]<0)||(f[2]>255)||(f[3]=="")||(f[3]<0)||(f[3]>255)){return false}for(c=0;c<e.length;c++){if((e.charAt(c)!="0")&&(e.charAt(c)!="1")&&(e.charAt(c)!="2")&&(e.charAt(c)!="3")&&(e.charAt(c)!="4")&&(e.charAt(c)!="5")&&(e.charAt(c)!="6")&&(e.charAt(c)!="7")&&(e.charAt(c)!="8")&&(e.charAt(c)!="9")){return false}}if(!f||f.length!=4){return false}else{for(c=0;c<4;c++){thisSegment=f[c];if(thisSegment!=""){if(!(thisSegment>=0&&thisSegment<=255)){return false}}else{return false}}}if(f[0]<255){if((f[1]>0)||(f[2]>0)||(f[3]>0)){d=false}else{a=f[0]}}else{if(f[1]<255){if((f[2]>0)||(f[3]>0)){d=false}else{a=f[1]}}else{if(f[2]<255){if((f[3]>0)){d=false}else{a=f[2]}}else{a=f[3]}}}if(d){switch(a){case"0":case"128":case"192":case"224":case"240":case"248":case"252":case"254":case"255":break;default:d=false}if(b=="0.0.0.0"){d=false}}else{d=false}return d}function checkgateway(e){var c=document.forms[0];var d=e.split(".");var a=d[0]+d[1]+d[2]+d[3];var b=0;if((d[0]=="")||(d[0]<0)||(d[0]>255)||(d[1]=="")||(d[1]<0)||(d[1]>255)||(d[2]=="")||(d[2]<0)||(d[2]>255)||(d[3]=="")||(d[3]<0)||(d[3]>255)){return false}for(b=0;b<a.length;b++){if((a.charAt(b)!="0")&&(a.charAt(b)!="1")&&(a.charAt(b)!="2")&&(a.charAt(b)!="3")&&(a.charAt(b)!="4")&&(a.charAt(b)!="5")&&(a.charAt(b)!="6")&&(a.charAt(b)!="7")&&(a.charAt(b)!="8")&&(a.charAt(b)!="9")){return false}}if(d[0]>223||d[0]==0){return false}if(e=="0.0.0.0"||e=="255.255.255.255"){return false}if(e=="127.0.0.1"){return false}if(!d||d.length!=4){return false}else{for(b=0;b<4;b++){thisSegment=d[b];if(thisSegment!=""){if(!(thisSegment>=0&&thisSegment<=255)){return false}}else{return false}}}return true}function getkey(a,d){var c,b;if(window.event){b=window.event;c=window.event.keyCode}else{if(d){b=d;c=d.which}else{return true}}if(b.ctrlKey&&(c==99||c==118||c==120)){return true}if(a=="apname"){if((c==34)||(c==39)||(c==92)){return false}else{return true}}else{if(a=="ipaddr"){if(((c>47)&&(c<58))||(c==8)||(c==0)||(c==46)){return true}else{return false}}else{if(a=="ssid"){if(c==32){return false}else{return true}}else{if(a=="wep"){if(((c>47)&&(c<58))||((c>64)&&(c<71))||((c>96)&&(c<103))||(c==8)||(c==0)){return true}else{return false}}else{if(a=="num"){if(((c>47)&&(c<58))||(c==8)||(c==0)){return true}else{return false}}else{if(a=="num_letter"){if((c>47&&c<58)||(c>64&&c<91)||(c>96&&c<123)||(c==8)||(c==0)){return true}else{return false}}else{if(a=="hostname"){if(((c>47)&&(c<58))||(c==45)||((c>64)&&(c<91))||((c>96)&&(c<123))||(c==8)||(c==0)){return true}else{return false}}else{if(a=="ddns_hostname"){if(((c>47)&&(c<58))||(c==45)||(c==46)||((c>64)&&(c<91))||((c>96)&&(c<123))||(c==8)||(c==0)){return true}else{return false}}else{if(a=="mac"){if(((c>47)&&(c<58))||((c>64)&&(c<71))||((c>96)&&(c<103))||(c==8)||(c==0)||(c==58)||(c==45)){return true}else{return false}}else{if(a=="folderPath"){if((c==47)||(c==42)||(c==63)||(c==34)||(c==60)||(c==62)||(c==124)){return false}else{return true}}else{if(a=="shareName"){if((c==47)||(c==42)||(c==63)||(c==34)||(c==58)||(c==60)||(c==62)||(c==92)||(c==93)||(c==124)){return false}else{return true}}else{if(a=="mediaServerName"){if((c==47)||(c==42)||(c==63)||(c==34)||(c==58)||(c==60)||(c==62)||(c==92)||(c==93)||(c==124)){alert("$media_server_name_colon");return false}else{return true}}else{return false}}}}}}}}}}}}}function setDisabled(c,a){for(var b=1;b<setDisabled.arguments.length;b++){setDisabled.arguments[b].disabled=c}}function maccheck_multicast(b){mac_array=b.split(":");var a=mac_array[0];a=a.substr(1,1);if((a=="1")||(a=="3")||(a=="5")||(a=="7")||(a=="9")||(a=="b")||(a=="d")||(a=="f")||(a=="B")||(a=="D")||(a=="F")){alert(bh_invalid_mac);return false}if(mac_array.length!=6){alert(bh_invalid_mac);return false}if((mac_array[0]=="")||(mac_array[1]=="")||(mac_array[2]=="")||(mac_array[3]=="")||(mac_array[4]=="")||(mac_array[5]=="")){alert(bh_invalid_mac);return false}if(((mac_array[0]=="00")&&(mac_array[1]=="00")&&(mac_array[2]=="00")&&(mac_array[3]=="00")&&(mac_array[4]=="00")&&(mac_array[5]=="00"))||((mac_array[0]=="ff")&&(mac_array[1]=="ff")&&(mac_array[2]=="ff")&&(mac_array[3]=="ff")&&(mac_array[4]=="ff")&&(mac_array[5]=="ff"))||((mac_array[0]=="FF")&&(mac_array[1]=="FF")&&(mac_array[2]=="FF")&&(mac_array[3]=="FF")&&(mac_array[4]=="FF")&&(mac_array[5]=="FF"))){alert(bh_invalid_mac);return false}if((mac_array[0].length!=2)||(mac_array[1].length!=2)||(mac_array[2].length!=2)||(mac_array[3].length!=2)||(mac_array[4].length!=2)||(mac_array[5].length!=2)){alert(bh_invalid_mac);return false}for(i=0;i<b.length;i++){if(isValidMac(b.charAt(i))==false){alert(bh_invalid_mac);return false}}return true}function setMAC(c,a){var b;if(c.MACAssign[0].checked||c.MACAssign[1].checked){b=true;c.Spoofmac.value=a;setDisabled(b,c.Spoofmac)}else{b=false;setDisabled(b,c.Spoofmac);c.Spoofmac.value=a}}function isValidMac(e){var d=new Array("0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F","a","b","c","d","e","f",":");var a=d.length;var c=0;var b=false;for(c=0;c<a;c++){if(e==d[c]){break}}if(c<a){b=true}return b}function isValidChar(a){if(a<33||a>126){return false}};