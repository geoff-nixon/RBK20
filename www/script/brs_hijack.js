function goto_home_page(){top.location.href="index.htm"}function addLoadEvent(a){var b=window.onload;if(typeof window.onload!="function"){window.onload=a}else{window.onload=function(){b();a()}}}function insertAfter(c,b){var a=b.parentNode;if(a.lastChild==b){a.appendChild(c)}else{a.insertBefore(c,b.nextSibling)}}function addClass(a,b){if(!a.className){a.className=b}else{newClassName=a.className;newClassName+=" ";newClassName+=b;a.className=newClassName}}function showFirmVersion(a){var b=top.document.getElementById("header_frame");if(b){var c=b.contentWindow.document.getElementById("firmware_version");if(c){c.style.display=a}}}function ssidKeyCode(b){var a=b?b:(window.event?window.event:null);var c=window.event?window.event.keyCode:(a?a.which:null);if(c==32){return false}else{return true}}function ipaddrKeyCode(b){var a=b?b:(window.event?window.event:null);var c=window.event?window.event.keyCode:(a?a.which:null);if(((c>47)&&(c<58))||(c==8)||(c==0)||(c==46)){return true}else{return false}}function numKeyCode(b){var a=b?b:(window.event?window.event:null);var c=window.event?window.event.keyCode:(a?a.which:null);if(((c>47)&&(c<58))||(c==8)||(c==0)){return true}else{return false}}function numLetterKeyCode(b){var a=b?b:(window.event?window.event:null);var c=window.event?window.event.keyCode:(a?a.which:null);if((c>47&&c<58)||(c>64&&c<91)||(c>96&&c<123)||(c==8)||(c==0)){return true}else{return false}}function hostnameKeyCode(b){var a=b?b:(window.event?window.event:null);var c=window.event?window.event.keyCode:(a?a.which:null);if(((c>47)&&(c<58))||(c==45)||((c>64)&&(c<91))||((c>96)&&(c<123))||(c==8)||(c==0)){return true}else{return false}}function ddnsHostnameKeyCode(b){var a=b?b:(window.event?window.event:null);var c=window.event?window.event.keyCode:(a?a.which:null);if(((c>47)&&(c<58))||(c==45)||(c==46)||((c>64)&&(c<91))||((c>96)&&(c<123))||(c==8)||(c==0)){return true}else{return false}}function macKeyCode(b){var a=b?b:(window.event?window.event:null);var c=window.event?window.event.keyCode:(a?a.which:null);if(((c>47)&&(c<58))||((c>64)&&(c<71))||((c>96)&&(c<103))||(c==8)||(c==0)||(c==58)||(c==45)){return true}else{return false}}function detectOS(){var d=navigator.userAgent;var f=(navigator.platform=="Win32")||(navigator.platform=="Win64")||(navigator.platform=="Windows");var h=(navigator.platform=="Mac68K")||(navigator.platform=="MacPPC")||(navigator.platform=="Macintosh")||(navigator.platform=="MacIntel");if(h){return"Mac"}var g=(navigator.platform=="X11")&&!f&&!h;if(g){return"Unix"}var c=(String(navigator.platform).indexOf("Linux")>-1);if(c){return"Linux"}if(f){var e=d.indexOf("Windows NT 5.0")>-1||d.indexOf("Windows 2000")>-1;if(e){return"Win2000"}var j=d.indexOf("Windows NT 5.1")>-1||d.indexOf("Windows XP")>-1;if(j){return"WinXP"}var b=d.indexOf("Windows NT 5.2")>-1||d.indexOf("Windows 2003")>-1;if(b){return"Win2003"}var b=d.indexOf("Windows NT 6.0")>-1||d.indexOf("Windows Vista")>-1;if(b){return"WinVista"}var b=d.indexOf("Windows NT 6.1")>-1||d.indexOf("Windows 7")>-1;if(b){return"Win7"}var a=d.indexOf("Windows NT 6.2")>-1||d.indexOf("Windows NT 6.3")>-1||d.indexOf("Windows 8")>-1;if(a){return"Win8"}var i=d.indexOf("Windows NT 10.0")>-1||d.indexOf("Windows 10")>-1;if(i){return"Win10"}return"Win"}return"None"}function isMac(){return(detectOS()=="Mac")}function control_display(a){if(a=="dsl_dhcp"){if(lan_ports_num==1){document.getElementById("bridge_doc").style.display="none";document.getElementById("bridge_lans").style.display="none";document.getElementById("content_div").style.width="100%";document.getElementById("connection_identi").style.height="60px"}}else{if(a=="dsl_pppoe"||a=="dsl_pppoe_gr"){if(display_iptv2=="1"){document.getElementById("iptv").style.display="";if(wan2_bridge=="1"&&lan_ports_num!=1){document.getElementById("bridge").style.display="";document.getElementById("bridge1").style.display="";document.getElementById("bridge2").style.display=""}else{document.getElementById("bridge").style.display="none";document.getElementById("bridge1").style.display="none";document.getElementById("bridge2").style.display="none"}}else{document.getElementById("iptv").style.display="none"}if(vlan_id==""){var b=document.getElementById("vlanid_text");if(b!=null){document.getElementById("vlanid").style.display="none";b.style.display="none"}}if(a=="dsl_pppoe"&&country=="France"&&isp=="SFR"){document.getElementById("servername_div").style.display="";document.getElementById("input_servername_div").style.display=""}}}}function gotto_link(a,b){if(a!="None"){top.open_or_close_sub(a)}top.click_adv_action(b)}function manuallyConfig(){if(confirm(bh_no_genie_help_confirm)==false){return false}if(top.dsl_enable_flag==1){this.location.href="BRS_log12_incorrect_go_to_internet.html"}else{var a=document.getElementsByTagName("form");var b=a[0];if(hijack_process=="1"){b.action="/apply.cgi?/welcomeok.htm timestamp="+ts;b.submit_flag.value="hijack_toBasic";b.submit()}else{gotto_link("setup","internet")}}return true};