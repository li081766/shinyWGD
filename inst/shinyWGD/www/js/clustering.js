Shiny.addCustomMessageHandler("Cluster_Synteny_Plotting", ClusterSyntenyPlotting);
function ClusterSyntenyPlotting(InputData) {
    var plotId = InputData.plot_id;
    var segmentedChrInfo = convertShinyData(InputData.segmented_chr);
    var segmentedAnchorpointsInfo = convertShinyData(InputData.segmented_anchorpoints);
    var queryChrOrder = InputData.subject_chr_order;
    var subjectChrOrder = InputData.query_chr_order;
    var querySpecies = InputData.query_sp;
    var subjectSpecies = InputData.subject_sp;
    var plotSize = InputData.size;
    var parInfo = InputData.pars;
    var treeByCol = InputData.tree_bycol;
    var treeByRow = InputData.tree_byrow;
    var rCutoff = InputData.r_cutoff;

    // console.log("rCutoff", rCutoff);
    // console.log("treeByCol", treeByCol);
    // console.log("treeByRow", treeByRow);

    // console.log("parInfo", parInfo);

    var querySpeciesTmp = querySpecies.replace(" ", "_");
    var queryChrInfo = segmentedChrInfo
        .filter(item => item.genome === querySpeciesTmp);

    queryChrInfo = queryChrInfo.map((item, index) => ({ ...item, index: index + 1 }));
    queryChrInfo = queryChrInfo.sort((a, b) => {
        const indexA = a.index;
        const indexB = b.index;

        const positionA = queryChrOrder.indexOf(indexA);
        const positionB = queryChrOrder.indexOf(indexB);

        return positionA - positionB;
    });

    var subjectSpeciesTmp = subjectSpecies.replace(" ", "_");
    var subjectChrInfo = segmentedChrInfo
        .filter(item => item.genome === subjectSpeciesTmp);

    subjectChrInfo = subjectChrInfo.map((item, index) => ({ ...item, index: index + 1 }));
    subjectChrInfo = subjectChrInfo.sort((a, b) => {
        const indexA = a.index;
        const indexB = b.index;

        const positionA = subjectChrOrder.indexOf(indexA);
        const positionB = subjectChrOrder.indexOf(indexB);

        return positionA - positionB;
    });

    const scaleRatio = plotSize / 600;
    // define plot dimension
    let topPadding = 100;
    const longestXLabelLength = d3.max(queryChrInfo, d => d.list.toString().length);
    const xAxisTitlePadding = longestXLabelLength * 6;
    // let bottomPadding = 80 + xAxisTitlePadding;
    let bottomPadding = 80;
    const longestYLabelLength = d3.max(subjectChrInfo, d => d.list.toString().length);
    const yAxisTitlePadding = longestYLabelLength * 6;
    // let leftPadding = 80 + yAxisTitlePadding;
    let leftPadding = 100;
    let rightPadding = 50;
    var tooltipDelay = 400;

    function calc_accumulate_num_renew(inputChrInfo) {
        let acc_len = 0;
        inputChrInfo.forEach((e, i) => {
            e.idx = i;
            e.accumulate_start = acc_len + 1;
            e.accumulate_end = e.accumulate_start + e.num_gene_remapped;
            acc_len = e.accumulate_end;
        });
        return inputChrInfo;
    }

    queryChrInfo = calc_accumulate_num_renew(queryChrInfo);
    subjectChrInfo = calc_accumulate_num_renew(subjectChrInfo);

    // choose the sp with larger width to make the scaler
    var queryWidth = d3.max(queryChrInfo, function (d) { return d.accumulate_end; });
    var subjectWidth = d3.max(subjectChrInfo, function (d) { return d.accumulate_end; });

    // define plot area size
    if (subjectWidth < queryWidth) {
        var xyscale = subjectWidth / queryWidth;
        var width = (plotSize + leftPadding + rightPadding) * scaleRatio;
        var height = (plotSize * xyscale + topPadding + bottomPadding) * scaleRatio;
    } else {
        var xyscale = queryWidth / subjectWidth;
        var width = (plotSize * xyscale + leftPadding + rightPadding) * scaleRatio;
        var height = (plotSize + topPadding + bottomPadding) * scaleRatio;
    }

    // prepare anchorpoints data
    segmentedAnchorpointsInfo.forEach((d) => {
        let queryChr = queryChrInfo.find(e => e.list === d.listX);
        let subjectChr = subjectChrInfo.find(e => e.list === d.listY);
        let queryAccumulateStart = queryChr.accumulate_start + d.coordX + 1;
        let subjectAccumulateStart = subjectChr.accumulate_start + d.coordY + 1;
        d.queryPos = {
            x: queryAccumulateStart
        };
        d.subjectPos = {
            x: subjectAccumulateStart
        };
    });

    // console.log("segmentedAnchorpointsInfo", segmentedAnchorpointsInfo);

    var script = document.createElement('script');
    script.src = 'https://d3js.org/d3.v3.min.js';
    document.head.appendChild(script);
    script.onload = function () {

        var xScaler = d3.scale.linear()
            .domain([queryChrInfo[0].accumulate_start, queryChrInfo[queryChrInfo.length - 1].accumulate_end])
            .range([leftPadding, width - rightPadding]);

        var yScaler = d3.scale.linear()
            .domain([subjectChrInfo[0].accumulate_start, subjectChrInfo[subjectChrInfo.length - 1].accumulate_end])
            .range([height - bottomPadding, topPadding]);

        const xAxis = d3.svg.axis()
            .scale(xScaler)
            .orient("bottom")
            .tickValues(queryChrInfo.map(function (e) { return e.accumulate_end; }).slice(0, -1));

        const yAxis = d3.svg.axis()
            .scale(yScaler)
            .orient("left")
            .tickValues(subjectChrInfo.map(function (e) { return e.accumulate_end; }).slice(0, -1));


        // remove old svgs
        d3.select("#" + plotId)
            .select("svg").remove();
        const svg = d3.select("#" + plotId)
            .append("svg")
            .attr("width", width)
            .attr("height", height);
        // .style("display", "none");

        // add x axis
        svg.append("g")
            .attr("class", "axis axis--x")
            .attr("transform", "translate(0," + (height - bottomPadding) + ")")
            .call(xAxis)
            .attr("stroke-width", 0.26)
            .selectAll(".tick text")
            .remove();

        svg.select(".axis--x .domain").remove();

        svg.append("g")
            .attr("class", "axis axis--X")
            // .attr("transform", "translate(0," + (height - bottomPadding) + ")")
            .append("line")
            .attr("x1", leftPadding)
            .attr("y1", height - bottomPadding)
            .attr("x2", leftPadding)
            .attr("y2", topPadding)
            .attr("stroke-width", 1.26)
            .attr("stroke-opacity", 0.31)
            .attr("stroke", "black");

        svg.selectAll(".axis--x .tick")
            .each(function () {
                const tick = d3.select(this);
                const x1 = tick.attr("transform").match(/(\d+(\.\d+)?)/g)[0];
                const y1 = height - bottomPadding;
                const x2 = x1;
                const y2 = topPadding;

                svg.append("line")
                    .attr("x1", x1)
                    .attr("y1", y1)
                    .attr("x2", x2)
                    .attr("y2", y2)
                    .attr("stroke-dasharray", "4 2")
                    .attr("stroke-width", 0.26)
                    .attr("stroke-opacity", 0.3)
                    .attr("stroke", "blue");
            });

        // add y axis;
        svg.append("g")
            .attr("class", "axis axis--y")
            .attr("transform", "translate(" + leftPadding + ", 0)")
            .call(yAxis)
            .attr("stroke-width", 0.26)
            .selectAll(".tick text")
            .remove();

        svg.select(".axis--y .domain").remove();

        svg.append("g")
            .attr("class", "axis axis--Y")
            // .attr("transform", "translate(" + leftPadding + ", 0)")
            .append("line")
            .attr("x1", leftPadding)
            .attr("y1", height - bottomPadding)
            .attr("x2", width - rightPadding)
            .attr("y2", height - bottomPadding)
            .attr("stroke-width", 1.26)
            .attr("stroke-opacity", 0.31)
            .attr("stroke", "black");

        svg.selectAll(".axis--y .tick")
            .each(function (d, i) {
                const tick = d3.select(this);
                const y = parseFloat(tick.attr("transform").match(/(\d+(\.\d+)?)/g)[1]);

                svg.append("line")
                    .attr("x1", leftPadding)
                    .attr("y1", y)
                    .attr("x2", width - rightPadding)
                    .attr("y2", y)
                    .attr("stroke-dasharray", "4 2")
                    .attr("stroke-opacity", 0.3)
                    .attr("stroke", "blue")
                    .attr("stroke-width", 0.26);
            });

        // add top and right border
        svg.append("g")
            .append("line")
            .attr("transform", `translate(${ leftPadding }, ${ topPadding })`)
            .attr("x2", function () {
                return width - leftPadding - rightPadding;
            })
            .attr("stroke", "black")
            .attr("stroke-width", 1.26)
            .attr("stroke-opacity", 0.31);

        svg.append("g")
            .append("line")
            .attr("transform", function () {
                return `translate(${ width - rightPadding }, ${ topPadding })`;
            })
            .attr("y2", function () {
                return height - topPadding - bottomPadding
            })
            .attr("stroke", "black")
            .attr("stroke-width", 1.26)
            .attr("stroke-opacity", 0.31);

        // add text labels on axises
        /* svg.append("g")
            .attr("class", "xLabel")
            .selectAll("text")
            .data(queryChrInfo)
            .enter().append("text")
            .attr("x", function (d) {
                return xScaler(d3.mean([d.accumulate_start, d.accumulate_end]));
            })
            .attr("y", function () {
                return height - bottomPadding + 15;
            })
            .attr("font-size", function () {
                return 8 * scaleRatio + "px";
            })
            .text(function (d) {
                return d.list;
            })
            .attr("id", function (d) {
                var chrName = d.list.replace(":", "_");
                chrName = chrName.replace("-", "_");
                return "xLabel_" + chrName;
            })
            .attr("text-anchor", "left")
            .attr("data-tippy-content", function (d) {
                return "<font color='#68AC57'>" + d.list +
                    "</font><br>num_gene_remapped: <font color='#68AC57'><b>" +
                    d.num_gene_remapped + "</b></font>";
            })
            .attr("transform", function (d) {
                return "rotate(90 " + xScaler(d3.mean([d.accumulate_start, d.accumulate_end])) + "," +
                    (height - bottomPadding + 15) + ")";
            }); */

        /* svg.append("g")
            .attr("class", "yLabel")
            .attr("transform", "translate(" + leftPadding + "," + topPadding + ")")
            .selectAll("g")
            .data(subjectChrInfo)
            .enter().append("g")
            .attr("transform", function (d) {
                return "translate(-15," + (yScaler(d3.mean([d.accumulate_start, d.accumulate_end])) - topPadding) + ")";
            })
            .append("text")
            .attr("font-size", function () {
                return 8 * scaleRatio + "px";
            })
            .text(function (d) {
                return d.list;
            })
            .attr("id", function (d) {
                return d.list;
            })
            .attr("text-anchor", "end")
            .attr("data-tippy-content", function (d) {
                return "<font color='#8E549E'>" + d.list +
                    "</font><br>num_gene_remapped: <font color='#8E549E'><b>" +
                    d.num_gene_remapped + "</b></font>";
            }); */

        // Add title for x and y
        svg.append("g")
            .attr("class", "xTitle")
            .append("text")
            .attr("x", function () {
                return d3.mean([leftPadding * scaleRatio, width])
            })
            .attr("y", height - 60)
            .attr("text-anchor", "middle")
            .attr("font-size", function () {
                return 13 * scaleRatio + "px";
            })
            .attr("font-weight", "bold")
            .attr("font-style", "italic")
            // .attr("font-family", "times")
            .text(querySpecies)
            .style("fill", "#68AC57");

        svg.append("g")
            .attr("class", "yTitle")
            .append("text")
            .attr("y", function () {
                return d3.mean([topPadding * scaleRatio, height - bottomPadding * scaleRatio])
            })
            .attr("x", leftPadding - 83)
            .attr("text-anchor", "middle")
            .attr("font-size", function () {
                return 13 * scaleRatio + "px";
            })
            .attr("font-weight", "bold")
            .attr("font-style", "italic")
            // .attr("font-family", "times")
            .attr("transform", function () {
                return `rotate(-90, ${ d3.select(this).attr("x") }, ${ d3.select(this).attr("y") })`;
            })
            .text(subjectSpecies)
            .style("fill", "#8E549E");

        svg.append('g')
            .attr("class", "anchorpoints")
            .selectAll("circle")
            .data(segmentedAnchorpointsInfo)
            .enter().append("circle")
            .attr("cx", function (d) {
                return xScaler(d.queryPos.x);
            })
            .attr("cy", function (d) {
                return yScaler(d.subjectPos.x);
            })
            .attr("r", 0.87 * scaleRatio)
            .attr("id", function (d) {
                return "multiplicon_" + d.multiplicon;
            })
            .attr("fill", function (d) {
                if (d.Ks > -1) {
                    return colorScale(d.Ks);
                } else {
                    return "#898989";
                }
            });

        // Define the gradient for the color scale
        var defs = svg.append("defs");
        var gradient = defs.append("linearGradient")
            .attr("id", "color-scale")
            .attr("x1", "0%").attr("y1", "0%")
            .attr("x2", "100%").attr("y2", "0%");

        gradient.append("stop")
            .attr("offset", "0%")
            .attr("stop-color", colorScale(0));
        gradient.append("stop")
            .attr("offset", "20%")
            .attr("stop-color", colorScale(1));
        gradient.append("stop")
            .attr("offset", "40%")
            .attr("stop-color", colorScale(2));
        gradient.append("stop")
            .attr("offset", "60%")
            .attr("stop-color", colorScale(3));
        gradient.append("stop")
            .attr("offset", "100%")
            .attr("stop-color", colorScale(4));

        // var legendGroup = svg.append("g")
        //     .attr("class", "legend")
        //     .attr("transform", "translate(" + (5 * scaleRatio) + "," + (10 * scaleRatio) + ")");

        var legendGroup = svg.append("g")
            .attr("class", "legend")
            .attr("transform", "translate(" + (5 * scaleRatio) + "," + (height - 70 * scaleRatio) + ")");

        legendGroup.append("rect")
            .attr("x", width - 200 * scaleRatio)
            .attr("y", 10 * scaleRatio)
            .attr("width", 150 * scaleRatio)
            .attr("height", 15 * scaleRatio)
            .attr("fill", "url(#color-scale)")
            .attr("fill-opacity", 0.7);

        // Calculate the width for the scaler group
        var scalerWidth = width - 50 * scaleRatio;

        var axisScale = d3.scale.linear()
            .domain([0, 5])
            .range([width - 200 * scaleRatio, scalerWidth]);

        var axis = d3.svg.axis()
            .scale(axisScale)
            .orient("bottom")
            .ticks(5);

        var axisGroup = legendGroup.append("g")
            .attr("class", "axis--scaler")
            .attr("transform", "translate(" + 0 + "," + (30 * scaleRatio) + ")")
            .call(axis)
            .attr("text-anchor", "middle")
            .attr("dominant-baseline", "hanging")
            .attr("font-size", (11 * scaleRatio) + "px");

        svg.select(".axis--scaler .domain").remove();

        axisGroup.append("g")
            .attr("class", "axis--scaler")
            .append("line")
            .attr("x1", (scalerWidth - 200 * scaleRatio) + 50 * scaleRatio)
            .attr("y1", 0)
            .attr("x2", scalerWidth)
            .attr("y2", 0)
            .attr("stroke-width", (1.26 * scaleRatio))
            .attr("stroke-opacity", 0.31)
            .attr("stroke", "black");

        axisGroup.selectAll(".tick line")
            .attr("stroke-width", (1.26 * scaleRatio))
            .attr("stroke-opacity", 0.31)
            .attr("stroke", "black");

        legendGroup.append("text")
            .attr("x", scalerWidth - 73 * scaleRatio)
            .attr("y", 65 * scaleRatio)
            .append("tspan")
            .style("font-style", "italic")
            .html("K")
            .style("font-size", (13 * scaleRatio) + "px")
            .append("tspan")
            .text("s")
            .style("font-size", (12 * scaleRatio) + "px")
            .attr("dx", (1 * scaleRatio) + "px")
            .attr("dy", (2 * scaleRatio) + "px");

        //tippy(".multipliscons path", {trigger: "mouseenter", followCursor: "initial",  delay: [tooltipDelay, null]});
        tippy(".xLabel text", { trigger: "mouseenter", followCursor: "initial", allowHTML: true, delay: [tooltipDelay, null] });
        tippy(".yLabel text", { trigger: "mouseenter", followCursor: "initial", allowHTML: true, delay: [tooltipDelay, null] });
        tippy(".multiplicons line", { trigger: "mouseenter", followCursor: "initial", allowHTML: true, delay: [tooltipDelay, null] });

        // Add PARs borders
        if (typeof parInfo !== undefined) {

            for (var i = 0; i < Object.keys(parInfo).length; i++) {
                if (i === 0) {
                    var listKey = "list";
                    var parIdKey = "par_id";
                } else {
                    var listKey = "list." + i;
                    var parIdKey = "par_id." + i;
                }

                if (parInfo.hasOwnProperty(listKey) && parInfo.hasOwnProperty(parIdKey)) {
                    var listArray = parInfo[listKey];
                    var parIdArray = parInfo[parIdKey];

                    var filteredParSubjectInfo = subjectChrInfo.filter(function (item) {
                        return listArray.includes(item.list);
                    });
                    var minParSubjectAccumulateStart = filteredParSubjectInfo.reduce(function (min, item) {
                        return Math.min(min, item.accumulate_start);
                    }, Infinity);
                    var maxParSubjectAccumulateEnd = filteredParSubjectInfo.reduce(function (max, item) {
                        return Math.max(max, item.accumulate_end);
                    }, -Infinity);

                    var maxY = yScaler(minParSubjectAccumulateStart);
                    var minY = yScaler(maxParSubjectAccumulateEnd);

                    var filteredParQueryInfo = queryChrInfo.filter(function (item) {
                        return listArray.includes(item.list);
                    });
                    var minParQueryAccumulateStart = filteredParQueryInfo.reduce(function (min, item) {
                        return Math.min(min, item.accumulate_start);
                    }, Infinity);
                    var maxParQueryAccumulateEnd = filteredParQueryInfo.reduce(function (max, item) {
                        return Math.max(max, item.accumulate_end);
                    }, -Infinity);

                    var minX = xScaler(minParQueryAccumulateStart);
                    var maxX = xScaler(maxParQueryAccumulateEnd);

                    svg.append("rect")
                        .attr("class", "ParRectangle")
                        .attr("x", minX)
                        .attr("y", minY)
                        .attr("width", maxX - minX)
                        .attr("height", maxY - minY)
                        .attr("fill", "#EAB904")
                        .attr("fill-opacity", 0.1)
                        .attr("stroke", "#EAB904")
                        .attr("stroke-width", 0.36)
                        .attr("stroke-opacity", 0.5)
                        .attr("stroke-dasharray", "5, 5");
                    // .lower();

                    svg.append("text")
                        .attr("class", "ParRectangle")
                        .attr("x", (minX + maxX) / 2)
                        .attr("y", minY - 12)
                        .attr("text-anchor", "middle")
                        .attr("alignment-baseline", "hanging")
                        .attr("font-size", function () {
                            return 8 * scaleRatio + "px";
                        })
                        .attr("font-weight", "bold")
                        //// .attr("font-family", "times")
                        .style("fill", "#04AFEA")
                        .text(parIdArray[0].replace("PAR ", "P"));
                }
            }
        }

        // Add the clustering tree
        var colTreeJson = parseTree(treeByCol);
        var maxColLen = findMaxLength(colTreeJson);
        standardizeLengths(colTreeJson, maxColLen);

        var treeColJsonCopy = JSON.parse(JSON.stringify(colTreeJson));
        var colTreeWidth = width - rightPadding - leftPadding;
        buildColTree(svg, treeColJsonCopy, queryChrInfo, xScaler, colTreeWidth, 70, leftPadding, scaleRatio, rCutoff);

        var rowTreeJson = parseTree(treeByRow);
        var maxRowLen = findMaxLength(rowTreeJson);
        standardizeLengths(rowTreeJson, maxRowLen);
        var treeRowJsonCopy = JSON.parse(JSON.stringify(rowTreeJson));
        var rowTreeHeight = height - bottomPadding - topPadding;
        buildRowTree(svg, treeRowJsonCopy, subjectChrInfo, yScaler, 70, rowTreeHeight, topPadding, scaleRatio, rCutoff);


        // buildTestTree("#dendrogramTreeView", treeColJsonCopy, 900, 500)
        // BuildHclustTree("#dendrogramTreeView", colHclust, 300, 400)
        /* var script = document.createElement('script');
        script.src = 'https://d3js.org/d3.v3.min.js';
        document.head.appendChild(script);
        script.onload = function () {
            // dendrogram Tree
            var svgTree = d3.select("#dendrogramTreeView")
                .append("svg")
                .attr("width", 300)
                .attr("height", 400);
            var g = svgTree
                .append("g")
                .attr("transform", "translate(" + 50 + "," + 50 + ")");
            var treeJson = JSON.parse(JSON.stringify(colHclust.json));
    
            BuildHeightTree("#dendrogramTreeView", treeJson, svgTree, 300, 400);
        } */
    }

    downloadSVG("cluster_download",
        plotId,
        querySpecies + "_vs_" + subjectSpecies + ".cluster.svg");
}

