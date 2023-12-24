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

Shiny.addCustomMessageHandler("UpdateProgressBarDownload", function (message) {
    var containerId = message.container;
    var progressBar = $("#" + containerId).find(".progress-bar");
    var progressText = $("#" + containerId).find(".progress-text");
    var programType = message.type;

    var width = message.width;

    progressBar.css("width", width + "%");
    progressBar.attr("aria-valuenow", width);

    progressText.text(programType).css({
        "color": "#778899",
        "position": "absolute",
        "top": "15px"
    });


    if (width >= 100) {
        progressBar.removeClass("active");
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

var progressBars = {};

Shiny.addCustomMessageHandler("Circular_Progress_Bar_Start", function (message) {
    var id = message.id;
    var customPercentage = message.customPercentage || 0;
    var customText = message.customText || '';
    // Create a new circular progress bar instance if not exists
    var circle = progressBars[id];
    if (!circle) {
        circle = new ProgressBar.SemiCircle("#wgd_progress_container", {
            strokeWidth: 6,
            color: '#FFEA82',
            trailColor: '#eee',
            trailWidth: 1,
            easing: 'easeInOut',
            duration: 1400,
            svgStyle: null,
            text: {
                value: customPercentage.toFixed(0) + '%',
                alignToBottom: false
            },
            from: { color: '#FFEA82' },
            to: { color: '#ED6A5A' },
            // Set default step function for all animate calls
            step: function (state, bar) {
                bar.path.setAttribute('stroke', state.color);
                bar.setText((bar.value() * 100).toFixed(0) + '%');
                bar.text.style.color = state.color;

                bar.text.style.fontFamily = '"Raleway", Helvetica, sans-serif';
                bar.text.style.fontSize = '1.5rem';
            }
        });

        progressBars[id] = circle;
    }

    circle.set(customPercentage / 100);

    $('#wgd_progress_text').html(customText);
    console.log("customText", customText)
});


Shiny.addCustomMessageHandler("Circular_Progress_Bar_Complete", function (message) {
    var id = message.id;
    var circle = progressBars[id];
    if (circle) {
        circle.animate(1);
        setTimeout(function () {
            circle.set(0);
        }, 2000);
    }
});
