Shiny.addCustomMessageHandler("Progress_Bar_Complete", progressBarData);
function progressBarData(inputData) {
    var actionButtonId = inputData.actionbutton;
    var container = inputData.container;

    var progressBar = createProgressBar();
    var buttonWidth = $("#" + actionButtonId).outerWidth();
    progressBar.css("width", buttonWidth + "px");
    progressBar.css("margin", $("#" + actionButtonId).css("margin"));

    $("#" + container).empty().append(progressBar);
}


function createProgressBar() {
    var progressBar = $("<div>")
        .addClass("progress")
        .append(
            $("<div>")
                .addClass("progress-bar progress-bar-striped active")
                .attr("role", "progressbar")
                .attr("aria-valuenow", 0)
                .attr("aria-valuemin", 0)
                .attr("aria-valuemax", 100)
                .css("width", "0%")
                .append(
                    $("<div>")
                        .addClass("progress-text")
                )
        );
    return progressBar;
}


Shiny.addCustomMessageHandler("UpdateProgressBar", function (message) {
    var containerId = message.container;
    var progressBar = $("#" + containerId).find(".progress-bar");
    var progressText = $("#" + containerId).find(".progress-text");
    var programType = message.type;

    var width = message.width; 

    progressBar.css("width", width + "%");
    progressBar.attr("aria-valuenow", width);

    if (width >= 100) {
        progressBar.removeClass("active");
        progressText.text("Create " +  programType + " codes complete").css("color", "#fff");
    }
});