Shiny.addCustomMessageHandler("Cluster_Zoom_In_Plotting", ClusterZoomInPlotting);
function ClusterZoomInPlotting(InputData) {
    var plotId = InputData.plot_id;
    var parId = InputData.par_id;
    var segmentedChrInfo = convertShinyData(InputData.segmented_chr);
    var segmentedAnchorpointsInfo = convertShinyData(InputData.segmented_anchorpoints);
    var queryChrLabels = InputData.subject_chr_labels
    var subjectChrLabels = InputData.query_chr_labels;
    var querySpecies = InputData.query_sp;
    var subjectSpecies = InputData.subject_sp;
    var plotSize = InputData.size;

    /* console.log("plotId", plotId);
    console.log("parId", parId);
    console.log("segmentedChrInfo", segmentedChrInfo);
    console.log("segmentedAnchorpointsInfo", segmentedAnchorpointsInfo);
    console.log("queryChrLabels", queryChrLabels);
    console.log("subjectChrLabels", subjectChrLabels);
    console.log("querySpecies", querySpecies);
    console.log("subjectSpecies", subjectSpecies); */

    var querySpeciesTmp = querySpecies.replace(" ", "_");
    var queryChrInfo = segmentedChrInfo
        .filter(item => item.genome === querySpeciesTmp);

    function customSortQuery(a, b) {
        const indexA = queryChrLabels.indexOf(a.list);
        const indexB = queryChrLabels.indexOf(b.list);

        return indexA - indexB;
    }

    queryChrInfo.sort(customSortQuery);

    var subjectSpeciesTmp = subjectSpecies.replace(" ", "_");
    var subjectChrInfo = segmentedChrInfo
        .filter(item => item.genome === subjectSpeciesTmp);

    function customSortSubject(a, b) {
        const indexA = subjectChrLabels.indexOf(a.list);
        const indexB = subjectChrLabels.indexOf(b.list);

        return indexA - indexB;
    }
    subjectChrInfo.sort(customSortSubject);

    const scaleRatio = plotSize / 400;
    // define plot dimension
    let topPadding = 100;
    const longestXLabelLength = d3.max(queryChrInfo, d => d.list.toString().length);
    const xAxisTitlePadding = longestXLabelLength * 6;
    let bottomPadding = 80 + xAxisTitlePadding;
    const longestYLabelLength = d3.max(subjectChrInfo, d => d.list.toString().length);
    const yAxisTitlePadding = longestYLabelLength * 6;
    let leftPadding = 180 + yAxisTitlePadding;
    let rightPadding = 100;
    var tooltipDelay = 400;

    function calc_accumulate_num_renew(inputChrInfo) {
        let acc_len = 0;
        inputChrInfo.forEach((e, i) => {
            e.idx = i;
            e.accumulate_start = acc_len + 1;
            e.accumulate_end = e.accumulate_start + e.num_gene_remapped;
            acc_len = e.accumulate_end;
        });
        return inputChrInfo;
    }

    queryChrInfo = calc_accumulate_num_renew(queryChrInfo);
    subjectChrInfo = calc_accumulate_num_renew(subjectChrInfo);

    var queryWidth = d3.max(queryChrInfo, function (d) { return d.accumulate_end; });
    var subjectWidth = d3.max(subjectChrInfo, function (d) { return d.accumulate_end; });

    if (subjectWidth < queryWidth) {
        var xyscale = subjectWidth / queryWidth;
        var width = (plotSize + leftPadding + rightPadding) * scaleRatio;
        var height = (plotSize * xyscale + topPadding + bottomPadding) * scaleRatio;
    } else {
        var xyscale = queryWidth / subjectWidth;
        var width = (plotSize * xyscale + leftPadding + rightPadding) * scaleRatio;
        var height = (plotSize + topPadding + bottomPadding) * scaleRatio;
    }

    segmentedAnchorpointsInfo.forEach((d) => {
        let queryChr = queryChrInfo.find(e => e.list === d.listX);
        let subjectChr = subjectChrInfo.find(e => e.list === d.listY);
        let queryAccumulateStart = queryChr.accumulate_start + d.coordX + 1;
        let subjectAccumulateStart = subjectChr.accumulate_start + d.coordY + 1;
        d.queryPos = {
            x: queryAccumulateStart
        };
        d.subjectPos = {
            x: subjectAccumulateStart
        };
    });

    var script = document.createElement('script');
    script.src = 'https://d3js.org/d3.v3.min.js';
    document.head.appendChild(script);
    script.onload = function () {

        var xScaler = d3.scale.linear()
            .domain([queryChrInfo[0].accumulate_start, queryChrInfo[queryChrInfo.length - 1].accumulate_end])
            .range([leftPadding, width - rightPadding]);

        var yScaler = d3.scale.linear()
            .domain([subjectChrInfo[0].accumulate_start, subjectChrInfo[subjectChrInfo.length - 1].accumulate_end])
            .range([height - bottomPadding, topPadding]);

        const xAxis = d3.svg.axis()
            .scale(xScaler)
            .orient("bottom")
            .tickValues(queryChrInfo.map(function (e) { return e.accumulate_end; }).slice(0, -1));

        const yAxis = d3.svg.axis()
            .scale(yScaler)
            .orient("left")
            .tickValues(subjectChrInfo.map(function (e) { return e.accumulate_end; }).slice(0, -1));

        d3.select("#" + plotId)
            .select("svg").remove();

        const svg = d3.select("#" + plotId)
            .append("svg")
            .attr("width", width)
            .attr("height", height);

        svg.append("g")
            .attr("class", "axis axis--x")
            .attr("transform", "translate(0," + (height - bottomPadding) + ")")
            .call(xAxis)
            .attr("stroke-width", 0.26)
            .selectAll(".tick text")
            .remove();

        svg.select(".axis--x .domain").remove();

        svg.append("g")
            .attr("class", "axis axis--X")
            // .attr("transform", "translate(0," + (height - bottomPadding) + ")")
            .append("line")
            .attr("x1", leftPadding)
            .attr("y1", height - bottomPadding)
            .attr("x2", leftPadding)
            .attr("y2", topPadding)
            .attr("stroke-width", 1.26)
            .attr("stroke-opacity", 0.31)
            .attr("stroke", "black");

        svg.selectAll(".axis--x .tick")
            .each(function () {
                const tick = d3.select(this);
                const x1 = tick.attr("transform").match(/(\d+(\.\d+)?)/g)[0];
                const y1 = height - bottomPadding;
                const x2 = x1;
                const y2 = topPadding;

                svg.append("line")
                    .attr("x1", x1)
                    .attr("y1", y1)
                    .attr("x2", x2)
                    .attr("y2", y2)
                    .attr("stroke-dasharray", "4 2")
                    .attr("stroke-width", 0.26)
                    .attr("stroke-opacity", 0.3)
                    .attr("stroke", "blue");
            });

        svg.append("g")
            .attr("class", "axis axis--y")
            .attr("transform", "translate(" + leftPadding + ", 0)")
            .call(yAxis)
            .attr("stroke-width", 0.26)
            .selectAll(".tick text")
            .remove();

        svg.select(".axis--y .domain").remove();

        svg.append("g")
            .attr("class", "axis axis--Y")
            // .attr("transform", "translate(" + leftPadding + ", 0)")
            .append("line")
            .attr("x1", leftPadding)
            .attr("y1", height - bottomPadding)
            .attr("x2", width - rightPadding)
            .attr("y2", height - bottomPadding)
            .attr("stroke-width", 1.26)
            .attr("stroke-opacity", 0.31)
            .attr("stroke", "black");

        svg.selectAll(".axis--y .tick")
            .each(function (d, i) {
                const tick = d3.select(this);
                const y = parseFloat(tick.attr("transform").match(/(\d+(\.\d+)?)/g)[1]);

                svg.append("line")
                    .attr("x1", leftPadding)
                    .attr("y1", y)
                    .attr("x2", width - rightPadding)
                    .attr("y2", y)
                    .attr("stroke-dasharray", "4 2")
                    .attr("stroke-opacity", 0.3)
                    .attr("stroke", "blue")
                    .attr("stroke-width", 0.26);
            });

        // add top and right border
        svg.append("g")
            .append("line")
            .attr("transform", `translate(${ leftPadding }, ${ topPadding })`)
            .attr("x2", function () {
                return width - leftPadding - rightPadding;
            })
            .attr("stroke", "black")
            .attr("stroke-width", 1.26)
            .attr("stroke-opacity", 0.31);

        svg.append("g")
            .append("line")
            .attr("transform", function () {
                return `translate(${ width - rightPadding }, ${ topPadding })`;
            })
            .attr("y2", function () {
                return height - topPadding - bottomPadding
            })
            .attr("stroke", "black")
            .attr("stroke-width", 1.26)
            .attr("stroke-opacity", 0.31);

        svg.append("g")
            .attr("class", "xLabel")
            .selectAll("text")
            .data(queryChrInfo)
            .enter().append("text")
            .attr("x", function (d) {
                return xScaler(d3.mean([d.accumulate_start, d.accumulate_end]));
            })
            .attr("y", function () {
                return height - bottomPadding + 15;
            })
            .attr("font-size", function () {
                return 10 * scaleRatio + "px";
            })
            .text(function (d) {
                return d.list;
            })
            .attr("id", function (d) {
                var chrName = d.list.replace(":", "_");
                chrName = chrName.replace("-", "_");
                return "xLabel_" + chrName;
            })
            .attr("text-anchor", "left")
            .attr("data-tippy-content", function (d) {
                return "<font color='#68AC57'>" + d.list +
                    "</font><br>num_gene_remapped: <font color='#68AC57'><b>" +
                    d.num_gene_remapped + "</b></font>";
            })
            .attr("transform", function (d) {
                return "rotate(90 " + xScaler(d3.mean([d.accumulate_start, d.accumulate_end])) + "," +
                    (height - bottomPadding + 15) + ")";
            });

        svg.append("g")
            .attr("class", "yLabel")
            .attr("transform", "translate(" + leftPadding + "," + topPadding + ")")
            .selectAll("g")
            .data(subjectChrInfo)
            .enter().append("g")
            .attr("transform", function (d) {
                return "translate(-15," + (yScaler(d3.mean([d.accumulate_start, d.accumulate_end])) - topPadding) + ")";
            })
            .append("text")
            .attr("font-size", function () {
                return 8 * scaleRatio + "px";
            })
            .text(function (d) {
                return d.list;
            })
            .attr("id", function (d) {
                return d.list;
            })
            .attr("text-anchor", "end")
            .attr("data-tippy-content", function (d) {
                return "<font color='#8E549E'>" + d.list +
                    "</font><br>num_gene_remapped: <font color='#8E549E'><b>" +
                    d.num_gene_remapped + "</b></font>";
            });

        svg.append("g")
            .attr("class", "xTitle")
            .append("text")
            .attr("x", function () {
                return d3.mean([leftPadding * scaleRatio, width])
            })
            .attr("y", height - 65)
            .attr("text-anchor", "middle")
            .attr("font-size", function () {
                return 13 * scaleRatio + "px";
            })
            .attr("font-weight", "bold")
            .attr("font-style", "italic")
            // .attr("font-family", "times")
            .text(querySpecies)
            .style("fill", "#68AC57");

        svg.append("g")
            .attr("class", "yTitle")
            .append("text")
            .attr("y", function () {
                return d3.mean([topPadding * scaleRatio, height - bottomPadding * scaleRatio])
            })
            .attr("x", leftPadding - 80)
            .attr("text-anchor", "middle")
            .attr("font-size", function () {
                return 13 * scaleRatio + "px";
            })
            .attr("font-weight", "bold")
            .attr("font-style", "italic")
            // .attr("font-family", "times")
            .attr("transform", function () {
                return `rotate(-90, ${ d3.select(this).attr("x") }, ${ d3.select(this).attr("y") })`;
            })
            .text(subjectSpecies)
            .style("fill", "#8E549E");

        svg.append('g')
            .attr("class", "anchorpoints")
            .selectAll("circle")
            .data(segmentedAnchorpointsInfo)
            .enter().append("circle")
            .attr("cx", function (d) {
                return xScaler(d.queryPos.x);
            })
            .attr("cy", function (d) {
                return yScaler(d.subjectPos.x);
            })
            .attr("r", 2.37 * scaleRatio)
            .attr("id", function (d) {
                return "multiplicon_" + d.multiplicon;
            })
            .attr("fill", function (d) {
                if (d.Ks > -1) {
                    return colorScale(d.Ks);
                } else {
                    return "#898989";
                }
            });

        svg.append("g")
            .append("text")
            .attr("x", function () {
                return d3.mean([leftPadding * scaleRatio, width])
            })
            .attr("y", topPadding - 25)
            .attr("text-anchor", "middle")
            .attr("alignment-baseline", "hanging")
            .attr("font-size", function () {
                return 15 * scaleRatio + "px";
            })
            .attr("font-style", "bold")
            .style("fill", "#04AFEA")
            .text(parId);

        //tippy(".multipliscons path", {trigger: "mouseenter", followCursor: "initial",  delay: [tooltipDelay, null]});
        tippy(".xLabel text", { trigger: "mouseenter", followCursor: "initial", allowHTML: true, delay: [tooltipDelay, null] });
        tippy(".yLabel text", { trigger: "mouseenter", followCursor: "initial", allowHTML: true, delay: [tooltipDelay, null] });
        tippy(".multiplicons line", { trigger: "mouseenter", followCursor: "initial", allowHTML: true, delay: [tooltipDelay, null] });

    }

    downloadSVG("PAR_download",
        plotId,
        querySpecies.replace(" ", "_") + "_vs_" + subjectSpecies.replace(" ", "_") + "." + parId.replace(" ", "_") + ".cluster.dot.svg");
}

