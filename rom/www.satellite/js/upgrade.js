(function(a){a(function(){var h,g,k=0;if(typeof(h)!=undefined){clearTimeout(h)}if(typeof(g)!=undefined){clearTimeout(g)}a.check_online=function(){a.getData("auto_get_status.htm",function(i){if(i.wan_status=="1"){if(i.status==9999){if(i.new_language!=""){a("#cur_language").html(current_language);a("#new_language").html(i.new_language.substring(1));a(".newLang").show();a("input[type=hidden]:first","#onlineUpgradeForm").val("download_language");k=1}if(i.new_version!=""){a("#cur_version").html(current_version);a("#new_version").html(i.new_version.substring(1));new_version=i.new_version.substring(1);a(".newFw").show();a("input[type=hidden]:first","#onlineUpgradeForm").val("download_image");k=0}a(".fwCheckingResult").show();a(".Checking").hide();a(".firmwareUpdateOptions").hide()}else{if(i.status>=10000){a(".Checking").hide();a(".firmwareUpdateOptions").hide();a("#pageMsg").html("<div style='text-align: center;'>"+i.msg+"</div>");a("#fwUpdateMsg").show()}else{clearTimeout(h);h=setTimeout("$$.check_online();",2*1000)}}}else{a(".Checking").hide();a(".firmwareUpdateOptions").hide();a("#pageMsg").html("<p class='red'>"+auto_upg_nowan_head+"</p>"+i.msg);a("#fwUpdateMsg").show()}})};a.get_upgrade_status=function(){if(fw_region.toUpperCase()=="WW"||fw_region==""||fw_region.toUpperCase()=="GR"||fw_region.toUpperCase()=="JP"){a.REBOOT_TIME=300}if(typeof(model_name)!="undefined"&&model_name=="RBS50Y"){a.REBOOT_TIME=210}a.ajax({url:"satellite_upg_get_status.htm"+a.ID_2,type:"GET",dataType:"json",contentType:"application/json; charset=utf-8",timeout:10000,success:function(i){if(a.reset_login(i)){return false}if(i.upgrade_status=="1100"){a.processing(0,a.REBOOT_TIME)}else{setTimeout("$$.get_upgrade_status();",3000)}},failed:function(){setTimeout("$$.processing( 0, "+a.REBOOT_TIME+");",5000)},error:function(){setTimeout("$$.processing( 0, "+a.REBOOT_TIME+");",5000)}})};if(a.getUrlParam("check")=="1"){a.getData("auto_get_status.htm",function(i){if(i.wan_status=="1"){if(i.status==9999){if(i.new_version!=""){a("#cur_version").html(current_version);a("#new_version").html(i.new_version.substring(1));a(".newFw").show()}if(i.new_language!=""){a("#cur_language").html(current_language);a("#new_language").html(i.new_language.substring(1));a(".newLang").show()}a(".fwCheckingResult").show();a(".Checking").hide();a(".firmwareUpdateOptions").hide()}else{if(i.status>=10000){a(".Checking").hide();a(".firmwareUpdateOptions").hide();a("#pageMsg").html(i.msg);a("#fwUpdateMsg").show()}}}else{a(".Checking").hide();a(".firmwareUpdateOptions").hide();a("#pageMsg").html("<p class='red'>"+auto_upg_nowan_head+"</p>"+i.msg);a("#fwUpdateMsg").show()}})}if(a("#checkFwBt").length){a("#checkFwBt").click(function(){a(".Checking").show();a(".firmwareUpdateOptions").hide();a.postForm("#upgCheckForm","",function(i){a("input[name=submit_flag]","#upgCheckForm").val("download_confile");g=setTimeout(function(){a.postForm("#upgCheckForm",a("#upgCheckForm").attr("action").replace(/admin.cgi/,"func.cgi"),function(m){a.check_online()})},6000)})})}if(a("#cancelCheckBt").length){a("#cancelCheckBt").click(function(){if(typeof(g)!="undefined"){clearTimeout(g)}a("input[name='upgrade_yes_no']").val(0);a(".Checking").hide();a(".firmwareUpdateOptions").show()})}a.download_all=function(){a.getData("download_all.htm",function(i){if(i.status==0){a(".download_per").html("100%");a(".download_per").css("width","100%");a(".doing").remove();a(".download_per").html("0%");a(".download_per").css("width","0%");a(".downloadImage").hide();a(".firmwareUpdateOptions").hide();a("#pageMsg").html(i.msg);a("#fwUpdateMsg").show()}else{if(i.percent=="100%"&&k){a(".download_per").html("100%");a(".download_per").css("width","100%");a.submit_wait("body",a.WAITING_DIV);a("input[name='submit_flag']","#downloadForm").val("reload_language");a.postForm("#downloadForm","",null);setTimeout('location.href="status.htm'+a.ID_2+'";',5*1000)}else{if(i.status==1){a(".download_per").html("100%");a(".download_per").css("width","100%");a(".doing").remove();a.submit_wait("body",a.UPGRADE_DIV);a("input[name='submit_flag']","#downloadForm").val("write_image");a.postForm("#downloadForm","",function(m){});a.get_upgrade_status()}else{a(".download_per").html(i.percent);a(".download_per").css("width",i.percent);clearTimeout(h);h=setTimeout("$$.download_all()",2*1000)}}}})};if(a("#onlineUpgradeYesBt").length){a("#onlineUpgradeYesBt").click(function(){a(".Checking").hide();a(".fwCheckingResult").hide();a(".downloadImage").show();a.postForm("#onlineUpgradeForm","",function(i){a.download_all()})})}if(a("#onlineUpgradeNoBt").length){a("#onlineUpgradeNoBt").click(function(){a(".fwCheckingResult").hide();a(".Checking").hide();a(".downloadImage").hide();a(".firmwareUpdateOptions").show();if(typeof(h)!="undefined"){clearTimeout(h)}})}if(a("#cancelDlBt").length){a("#cancelDlBt").click(function(){a("input[name='submit_flag']","#downloadForm").val("cancel_image");if(typeof(h)!="undefined"){clearTimeout(h)}a.postForm("#downloadForm","",function(i){a(".download_per").html("0%");a(".download_per").css("width","0%");a(".downloadImage").hide();a(".Checking").hide();a(".fwCheckingResult").hide();a(".firmwareUpdateOptions").show()})})}if(a("#uploadBt").length){if(warning_msg!=""){a(".firmwareUpdateOptions").hide();a("#updateFirmwareForm").hide();a("#pageMsg").html(warning_msg);a("#fwUpdateMsg").show()}a("#uploadBt").click(function(){a("#updateFirmwareForm").show();a.submit_wait(".main:first",a.PAGE_WAITING_DIV);var i=a("#updateFirmwareForm").attr("action");a("#updateFirmwareForm").attr("action",i+" timestamp="+ts+a.ID_1);a("#updateFirmwareForm").submit()})}if(a("#updateFile").length){a("#updateFile").on("change",function(){if(a.check_filesize(this,max_file_size,max_file_unit,incorrect_firmware)){a("#uploadBt").prop("disabled",false)}else{a("#uploadBt").prop("disabled",true)}var m=a(this).val();var i=m.substr(m.lastIndexOf("\\")+1);a(".fakeInputField").val(i)})}function j(){location.href="fwUpdate.htm"+a.ID_2}if(a("#okBt").length){a("#okBt").click(function(){j()})}if(a("#localUpgradeForm").length){a("#cur_version").html(current_version);a("#new_version").html(new_version);if(a("#localUpgradeYesBt").length){a("#localUpgradeYesBt").click(function(){a("#upgrade_yes_no").val("1");a.submit_wait("body",a.UPGRADE_DIV);a.postForm("#localUpgradeForm","",function(i){if(i.status=="1"){a.get_upgrade_status()}else{a(".fwCheckingResult").hide();a(".running").remove();a("#pageMsg").html(i.msg);a("#fwUpdateMsg").show()}})})}if(a("#localUpgradeNoBt").length){a("#localUpgradeNoBt").click(function(){a("#upgrade_yes_no").val("0");a.postForm("#localUpgradeForm","",function(i){j()})})}var c=0,f;var b=new_version.split(".");for(f=0;f<b.length;f++){c=parseInt(b[f])+c*1000}var d=0;var l=current_version.split(".");for(f=0;f<l.length;f++){d=parseInt(l[f])+d*1000}var e="";if((cfg_allow_upgrade=="0"&&c<"1004000000")||(parseInt(hw_revision,16)==1&&c<"2001004016")||(parseInt(hw_revision,16)==2&&c<"2002002010")){a("#localUpgradeForm").hide();a("#pageMsg").html(incorrect_firmware);a("#fwUpdateMsg").show()}else{if(d<c){a("#localUpgradeYesBt").trigger("click");a(".formButtons").hide()}else{if(d>c){e+=upg_2_old}else{e+=upg_2_same}}}if(current_region=="NA"){if(new_region.toUpperCase()=="WW"||new_region==""){e+=ww_2_na}}else{if(current_region==""||current_region.toUpperCase()=="WW"){if(new_region.toUpperCase()=="NA"){e+=na_2_ww}}}if(e!=""){e+="<br />"+upg_continue}a("#upgradeMsg").html(e)}})}(jQuery));