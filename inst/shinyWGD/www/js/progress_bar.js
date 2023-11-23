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
        progressText.text(programType + " complete").css("color", "#fff");
    }
});


Shiny.addCustomMessageHandler("Progress_Bar_Update", showPopup);
function showPopup(message) {
    var modal = $("<div>")
        .addClass("modal")
        .appendTo("body");

    modal.css("position", "fixed")
        .css("z-index", "1")
        .css("left", "0")
        .css("top", "0")
        .css("width", "100%")
        .css("height", "100%")
        .css("background-color", "rgba(0, 0, 0, 0.7)")
        .css("text-align", "center");

    var modalContent = $("<div>")
        .addClass("modal-content")
        .appendTo(modal);

    modalContent.css("position", "absolute")
        .css("top", "50%")
        .css("left", "50%")
        .css("transform", "translate(-50%, -50%)")
        .css("padding", "20px");

    modalContent.append(createProgressBar());

    modal.css("display", "block");

    setTimeout(function () {
        modal.css("display", "none");
    }, 5000000);
}