Shiny.addCustomMessageHandler("Cluster_Zoom_In_Link_Plotting", ClusterZoomInLinkPlotting);
function ClusterZoomInLinkPlotting(InputData) {
    var plotId = InputData.plot_id;
    var parId = InputData.par_id;
    var segmentedChrInfo = convertShinyData(InputData.segmented_chr);
    var segmentedAnchorpointsInfo = convertShinyData(InputData.segmented_anchorpoints);
    var queryChrLabels = InputData.subject_chr_labels
    var subjectChrLabels = InputData.query_chr_labels;
    var querySpecies = InputData.query_sp;
    var subjectSpecies = InputData.subject_sp;
    var plotSize = InputData.size;

/*     console.log("plotId", plotId);
    console.log("parId", parId);
    console.log("segmentedChrInfo", segmentedChrInfo);
    console.log("segmentedAnchorpointsInfo", segmentedAnchorpointsInfo);
    console.log("queryChrLabels", queryChrLabels);
    console.log("subjectChrLabels", subjectChrLabels);
    console.log("querySpecies", querySpecies);
    console.log("subjectSpecies", subjectSpecies); */

    var querySpeciesTmp = querySpecies.replace(" ", "_");
    var queryChrInfo = segmentedChrInfo
        .filter(item => item.genome === querySpeciesTmp);

    function customSortQuery(a, b) {
        const indexA = queryChrLabels.indexOf(a.list);
        const indexB = queryChrLabels.indexOf(b.list);

        return indexA - indexB;
    }

    queryChrInfo.sort(customSortQuery);

    var subjectSpeciesTmp = subjectSpecies.replace(" ", "_");
    var subjectChrInfo = segmentedChrInfo
        .filter(item => item.genome === subjectSpeciesTmp);

    function customSortSubject(a, b) {
        const indexA = subjectChrLabels.indexOf(a.list);
        const indexB = subjectChrLabels.indexOf(b.list);

        return indexA - indexB;
    }
    subjectChrInfo.sort(customSortSubject);

    const scaleRatio = plotSize / 300;

    var width = 600 * scaleRatio;
    var height = 450 * scaleRatio;
    // define plot dimension
    let topPadding = 150 * scaleRatio;
    const longestXLabelLength = d3.max(queryChrInfo, d => d.list.toString().length);
    const xAxisTitlePadding = longestXLabelLength * 6;
    var bottomPadding = 80 + xAxisTitlePadding;
    var bottomPadding = 150 * scaleRatio;
    const longestYLabelLength = d3.max(subjectChrInfo, d => d.list.toString().length);
    const yAxisTitlePadding = longestYLabelLength * 6;
    let leftPadding = 150 * scaleRatio;
    let rightPadding = 100 * scaleRatio;
    var tooltipDelay = 400;

    function calc_accumulate_num_renew(inputChrInfo) {
        let acc_len = 0;
        inputChrInfo.forEach((e, i) => {
            e.idx = i;
            e.accumulate_start = acc_len + 1;
            e.accumulate_end = e.accumulate_start + e.num_gene_remapped;
            acc_len = e.accumulate_end + 20;
        });
        return inputChrInfo;
    }

    queryChrInfo = calc_accumulate_num_renew(queryChrInfo);
    subjectChrInfo = calc_accumulate_num_renew(subjectChrInfo);

    var queryWidth = d3.max(queryChrInfo, function (d) { return d.accumulate_end; });
    var subjectWidth = d3.max(subjectChrInfo, function (d) { return d.accumulate_end; });

    // console.log("queryWidth", queryWidth);
    // console.log("subjectWidth", subjectWidth);

    if (queryWidth > subjectWidth) {
        var maxLen = queryWidth;
    } else {
        var maxLen = subjectWidth;
    }

    segmentedAnchorpointsInfo.forEach((d) => {
        let queryChr = queryChrInfo.find(e => e.list === d.listX);
        let subjectChr = subjectChrInfo.find(e => e.list === d.listY);
        let queryAccumulateStart = queryChr.accumulate_start + d.coordX + 1;
        let subjectAccumulateStart = subjectChr.accumulate_start + d.coordY + 1;
        d.queryPos = {
            x: queryAccumulateStart
        };
        d.subjectPos = {
            x: subjectAccumulateStart
        };
    });

    var script = document.createElement('script');
    script.src = 'https://d3js.org/d3.v3.min.js';
    document.head.appendChild(script);
    script.onload = function () {
        const ChrScaler = d3
            .scale.linear()
            .domain([1, maxLen])
            .range([
                0,
                width - rightPadding - leftPadding
            ]);

        var middlePoint = (width - leftPadding - rightPadding) / 2;
        var queryStartX = middlePoint - ChrScaler(queryWidth) / 2 + leftPadding;
        var subjectStartX = middlePoint - ChrScaler(subjectWidth) / 2 + leftPadding;
/*         console.log("middlePoint", middlePoint);
        console.log("queryStartX", queryStartX);
        console.log("subjectStartX", subjectStartX); */

        d3.select("#" + plotId)
            .select("svg").remove();

        const svg = d3.select("#" + plotId)
            .append("svg")
            .attr("width", width)
            .attr("height", height);

        svg.append("g")
            .attr("class", "queryTitle")
            .append("text")
            .attr("x", queryStartX - 10)
            .attr("y", topPadding + 10)
            .attr("text-anchor", "end")
            .attr("font-size", function () {
                return 12 * scaleRatio + "px";
            })
            .attr("font-weight", "bold")
            .attr("font-style", "italic")
            .text(querySpecies.replace(/(\w)\w+\s(\w+)/, "$1. $2"))
            .style("fill", "#68AC57");

        // console.log("queryChrInfo", queryChrInfo);

        svg.append("g")
            .attr("class", "queryChrLabel")
            .selectAll("text")
            .data(queryChrInfo)
            .enter()
            .append("text")
            .text((d) => d.list)
            .attr("x", function (d) {
                return queryStartX + d3.mean([ChrScaler(d.accumulate_end), ChrScaler(d.accumulate_start)]);
            })
            .attr("y", topPadding - 15)
            .attr("text-anchor", "start")
            .attr("font-size", 10 * scaleRatio + "px")
            .attr("transform", function (d) {
                const x = queryStartX + d3.mean([ChrScaler(d.accumulate_end), ChrScaler(d.accumulate_start)]);
                const y = topPadding - 15;
                return "rotate(-30 " + x + " " + y + ")";
            });;

        svg.append("g")
            .attr("class", "queryRect")
            .selectAll("rect")
            .data(queryChrInfo)
            .enter()
            .append("rect")
            .attr("x", function (d) {
                return queryStartX + ChrScaler(d.accumulate_start);
            })
            .attr("y", topPadding)
            .attr(
                "width",
                (d) => ChrScaler(d.accumulate_end) - ChrScaler(d.accumulate_start)
            )
            .attr("height", 14)
            .attr("opacity", 1)
            .attr("fill", "#9D9D9D")
            // .attr("ry", 3);

        svg.append("g")
            .attr("class", "subjectTitle")
            .append("text")
            .attr("y", height - bottomPadding + 10)
            .attr("x", subjectStartX - 10)
            .attr("text-anchor", "end")
            .attr("font-size", function () {
                return 13 * scaleRatio + "px";
            })
            .attr("font-weight", "bold")
            .attr("font-style", "italic")
            .text(subjectSpecies.replace(/(\w)\w+\s(\w+)/, "$1. $2"))
            .style("fill", "#8E549E");

        svg.append("g")
            .attr("class", "subjectChrLabel")
            .selectAll("text")
            .data(subjectChrInfo)
            .enter()
            .append("text")
            .text((d) => d.list)
            .attr("x", function (d) {
                return subjectStartX + d3.mean([ChrScaler(d.accumulate_end), ChrScaler(d.accumulate_start)]);
            })
            .attr("y", height - bottomPadding + 25)
            .attr("text-anchor", "start")
            .attr("font-size", 10 * scaleRatio + "px")
            .attr("transform", function (d) {
                const x = subjectStartX + d3.mean([ChrScaler(d.accumulate_end), ChrScaler(d.accumulate_start)]);
                const y = height - bottomPadding + 25;
                return "rotate(30 " + x + " " + y + ")";
            });

        svg.append("g")
            .attr("class", "subjectRect")
            .selectAll("rect")
            .data(subjectChrInfo)
            .enter()
            .append("rect")
            .attr("x", function (d) {
                return subjectStartX + ChrScaler(d.accumulate_start);
            })
            .attr("y", height - bottomPadding - 5)
            .attr(
                "width",
                (d) => ChrScaler(d.accumulate_end) - ChrScaler(d.accumulate_start)
            )
            .attr("height", 14)
            .attr("opacity", 1)
            .attr("fill", "#BC8F8F");
            // .attr("ry", 3);

        segmentedAnchorpointsInfo.forEach((d) => {
            let queryChr = queryChrInfo.find(e => e.list === d.listX);
            let subjectChr = subjectChrInfo.find(e => e.list === d.listY);
            let queryAccumulateStart = queryChr.accumulate_start + d.coordX;
            let queryAccumulateEnd = queryChr.accumulate_start + d.coordX + 1;
            let subjectAccumulateStart = subjectChr.accumulate_start + d.coordY;
            let subjectAccumulateEnd = subjectChr.accumulate_start + d.coordY + 1;

            var queryX = queryStartX + ChrScaler(queryAccumulateStart);
            var queryX1 = queryStartX + ChrScaler(queryAccumulateEnd);

            var subjectX = subjectStartX + ChrScaler(subjectAccumulateStart);
            var subjectX1 = subjectStartX + ChrScaler(subjectAccumulateEnd);

            d.ribbonPosition = {
                source: {
                    x: queryX,
                    x1: queryX1,
                    y: topPadding + 15,
                    y1: topPadding + 15
                },
                target: {
                    x: subjectX,
                    x1: subjectX1,
                    y: height - bottomPadding - 6,
                    y1: height - bottomPadding - 6
                }
            };
        });
        // console.log("segmentedAnchorpointsInfo", segmentedAnchorpointsInfo);

        svg.append("g")
            .attr("class", "parLink")
            .selectAll("path")
            .data(segmentedAnchorpointsInfo)
            .enter()
            .append("path")
            .attr("d", function (d) {
                return createLinkPolygonPath(d.ribbonPosition);
            })
            .attr("fill", (d) => {
                if (d.Ks > -1) {
                    return colorScale(d.Ks);
                } else {
                    return "#898989";
                }
            })
            .attr("opacity", 0.6)
            .attr("stroke", (d) => {
                if (d.Ks > -1) {
                    return colorScale(d.Ks);
                } else {
                    return "#898989";
                }
            })
            .attr("stroke-width", 0.79)
            .attr("stroke-opacity", 0.4)
            .attr("data-tippy-content", d => {
                return "<b><font color='#FFE153'>Query:</font></b> " + d.firstX + " &#8594 " + d.lastX + "<br>" +
                    "<font color='red'><b>&#8595</b></font><br>" +
                    "<b><font color='#4DFFFF'>Subject:</font></b> " + d.firstY + " &#8594 " + d.lastY;
            });

        svg.append("g")
            .append("text")
            .attr("x", leftPadding - 20)
            .attr("y", height / 2 - 25)
            .attr("text-anchor", "middle")
            .attr("alignment-baseline", "hanging")
            .attr("font-size", function () {
                return 15 * scaleRatio + "px";
            })
            .attr("font-style", "bold")
            .style("fill", "#04AFEA")
            .text(parId);

        //tippy(".multipliscons path", {trigger: "mouseenter", followCursor: "initial",  delay: [tooltipDelay, null]});
        tippy(".xLabel text", { trigger: "mouseenter", followCursor: "initial", allowHTML: true, delay: [tooltipDelay, null] });
        tippy(".yLabel text", { trigger: "mouseenter", followCursor: "initial", allowHTML: true, delay: [tooltipDelay, null] });
        tippy(".parLink path", { trigger: "mouseenter", followCursor: "initial", allowHTML: true, delay: [tooltipDelay, null] });

    }

    downloadSVG("PAR_download",
        plotId,
        querySpecies.replace(" ", "_") + "_vs_" + subjectSpecies.replace(" ", "_") + "." + parId.replace(" ", "_") + ".cluster.link.svg");
}

