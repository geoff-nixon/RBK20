function initPage(){var b=document.getElementsByTagName("h1");var a=document.createTextNode(bh_apply_connection);b[0].appendChild(a);var d=document.getElementsByTagName("p");var c=document.createTextNode(bh_plz_waite_apply_connection);d[0].appendChild(c);showFirmVersion("none");if(ap_mode=="1"){if(top.location.href.indexOf("BRS_index.htm")>-1){if(top.location.href.indexOf("orbilogin.net")>-1){setTimeout("top.location.href='http://orbilogin.com/BRS_index.htm';",100000)}else{setTimeout("top.location.href='http://orbilogin.net/BRS_index.htm';",100000)}}else{setTimeout("this.location.href='BRS_04_applySettings_ping.html';",100000)}}else{if(top.dsl_enable_flag=="1"){if(top.location.href.indexOf("BRS_index.htm")>-1){if(top.location.href.indexOf("orbilogin.net")>-1){setTimeout("set_jump(1)",20000)}else{setTimeout("set_jump(2)",20000)}}else{setTimeout("this.location.href='BRS_04_applySettings_ppp_obtain_ip.html';",30000)}}else{if(top.location.href.indexOf("BRS_index.htm")>-1){if(top.location.href.indexOf("orbilogin.net")>-1){setTimeout("top.location.href='http://orbilogin.com/BRS_index.htm';",60000)}else{setTimeout("top.location.href='http://orbilogin.net/BRS_index.htm';",60000)}}else{setTimeout("this.location.href='BRS_04_applySettings_ping.html';",60000)}}}}function set_jump(c){var b=createXMLHttpRequest();var a="/obtain_ip.txt?ts="+new Date().getTime();b.onreadystatechange=function(){if(b.readyState==4&&b.status==200){if(c==1){top.location.href="http://orbilogin.com/BRS_index.htm"}else{top.location.href="http://orbilogin.net/BRS_index.htm"}}else{if(b.readyState==4&&b.status==0){if(c==1){setTimeout("top.location.href='http://orbilogin.com/BRS_index.htm';",20000)}else{setTimeout("top.location.href='http://orbilogin.net/BRS_index.htm';",20000)}}}};b.open("GET",a,true);b.send(null)}addLoadEvent(initPage);