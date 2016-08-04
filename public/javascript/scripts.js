
var globalInput = "";                   //input string will store the input typed in a keyboard up until the user presses enter
var selectedInput = "none";             //currently selected input on the assentInfo table. e.x. 'asset_type' OR 'customer'
var selectedTableAsset = "none";        //currently selected asset from the table. Will be set as the tag of the asset selected from the table. ex. 123456A
var currentAsset = {};

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
    //instead of this, load the most recent property changes from the server
    currentAsset = fakeData; //also this function could probably be completely removed and moved to the serve maybe
    
    defaultAssetRow = $("#assetTableBody").html();
    
    //updateAssetTable(fd);
    $.ajax({
        url:'/table',
        type:'GET',
        dataType:'json',
    }).done(function(data){
        updateAssetTable(data);
        $(".assetTable tr").click(function(){ 
            $("#" + selectedTableAsset).removeClass('selected');
            $(this).addClass('selected');
            selectedTableAsset = $(this).attr('id');
            processInput($(this).attr('id'));
        });
    });
    
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
    
    //IMPORTSNANT see change asset info to find the select and INPUT element chagne listener
    
    console.log("it is here");
}

function updateAssetTable(data) {
    var html = "";
    var totalHtml = "";
    
    data.forEach(function(item, index) {
        html = defaultAssetRow;
        html = html.replace(/TAG/g, item.tag);
        html = html.replace(/PARENT/g, item.parenttag);
        html = html.replace(/CUSTOMER/g, item.customer);
        html = html.replace(/RECEIVED/g, item.received);
        html = html.replace(/CUST_AG/g, item.customer_tag);
        html = html.replace(/SERIAL/g, item.serial);
        html = html.replace(/ASSET_TYPE/g, item.asset_type);
        html = html.replace(/MANUFACTURER/g, item.manufacturer);
        html = html.replace(/PRODUCT/g, item.product);
        html = html.replace(/MODEL/g, item.model);
        html = html.replace(/LOCATION/g, item.location);
        
        totalHtml += html;
    });
    
    $("#assetTableBody").html(totalHtml);
}

function showAssetInfo(asset) {
    $("#noAssetMessage").hide();
    console.log('here woah');
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
        $("#" + $(this).attr('id').substring($(this).attr('id').indexOf('_') + 1)).val($(this).val());
    });
    
    $("input").keypress(function(e){
        if(e.key == "Enter") {
            if(processInput(globalInput)) {
                $(this).val($(this).val().replace(globalInput, ""));
            }
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
       console.log("send info to the server");
    });
    
    currentAsset = asset;
}

function clearAssetInfo() {
    $('input').val('');
}

function hideAssetInfo() {
    $("#noAssetMessage").show();
    $("#assetInfo").html('');
    $("#" + selectedTableAsset).removeClass('selected');
}

function processInput(input) {
    var isCommand = false;
    
    $.ajax({
        url:'/mastercontroller',
        type:'post',
        dataType:'json',
        data:{tag : input}
    }).done(function(data){
        console.log(data);
        showAssetInfo(data);
    });
    
    return isCommand;
}

var fakeData = {};
fakeData.tag = "QQ123Q";
fakeData.parent_tag = "abc123";
fakeData.customer = "BillyBob";
fakeData.received = "04/09/2014";
fakeData.customer_tag = "112342";
fakeData.serial = "123456";
fakeData.asset_type = "Phone";
fakeData.manufacturer = "Banana Corps";
fakeData.product = "Banana Phone";
fakeData.model = "Yellow Mode 3.1.2";
fakeData.location = "Ceiling";
fakeData.price = 100.1;