function buildColTree(vis, treeJson, queryChrInfo, xScaler, w, h, leftPadding, scaleRatio, rCutoff) {
    /*     var vis = d3.select(selector)
            .append("svg")
            .attr("width", w + 200)
            .attr("height", h + 200); */

    var tree = d3.layout.cluster()
        .size([h, w])
        .separation(function (a, b) {
            return 1;
        })
        .children(function (node) {
            return node.branchset;
        });

    var treeNodes = tree(treeJson);

    scaleColBranchLengths(treeNodes, h).range([0, h]);

    // Create a vertical layout by swapping x and y positions
    treeNodes.forEach(function (node) {
        var tempX = node.x;
        node.x = node.y;
        node.y = tempX;
    });

    var desiredLeafPositions = {};

    queryChrInfo.forEach(function (info) {
        var listName = info.list;
        var desiredX = xScaler(d3.mean([info.accumulate_start, info.accumulate_end])) - leftPadding;
        desiredLeafPositions[listName] = desiredX;
    });

    customColTreeLayout(treeNodes[0], desiredLeafPositions);

    var colTreeGroup = vis.append("g")
        .attr("transform", "translate(" + leftPadding + "," + 28 + ")");

    colTreeGroup.selectAll("g.node")
        .data(treeNodes)
        .enter().append("svg:g")
        .attr("class", function (n) {
            if (n.children) {
                if (n.depth == 0) {
                    return "root-node";
                } else {
                    return "inner-node";
                }
            } else {
                return "leaf-node";
            }
        })
        .attr("transform", function (d) { return "translate(" + d.y + "," + d.x + ")"; });

    /*     colTreeGroup.selectAll('g.leaf-node')
            .append("text")
            .attr("class", "my-text")
            .attr("dx", 8)
            .attr("dy", 3)
            .attr("text-anchor", "start")
            .attr("font-size", "8px")
            .attr('fill', 'black')
            .attr("transform", "rotate(90)")
            .text(function (d) {
                return d.name;
            }); */


    // add the r cutoff line
    colTreeGroup.append("text")
        .attr("class", "cutoff--r2")
        .attr("x", -15)
        .attr("y", 70 * (1 - rCutoff) + 5)
        .attr("text-anchor", "end")
        .style("font-size", (12 * scaleRatio) + "px")
        .style("fill", "red")
        .style("font-opacity", 0.32)
        .text(function () {
            return "r = " + rCutoff;
        });

    colTreeGroup.append("line")
        .attr("class", "cutoff--r2")
        .attr("x1", -5)
        .attr("y1", 70 * (1 - rCutoff))
        .attr("x2", w)
        .attr("y2", 70 * (1 - rCutoff))
        .attr("stroke-width", (2.06 * scaleRatio))
        .attr("stroke-opacity", 0.32)
        .attr("stroke-dasharray", "4 3")
        .attr("stroke", "red");

    var diagonal = topAngleDiagonal();
    colTreeGroup.selectAll("path.link")
        .data(tree.links(treeNodes))
        .enter().append("svg:path")
        .attr("class", "link")
        .attr("d", diagonal)
        .attr("fill", "none")
        .attr("stroke", "#001115")
        .attr("stroke-width", function () {
            return 1.08 * scaleRatio + "px"
        });

    // Move the created paths to the bottom of the SVG
    vis.selectAll("path.link").each(function () {
        var firstChild = this.parentNode.firstChild;
        if (firstChild) {
            this.parentNode.insertBefore(this, firstChild);
        }
    });
}

