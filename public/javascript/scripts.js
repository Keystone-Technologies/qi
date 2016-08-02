
var globalInput = "";                   //input string will store the input typed in a keyboard up until the user presses enter
var selectedInput = "none";             //currently selected input on the assentInfo table. e.x. 'asset_type' OR 'customer'
var selectedTableAsset = "none";        //currently selected asset from the table. Will be set as the tag of the asset selected from the table. ex. 123456A
var currentAsset = {};

const MACRO_LETTERS = "ABYZ";            //Contains all of the recognized macro letter endings 
const MACRO_LOAD_ASSET_LETTERS = "ABZ";  //Contains macro letters that will load an asset or create a new one if it is not in the db
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
            if($(".signInBadge").val() == "123456Y") {
                $(".backgroundCover").hide();
                $(".signInContainer").hide();
                initialize();
                
                //instead of setting to the badge here, set it to the username received from the server
                $("#user").html($(".signInBadge").val());
            }
            $(".signInBadge").val('');
        }
    });
    
    $("body").keypress(function(e){
        if(selectedInput == "none") {
            if(e.key == "Enter") {
                processInput(globalInput);
                globalInput = "";
            }
            else {
                globalInput += e.key;
            }
        }
    });
});

function initialize() {
    //load the data from the server here josh
    var fd = [];
    for(var i = 0; i < 30; i ++) {
        fd[i] = fakeData;
    }
    
    //instead of this, load the most recent property changes from the server
    currentAsset = getDefaultAssetProperties(); //also this function could probably be completely removed and moved to the serve maybe
    
    defaultAssetRow = $("#assetTableBody").html();
    
    updateAssetTable(fd);
    
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
    
    $(".assetTable tr").click(function(){ 
        $("#" + selectedTableAsset).removeClass('selected');
        $(this).addClass('selected');
        selectedTableAsset = $(this).attr('id');
        
        console.log("Get server info for this tag then pass it in here");
        showAssetInfo(fakeData);
    });
}

function updateAssetTable(data) {
    var html = "";
    var totalHtml = "";
    
    data.forEach(function(item, index) {
        html = defaultAssetRow;
        html = html.replace(/TAG/g, item.tag + index);
        html = html.replace(/PARENT/g, item.parent_tag);
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
    var endChar = input.charAt(input.length - 1);
    if(input.length == 7) {
        if(MACRO_LETTERS.indexOf(endChar) != -1) {
            isCommand = true;
            if(MACRO_LOAD_ASSET_LETTERS.indexOf(endChar) != -1) {
                //these things should only be happening when you are 100% certain they want to create a new asset
                var asset = $.extend(true, {}, currentAsset);
                 for (var property in asset) {
                    if (asset.hasOwnProperty(property)) {
                        asset[property] = "";
                    }
                 }
                
                asset.tag = input;
                asset.customer = currentAsset.customer;
                asset.asset_type = currentAsset.asset_type;
                asset.received = currentAsset.received;
                showAssetInfo(asset);
            }
            else {
                console.log("Do a macro thing");
                console.log("As of right now this macro parse will still run everytime the user signs in, we don't want that. Figure out a way to stop that josh")
            }
        }
        else {
            console.log(endChar + " is not a recognized macro ending");
        }
    }
    return isCommand;
}

//returns the default properties of a new asset
function getDefaultAssetProperties(assetType, sell) {
    var asset = {};
    var today = new Date();
    //declare these first because they appear in the order they are declared
    // probably get it from the server each time, OR just once or something
    // maybe store a global constant object with these?
    asset.tag = "";
    asset.customer = "";
    asset.parent_tag = "";
    asset.received = today.toISOString().substring(0, today.toISOString().indexOf('T'));
    asset.customer_tag = "";
    asset.serial = "";
    asset.asset_type = "";
    asset.manufacturer = "";
    asset.product = "";
    asset.model = "";
    asset.location = "";
    
    //probably do a get request from the server to get the latest info, but for now this is fine
    switch(assetType) {
        case "banana-phone" : 
            asset.color = "yellow"; //this is where you would give the object its special properties, like ram or something, and do it by a get request probably idk DUDDE
            break;
    }
    
    if(sell) {
        asset.sold_date = today.toISOString().substring(0, today.toISOString().indexOf('T'));;
        asset.sold_via = "";
        asset.price = 0.00;
    }
    
    return asset;
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