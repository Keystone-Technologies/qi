
var globalInput = "";                   //input string will store the input typed in a keyboard up until the user presses enter
var selectedInput = "none";             //currently selected input on the assentInfo table. e.x. 'asset_type' OR 'customer'
var selectedTableAsset = "none";        //currently selected asset from the table. Will be set as the tag of the asset selected from the table. ex. 123456A
var assetOpen = false;                  //set to true if the user is viewing assent information
var SPECIAL_INPUTS = {};

//variables that will hold HTML for different elements in the 
var defaultAssetRow = "";
var assetInfoNoChange = "";
var assetInfoText = "";
var assetInfoDate = "";
var assetInfoNumber = "";
var assetInfoSelect = "";

$(document).ready(function() {
    $(".signInBadge").focus();
    
    $(".signInBadge").keypress(function(e){
        if(e.key == "Enter") {
            $.ajax({
                url : '/mastercontroller/',
                type : 'POST',
                dataType : 'json',
                data : {tag : $(".signInBadge").val()}
            }).done(function(data){
                if(data.name != undefined) {
                    console.log(data.name + " has signed in WOOO");
                    $("#user").html(data.name);
                    $(".backgroundCover").hide();
                    $(".signInContainer").hide();
                    initialize();
                }
                else {
                    console.log("Wow that badge was not found..?");
                }
            });
            $(".signInBadge").val('');
        }
    });
    
    //if the user has a session stored
    if(user != "") {
        $("#user").html(user);
        $(".backgroundCover").hide();
        $(".signInContainer").hide();
        initialize();
    }
    
    $("body").keypress(function(e){
        if(selectedInput == "none") {
            if(e.key == "Enter") {
                processInput(globalInput);
                globalInput = "";
            }
            else {
                globalInput += e.key;
            }
            $("#globalInput").html(globalInput);
        }
    });
});

function initialize() {
    defaultAssetRow = $("#assetTableBody").html();
    
    updateAssetTable();
    
    $.get('/specialinputs', function(data){SPECIAL_INPUTS = data});
    
    assetInfoNoChange = "<tr id='row_TITLE'>" + $("#nochange").html() + "</tr>";
    assetInfoText = "<tr id='row_TITLE'>" + $("#text").html() + "</tr>";
    assetInfoDate = "<tr id='row_TITLE'>" + $("#date").html() + "</tr>";
    assetInfoNumber = "<tr id='row_TITLE'>" + $("#number").html() + "</tr>";
    assetInfoSelect = "<tr id='row_TITLE'>" + $("#selection").html() + "</tr>";
    
    $("#nochange").remove();
    $("#text").remove();
    $("#date").remove();
    $("#number").remove();
    $("#selection").remove();
}

function updateAssetTable(data) {
    
    if(data == null) {
        $.ajax({
            url:'/table',
            type:'GET',
            dataType:'json',
        }).done(function(data){
            updateAssetTable(data);
        });
        return;
    }
    var html = "";
    var totalHtml = "";
    
    data.forEach(function(item, index) {
        html = defaultAssetRow;
        html = html.replace(/TAG/g, item.tag || "");
        html = html.replace(/PARENT/g, item.parenttag || "-");
        html = html.replace(/CUSTOMER/g, item.customer || "");
        html = html.replace(/RECEIVED/g, item.received || "");
        html = html.replace(/CUST_AG/g, item.customer_tag || "");
        html = html.replace(/SERIAL/g, item.serial || "");
        html = html.replace(/ASSET_TYPE/g, item.asset_type || "");
        html = html.replace(/MANUFACTURER/g, item.manufacturer || "");
        html = html.replace(/PRODUCT/g, item.product || "");
        html = html.replace(/MODEL/g, item.model || "");
        html = html.replace(/LOCATION/g, item.location || "");
        
        totalHtml += html;
    });
    
    $("#assetTableBody").html(totalHtml);
    
    $(".assetTable tr").click(function(){ 
        $("#" + selectedTableAsset).removeClass('selected');
        $(this).addClass('selected');
        selectedTableAsset = $(this).attr('id');
        processInput($(this).attr('id'));
    });
}