function buildRowTree(vis, treeJson, subjectChrInfo, yScaler, w, h, topPadding, scaleRatio, rCutoff) {

    var tree = d3.layout.cluster()
        .size([h, w])
        .separation(function (a, b) {
            return 1;
        })
        .children(function (node) {
            return node.branchset
        });

    var treeNodes = tree(treeJson);
    scaleBranchLengths(treeNodes, w).range([0, w]);

    treeNodes.forEach(function (node) {
        node.x = w - node.x;
    });

    var desiredRowLeafPositions = {};

    subjectChrInfo.forEach(function (info) {
        var listName = info.list;
        var desiredY = yScaler(d3.mean([info.accumulate_start, info.accumulate_end])) - topPadding;
        desiredRowLeafPositions[listName] = desiredY;
    });

    customRowTreeLayout(treeNodes[0], desiredRowLeafPositions);

    var rowTreeGroup = vis.append("g")
        .attr("transform", "translate(" + 28 + "," + topPadding + ")");

    rowTreeGroup.selectAll("g.node")
        .data(treeNodes)
        .enter().append("svg:g")
        .attr("class", function (n) {
            if (n.children) {
                if (n.depth == 0) {
                    return "root-node";
                } else {
                    return "inner-node";
                }
            } else {
                return "leaf-node";
            }
        })
        .attr("transform", function (d) { return "translate(" + d.y + "," + d.x + ")"; });

    /* rowTreeGroup.selectAll('g.leaf-node')
        .append("text")
        .attr("class", "my-text")
        .attr("dx", 8)
        .attr("dy", 3)
        .attr("text-anchor", "start")
        .attr("font-size", "12px")
        .attr('fill', 'black')
        .text(function (d) {
            return d.name;
        }); */

    var diagonal = rowAngleDiagonal();

    rowTreeGroup.append("line")
        .attr("class", "cutoff--r2")
        .attr("x1", 70 * (1 - rCutoff))
        .attr("y1", -13 - 5 * rCutoff)
        .attr("x2", 70 * (1 - rCutoff))
        .attr("y2", h)
        .attr("stroke-width", (2.06 * scaleRatio))
        .attr("stroke-opacity", 0.32)
        .attr("stroke-dasharray", "4 3")
        .attr("stroke", "red");

    rowTreeGroup.selectAll("path.link")
        .data(tree.links(treeNodes))
        .enter().append("svg:path")
        .attr("class", "link")
        .attr("d", diagonal)
        .attr("fill", "none")
        .attr("stroke", "#001115")
        .attr("stroke-width", function () {
            return 1.08 * scaleRatio + "px"
        });

    // Move the created paths to the bottom of the SVG
    rowTreeGroup.selectAll("path.link").each(function () {
        var firstChild = this.parentNode.firstChild;
        if (firstChild) {
            this.parentNode.insertBefore(this, firstChild);
        }
    });
}

