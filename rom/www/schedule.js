function BlockAllClickCheck(a){if(top.enable_ap_flag==1||enable_extender_flag=="1"){a.checkboxNameAll.disabled=true;a.checkboxNameMon.disabled=true;a.checkboxNameTue.disabled=true;a.checkboxNameWed.disabled=true;a.checkboxNameThu.disabled=true;a.checkboxNameFri.disabled=true;a.checkboxNameSat.disabled=true;a.checkboxNameSun.disabled=true}else{if(a.checkboxNameAll.checked){a.checkboxNameMon.checked=true;a.checkboxNameTue.checked=true;a.checkboxNameWed.checked=true;a.checkboxNameThu.checked=true;a.checkboxNameFri.checked=true;a.checkboxNameSat.checked=true;a.checkboxNameSun.checked=true;a.checkboxNameMon.disabled=true;a.checkboxNameTue.disabled=true;a.checkboxNameWed.disabled=true;a.checkboxNameThu.disabled=true;a.checkboxNameFri.disabled=true;a.checkboxNameSat.disabled=true;a.checkboxNameSun.disabled=true}else{a.checkboxNameMon.disabled=false;a.checkboxNameTue.disabled=false;a.checkboxNameWed.disabled=false;a.checkboxNameThu.disabled=false;a.checkboxNameFri.disabled=false;a.checkboxNameSat.disabled=false;a.checkboxNameSun.disabled=false}}BlockPeriodClick(a);return}function BlockPeriodClick(a){if(top.enable_ap_flag==1||enable_extender_flag=="1"){a.checkboxNamehours.disabled=true;a.start_hour.disabled=true;a.start_minute.disabled=true;a.end_hour.disabled=true;a.end_minute.disabled=true}else{if(a.checkboxNamehours.checked==true){a.start_hour.disabled=true;a.start_minute.disabled=true;a.end_hour.disabled=true;a.end_minute.disabled=true;TimePeriodDisabled=true;ClearData1()}else{a.start_hour.disabled=false;a.start_minute.disabled=false;a.end_hour.disabled=false;a.end_minute.disabled=false;TimePeriodDisabled=false}}return}function ClearData1(){var a=document.forms[0];a.start_hour.value="0";a.start_minute.value="0";a.end_hour.value="24";a.end_minute.value="0"}function check_schedule_apply(e){var e=document.forms[0];var d=0;var a,c;var f="";var b;if(e.checkboxNameAll.checked){f="everyday"}else{if(e.checkboxNameSun.checked){f+="0,"}if(e.checkboxNameMon.checked){f+="1,"}if(e.checkboxNameTue.checked){f+="2,"}if(e.checkboxNameWed.checked){f+="3,"}if(e.checkboxNameThu.checked){f+="4,"}if(e.checkboxNameFri.checked){f+="5,"}if(e.checkboxNameSat.checked){f+="6,"}}e.days_to_block.value=f;if(f==""){alert("$invalid_day");return false}if(e.checkboxNamehours.checked==true){b=1}else{b=0;if(e.start_hour.value==e.end_hour.value&&e.start_minute.value==e.end_minute.value){alert("$invalid_time");return false}if(!_isNumeric(e.start_hour.value)||!_isNumeric(e.end_hour.value)||!_isNumeric(e.start_minute.value)||!_isNumeric(e.end_minute.value)){alert("$invalid_time");return false}if((e.start_hour.value<0)||(e.start_hour.value>23)||(e.end_hour.value<0)||(e.end_hour.value>23)||(e.start_minute.value<0)||(e.start_minute.value>59)||(e.end_minute.value<0)||(e.end_minute.value>59)){if((e.start_hour.value=="24"&&e.start_minute.value=="0")||(e.start_hour.value=="24"&&e.start_minute.value=="00")||(e.end_hour.value=="24"&&e.end_minute.value=="0")||(e.end_hour.value=="24"&&e.end_minute.value=="00")){if((e.start_hour.value<0)||(e.start_hour.value>23)||(e.start_minute.value<0)||(e.start_minute.value>59)){alert("$invalid_time");return false}}else{alert("$invalid_time");return false}}if((e.start_hour.value=="")||(e.end_hour.value=="")){alert("$invalid_time");return false}if((e.start_hour.value!="")&&(e.end_hour.value!="")){if(e.start_minute.value==""){e.start_minute.value=0}if(e.end_minute.value==""){e.end_minute.value=0}}a=e.start_hour.value+":"+e.start_minute.value;c=e.end_hour.value+":"+e.end_minute.value;e.start_block_time.value=a;e.end_block_time.value=c}if(b==1){e.start_block_time.value="0:0";e.end_block_time.value="24:0"}else{var a=e.start_block_time.value.split(":");var c=e.end_block_time.value.split(":");e.start_block_time.value=a[0]+":"+a[1];e.end_block_time.value=c[0]+":"+c[1]}e.hidden_all_day.value=b;e.submit();return true}function check_ntp(b){cfindex=b.time_zone.options[b.time_zone.selectedIndex].value;if(cfindex=="GMT+1"||cfindex=="GMT+2"||cfindex=="GMT+3"){b.ntpserver1.value="time-h.netgear.com";b.ntpserver2.value="time-a.netgear.com"}else{if(cfindex=="GMT+3:30"||cfindex=="GMT+4"||cfindex=="GMT+5"||cfindex=="GMT+6"){b.ntpserver1.value="time-a.netgear.com";b.ntpserver2.value="time-b.netgear.com"}else{if(cfindex=="GMT+7"||cfindex=="GMT+8"||cfindex=="GMT+9"){b.ntpserver1.value="time-b.netgear.com";b.ntpserver2.value="time-c.netgear.com"}else{if(cfindex=="GMT+10"||cfindex=="GMT+11"||cfindex=="GMT+12"){b.ntpserver1.value="time-c.netgear.com";b.ntpserver2.value="time-d.netgear.com"}else{if(cfindex=="GMT-9"||cfindex=="GMT-9:30"||cfindex=="GMT-10"||cfindex=="GMT-11"||cfindex=="GMT-12"||cfindex=="GMT-13"){b.ntpserver1.value="time-d.netgear.com";b.ntpserver2.value="time-e.netgear.com"}else{if(cfindex=="GMT-6"||cfindex=="GMT-7"||cfindex=="GMT-8"){b.ntpserver1.value="time-e.netgear.com";b.ntpserver2.value="time-f.netgear.com"}else{if(cfindex=="GMT-3"||cfindex=="GMT-4"||cfindex=="GMT-5"||cfindex=="GMT-5:30"){b.ntpserver1.value="time-f.netgear.com";b.ntpserver2.value="time-g.netgear.com"}else{if(cfindex=="GMT-0"||cfindex=="GMT-1"||cfindex=="GMT-2"){b.ntpserver1.value="time-g.netgear.com";b.ntpserver2.value="time-h.netgear.com"}}}}}}}}if(b.adjust.checked==true){b.ntpadjust.value="1";var a=b.time_zone.selectedIndex;if((a>=2&&a<=7)||(a>=10&&a<=13)){b.hidden_ntpserver.value=b.time_zone.value+"GMT,M3.2.0/2:00,M11.1.0/2:00"}else{if(a==8){b.hidden_ntpserver.value=b.time_zone.value+"GMT,M4.1.0/2:00,M10.5.0/2:00"}else{if(a>=14&&a<=25){b.hidden_ntpserver.value=b.time_zone.value+"GMT,M3.5.0/2:00,M10.5.0/2:00"}else{if(a==37){b.hidden_ntpserver.value=b.time_zone.value+"GMT,M10.1.0/2:00,M4.1.0/2:00"}else{if((a>=39&&a<=42)&&a!=40){b.hidden_ntpserver.value=b.time_zone.value+"GMT,M10.5.0/2:00,M3.5.0/2:00"}else{b.hidden_ntpserver.value=b.time_zone.value}}}}}}else{b.ntpadjust.value="0";b.hidden_ntpserver.value=b.time_zone.value}if(old_ntpadjust==b.ntpadjust.value){b.hidden_dstflag.value="0"}else{b.hidden_dstflag.value="1"}b.hidden_select.value=b.time_zone.selectedIndex;if(select_ntp==b.hidden_select.value.toString()){b.dif_timezone.value="0"}else{b.dif_timezone.value="1"}return true};