function showAssetInfo(asset) {
    $("#noAssetMessage").hide();
    assetOpen = true;
    var endHtml = "";
    for (var property in asset) {
        if (asset.hasOwnProperty(property)) {
            var html = ""; //the html for a single property yeuah
            
            var type = SPECIAL_INPUTS[property];
            switch(type) {
                case 'nochange' :
                    html += assetInfoNoChange;
                    break;
                case 'select':
                    html += assetInfoSelect;
                    //gets the array of the top ones
                    //  ex asset[top_customers]
                    var top = asset["top_" + property + "s"];
                    for(var i = 0; i < 4; i ++) {
                        html = html.replace("NAME_ID", top[i].name + "_" + top[i].id)
                        html = html.replace("NAME", top[i].name);
                    }
                    delete asset["top_" + property + "s"]; //deletes the property so that it is not shown on the asset table!
                    break;
                case 'date':
                    html += assetInfoDate;
                    var date = new Date(asset[property]);
                    html = html.replace(/VALUE/g, date.toISOString().substring(0, date.toISOString().indexOf('T')));
                    break;
                case 'number' :
                    html += assetInfoNumber;
                    break;
                default :
                    html += assetInfoText;
                    break;
            }
            html = html.replace(/CTITLE/g, (property.substring(0, 1).toUpperCase() + property.substring(1)).replace('_', " "));
            html = html.replace(/TITLE/g, property);
            html = html.replace(/VALUE/g, asset[property]);
            
            endHtml += html;
        }
    }
    
    $("#assetInfo").html(endHtml);
    
    //THESE LISTENERS are here because they only apply to elemtents that exist on the page already
    $("select").on('change', function() {
        //the id of this looks like 'select_customer' so to find property, split it from the underscore
        var property = $(this).attr('id').substring($(this).attr('id').indexOf('_') + 1);
        
        //the value of the select looks like VALUE_ID or Amdocks_13 or something. split it up to get the name and the id of it
        var value = $(this).val().substring(0, $(this).val().indexOf('_'));
        var id = $(this).val().substring($(this).val().indexOf('_') + 1);
        
        $("#" + property).html(value);
        updateAsset(property + "_id", id);
    });
    
    $("input").keypress(function(e){
        if(e.key == "Enter") {
            //processInput returns true if the command was an input
            var id = "#" + $(this).attr('id');
            console.log("enter was presses");
            processInput(globalInput, function(isCommand){
                if(isCommand) {
                    console.log("in calback, that was a command");
                    $(id).val($(id).val().replace(globalInput, ""));
                }
                else {
                    console.log("in callback, that was not a command, su updating the asset");
                    //what they entered was not a command, send it to the server
                    updateAsset($(id).attr('id'), $(id).val());
                }
            });
            
            globalInput = "";
        }
        else {
            globalInput += e.key;
        }
    });
    
    $("input").focus(function() {
        globalInput = "";
        selectedInput = $(this).attr('id');
        $("#row_" + $(this).attr('id')).addClass('selected');
    });
    
    $("input").focusout(function() {
       globalInput = "";
       selectedInput = "none";
       $("#row_" + $(this).attr('id')).removeClass('selected');
       updateAsset($(this).attr('id'), $(this).val());
    });
}

function clearAssetInfo() {
    $('input').val('');
}

function hideAssetInfo() {
    $("#noAssetMessage").show();
    $("#assetInfo").html('');
    $("#" + selectedTableAsset).removeClass('selected');
    assetOpen = false;
}

function processInput(input, callback) {
    var isCommand = false;
    console.log("Processing input...");
    
    $.ajax({
        url:'/mastercontroller',
        type:'post',
        dataType:'json',
        data:{tag : input, asset_open : assetOpen}
    }).done(function(data){
        if(data.not_a_command) {
            console.log("that was not a command");
        }
        else {
            console.log("that was a command");
            isCommand = true;
            if(data.refresh) {
                processInput(data.tag);
            }
            else {
                showAssetInfo(data);
            }
            updateAssetTable();
        }
        
        if(!(callback == undefined)) {
            callback(isCommand);
        }
    });
    
    return isCommand;
}

function updateAsset(property, value) {
    console.log("update with prop " + property + " and val " + value);
    
    $.ajax({
       url:'/asset',
       type:'POST',
       dataType:'json',
       data: {property : property, value : value}
    }).done(function(data){
        //if null, it didnt work
        if(data == null) {
            console.log("Unable to update asset");
        }
        else {
            console.log("all is good heh");
            updateAssetTable();
        }
    });
}