function parseTree(treeData) {
    /* 
    * The function to convert tree in newick format into JSON
    * Example Clustering_info.20.bycol.newick which generated by hclust and ape
    */

    var ancestors = [];
    var tree = {};
    var tokens = treeData.replace(";", "")
        .split(/\s*(;|\(|\)|,|:)\s*/)
        .map(token => token.trim())
        .filter(Boolean);
    var cid = 0;
    if (cid === 0) {
        tree.length = 1.1;
    }
    for (var i = 0; i < tokens.length; i++) {
        var token = tokens[i];
        switch (token) {
            case '(':
                var subtree = {};
                tree.size = cid;
                tree.index = -1;
                cid++;
                tree.children = [subtree];
                ancestors.push(tree);
                tree = subtree;
                break;
            case ',':
                var subtree = {};
                ancestors[ancestors.length - 1].children.push(subtree);
                tree = subtree;
                break;
            case ')':
                tree = ancestors.pop();
                break;
            case ':':
                break;
            default:
                var x = tokens[i - 1];
                if (x == ')' || x == '(' || x == ',') {
                    tree.name = token;
                    tree.size = cid;
                    tree.index = -1;
                    cid++;
                } else if (x == ':') {
                    tree.length = parseFloat(token);
                }
        }
    }

    function setLeafStatus(node) {
        if (node.children) {
            node.isLeaf = false;
            node.children.forEach(child => setLeafStatus(child));
        } else {
            node.isLeaf = true;
        }
    }

    setLeafStatus(tree);

    return tree;
}

