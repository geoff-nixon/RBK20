function initPage(){var l=document.getElementsByTagName("h1");var m=document.createTextNode(bh_bpa_connection);l[0].appendChild(m);var s=document.getElementsByTagName("p");var i=document.createTextNode(bh_enter_info_below);s[0].appendChild(i);var g=document.getElementById("loginName");var p=document.createTextNode(bh_pptp_login_name);g.appendChild(p);var q=document.getElementById("passwd");var d=document.createTextNode(bh_ddns_passwd);q.appendChild(d);var a=document.getElementById("idleTimeout");var h=document.createTextNode(bh_basic_pppoe_idle);a.appendChild(h);var n=document.getElementById("serverIP");var b=document.createTextNode(bh_basic_bpa_auth_serv);n.appendChild(b);var r=document.getElementById("inputName");r.onkeypress=ssidKeyCode;var f=document.getElementById("inputPasswd");f.onkeypress=ssidKeyCode;var c=document.getElementById("inputIdle");c.onkeypress=numKeyCode;var j=document.getElementById("inputServerIP");j.onkeypress=ssidKeyCode;var e=document.getElementById("btnsContainer_div");e.onclick=function(){return checkBPA()};var k=document.getElementById("btn_text_div");var o=document.createTextNode(bh_next_mark);k.appendChild(o)}function checkBPA(){var b=document.getElementsByTagName("form");var g=b[0];var h=document.getElementById("inputName");var f=document.getElementById("inputPasswd");var e=document.getElementById("inputIdle");var a=document.getElementById("inputServerIP");if(h.value==""){alert(bh_login_name_null);return false}for(c=0;c<f.value.length;c++){if(isValidChar(f.value.charCodeAt(c))==false){alert(bh_password_error);return false}}if(e.value.length<=0){alert(bh_idle_time_null);return false}else{if(!_isNumeric(e.value)){alert(bh_invalid_idle_time);return false}}if(a.value.length<=0){alert(bh_bpa_invalid_serv_name);return false}var d=a.value.split(".");var c;for(c=0;c<d.length;c++){if(d[c].length>63){alert(bh_invalid_servip_length);return false}}for(c=0;c<a.value.length;c++){if(isValidChar(a.value.charCodeAt(c))==false){alert(bh_bpa_invalid_serv_name);return false}}g.submit();return true}addLoadEvent(initPage);