function findMaxLength(node) {
    if (!node) return 0;

    let maxLength = 0;

    if (node.branchset && node.branchset.length > 0) {
        for (const childNode of node.branchset) {
            const childLength = findMaxLength(childNode);
            maxLength = Math.max(maxLength, childLength);
        }
    }

    if (node.length) {
        maxLength = Math.max(maxLength, node.length);
    }

    return maxLength;
}

function standardizeLengths(node, maxLength) {
    if (!node) return;

    if (node.branchset && node.branchset.length > 0) {
        for (const childNode of node.branchset) {
            standardizeLengths(childNode, maxLength);
        }
    }

    if (node.length) {
        node.length /= maxLength;
    }
}

function scaleColBranchLengths(nodes, h) {
    var visitPreOrder = function (root, callback) {
        callback(root);
        if (root.children) {
            for (var i = root.children.length - 1; i >= 0; i--) {
                visitPreOrder(root.children[i], callback);
            }
        }
    };

    visitPreOrder(nodes[0], function (node) {
        node.rootDist = (node.parent ? node.parent.rootDist : 0) + (node.length || 0);
    });

    var rootDists = nodes.map(function (n) {
        return n.rootDist;
    });

    var yscale = d3.scale.linear()
        .domain([0, d3.max(rootDists)])
        .range([0, h]);

    visitPreOrder(nodes[0], function (node) {
        node.y = parseInt(yscale(node.rootDist));
    });

    return yscale;
}

function customColTreeLayout(node, desiredLeafPositions) {
    if (!node.children) {
        var listName = node.name.replace("-", ":");
        if (desiredLeafPositions[listName] !== undefined) {
            node.y = desiredLeafPositions[listName];
        }
    } else {
        var yValues = [];

        node.children.forEach(function (child) {
            customColTreeLayout(child, desiredLeafPositions);
            yValues.push(child.y);
        });

        var minY = Math.min.apply(null, yValues);
        var maxY = Math.max.apply(null, yValues);
        node.y = (minY + maxY) / 2;
    }
}

function topAngleDiagonal() {
    var projection = function (d) {
        return [d.y, d.x];
    }
    var path = function (pathData) {
        return "M" + pathData[0] + ' ' + pathData[1] + " " + pathData[2];
    }

    function diagonal(diagonalPath, i) {
        var source = diagonalPath.source;
        var target = diagonalPath.target;
        var pathData = [source, { x: source.x, y: target.y }, target];
        pathData = pathData.map(projection);

        return path(pathData)
    }
    diagonal.projection = function (x) {
        if (!arguments.length) return projection;
        projection = x;
        return diagonal;
    };
    diagonal.path = function (x) {
        if (!arguments.length) return path;
        path = x;
        return diagonal;
    };
    return diagonal;
}

function customRowTreeLayout(node, desiredRowLeafPositions) {
    if (!node.children) {
        var listName = node.name.replace("-", ":");
        if (desiredRowLeafPositions[listName] !== undefined) {
            node.x = desiredRowLeafPositions[listName];
        }
    } else {
        var xValues = [];

        node.children.forEach(function (child) {
            customRowTreeLayout(child, desiredRowLeafPositions);
            xValues.push(child.x);
        });

        var minX = Math.min.apply(null, xValues);
        var maxX = Math.max.apply(null, xValues);
        node.x = (minX + maxX) / 2;
    }
}

function rowAngleDiagonal() {
    var projection = function (d) {
        return [d.y, d.x];
    }
    var path = function (pathData) {
        return "M" + pathData[0] + ' ' + pathData[1] + " " + pathData[2];
    }
    function diagonal(diagonalPath, i) {
        var source = diagonalPath.source;
        var target = diagonalPath.target;
        var pathData = [source, { x: target.x, y: source.y }, target];
        pathData = pathData.map(projection);
        return path(pathData);
    }
    diagonal.projection = function (x) {
        if (!arguments.length) return projection;
        projection = x;
        return diagonal;
    };
    diagonal.path = function (x) {
        if (!arguments.length) return path;
        path = x;
        return diagonal;
    };
    return diagonal;
}


// create custom band generator
// code sourced from synvisio: https://github.com/kiranbandi/synvisio/blob/master/src/components/MultiGenomeView/Links.jsx
function createLinkPolygonPath(d) {
    let curvature = 0.45;
    // code block sourced from d3-sankey https://github.com/d3/d3-sankey for drawing curved blocks
    let x = d.source.x,
        x1 = d.target.x,
        y = d.source.y,
        y1 = d.target.y,
        yi = d3.interpolateNumber(y, y1),
        y2 = yi(curvature),
        y3 = yi(1 - curvature),
        p0 = d.target.x1,
        p1 = d.source.x1,
        qi = d3.interpolateNumber(y1, y),
        q2 = qi(curvature),
        q3 = qi(1 - curvature);

    return "M" + x + "," + y + // svg start point
        "C" + x + "," + y2 + // 1st curve point 1
        " " + x1 + "," + y3 + // 1st curve point 2
        " " + x1 + "," + y1 + // 1st curve end point
        "L" + p0 + "," + y1 + // bottom line
        "C" + p0 + "," + q2 + // 2nd curve point 1
        " " + p1 + "," + q3 + // 2nd curve point 2
        " " + p1 + "," + y; // end point and move back to start
}
