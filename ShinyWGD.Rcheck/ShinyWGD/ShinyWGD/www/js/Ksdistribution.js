var numFormatter = d3.format(".0f");
const floatFormatter = d3.format(".2f");

Shiny.addCustomMessageHandler("Bar_Density_Plotting", mixBarDensityPlotting);
function mixBarDensityPlotting(InputData) {
    var plotId = InputData.plot_id;
    var KsDensityInfo = convertShinyData(InputData.ks_density_df);
    var rateCorrectionInfo = convertShinyData(InputData.rate_correction_df);
    var paralogId = InputData.paralog_id;
    var paralogSpecies = InputData.paralogSpecies;
    var KsXlimit = InputData.xlim;
    var KsYlimit = InputData.ylim;
    var KsY2limit = InputData.y2lim;
    var barOpacity = InputData.opacity;
    var height = InputData.height;
    var width = InputData.width;

    const colors = [
        "#9B3A4D", "#32AEEC", "#E2AE79", "#8E549E", "#EA7500",
        "#566CA5", "#D2352C", "#394A92", "#68AC57", "#F4C28F"
    ];

    // draw a wgd bar plot
    d3.select("#" + plotId).select("svg").remove();
    d3.selectAll("body svg").remove();

    let topPadding = 50;
    let bottomPadding = 40;
    let leftPadding = 80;
    let rightPadding = 50;
    var tooltipDelay = 500;

    const svg = d3.select("#" + plotId)
        .append("svg")
        .attr("width", width)
        .attr("height", height);

    // Define the x and y scales
    var xScale = d3.scaleLinear()
        .domain([0, KsXlimit])
        .range([0 + leftPadding, width - rightPadding]);

    var xtickValues = d3.range(0, KsXlimit + 1, 1);
    var xAxis = d3.axisBottom(xScale)
        .tickValues(xtickValues)
        .tickFormat(d3.format("d"));

    svg.append("g")
        .attr("class", "axis axis--x")
        .attr("transform", `translate(0, ${ height - bottomPadding })`)
        .call(xAxis)
        .attr("font-size", "12px")
        .attr("font-family", "calibri");

    svg.append("g")
        .attr("class", "xTitle")
        .append("text")
        .attr("x", d3.mean([leftPadding - 30, width]))
        .attr("y", height - 10)
        .attr("text-anchor", "middle")
        .append("tspan")
        .attr("font-family", "times")
        .html("<tspan style='font-style: italic;'>K</tspan>")
        .style("font-size", "14px")
        .append("tspan")
        .text("s")
        .style("font-size", "12px")
        .attr("dx", "1px")
        .attr("dy", "2px");

    if (typeof paralogId !== 'undefined') {
        var KsInfo = convertShinyData(InputData.ks_bar_df);
        var titles = [...new Set(KsInfo.map(d => d.title))];
        // console.log("titles", titles);

        const colorScale = d3.scaleOrdinal()
            .domain(KsInfo.map(function (d) { return d.title; }))
            .range(colors);

        svg.append("g")
            .attr("class", "yTitle")
            .append("text")
            .attr("y", d3.mean([topPadding, height - bottomPadding]))
            .attr("x", leftPadding - 50)
            .attr("text-anchor", "middle")
            .attr("font-size", "14px")
            .attr("font-family", "times")
            .attr("transform", function () {
                return `rotate(-90, ${ d3.select(this).attr("x") }, ${ d3.select(this).attr("y") })`;
            })
            .text("Number of retained duplicates");

        var yScale = d3.scaleLinear()
            .domain([0, KsYlimit])
            .range([height - bottomPadding, topPadding]);
        var ytickValues = d3.range(0, KsYlimit + 1, 500);
        var yAxis = d3.axisLeft(yScale)
            .tickValues(ytickValues);

        svg.append("g")
            .attr("class", "axis axis--y")
            .attr("transform", `translate(${ leftPadding - 5 }, 0)`)
            .call(yAxis)
            .attr("font-size", "12px")
            .attr("font-family", "calibri");

        var paralogData = KsInfo.filter(function (d) {
            var paralogIdFile = paralogId + ".ks";
            var paralogIdAnchorsFile = paralogId + ".ks_anchors";
            return (d.title === paralogIdFile) || (d.title === paralogIdAnchorsFile);
        });

        var barColorScale = d3.scaleOrdinal()
            .domain(paralogData.map(function (d) { return d.title.split(".")[0]; }))
            .range(["black", "#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "#9467bd"]);

        var ksOpacity = 0.2;
        var anchorsOpacity = 0.5;

        svg.append("g")
            .attr("class", "rect bar")
            .selectAll("rect")
            .data(paralogData)
            .join("rect")
            .attr("id", (d) => "Ks_" + d.ks)
            .attr("x", function (d, i) { return xScale(d.ks) - width / 100 * 0.9; })
            .attr("y", function (d) { return yScale(d.x); })
            .attr("width", width / 100 * 1.35)
            .attr("height", function (d) { return height - bottomPadding - yScale(d.x); })
            .attr("fill", function (d) {
                var titlePrefix = d.title.split(".")[0];
                return barColorScale(titlePrefix); // Set color based on the title prefix
            })
            .attr("fill-opacity", function (d) {
                if (d.title.includes("ks_anchor")) {
                    return anchorsOpacity; // Set opacity for "ks_anchors" bars
                } else {
                    return ksOpacity;
                }
            })
            .attr("data-tippy-content", function (d) {
                // Tooltip content generation
                var xMatches = KsInfo.filter(function (item) { return item.ks === d.ks && item.title.startsWith(d.title.split(".")[0]); });
                xMatches.sort(function (a, b) { return b.x - a.x; });
                let content = "<font color='#ff7575'><i>K</i><sub>s</sub></font>: " + d.ks + "<br>";
                xMatches.forEach(function (match) {
                    content += "<font color='#00BB00'><i>" + match.title + "</i></font>: " + numFormatter(match.x) + "<br>";
                });
                return content;
            })
            .on("mouseover", function (event, d) {
                // Tippy tooltip initialization
                tippy(this, {
                    theme: "light",
                    placement: "top-start",
                    allowHTML: true,
                    animation: "scale",
                    delay: [1000, 0],
                    duration: [200, 200]
                });
            })
            .on("mouseout", function (event, d) {
                tippy.hideAll();
            });

        var line = d3.line()
            .x(function (d) { return xScale(d.ks); })
            .y(function (d) { return yScale(d.x); })
            .curve(d3.curveCatmullRom.alpha(0.8));

        var groupedLineData = d3.group(paralogData, function (d) {
            return d.title;
        });

        groupedLineData.forEach(function (dataGroup) {
            var stepSize = Math.ceil(dataGroup.length / 25);
            var reducedData = dataGroup.filter(function (d, i) {
                return i % stepSize === 0;
            });

            // console.log("reducedData", reducedData)
            svg.append("path")
                .datum(reducedData)
                .attr("class", "line")
                .attr("d", line)
                .attr("fill", "none")
                .attr("stroke", function (d) {
                    var titlePrefix = d[0].title.split(".")[0];
                    return barColorScale(titlePrefix);
                })
                .attr("stroke-width", 1.5)
                .attr("stroke-opacity", function (d) {
                    if (d[0].title.includes("ks_anchor")) {
                        return anchorsOpacity + 0.2;
                    } else {
                        return ksOpacity + 0.2;
                    }
                });
        });

        var paralogIdData = titles.filter(function (d) {
            var paralogIdFile = paralogId + ".ks";
            var paralogIdAnchorsFile = paralogId + ".ks_anchors";
            return (d === paralogIdFile) || (d === paralogIdAnchorsFile);
        });

        var legend = svg.append("g")
            .attr("class", "legend")
            .attr("transform", `translate(${ width - 200 }, 40)`);

        var legendItems = legend.selectAll(".legend-item")
            .data(paralogIdData)
            .enter()
            .append("g")
            .attr("class", "legend-item")
            .attr("transform", function (d, i) { return `translate(0, ${ i * 20 })`; });

        legendItems.append("rect")
            .attr("x", 0)
            .attr("y", 0)
            .attr("width", 10)
            .attr("height", 10)
            .attr("fill", function (d) {
                var titlePrefix = d.split(".")[0];
                return barColorScale(titlePrefix);
            })
            .attr("fill-opacity", function (d) {
                if (d.includes("ks_anchor")) {
                    return anchorsOpacity;
                } else {
                    return ksOpacity;
                }
            });

        legendItems.append("text")
            .attr("x", 20)
            .attr("y", 10)
            .attr("font-family", "calibri")
            .attr("font-size", "12px")
            .attr("fill", "#333")
            .html(function (d) {
                var speciesName = paralogSpecies.replace(/(\w)\w+\s(\w+)/, "$1. $2");
                if (d.includes("ks_anchor")) {
                    return "<tspan style='font-style: italic;'>" + speciesName + "</tspan>" + " - Anchors";
                } else {
                    return "<tspan style='font-style: italic;'>" + speciesName + "</tspan>";
                }
            });

        // Add density plot for orthologous groups
        var kde = kernelDensityEstimator(kernelEpanechnikov(0.25), xScale.ticks(500));

        var groupedData = Array.from(d3.group(KsDensityInfo, d => d.title), ([key, values]) => ({ key, values }));
        groupedData = groupedData.filter(function (d) {
            var paralogSpeciesFile = paralogId + ".ks";
            var paralogSpeciesAnchorsFile = paralogId + ".ks_anchors";
            return (d.key !== paralogSpeciesFile) && (d.key !== paralogSpeciesAnchorsFile);
        });

        var densityData = groupedData.map(function (d) {
            var density = kde(d.values.map(function (d) { return d.ks; }));
            return { key: d.key, density: density };
        });

        var iterations = 1000;
        var confidenceLevel = 0.95;
        var binWidth = 0.01;

        var confidenceIntervals = [];
        var groupConfidenceIntervals = [];

        densityData.forEach(function (group) {
            for (var i = 0; i < iterations; i++) {
                var peakPosition = null;
                var peakArea = 0;

                var sampledValues = group.density.map(function (point) {
                    var randomIndex = Math.floor(Math.random() * group.density.length);
                    return group.density[randomIndex];
                });

                var peakPoint = sampledValues.reduce(function (prevPoint, currPoint) {
                    return currPoint[1] > prevPoint[1] ? currPoint : prevPoint;
                });

                var totalArea = sampledValues.reduce(function (sum, point) {
                    return sum + point[1] * binWidth;
                }, 0);

                var cumulativeArea = 0;
                var cutoffIndex = 0;
                while (cumulativeArea < totalArea * confidenceLevel) {
                    cumulativeArea += sampledValues[cutoffIndex][1] * binWidth;
                    cutoffIndex++;
                }

                if (peakPoint[0] >= sampledValues[cutoffIndex][0] && peakPoint[0] <= sampledValues[cutoffIndex - 1][0]) {
                    peakPosition = peakPoint[0];
                    peakArea = peakPoint[1] * binWidth;
                }

                groupConfidenceIntervals.push({ position: peakPosition, area: peakArea });
            }

            groupConfidenceIntervals = groupConfidenceIntervals.filter(function (peak) {
                return peak.position !== null;
            });

            var sortedPositions = groupConfidenceIntervals.map(function (peak) {
                return peak.position;
            }).sort(function (a, b) {
                return a - b;
            });
            var lowerBoundIndex = Math.floor((1 - confidenceLevel) / 2 * groupConfidenceIntervals.length);
            var upperBoundIndex = Math.ceil((1 + confidenceLevel) / 2 * groupConfidenceIntervals.length);
            var lowerBound = sortedPositions[lowerBoundIndex];
            var upperBound = sortedPositions[upperBoundIndex];

            confidenceIntervals.push({ group: group.key, confidenceInterval: [lowerBound, upperBound] });
        });

        var y2Scale = d3.scaleLinear()
            .domain([0, KsY2limit])
            .range([height - bottomPadding, topPadding]);
        var y2tickValues = d3.range(0, KsY2limit + 0.1, 0.2);
        var y2Axis = d3.axisRight(y2Scale)
            .tickValues(y2tickValues);

        svg.append("g")
            .attr("class", "axis axis--y2")
            .attr("transform", `translate(${ width - rightPadding + 5 }, 0)`)
            .call(y2Axis)
            .attr("font-size", "12px")
            .attr("font-family", "calibri");

        svg.append("g")
            .attr("class", "y2Title")
            .append("text")
            .attr("y", d3.mean([topPadding, height - bottomPadding]))
            .attr("x", width - rightPadding + 50)
            .attr("text-anchor", "middle")
            .attr("font-size", "14px")
            .attr("font-family", "times")
            .attr("transform", function () {
                return `rotate(-90, ${ d3.select(this).attr("x") }, ${ d3.select(this).attr("y") })`;
            })
            .text("Ortholog Density");

        var area = d3.area()
            .x(function (d) { return xScale(d[0]); })
            .y0(height - bottomPadding)
            .y1(function (d) { return y2Scale(d[1]); });

        var peaksInfo = [];

        svg.selectAll(".area")
            .data(densityData)
            .enter()
            .append("path")
            .attr("class", "area path")
            .attr("d", function (d) { return area(d.density); })
            .style("fill", function (d) { return colorScale(d.key); })
            .attr("fill-opacity", barOpacity)
            .attr("data-tippy-content", (d, i) => {
                var maxDensity = d3.max(d.density, function (m) {
                    return m[1];
                });

                var maxDensityData = d.density.find(function (d) {
                    return d[1] === maxDensity;
                });

                var maxDensityKs = maxDensityData ? maxDensityData[0] : undefined;

                /* svg.append("line")
                    .attr("x1", xScale(maxDensityData[0]))
                    .attr("y1", y2Scale(0))
                    .attr("x2", xScale(maxDensityData[0]))
                    .attr("y2", y2Scale(KsY2limit))
                    .style("stroke", colorScale(d.key))
                    .style("stroke-width", "1.4")
                    .style("stroke-dasharray", "5, 5"); */
                peaksInfo.push({ group: d.key, peak: maxDensityData[0] });

                var nintyfiveCI = confidenceIntervals[i].confidenceInterval;
                /* svg.append("rect")
                    .attr("x", xScale(nintyfiveCI[0]))
                    .attr("y", y2Scale(KsY2limit))
                    .attr("width", xScale(nintyfiveCI[1]) - xScale(nintyfiveCI[0]))
                    .attr("height", y2Scale(0) - 50)
                    .style("fill", colorScale(d.key))
                    .style("fill-opacity", 0.2)
                    .attr("data-tippy-content", function () {
                        var peakContent = "Peak: <span style='color: " + colorScale(d.key.replace(".ks", "")) + ";'>" + maxDensityKs + "</span><br>" +
                            "95% CIs: <span style='color: " + highlightColor + "; background-color: " + color + "';>" +
                            nintyfiveCI[0].toFixed(2) + " <--> " + nintyfiveCI[1].toFixed(2) + "</span>";
                        return peakContent;
                    })
                    .on("mouseover", function (event, d) {
                        tippy(this, {
                            theme: "light",
                            placement: "right",
                            allowHTML: true,
                            animation: "scale",
                            delay: [1000, 0],
                            duration: [200, 200],
                            followCursor: true,
                            offset: [-15, 15]
                        });
                    })
                    .on("mouseout", function (event, d) {
                        tippy.hideAll();
                    }); */

                var highlightColors = {
                    "red": "yellow",
                    "green": "cyan",
                    "blue": "magenta",
                    "yellow": "black",
                    "cyan": "orange",
                    "magenta": "lime",
                    "black": "white"
                };

                var color = colorScale(d.key);
                var highlightColor = highlightColors[color] || "white";
                var name = d.key.replace(/\d+/g, "");
                var content = "<span style='color: " + highlightColor + "; background-color: " + color + ";'>" + name + "</span> <br> Peak: <span style='color: red;'>" +
                    maxDensityKs + "</span> (Density: <span style='color: " + color + ";'>" + maxDensity.toFixed(2) + "</span>)<br>" +
                    "95% CIs: <span style='color: " + highlightColor + "; background-color: " + color + "';>" + nintyfiveCI[0].toFixed(2) + " <--> " + nintyfiveCI[1].toFixed(2) + "</span>";

                return content;
            })
            .on("mouseover", function (event, d) {
                tippy(this, {
                    theme: "light",
                    placement: "right",
                    allowHTML: true,
                    animation: "scale",
                    delay: [1000, 0],
                    duration: [200, 200],
                    followCursor: true,
                    offset: [-15, 15]
                });
            })
            .on("mouseout", function (event, d) {
                tippy.hideAll();
            });

        var maxYvalueInfo = [];
        densityData.forEach(function (d) {
            var maxYvalue = d3.max(d.density, function (m) {
                return m[1];
            });
            maxYvalueInfo.push({ group: d.key, Yvalue: maxYvalue });
        });

        var highestYValues = densityData.map(function (d) {
            var maxDensity = d3.max(d.density, function (m) {
                return m[1];
            });
            return maxDensity;
        });

        var maxModeSum = Math.max(
            ...rateCorrectionInfo.map(function (item) {
                var sumAC = parseFloat(item.a_mode) + parseFloat(item.c_mode);
                var sumBC = parseFloat(item.b_mode) + parseFloat(item.c_mode);
                return Math.max(sumAC, sumBC);
            })
        );

        // Add relative rate test output to plot
        rateCorrectionInfo.forEach(function (each, i) {
            var ref_full = parseFloat(each.a_mode) + parseFloat(each.c_mode);
            var cal_full = parseFloat(each.b_mode) + parseFloat(each.c_mode);

            var firstStudyElement = each.study.split(' ')[0];
            var firstOutgroupElement = each.outgroup.split(' ')[0];
            var firstRefElement = each.ref.split(" ")[0];
            var matchingTitles = titles.filter(function (item) {
                return item.includes(firstOutgroupElement);
            });
            var study2outgroup = matchingTitles.find(function (item) {
                return item.includes(firstStudyElement);
            });
            var ref2outgroup = matchingTitles.find(function (item) {
                return item.includes(firstRefElement);
            })

            var study2outgroupYpos = maxYvalueInfo.find(function (item) {
                var pos = item.group.includes(study2outgroup);
                return pos;
            });

            var ref2outgroupYpos = maxYvalueInfo.find(function (item) {
                var pos = item.group.includes(ref2outgroup);
                return pos;
            });

            var rateYpos = d3.max(highestYValues) + 0.2;

            // rect(mode.3$c.low.bound, 1-0.25, mode.3$c.up.bound, 1+0.25, col = "#8080804D", border = NA)
            svg.append('circle')
                .attr("class", "rate test")
                .attr("r", 2)
                .attr("cx", xScale(parseFloat(each.c_mode)))
                .attr("cy", y2Scale(rateYpos + i * 0.4))
                .attr("fill", "black")
                .attr("fill-opacity", "0.7");

            svg.append("rect")
                .attr("class", "rate test")
                .attr("id", "rate_correction_" + each.study)
                .attr("x", xScale(each.c_low_bound))
                .attr("y", y2Scale(rateYpos + i * 0.4) - 4)
                .attr("width", xScale(each.c_up_bound) - xScale(each.c_low_bound))
                .attr("height", 8)
                .attr("fill", "#8080804D")
                .attr("fill-opacity", "0.9");

            // Define the marker for triangle shape
            svg.append('marker')
                .attr('id', 'triangle-marker-1')
                .attr('viewBox', '0 0 10 10')
                .attr('refX', 9)
                .attr('refY', 5)
                .attr('markerWidth', 6)
                .attr('markerHeight', 9)
                .attr('orient', 'auto')
                .append('path')
                .attr('d', 'M 0 0 L 10 5 L 0 10 z')
                .attr('fill', 'grey');

            if (i === 0) {
                var ref2outgroupLabel = each.outgroup.replace(/(\w)\w+\s(\w+)/, "$1. $2") +
                    " - " + each.ref.replace(/(\w)\w+\s(\w+)/, "$1. $2");
                svg.append('text')
                    .attr('x', xScale(maxModeSum + 0.1))
                    .attr('y', y2Scale(rateYpos + i * 0.4) + 3)
                    .text(ref2outgroupLabel)
                    .attr('fill', colorScale(ref2outgroup))
                    .attr("font-size", "10px")
                    .attr('text-anchor', 'start')
                    .attr("font-family", "calibri")
                    .attr("font-style", "italic");
            }

            svg.append('line')
                .attr("class", "rate test")
                .attr('x1', xScale(parseFloat(each.c_mode)))
                .attr('y1', y2Scale(rateYpos + i * 0.4))
                .attr('x2', xScale(0))
                .attr('y2', y2Scale(rateYpos + i * 0.4))
                .attr('stroke', 'grey')
                .attr('marker-end', 'url(#triangle-marker-1)');

            svg.append('marker')
                .attr('id', 'triangle-marker-2')
                .attr('viewBox', '0 0 10 10')
                .attr('refX', 9)
                .attr('refY', 5)
                .attr('markerWidth', 6)
                .attr('markerHeight', 9)
                .attr('orient', 'auto')
                .append('path')
                .attr('d', 'M 0 0 L 10 5 L 0 10 z')
                .attr('fill', colorScale(ref2outgroup));

            svg.append('line')
                .attr("class", "rate test")
                .attr('x1', xScale(parseFloat(each.c_mode)))
                .attr('y1', y2Scale(rateYpos + i * 0.4))
                .attr('x2', xScale(ref_full))
                .attr('y2', y2Scale(rateYpos + i * 0.4))
                .attr('stroke', colorScale(ref2outgroup))
                .attr('marker-end', 'url(#triangle-marker-2)');

            svg.append("line")
                .attr("class", "rate test")
                .attr('x1', xScale(ref_full))
                .attr('y1', y2Scale(rateYpos + i * 0.4))
                .attr('x2', xScale(ref_full))
                .attr('y2', y2Scale(ref2outgroupYpos.Yvalue))
                .attr('stroke', colorScale(ref2outgroup))
                .attr('opacity', '0.6')
                .attr("stroke-dasharray", "5 3");

            svg.append('line')
                .attr('x1', xScale(parseFloat(each.c_mode)))
                .attr('y1', y2Scale(rateYpos + i * 0.4))
                .attr('x2', xScale(parseFloat(each.c_mode)))
                .attr('y2', y2Scale(rateYpos + i * 0.4 + 0.15))
                .attr('stroke', colorScale(study2outgroup));

            svg.append('marker')
                .attr('id', 'triangle-marker-3')
                .attr('viewBox', '0 0 10 10')
                .attr('refX', 9)
                .attr('refY', 5)
                .attr('markerWidth', 6)
                .attr('markerHeight', 9)
                .attr('orient', 'auto')
                .append('path')
                .attr('d', 'M 0 0 L 10 5 L 0 10 z')
                .attr('fill', colorScale(study2outgroup));

            svg.append('line')
                .attr('x1', xScale(parseFloat(each.c_mode)))
                .attr('y1', y2Scale(rateYpos + i * 0.4 + 0.15))
                .attr('x2', xScale(cal_full))
                .attr('y2', y2Scale(rateYpos + i * 0.4 + 0.15))
                .attr('stroke', colorScale(study2outgroup))
                .attr('marker-end', 'url(#triangle-marker-3)');

            svg.append("line")
                .attr("class", "rate test")
                .attr('x1', xScale(cal_full))
                .attr('y1', y2Scale(rateYpos + i * 0.4 + 0.15))
                .attr('x2', xScale(cal_full))
                .attr('y2', y2Scale(study2outgroupYpos.Yvalue))
                .attr('stroke', colorScale(study2outgroup))
                .attr('opacity', '0.6')
                .attr("stroke-dasharray", "5 3");

            var study2outgroupLabel = each.outgroup.replace(/(\w)\w+\s(\w+)/, "$1. $2") +
                " - " + each.study.replace(/(\w)\w+\s(\w+)/, "$1. $2");

            svg.append('text')
                .attr('x', xScale(maxModeSum + 0.1))
                .attr('y', y2Scale(rateYpos + i * 0.4 + 0.15) + 3)
                .text(study2outgroupLabel)
                .attr('fill', colorScale(study2outgroup))
                .attr("font-size", "10px")
                .attr('text-anchor', 'start')
                .attr("font-family", "calibri")
                .attr("font-style", "italic");

            svg.append('text')
                .attr('x', xScale(parseFloat(each.c_mode) - 0.2))
                .attr('y', y2Scale(rateYpos + i * 0.4 + 0.05))
                .text(floatFormatter(parseFloat(each.c_mode)))
                .attr('fill', 'grey')
                .attr("font-size", "10px")
                .attr('text-anchor', 'end')
                .attr("font-family", "calibri");

            svg.append('text')
                .attr('x', xScale(parseFloat(each.c_mode) + 0.2))
                .attr('y', y2Scale(rateYpos + i * 0.4 + 0.05))
                .text(floatFormatter(each.a_mode))
                .attr('fill', colorScale(ref2outgroup))
                .attr("font-size", "10px")
                .attr("font-family", "calibri");

            svg.append('text')
                .attr('x', xScale(parseFloat(each.c_mode) + 0.2))
                .attr('y', y2Scale(rateYpos + i * 0.4 + 0.2))
                .text(floatFormatter(each.b_mode))
                .attr('fill', colorScale(study2outgroup))
                .attr("font-size", "10px")
                .attr("font-family", "calibri");
        });
    } else {
        var KsDensityInfo = convertShinyData(InputData.ks_density_df);
        var titles = [...new Set(KsDensityInfo.map(d => d.title))];

        const colorScale = d3.scaleOrdinal()
            .domain(KsDensityInfo.map(function (d) { return d.title; }))
            .range(colors);

        var kde = kernelDensityEstimator(kernelEpanechnikov(0.25), xScale.ticks(500));

        var groupedData = Array.from(d3.group(KsDensityInfo, d => d.title), ([key, values]) => ({ key, values }));
        groupedData = groupedData.filter(function (d) {
            var paralogSpeciesFile = paralogId + ".ks";
            var paralogSpeciesAnchorsFile = paralogId + ".ks_anchors";
            return (d.key !== paralogSpeciesFile) && (d.key !== paralogSpeciesAnchorsFile);
        });

        var densityData = groupedData.map(function (d) {
            var density = kde(d.values.map(function (d) { return d.ks; }));
            return { key: d.key, density: density };
        });

        var iterations = 1000;
        var confidenceLevel = 0.95;
        var binWidth = 0.01;

        var confidenceIntervals = [];
        var groupConfidenceIntervals = [];

        densityData.forEach(function (group) {
            for (var i = 0; i < iterations; i++) {
                var peakPosition = null;
                var peakArea = 0;

                var sampledValues = group.density.map(function (point) {
                    var randomIndex = Math.floor(Math.random() * group.density.length);
                    return group.density[randomIndex];
                });

                var peakPoint = sampledValues.reduce(function (prevPoint, currPoint) {
                    return currPoint[1] > prevPoint[1] ? currPoint : prevPoint;
                });

                var totalArea = sampledValues.reduce(function (sum, point) {
                    return sum + point[1] * binWidth;
                }, 0);

                var cumulativeArea = 0;
                var cutoffIndex = 0;
                while (cumulativeArea < totalArea * confidenceLevel) {
                    cumulativeArea += sampledValues[cutoffIndex][1] * binWidth;
                    cutoffIndex++;
                }

                if (peakPoint[0] >= sampledValues[cutoffIndex][0] && peakPoint[0] <= sampledValues[cutoffIndex - 1][0]) {
                    peakPosition = peakPoint[0];
                    peakArea = peakPoint[1] * binWidth;
                }

                groupConfidenceIntervals.push({ position: peakPosition, area: peakArea });
            }

            groupConfidenceIntervals = groupConfidenceIntervals.filter(function (peak) {
                return peak.position !== null;
            });

            var sortedPositions = groupConfidenceIntervals.map(function (peak) {
                return peak.position;
            }).sort(function (a, b) {
                return a - b;
            });
            var lowerBoundIndex = Math.floor((1 - confidenceLevel) / 2 * groupConfidenceIntervals.length);
            var upperBoundIndex = Math.ceil((1 + confidenceLevel) / 2 * groupConfidenceIntervals.length);
            var lowerBound = sortedPositions[lowerBoundIndex];
            var upperBound = sortedPositions[upperBoundIndex];

            confidenceIntervals.push({ group: group.key, confidenceInterval: [lowerBound, upperBound] });
        });

        var y2Scale = d3.scaleLinear()
            .domain([0, KsY2limit])
            .range([height - bottomPadding, topPadding])
        var y2tickValues = d3.range(0, KsY2limit + 0.1, 0.2);
        var y2Axis = d3.axisLeft(y2Scale)
            .tickValues(y2tickValues);

        svg.append("g")
            .attr("class", "axis axis--y2")
            .attr("transform", `translate(${ leftPadding - 5 }, 0)`)
            .call(y2Axis)
            .attr("font-size", "12px")
            .attr("font-family", "calibri");

        svg.append("g")
            .attr("class", "y2Title")
            .append("text")
            .attr("y", d3.mean([topPadding, height - bottomPadding]))
            .attr("x", leftPadding - 50)
            .attr("text-anchor", "middle")
            .attr("font-size", "14px")
            .attr("font-family", "times")
            .attr("transform", function () {
                return `rotate(-90, ${ d3.select(this).attr("x") }, ${ d3.select(this).attr("y") })`;
            })
            .text("Ortholog Density");

        var area = d3.area()
            .x(function (d) { return xScale(d[0]); })
            .y0(height - bottomPadding)
            .y1(function (d) { return y2Scale(d[1]); });

        var peaksInfo = [];
        svg.selectAll(".area")
            .data(densityData)
            .enter()
            .append("path")
            .attr("class", "area path")
            .attr("d", function (d) { return area(d.density); })
            .style("fill", function (d) { return colorScale(d.key); })
            .attr("fill-opacity", barOpacity)
            .attr("data-tippy-content", (d, i) => {
                var maxDensity = d3.max(d.density, function (m) {
                    return m[1];
                });

                var maxDensityData = d.density.find(function (d) {
                    return d[1] === maxDensity;
                });

                var maxDensityKs = maxDensityData ? maxDensityData[0] : undefined;
                peaksInfo.push({ group: d.key, peak: maxDensityData[0] });

                var nintyfiveCI = confidenceIntervals[i].confidenceInterval;

                var highlightColors = {
                    "red": "yellow",
                    "green": "cyan",
                    "blue": "magenta",
                    "yellow": "black",
                    "cyan": "orange",
                    "magenta": "lime",
                    "black": "white"
                };

                var color = colorScale(d.key);
                var highlightColor = highlightColors[color] || "white";
                var name = d.key.replace(/\d+/g, "");
                var content = "<span style='color: " + highlightColor + "; background-color: " + color + ";'>" + name + "</span> <br> Peak: <span style='color: red;'>" +
                    maxDensityKs + "</span> (Density: <span style='color: " + color + ";'>" + maxDensity.toFixed(2) + "</span>)<br>" +
                    "95% CIs: <span style='color: " + highlightColor + "; background-color: " + color + "';>" + nintyfiveCI[0].toFixed(2) + " <--> " + nintyfiveCI[1].toFixed(2) + "</span>";

                return content;
            })
            .on("mouseover", function (event, d) {
                tippy(this, {
                    theme: "light",
                    placement: "right",
                    allowHTML: true,
                    animation: "scale",
                    delay: [1000, 0],
                    duration: [200, 200],
                    followCursor: true,
                    offset: [-15, 15]
                });
            })
            .on("mouseout", function (event, d) {
                tippy.hideAll();
            });

        var maxYvalueInfo = [];
        densityData.forEach(function (d) {
            var maxYvalue = d3.max(d.density, function (m) {
                return m[1];
            });
            maxYvalueInfo.push({ group: d.key, Yvalue: maxYvalue });
        });

        var highestYValues = densityData.map(function (d) {
            var maxDensity = d3.max(d.density, function (m) {
                return m[1];
            });
            return maxDensity;
        });

        var maxModeSum = Math.max(
            ...rateCorrectionInfo.map(function (item) {
                var sumAC = parseFloat(item.a_mode) + parseFloat(item.c_mode);
                var sumBC = parseFloat(item.b_mode) + parseFloat(item.c_mode);
                return Math.max(sumAC, sumBC);
            })
        )
        // ("maxModeSum", maxModeSum, xScale(maxModeSum + 0.2));

        // Add relative rate test output to plot
        rateCorrectionInfo.forEach(function (each, i) {
            var ref_full = parseFloat(each.a_mode) + parseFloat(each.c_mode);
            var cal_full = parseFloat(each.b_mode) + parseFloat(each.c_mode);

            var firstStudyElement = each.study.split(' ')[0];
            var firstOutgroupElement = each.outgroup.split(' ')[0];
            var firstRefElement = each.ref.split(" ")[0];
            var matchingTitles = titles.filter(function (item) {
                return item.includes(firstOutgroupElement);
            });
            var study2outgroup = matchingTitles.find(function (item) {
                return item.includes(firstStudyElement);
            });
            var ref2outgroup = matchingTitles.find(function (item) {
                return item.includes(firstRefElement);
            })

            var study2outgroupYpos = maxYvalueInfo.find(function (item) {
                var pos = item.group.includes(study2outgroup);
                return pos;
            });

            var ref2outgroupYpos = maxYvalueInfo.find(function (item) {
                var pos = item.group.includes(ref2outgroup);
                return pos;
            });

            var rateYpos = d3.max(highestYValues) + 0.2;

            svg.append('circle')
                .attr("class", "rate test")
                .attr("r", 2)
                .attr("cx", xScale(parseFloat(each.c_mode)))
                .attr("cy", y2Scale(rateYpos + i * 0.4))
                .attr("fill", "black")
                .attr("fill-opacity", "0.7");

            svg.append("rect")
                .attr("class", "rate test")
                .attr("id", "rate_correction_" + each.study)
                .attr("x", xScale(each.c_low_bound))
                .attr("y", y2Scale(rateYpos + i * 0.4) - 4)
                .attr("width", xScale(each.c_up_bound) - xScale(each.c_low_bound))
                .attr("height", 8)
                .attr("fill", "#8080804D")
                .attr("fill-opacity", "0.9");

            svg.append('marker')
                .attr('id', 'triangle-marker-1')
                .attr('viewBox', '0 0 10 10')
                .attr('refX', 9)
                .attr('refY', 5)
                .attr('markerWidth', 6)
                .attr('markerHeight', 9)
                .attr('orient', 'auto')
                .append('path')
                .attr('d', 'M 0 0 L 10 5 L 0 10 z')
                .attr('fill', 'grey');

            if (i === 0) {
                var ref2outgroupLabel = each.outgroup.replace(/(\w)\w+\s(\w+)/, "$1. $2") +
                    " - " + each.ref.replace(/(\w)\w+\s(\w+)/, "$1. $2")
                svg.append('text')
                    .attr('x', xScale(maxModeSum + 0.1))
                    .attr('y', y2Scale(rateYpos + i * 0.4) + 3)
                    .text(ref2outgroupLabel)
                    .attr('fill', colorScale(ref2outgroup))
                    .attr("font-size", "10px")
                    .attr('text-anchor', 'start')
                    .attr("font-family", "calibri")
                    .attr("font-style", "italic");
            }

            svg.append('line')
                .attr("class", "rate test")
                .attr('x1', xScale(parseFloat(each.c_mode)))
                .attr('y1', y2Scale(rateYpos + i * 0.4))
                .attr('x2', xScale(0))
                .attr('y2', y2Scale(rateYpos + i * 0.4))
                .attr('stroke', 'grey')
                .attr('marker-end', 'url(#triangle-marker-1)');

            svg.append('marker')
                .attr('id', 'triangle-marker-2')
                .attr('viewBox', '0 0 10 10')
                .attr('refX', 9)
                .attr('refY', 5)
                .attr('markerWidth', 6)
                .attr('markerHeight', 9)
                .attr('orient', 'auto')
                .append('path')
                .attr('d', 'M 0 0 L 10 5 L 0 10 z')
                .attr('fill', colorScale(ref2outgroup));

            svg.append('line')
                .attr("class", "rate test")
                .attr('x1', xScale(parseFloat(each.c_mode)))
                .attr('y1', y2Scale(rateYpos + i * 0.4))
                .attr('x2', xScale(ref_full))
                .attr('y2', y2Scale(rateYpos + i * 0.4))
                .attr('stroke', colorScale(ref2outgroup))
                .attr('marker-end', 'url(#triangle-marker-2)');

            svg.append("line")
                .attr("class", "rate test")
                .attr('x1', xScale(ref_full))
                .attr('y1', y2Scale(rateYpos + i * 0.4))
                .attr('x2', xScale(ref_full))
                .attr('y2', y2Scale(ref2outgroupYpos.Yvalue))
                .attr('stroke', colorScale(ref2outgroup))
                .attr('opacity', '0.6')
                .attr("stroke-dasharray", "5 3");

            svg.append('line')
                .attr('x1', xScale(parseFloat(each.c_mode)))
                .attr('y1', y2Scale(rateYpos + i * 0.4))
                .attr('x2', xScale(parseFloat(each.c_mode)))
                .attr('y2', y2Scale(rateYpos + i * 0.4 + 0.15))
                .attr('stroke', colorScale(study2outgroup));

            svg.append('marker')
                .attr('id', 'triangle-marker-3')
                .attr('viewBox', '0 0 10 10')
                .attr('refX', 9)
                .attr('refY', 5)
                .attr('markerWidth', 6)
                .attr('markerHeight', 9)
                .attr('orient', 'auto')
                .append('path')
                .attr('d', 'M 0 0 L 10 5 L 0 10 z')
                .attr('fill', colorScale(study2outgroup));

            svg.append('line')
                .attr('x1', xScale(parseFloat(each.c_mode)))
                .attr('y1', y2Scale(rateYpos + i * 0.4 + 0.15))
                .attr('x2', xScale(cal_full))
                .attr('y2', y2Scale(rateYpos + i * 0.4 + 0.15))
                .attr('stroke', colorScale(study2outgroup))
                .attr('marker-end', 'url(#triangle-marker-3)');

            svg.append("line")
                .attr("class", "rate test")
                .attr('x1', xScale(cal_full))
                .attr('y1', y2Scale(rateYpos + i * 0.4 + 0.15))
                .attr('x2', xScale(cal_full))
                .attr('y2', y2Scale(study2outgroupYpos.Yvalue))
                .attr('stroke', colorScale(study2outgroup))
                .attr('opacity', '0.6')
                .attr("stroke-dasharray", "5 3");

            var study2outgroupLabel = each.outgroup.replace(/(\w)\w+\s(\w+)/, "$1. $2") +
                " - " + each.study.replace(/(\w)\w+\s(\w+)/, "$1. $2");
            svg.append('text')
                .attr('x', xScale(maxModeSum + 0.1))
                .attr('y', y2Scale(rateYpos + i * 0.4 + 0.15) + 3)
                .text(study2outgroupLabel)
                .attr('fill', colorScale(study2outgroup))
                .attr("font-size", "10px")
                .attr('text-anchor', 'start')
                .attr("font-family", "calibri")
                .attr("font-style", "italic");

            svg.append('text')
                .attr('x', xScale(parseFloat(each.c_mode) - 0.2))
                .attr('y', y2Scale(rateYpos + i * 0.4 + 0.05))
                .text(floatFormatter(parseFloat(each.c_mode)))
                .attr('fill', 'grey')
                .attr("font-size", "10px")
                .attr('text-anchor', 'end')
                .attr("font-family", "calibri");

            svg.append('text')
                .attr('x', xScale(parseFloat(each.c_mode) + 0.2))
                .attr('y', y2Scale(rateYpos + i * 0.4 + 0.05))
                .text(floatFormatter(each.a_mode))
                .attr('fill', colorScale(ref2outgroup))
                .attr("font-size", "10px")
                .attr("font-family", "calibri");

            svg.append('text')
                .attr('x', xScale(parseFloat(each.c_mode) + 0.2))
                .attr('y', y2Scale(rateYpos + i * 0.4 + 0.2))
                .text(floatFormatter(each.b_mode))
                .attr('fill', colorScale(study2outgroup))
                .attr("font-size", "10px")
                .attr("font-family", "calibri");
        });
    }

    // add the vertical lines
    /* // Define the vertical line data
    var verticalLineData = InputData.vlines;

    // Append the vertical lines to the SVG
    if (verticalLineData.length > 0) {
        svg.selectAll(".vertical-line")
            .data(verticalLineData)
            .enter()
            .append("line")
            .attr("class", "vertical-line")
            .attr("x1", function (d) { return xScale(d); })
            .attr("x2", function (d) { return xScale(d); })
            .attr("y1", topPadding)
            .attr("y2", height - bottomPadding)
            .attr("stroke", "orange")
            .attr("stroke-width", 2)
            .attr("stroke-dasharray", "5,5");
    } */

    tippy(".rect bar", { trigger: "mouseenter", followCursor: "initial", delay: [tooltipDelay, null] });

    downloadSVG("ksPlotRateDownload",
        plotId,
        plotId + ".svg"
    )
}

function kernelDensityEstimator(kernel, X) {
    return function (V) {
        return X.map(function (x) {
            return [x, d3.mean(V, function (v) { return kernel(x - v); })];
        });
    };
}

function kernelEpanechnikov(k) {
    return function (v) {
        return Math.abs(v /= k) <= 1 ? 0.75 * (1 - v * v) / k : 0;
    };
}

function kernelGaussian(scale) {
    return function (u) {
        return Math.exp(-0.5 * u * u) / Math.sqrt(2 * Math.PI) / scale;
    };
}

function mixBarDensityPlottingOld(InputData) {
    var plotId = InputData.plot_id;
    var KsInfo = convertShinyData(InputData.ks_bar_df);
    var rateCorrectionInfo = convertShinyData(InputData.rate_correction_df);
    var paralogSpecies = InputData.paralog_id;
    var KsXlimit = InputData.xlim;
    var KsYlimit = InputData.ylim;
    var KsY2limit = InputData.y2lim;
    var barOpacity = InputData.opacity;
    var inputColor = InputData.color;
    var height = InputData.height;
    var width = InputData.width;

    // console.log("rateCorrectionInfo", rateCorrectionInfo);

    var titles = [...new Set(KsInfo.map(d => d.title))];;
    const titleCount = titles.length;

    const colors = [
        "#9B3A4D", "#32AEEC", "#E2AE79", "#8E549E", "#EA7500",
        "#566CA5", "#D2352C", "#394A92", "#68AC57", "#F4C28F"
    ];

    const colorScale = d3.scaleOrdinal()
        .domain(KsInfo.map(function (d) { return d.title; }))
        .range(colors);

    // draw a wgd bar plot
    d3.select("#Wgd_plot_" + plotId).select("svg").remove();

    let topPadding = 50;
    let bottomPadding = 40;
    let leftPadding = 80;
    let rightPadding = 50;
    var tooltipDelay = 500;

    const svg = d3.select("#Wgd_plot_" + plotId)
        .append("svg")
        .attr("width", width)
        .attr("height", height);

    // Define the x and y scales
    var xScale = d3.scaleLinear()
        .domain([0, KsXlimit])
        .range([0 + leftPadding, width - rightPadding]);

    // Create the x and y axes
    var xtickValues = d3.range(0, KsXlimit + 1, 1);
    var xAxis = d3.axisBottom(xScale)
        .tickValues(xtickValues)
        .tickFormat(d3.format("d"));

    // Add the x and y axes to the SVG element
    svg.append("g")
        .attr("class", "axis axis--x")
        .attr("transform", `translate(0, ${ height - bottomPadding })`)
        .call(xAxis)
        .attr("font-size", "12px")
        .attr("font-family", "calibri");

    svg.append("g")
        .attr("class", "xTitle")
        .append("text")
        .attr("x", d3.mean([leftPadding - 30, width]))
        .attr("y", height - 10)
        .attr("text-anchor", "middle")
        .append("tspan")
        .attr("font-family", "times")
        .html("<tspan style='font-style: italic;'>K</tspan>")
        .style("font-size", "14px")
        .append("tspan")
        .text("s")
        .style("font-size", "12px")
        .attr("dx", "1px")
        .attr("dy", "2px");

    if (titleCount > 1) {
        svg.append("g")
            .attr("class", "yTitle")
            .append("text")
            .attr("y", d3.mean([topPadding, height - bottomPadding]))
            .attr("x", leftPadding - 50)
            .attr("text-anchor", "middle")
            .attr("font-size", "14px")
            .attr("font-family", "times")
            .attr("transform", function () {
                return `rotate(-90, ${ d3.select(this).attr("x") }, ${ d3.select(this).attr("y") })`;
            })
            .text("Number of retained duplicates");

        var yScale = d3.scaleLinear()
            .domain([0, KsYlimit])
            .range([height - bottomPadding, topPadding]);

        var ytickValues = d3.range(0, KsYlimit + 1, 500);
        var yAxis = d3.axisLeft(yScale)
            .tickValues(ytickValues);

        svg.append("g")
            .attr("class", "axis axis--y")
            .attr("transform", `translate(${ leftPadding - 5 }, 0)`)
            .call(yAxis)
            .attr("font-size", "12px")
            .attr("font-family", "calibri");

        var paralogData = KsInfo.filter(function (d) {
            var paralogSpeciesFile = paralogSpecies + ".ks";
            var paralogSpeciesAnchorsFile = paralogSpecies + ".ks_anchors";
            return (d.title === paralogSpeciesFile) || (d.title === paralogSpeciesAnchorsFile);
        });

        var barColorScale = d3.scaleOrdinal()
            .domain(paralogData.map(function (d) { return d.title.split(".")[0]; }))
            .range(["black", "#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "#9467bd"]); // Adjust the color range as needed

        var ksOpacity = 0.2;
        var anchorsOpacity = 0.5;

        svg.append("g")
            .attr("class", "rect bar")
            .selectAll("rect")
            .data(paralogData)
            .join("rect")
            .attr("id", (d) => "Ks_" + d.ks)
            .attr("x", function (d, i) { return xScale(d.ks) - width / 100 * 0.9; })
            .attr("y", function (d) { return yScale(d.x); })
            .attr("width", width / 100 * 1.35)
            .attr("height", function (d) { return height - bottomPadding - yScale(d.x); })
            .attr("fill", function (d) {
                var titlePrefix = d.title.split(".")[0];
                return barColorScale(titlePrefix); // Set color based on the title prefix
            })
            .attr("fill-opacity", function (d) {
                if (d.title.includes("ks_anchor")) {
                    return anchorsOpacity; // Set opacity for "ks_anchors" bars
                } else {
                    return ksOpacity;
                }
            })
            .attr("data-tippy-content", function (d) {
                // Tooltip content generation
                var xMatches = KsInfo.filter(function (item) { return item.ks === d.ks && item.title.startsWith(d.title.split(".")[0]); });
                xMatches.sort(function (a, b) { return b.x - a.x; });
                let content = "<font color='#ff7575'><i>K</i><sub>s</sub></font>: " + d.ks + "<br>";
                xMatches.forEach(function (match) {
                    content += "<font color='#00BB00'><i>" + match.title + "</i></font>: " + numFormatter(match.x) + "<br>";
                });
                return content;
            })
            .on("mouseover", function (event, d) {
                // Tippy tooltip initialization
                tippy(this, {
                    theme: "light",
                    placement: "top-start",
                    allowHTML: true,
                    animation: "scale",
                    delay: [1000, 0],
                    duration: [200, 200]
                });
            })
            .on("mouseout", function (event, d) {
                tippy.hideAll();
            });

        // Add a line for paralog species
        var line = d3.line()
            .x(function (d) { return xScale(d.ks); })
            .y(function (d) { return yScale(d.x); })
            .curve(d3.curveCatmullRom.alpha(0.8));

        // Group the data by title
        var groupedLineData = d3.group(paralogData, function (d) {
            return d.title;
        });

        // Draw separate lines for each group
        groupedLineData.forEach(function (dataGroup) {
            var stepSize = Math.ceil(dataGroup.length / 25);
            var reducedData = dataGroup.filter(function (d, i) {
                return i % stepSize === 0;
            });

            // console.log("reducedData", reducedData)
            svg.append("path")
                .datum(reducedData)
                .attr("class", "line")
                .attr("d", line)
                .attr("fill", "none")
                .attr("stroke", function (d) {
                    var titlePrefix = d[0].title.split(".")[0];
                    return barColorScale(titlePrefix);
                })
                .attr("stroke-width", 1.5)
                .attr("stroke-opacity", function (d) {
                    if (d[0].title.includes("ks_anchor")) {
                        return anchorsOpacity + 0.2;
                    } else {
                        return ksOpacity + 0.2;
                    }
                });
        });

        // add density plot for all comparsion
        var KsDensityInfo = convertShinyData(InputData.ks_density_df);
        // Define the kernel density estimator function
        function kernelDensityEstimator(kernel, X) {
            return function (V) {
                return X.map(function (x) {
                    return [x, d3.mean(V, function (v) { return kernel(x - v); })];
                });
            };
        }

        // Define the Epanechnikov kernel funciton
        function kernelEpanechnikov(k) {
            return function (v) {
                return Math.abs(v /= k) <= 1 ? 0.75 * (1 - v * v) / k : 0;
            };
        }

        // Define the Gaussian kernel function
        function kernelGaussian(scale) {
            return function (u) {
                return Math.exp(-0.5 * u * u) / Math.sqrt(2 * Math.PI) / scale;
            };
        }
        var kde = kernelDensityEstimator(kernelEpanechnikov(0.25), xScale.ticks(500));

        var groupedData = Array.from(d3.group(KsDensityInfo, d => d.title), ([key, values]) => ({ key, values }));
        groupedData = groupedData.filter(function (d) {
            var paralogSpeciesFile = paralogSpecies + ".ks";
            var paralogSpeciesAnchorsFile = paralogSpecies + ".ks_anchors";
            return (d.key !== paralogSpeciesFile) && (d.key !== paralogSpeciesAnchorsFile);
        });

        // Generate density data for each group
        var densityData = groupedData.map(function (d) {
            var density = kde(d.values.map(function (d) { return d.ks; }));
            return { key: d.key, density: density };
        });

        // Get the 95% CI of Ks peak from 100 iterations
        var iterations = 1000;
        var confidenceLevel = 0.95;
        var binWidth = 0.01;

        var confidenceIntervals = [];

        // Loop over each group in densityData
        densityData.forEach(function (group) {
            var groupConfidenceIntervals = [];

            for (var i = 0; i < iterations; i++) {
                var peakPosition = null;
                var peakArea = 0;

                var sampledValues = group.density.map(function (point) {
                    var randomIndex = Math.floor(Math.random() * group.density.length);
                    return group.density[randomIndex];
                });

                var peakPoint = sampledValues.reduce(function (prevPoint, currPoint) {
                    return currPoint[1] > prevPoint[1] ? currPoint : prevPoint;
                });

                var totalArea = sampledValues.reduce(function (sum, point) {
                    return sum + point[1] * binWidth;
                }, 0);

                var cumulativeArea = 0;
                var cutoffIndex = 0;
                while (cumulativeArea < totalArea * confidenceLevel) {
                    cumulativeArea += sampledValues[cutoffIndex][1] * binWidth;
                    cutoffIndex++;
                }

                if (peakPoint[0] >= sampledValues[cutoffIndex][0] && peakPoint[0] <= sampledValues[cutoffIndex - 1][0]) {
                    peakPosition = peakPoint[0];
                    peakArea = peakPoint[1] * binWidth;
                }

                groupConfidenceIntervals.push({ position: peakPosition, area: peakArea });
            }

            groupConfidenceIntervals = groupConfidenceIntervals.filter(function (peak) {
                return peak.position !== null;
            });

            var sortedPositions = groupConfidenceIntervals.map(function (peak) {
                return peak.position;
            }).sort(function (a, b) {
                return a - b;
            });
            var lowerBoundIndex = Math.floor((1 - confidenceLevel) / 2 * groupConfidenceIntervals.length);
            var upperBoundIndex = Math.ceil((1 + confidenceLevel) / 2 * groupConfidenceIntervals.length);
            var lowerBound = sortedPositions[lowerBoundIndex];
            var upperBound = sortedPositions[upperBoundIndex];

            confidenceIntervals.push({ group: group.key, confidenceInterval: [lowerBound, upperBound] });
        });

        var y2Scale = d3.scaleLinear()
            .domain([0, KsY2limit])
            .range([height - bottomPadding, topPadding])
        var y2tickValues = d3.range(0, KsY2limit + 0.1, 0.2);
        var y2Axis = d3.axisRight(y2Scale)
            .tickValues(y2tickValues)
        svg.append("g")
            .attr("class", "axis axis--y2")
            .attr("transform", `translate(${ width - rightPadding + 5 }, 0)`)
            .call(y2Axis)
            .attr("font-size", "12px")
            .attr("font-family", "calibri");

        svg.append("g")
            .attr("class", "y2Title")
            .append("text")
            .attr("y", d3.mean([topPadding, height - bottomPadding]))
            .attr("x", width - rightPadding + 50)
            .attr("text-anchor", "middle")
            .attr("font-size", "14px")
            .attr("font-family", "times")
            .attr("transform", function () {
                return `rotate(-90, ${ d3.select(this).attr("x") }, ${ d3.select(this).attr("y") })`;
            })
            .text("Ortholog Density");

        // Create the area generator
        var area = d3.area()
            .x(function (d) { return xScale(d[0]); })
            .y0(height - bottomPadding)
            .y1(function (d) { return y2Scale(d[1]); });

        // Append the areas for each group
        svg.selectAll(".area")
            .data(densityData)
            .enter()
            .append("path")
            .attr("class", "area path")
            .attr("d", function (d) { return area(d.density); })
            .style("fill", function (d) { return colorScale(d.key); })
            .attr("fill-opacity", barOpacity)
            .attr("data-tippy-content", (d, i) => {
                var maxDensity = d3.max(d.density, function (m) {
                    return m[1];
                });

                var maxDensityData = d.density.find(function (d) {
                    return d[1] === maxDensity;
                });

                var maxDensityKs = maxDensityData ? maxDensityData[0] : undefined;

                svg.append("line")
                    .attr("x1", xScale(maxDensityData[0]))
                    .attr("y1", y2Scale(0))
                    .attr("x2", xScale(maxDensityData[0]))
                    .attr("y2", y2Scale(KsY2limit))
                    .style("stroke", colorScale(d.key))
                    .style("stroke-width", "1.4")
                    .style("stroke-dasharray", "5, 5");

                var nintyfiveCI = confidenceIntervals[i].confidenceInterval;
                svg.append("rect")
                    .attr("x", xScale(nintyfiveCI[0]))
                    .attr("y", y2Scale(KsY2limit))
                    .attr("width", xScale(nintyfiveCI[1]) - xScale(nintyfiveCI[0]))
                    .attr("height", y2Scale(0) - 50)
                    .style("fill", colorScale(d.key))
                    .style("fill-opacity", 0.2)
                    .attr("data-tippy-content", function () {
                        var peakContent = "Peak: <span style='color: " + colorScale(d.key.replace(".ks", "")) + ";'>" + maxDensityKs + "</span><br>" +
                            "95% CIs: <span style='color: " + highlightColor + "; background-color: " + color + "';>" +
                            nintyfiveCI[0].toFixed(2) + " <--> " + nintyfiveCI[1].toFixed(2) + "</span>";
                        return peakContent;
                    })
                    .on("mouseover", function (event, d) {
                        tippy(this, {
                            theme: "light",
                            placement: "right",
                            allowHTML: true,
                            animation: "scale",
                            delay: [1000, 0],
                            duration: [200, 200],
                            followCursor: true,
                            offset: [-15, 15]
                        });
                    })
                    .on("mouseout", function (event, d) {
                        tippy.hideAll();
                    });

                var highlightColors = {
                    "red": "yellow",
                    "green": "cyan",
                    "blue": "magenta",
                    "yellow": "black",
                    "cyan": "orange",
                    "magenta": "lime",
                    "black": "white"
                };

                var color = colorScale(d.key);
                var highlightColor = highlightColors[color] || "white";
                var name = d.key.replace(/\d+/g, "");
                var content = "<span style='color: " + highlightColor + "; background-color: " + color + ";'>" + name + "</span> <br> Peak: <span style='color: red;'>" +
                    maxDensityKs + "</span> (Density: <span style='color: " + color + ";'>" + maxDensity.toFixed(2) + "</span>)<br>" +
                    "95% CIs: <span style='color: " + highlightColor + "; background-color: " + color + "';>" + nintyfiveCI[0].toFixed(2) + " <--> " + nintyfiveCI[1].toFixed(2) + "</span>";

                return content;
            })
            .on("mouseover", function (event, d) {
                tippy(this, {
                    theme: "light",
                    placement: "right",
                    allowHTML: true,
                    animation: "scale",
                    delay: [1000, 0],
                    duration: [200, 200],
                    followCursor: true,
                    offset: [-15, 15]
                });
            })
            .on("mouseout", function (event, d) {
                tippy.hideAll();
            });

    } else {
        var yScale = d3.scaleLinear()
            .domain([0, KsYlimit])
            .range([height - bottomPadding, topPadding]);
        var ytickValues = d3.range(0, KsYlimit + 1, 500);
        var yAxis = d3.axisLeft(yScale)
            .tickValues(ytickValues)
            .tickSizeInner(-width + leftPadding + rightPadding)
            .tickSizeOuter(2);
        svg.append("g")
            .attr("class", "axis axis--y")
            .attr("transform", `translate(${ leftPadding - 5 }, 0)`)
            .call(yAxis)
            .attr("font-size", "12px")
            .attr("font-family", "calibri")
            .selectAll(".tick line")
            .style("z-index", "-100")
            .attr("stroke", "black")
            .attr("stroke-dasharray", "4 2")
            .attr("stroke-width", 0.46)
            .attr("stroke-opacity", 0.2)
            .filter(function (d) { return d === d3.max(ytickValues); })
            .remove()
            .filter(function (d) { return d === d3.min(ytickValues); })
            .remove();

        svg.append("g")
            .attr("class", "rect bar")
            .selectAll("rect")
            .data(KsInfo)
            .join("rect")
            .attr("id", (d) => "Ks_" + d.ks)
            .attr("x", function (d, i) { return xScale(d.ks) - width / 100 * 0.9; })
            .attr("y", function (d) { return yScale(d.x); })
            .attr("width", width / 100 * 1.35)
            .attr("height", function (d) { return height - bottomPadding - yScale(d.x); })
            .attr("fill", function () {
                if (inputColor !== null) {
                    return inputColor
                } else {
                    return colors[plotId - 1]
                }
            })
            .attr("fill-opacity", barOpacity)
            .attr("data-tippy-content", (d) => {
                const xMatches = KsInfo.filter((item) => item.ks === d.ks);
                xMatches.sort(function (a, b) {
                    return b.x - a.x;
                });
                let content = "<font color='#ff7575'><i>K</i><sub>s</sub></font>: " + d.ks + "<br>";
                xMatches.forEach((match) => {
                    content += "<font color='#00BB00'><i>" + match.title + "</i></font>: " + numFormatter(match.x) + "<br>";
                });
                return content;
            })
            .on("mouseover", function (event, d) {
                tippy(this, {
                    theme: "light",
                    placement: "top-start",
                    allowHTML: true,
                    animation: "scale",
                    delay: [1000, 0],
                    duration: [200, 200],
                });
            })
            .on("mouseout", function (event, d) {
                tippy.hideAll();
            });
    }

    // add the vertical lines
    /* // Define the vertical line data
    var verticalLineData = InputData.vlines;

    // Append the vertical lines to the SVG
    if (verticalLineData.length > 0) {
        svg.selectAll(".vertical-line")
            .data(verticalLineData)
            .enter()
            .append("line")
            .attr("class", "vertical-line")
            .attr("x1", function (d) { return xScale(d); })
            .attr("x2", function (d) { return xScale(d); })
            .attr("y1", topPadding)
            .attr("y2", height - bottomPadding)
            .attr("stroke", "orange")
            .attr("stroke-width", 2)
            .attr("stroke-dasharray", "5,5");
    } */

    // add the legend
    if (titleCount > 1) {
        var legendData = [...new Set(groupedData.map((d) => d.key))];
        // console.log(legendData);
        var legend = svg.append("g")
            .attr("class", "legend")
            .attr("transform", `translate(${ width - 200 }, 20)`);
        var legendItems = legend.selectAll(".legend-item")
            .data(legendData)
            .enter()
            .append("g")
            .attr("class", "legend-item")
            .attr("transform", function (d, i) { return `translate(0, ${ i * 20 })`; });

        // console.log(legendItems);

        legendItems.append("rect")
            .attr("x", 0)
            .attr("y", 0)
            .attr("width", 10)
            .attr("height", 10)
            .attr("fill", function (d) { return colorScale(d); })
            .attr("fill-opacity", barOpacity);

        legendItems.append("text")
            .attr("x", 20)
            .attr("y", 10)
            .text(function (d) { return d.replace(/\d+|\.ks/g, ""); });

        legend.selectAll("text")
            .attr("font-family", "calibri")
            .attr("font-size", "12px")
            .attr("fill", "#333");

        d3.select("#Wgd_plot_correct_" + plotId).select("svg").remove();
        /*         // Clone the existing SVG and modify the ID
                function clone(selector) {
                    var node = d3.select(selector).node();
                    return d3.select(node.cloneNode(true));
                }
        
                var correctSvg = clone("#Wgd_plot_" + plotId); //.attr("transform", "translate(120,100)");
                correctSvg.attr("id", "#Wgd_plot_correct_" + plotId);
                // Append the new SVG to the desired location
                d3.select("#Wgd_plot_correct_" + plotId)
                    .node()
                    .appendChild(correctSvg.node()); */

        // Add the title of the original figure
        /* svg.append("g")
            .attr("class", "figureTitle")
            .append("text")
            .attr("y", 10)
            .attr("x", leftPadding + 145)
            .attr("text-anchor", "middle")
            .attr("font-size", "14px")
            .attr("font-family", "times")
            .html("")
            .append("tspan")
            .attr("font-weight", "bold")
            .attr("font-family", "times")
            .attr("fill", "#00AEAE")
            .text("Original ")
            .append("tspan")
            .attr("font-style", "italic")
            .text("K")
            .append("tspan")
            .attr("baseline-shift", "sub")
            .text("s")
            .attr("dy", "-5px")
            .append("tspan")
            .attr("font-weight", "normal")
            .attr("font-style", "normal")
            //.attr("fill", "black")
            .text(" Distribution Plot")
            .attr("dy", "5px"); */
        // Add the title of the correct figure
        /* correctSvg.append("g")
            .attr("class", "figureTitle")
            .append("text")
            .attr("y", 10)
            .attr("x", leftPadding + 45)
            .attr("text-anchor", "middle")
            .attr("font-size", "14px")
            .attr("font-family", "times")
            .html("Corrected <b><i>K</b></i><sub>s</sub> Distribution Plot"); */

    } else {
        var legendData = [...new Set(KsInfo.map((d) => d.title))];
        var legend = svg.append("g")
            .attr("class", "legend")
            .attr("transform", `translate(${ width - 200 }, 20)`);

        var legendItems = legend.selectAll(".legend-item")
            .data(legendData.map(function (d) {
                return d.replace(/\d+/g, "")
            }))
            .enter()
            .append("g")
            .attr("class", "legend-item")
            .attr("transform", function (d, i) { return `translate(0, ${ i * 20 })`; });
        legendItems.append("rect")
            .attr("x", 0)
            .attr("y", 0)
            .attr("width", 10)
            .attr("height", 10)
            .attr("fill", function () {
                if (inputColor !== null) {
                    return inputColor
                } else {
                    return colors[plotId - 1]
                }
            })
            .attr("opacity", barOpacity);
        legendItems.append("text")
            .attr("x", 20)
            .attr("y", 10)
            .text(function (d) { return d; });

        legend.selectAll("text")
            .attr("font-family", "calibri")
            .attr("font-size", "12px")
            .attr("fill", "#333");

    }

    tippy(".rect bar", { trigger: "mouseenter", followCursor: "initial", delay: [tooltipDelay, null] });

    if (titleCount > 1) {
        downloadSVG("ks_download_correct_" + plotId,
            "Wgd_plot_correct_" + plotId,
            "corrected_Ks_" + plotId + ".svg"
        )
    }
    downloadSVG("ks_download_" + plotId,
        "Wgd_plot_" + plotId,
        "Ks_" + plotId + ".svg"
    )
}

Shiny.addCustomMessageHandler("Paralog_Bar_Plotting", MultipleBarPlotting);
function MultipleBarPlottingV2(InputData) {
    var plotId = InputData.plot_id;
    var KsInfo = convertShinyData(InputData.ks_bar_df);
    var paralogSpecies = InputData.paralog_id;
    var KsXlimit = InputData.xlim;
    var KsYlimit = InputData.ylim;
    var barOpacity = InputData.opacity;
    var height = InputData.height;
    var width = InputData.width;
    // console.log("KsInfo", KsInfo);

    var titles = [...new Set(KsInfo.map(d => d.title))];
    var tmpList = titles.map(element => element.replace(/\.ks(_anchors)?$/, ''));
    var speciesList = [...new Set(tmpList)];
    const titleCount = titles.length;
    // console.log(titles);
    // console.log(speciesList);
    // console.log(titleCount);

    const colors = [
        "#9B3A4D", "#32AEEC", "#E2AE79", "#8E549E", "#EA7500",
        "#566CA5", "#D2352C", "#394A92", "#68AC57", "#F4C28F"
    ];

    // draw a wgd bar plot
    d3.select("#" + plotId).select("svg").remove();

    let topPadding = 50;
    let bottomPadding = 40;
    let leftPadding = 80;
    let rightPadding = 50;
    var tooltipDelay = 500;

    const svg = d3.select("#" + plotId)
        .append("svg")
        .attr("width", width)
        .attr("height", height);

    var xScale = d3.scaleLinear()
        .domain([0, KsXlimit])
        .range([0 + leftPadding, width - rightPadding]);

    var xtickValues = d3.range(0, KsXlimit + 1, 1);
    var xAxis = d3.axisBottom(xScale)
        .tickValues(xtickValues)
        .tickFormat(d3.format("d"));

    svg.append("g")
        .attr("class", "axis axis--x")
        .attr("transform", `translate(0, ${ height - bottomPadding })`)
        .call(xAxis)
        .attr("font-size", "12px")
        .attr("font-family", "calibri");

    svg.append("g")
        .attr("class", "xTitle")
        .append("text")
        .attr("x", d3.mean([leftPadding - 30, width]))
        .attr("y", height - 10)
        .attr("text-anchor", "middle")
        .append("tspan")
        .attr("font-family", "times")
        .html("<tspan style='font-style: italic;'>K</tspan>")
        .style("font-size", "14px")
        .append("tspan")
        .text("s")
        .style("font-size", "12px")
        .attr("dx", "1px")
        .attr("dy", "2px");

    svg.append("g")
        .attr("class", "yTitle")
        .append("text")
        .attr("y", d3.mean([topPadding, height - bottomPadding]))
        .attr("x", leftPadding - 45)
        .attr("text-anchor", "middle")
        .attr("font-size", "14px")
        .attr("font-family", "times")
        .attr("transform", function () {
            return `rotate(-90, ${ d3.select(this).attr("x") }, ${ d3.select(this).attr("y") })`;
        })
        .text("Number of retained duplicates");

    var yScale = d3.scaleLinear()
        .domain([0, KsYlimit])
        .range([height - bottomPadding, topPadding]);

    var ytickValues = d3.range(0, KsYlimit + 1, 500);
    var yAxis = d3.axisLeft(yScale)
        .tickValues(ytickValues);

    svg.append("g")
        .attr("class", "axis axis--y")
        .attr("transform", `translate(${ leftPadding - 5 }, 0)`)
        .call(yAxis)
        .attr("font-size", "12px")
        .attr("font-family", "calibri");

    if (titleCount > 1) {
        var paralogData = KsInfo.filter(function (d) {
            var paralogSpeciesFile = paralogSpecies + ".ks";
            var paralogSpeciesAnchorsFile = paralogSpecies + ".ks_anchors";
            return (d.title === paralogSpeciesFile) || (d.title === paralogSpeciesAnchorsFile);
        });

        var barColorScale = d3.scaleOrdinal()
            .domain(paralogData.map(function (d) { return d.title.split(".")[0]; }))
            .range(["black", "#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "#9467bd"]); // Adjust the color range as needed

        var ksOpacity = 0.2;
        var anchorsOpacity = 0.5;

        svg.append("g")
            .attr("class", "rect bar")
            .selectAll("rect")
            .data(paralogData)
            .join("rect")
            .attr("id", (d) => "Ks_" + d.ks)
            .attr("x", function (d, i) { return xScale(d.ks) - width / 100 * 0.9; })
            .attr("y", function (d) { return yScale(d.x); })
            .attr("width", width / 100 * 1.35)
            .attr("height", function (d) { return height - bottomPadding - yScale(d.x); })
            .attr("fill", function (d) {
                var titlePrefix = d.title.split(".")[0];
                return barColorScale(titlePrefix);
            })
            .attr("fill-opacity", function (d) {
                if (d.title.includes("ks_anchor")) {
                    return anchorsOpacity;
                } else {
                    return ksOpacity;
                }
            })
            .attr("data-tippy-content", function (d) {
                // Tooltip content generation
                var xMatches = KsInfo.filter(function (item) {
                    return item.ks === d.ks && item.title.startsWith(d.title.split(".")[0]);
                });
                xMatches.sort(function (a, b) { return b.x - a.x; });
                let content = "<font color='#ff7575'><i>K</i><sub>s</sub></font>: " + d.ks + "<br>";
                xMatches.forEach(function (match) {
                    content += "<font color='#00BB00'><i>" + match.title + "</i></font>: " + numFormatter(match.x) + "<br>";
                });
                return content;
            })
            .on("mouseover", function (event, d) {
                // Tippy tooltip initialization
                tippy(this, {
                    theme: "light",
                    placement: "top-start",
                    allowHTML: true,
                    animation: "scale",
                    delay: [1000, 0],
                    duration: [200, 200]
                });
            })
            .on("mouseout", function (event, d) {
                tippy.hideAll();
            });

        // Add a line for paralog species
        var line = d3.line()
            .x(function (d) { return xScale(d.ks); })
            .y(function (d) { return yScale(d.x); })
            .curve(d3.curveCatmullRom.alpha(0.8));

        // Group the data by title
        var groupedLineData = d3.group(paralogData, function (d) {
            return d.title;
        });

        // Draw separate lines for each group
        groupedLineData.forEach(function (dataGroup) {
            var stepSize = Math.ceil(dataGroup.length / 25);
            var reducedData = dataGroup.filter(function (d, i) {
                return i % stepSize === 0;
            });

            svg.append("path")
                .datum(reducedData)
                .attr("class", "line")
                .attr("d", line)
                .attr("fill", "none")
                .attr("stroke", function (d) {
                    var titlePrefix = d[0].title.split(".")[0];
                    return barColorScale(titlePrefix);
                })
                .attr("stroke-width", 1.5)
                .attr("stroke-opacity", function (d) {
                    if (d[0].title.includes("ks_anchor")) {
                        return anchorsOpacity + 0.2;
                    } else {
                        return ksOpacity + 0.2;
                    }
                });
        });

        var legendData = [...new Set(KsInfo.map((d) => d.title))];
        var legend = svg.append("g")
            .attr("class", "legend")
            .attr("transform", `translate(${ width - 200 }, 20)`);
        var legendItems = legend.selectAll(".legend-item")
            .data(legendData)
            .enter()
            .append("g")
            .attr("class", "legend-item")
            .attr("transform", function (d, i) { return `translate(0, ${ i * 20 })`; });

        // console.log(legendItems);

        legendItems.append("rect")
            .attr("x", 0)
            .attr("y", 0)
            .attr("width", 10)
            .attr("height", 10)
            .attr("fill", function (d) {
                var titlePrefix = d.split(".")[0];
                return barColorScale(titlePrefix);
            })
            .attr("fill-opacity", function (d) {
                if (d.includes("ks_anchor")) {
                    return anchorsOpacity;
                } else {
                    return ksOpacity;
                }
            });

        legendItems.append("text")
            .attr("x", 20)
            .attr("y", 10)
            .text(function (d) { return d.replace(/\d+|\.ks/g, ""); });

        legend.selectAll("text")
            .attr("font-family", "calibri")
            .attr("font-size", "12px")
            .attr("fill", "#333");

        d3.select("#Wgd_plot_correct_" + plotId).select("svg").remove();
        // Add the title of the figure
        svg.append("g")
            .attr("class", "figureTitle")
            .append("text")
            .attr("y", 10)
            .attr("x", leftPadding + 145)
            .attr("text-anchor", "middle")
            .attr("font-size", "14px")
            .attr("font-family", "times")
            .html("")
            .append("tspan")
            .attr("font-weight", "bold")
            .attr("font-family", "times")
            .attr("fill", "#8E549E")
            .text("Paralogous ")
            .append("tspan")
            .attr("font-style", "italic")
            .text("K")
            .append("tspan")
            .attr("baseline-shift", "sub")
            .text("s")
            .attr("dy", "-5px")
            .append("tspan")
            .attr("font-weight", "normal")
            .attr("font-style", "normal")
            //.attr("fill", "black")
            .text(" Distribution Plot")
            .attr("dy", "5px");

    } else {
        var yScale = d3.scaleLinear()
            .domain([0, KsYlimit])
            .range([height - bottomPadding, topPadding]);
        var ytickValues = d3.range(0, KsYlimit + 1, 500);
        var yAxis = d3.axisLeft(yScale)
            .tickValues(ytickValues)
            .tickSizeInner(-width + leftPadding + rightPadding)
            .tickSizeOuter(2);
        svg.append("g")
            .attr("class", "axis axis--y")
            .attr("transform", `translate(${ leftPadding - 5 }, 0)`)
            .call(yAxis)
            .attr("font-size", "12px")
            .attr("font-family", "calibri")
            .selectAll(".tick line")
            .style("z-index", "-100")
            .attr("stroke", "black")
            .attr("stroke-dasharray", "4 2")
            .attr("stroke-width", 0.46)
            .attr("stroke-opacity", 0.2)
            .filter(function (d) { return d === d3.max(ytickValues); })
            .remove()
            .filter(function (d) { return d === d3.min(ytickValues); })
            .remove();

        svg.append("g")
            .attr("class", "rect bar")
            .selectAll("rect")
            .data(KsInfo)
            .join("rect")
            .attr("id", (d) => "Ks_" + d.ks)
            .attr("x", function (d, i) { return xScale(d.ks) - width / 100 * 0.9; })
            .attr("y", function (d) { return yScale(d.x); })
            .attr("width", width / 100 * 1.35)
            .attr("height", function (d) { return height - bottomPadding - yScale(d.x); })
            .attr("fill", function () {
                if (inputColor !== null) {
                    return inputColor
                } else {
                    return colors[plotId - 1]
                }
            })
            .attr("fill-opacity", barOpacity)
            .attr("data-tippy-content", (d) => {
                const xMatches = KsInfo.filter((item) => item.ks === d.ks);
                xMatches.sort(function (a, b) {
                    return b.x - a.x;
                });
                let content = "<font color='#ff7575'><i>K</i><sub>s</sub></font>: " + d.ks + "<br>";
                xMatches.forEach((match) => {
                    content += "<font color='#00BB00'><i>" + match.title + "</i></font>: " + numFormatter(match.x) + "<br>";
                });
                return content;
            })
            .on("mouseover", function (event, d) {
                tippy(this, {
                    theme: "light",
                    placement: "top-start",
                    allowHTML: true,
                    animation: "scale",
                    delay: [1000, 0],
                    duration: [200, 200],
                });
            })
            .on("mouseout", function (event, d) {
                tippy.hideAll();
            });
    }

    // add the legend
    /* if (titleCount = 1) {
        var legendData = [...new Set(KsInfo.map((d) => d.title))];
        var legend = svg.append("g")
            .attr("class", "legend")
            .attr("transform", `translate(${ width - 200 }, 20)`);

        var legendItems = legend.selectAll(".legend-item")
            .data(legendData.map(function (d) {
                return d.replace(/\d+/g, "")
            }))
            .enter()
            .append("g")
            .attr("class", "legend-item")
            .attr("transform", function (d, i) { return `translate(0, ${ i * 20 })`; });
        legendItems.append("rect")
            .attr("x", 0)
            .attr("y", 0)
            .attr("width", 10)
            .attr("height", 10)
            .attr("fill", function () {
                if (inputColor !== null) {
                    return inputColor
                } else {
                    return colors[plotId - 1]
                }
            })
            .attr("opacity", barOpacity);
        legendItems.append("text")
            .attr("x", 20)
            .attr("y", 10)
            .text(function (d) { return d; });

        legend.selectAll("text")
            .attr("font-family", "calibri")
            .attr("font-size", "12px")
            .attr("fill", "#333");

    } */

    tippy(".rect bar", { trigger: "mouseenter", followCursor: "initial", delay: [tooltipDelay, null] });

    if (titleCount > 1) {
        downloadSVG("ks_download_correct_" + plotId,
            "Wgd_plot_correct_" + plotId,
            "corrected_Ks_" + plotId + ".svg"
        )
    }
    downloadSVG("ks_download_" + plotId,
        "Wgd_plot_" + plotId,
        "Ks_" + plotId + ".svg"
    )
}

function MultipleBarPlotting(InputData) {
    var plotId = InputData.plot_id;
    var KsInfo = convertShinyData(InputData.ks_bar_df);
    var KsMclust = convertShinyData(InputData.mclust_df);
    var KsSizerInfo = InputData.sizer_list;
    var KsXlimit = InputData.xlim;
    var barOpacity = InputData.opacity;
    var height = InputData.height;
    var width = InputData.width;
    var namesInfo = convertShinyData(InputData.species_list);
    /*     console.log("KsInfo", KsInfo);
        console.log("namesInfo", namesInfo);
        console.log("KsMclust", KsMclust);
        console.log("SizerInfo", KsSizerInfo); */

    var titles = [...new Set(KsInfo.map(d => d.title))];
    var tmpList = titles.map(element => element.replace(/\.ks(_anchors)?$/, ''));
    var speciesList = [...new Set(tmpList)];
    var numRows = Math.ceil(speciesList.length / 2);
    const titleCount = titles.length;

    const colors = [
        "#9B3A4D", "#32AEEC", "#E2AE79", "#8E549E", "#EA7500",
        "#566CA5", "#D2352C", "#394A92", "#68AC57", "#F4C28F"
    ];

    d3.select("#" + plotId).selectAll("svg").remove();
    d3.selectAll("body svg").remove();

    var subplotWidth = width / 2;
    var subplotHeight = height / numRows;

    var svg = d3.select("#" + plotId)
        .append("svg")
        .attr("width", width)
        .attr("height", height);

    speciesList.forEach((species, index) => {
        var nameInfo = namesInfo.find(function (info) {
            return info.informal_name === species;
        });
        if (nameInfo) {
            var latinName = nameInfo.latin_name;
        }
        var paralogData = KsInfo.filter(function (d) {
            var paralogSpeciesFile = species + ".ks";
            var paralogSpeciesAnchorsFile = species + ".ks_anchors";
            return (d.title === paralogSpeciesFile) || (d.title === paralogSpeciesAnchorsFile);
        });

        var eachKsMclustData = KsMclust.filter(function (d) {
            var titleParts = d.title.split(".");
            return titleParts[0] === species;
        })

        var maxHeight = d3.max(paralogData, function (d) { return d.x; });

        // Calculate the row and column position for the current subplot
        var row = Math.floor(index / 2);
        var col = index % 2;

        // Calculate the translate values for the subplot position
        var translateX = col * subplotWidth;
        var translateY = row * subplotHeight;

        // Create a new group element for the subplot with a unique ID
        var subplot = svg.append("g")
            .attr("id", "subplot-bar-" + species)
            .attr("transform", "translate(" + translateX + ", " + translateY + ")");

        barSubplot(paralogData, eachKsMclustData, latinName, subplot, subplotWidth, subplotHeight * (3 / 4), KsXlimit, maxHeight, barOpacity);
        // console.log("Bar Plot Done: ", species);

        var sizerPlot = KsSizerInfo[species + ".ks_anchors"];

        // console.log("sizerPlot", sizerPlot);

        if (sizerPlot) {
            // var sizerTranslateY = translateY + (3 * subplotHeight) / 4; // Start position for SiZer plot
            // var sizerTranslateY = translateY + (3 * subplotHeight) / 4 + row * subplotHeight;
            var sizerTranslateY = translateY + subplotHeight * (3 / 4);
            var sizerHeight = subplotHeight / 4;

            // console.log(species, "row", row, "subplotHeight", subplotHeight, "translateY", translateY, "sizerTranslateY", sizerTranslateY)

            var sizerGroup = svg.append("g")
                .attr("id", "subplot-sizer-" + species)
                .attr("transform", "translate(" + translateX + ", " + sizerTranslateY + ")");

            siZerPlot(sizerPlot, sizerGroup, subplotWidth, sizerHeight, KsXlimit);
        }
    });

    downloadSVG("ksPlotParalogousDownload",
        plotId,
        "Paralogous_Ks.svg"
    )
}

function barSubplot(paralogData, eachKsMclustData, latinName, subplot, subplotWidth, subplotHeight, KsXlimit, maxHeight, barOpacity) {
    let topPadding = 50;
    let bottomPadding = 40;
    let leftPadding = 80;
    let rightPadding = 30;

    // console.log("latinName", latinName);
    // console.log("paralogData", paralogData);
    // console.log("eachKsMclustData", eachKsMclustData);

    var barColorScale = d3.scaleOrdinal()
        .domain(paralogData.map(function (d) { return d.title.split(".")[0]; }))
        .range(["black", "#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "#9467bd"]);

    var xScale = d3.scaleLinear()
        .domain([0, KsXlimit])
        .range([0 + leftPadding, subplotWidth - rightPadding]);

    var xtickValues = d3.range(0, KsXlimit + 1, 1);
    var xAxis = d3.axisBottom(xScale)
        .tickValues(xtickValues)
        .tickFormat(d3.format("d"));

    subplot.append("g")
        .attr("class", "axis axis--x")
        .attr("transform", `translate(0, ${ subplotHeight - bottomPadding })`)
        .call(xAxis)
        .attr("font-size", "12px")
        .attr("font-family", "calibri");

    subplot.append("g")
        .attr("class", "xTitle")
        .append("text")
        .attr("x", d3.mean([leftPadding - 30, subplotWidth]))
        .attr("y", subplotHeight - 10)
        .attr("text-anchor", "middle")
        .append("tspan")
        .attr("font-family", "times")
        .html("<tspan style='font-style: italic;'>K</tspan>")
        .style("font-size", "14px")
        .append("tspan")
        .text("s")
        .style("font-size", "12px")
        .attr("dx", "1px")
        .attr("dy", "2px");

    subplot.append("g")
        .attr("class", "yTitle")
        .append("text")
        .attr("y", d3.mean([topPadding, subplotHeight - bottomPadding]))
        .attr("x", leftPadding - 50)
        .attr("text-anchor", "middle")
        .attr("font-size", "14px")
        .attr("font-family", "times")
        .attr("transform", function () {
            return `rotate(-90, ${ d3.select(this).attr("x") }, ${ d3.select(this).attr("y") })`;
        })
        .text("Number of retained duplicates");

    // console.log("maxHeight", maxHeight);
    var KsYlimit = Math.ceil(maxHeight / 500) * 500;
    // console.log("KsYlimit", KsYlimit);

    var yScale = d3.scaleLinear()
        .domain([0, KsYlimit])
        .range([subplotHeight - bottomPadding, topPadding]);

    var ytickValues = d3.range(0, KsYlimit + 1, 500);
    var yAxis = d3.axisLeft(yScale)
        .tickValues(ytickValues);

    subplot.append("g")
        .attr("class", "axis axis--y")
        .attr("transform", `translate(${ leftPadding - 5 }, 0)`)
        .call(yAxis)
        .attr("font-size", "12px")
        .attr("font-family", "calibri");

    var barWidth;
    if (paralogData.some(d => d.title.includes("ks_anchor"))) {
        barWidth = ((xScale.range()[1] - xScale.range()[0]) / paralogData.length) * 1.75;
    } else {
        barWidth = (xScale.range()[1] - xScale.range()[0]) / paralogData.length * 1.75 / 2;
    }

    var ksOpacity = 0.2;
    var anchorsOpacity = 0.3;

    subplot.append("g")
        .attr("class", "rect bar")
        .selectAll("rect")
        .data(paralogData)
        .join("rect")
        .attr("id", (d) => "Ks_" + d.ks)
        .attr("x", function (d, i) { return xScale(d.ks) - subplotWidth / 100 * 0.9; })
        .attr("y", function (d) { return yScale(d.x); })
        //.attr("width", subplotWidth / 100 * 1.35)
        .attr("width", barWidth)
        .attr("height", function (d) { return subplotHeight - bottomPadding - yScale(d.x); })
        .attr("fill", function (d) {
            var titlePrefix = d.title.split(".")[0];
            return barColorScale(titlePrefix);
        })
        .attr("fill-opacity", function (d) {
            if (d.title.includes("ks_anchor")) {
                return anchorsOpacity;
            } else {
                return ksOpacity;
            }
        })
        .attr("data-tippy-content", function (d) {
            // Tooltip content generation
            var xMatches = paralogData.filter(function (item) {
                return item.ks === d.ks && item.title.startsWith(d.title.split(".")[0]);
            });
            xMatches.sort(function (a, b) { return b.x - a.x; });
            let content = "<font color='#ff7575'><i>K</i><sub>s</sub></font>: " + d.ks + "<br>";
            xMatches.forEach(function (match) {
                content += "<font color='#00BB00'><i>" + match.title + "</i></font>: " + numFormatter(match.x) + "<br>";
            });
            return content;
        })
        .on("mouseover", function (event, d) {
            // Tippy tooltip initialization
            tippy(this, {
                theme: "light",
                placement: "top-start",
                allowHTML: true,
                animation: "scale",
                delay: [1000, 0],
                duration: [200, 200]
            });
        })
        .on("mouseout", function (event, d) {
            tippy.hideAll();
        });

    var line = d3.line()
        .x(function (d) { return xScale(d.ks); })
        .y(function (d) { return yScale(d.x); })
        .curve(d3.curveCatmullRom.alpha(0.9));

    // Group the data by title
    var groupedLineData = d3.group(paralogData, function (d) {
        return d.title;
    });

    // Draw separate lines for each group
    groupedLineData.forEach(function (dataGroup) {
        var stepSize = Math.ceil(dataGroup.length / 25);
        var reducedData = dataGroup.filter(function (d, i) {
            return i % stepSize === 0;
        });

        subplot.append("path")
            .datum(reducedData)
            .attr("class", "line")
            .attr("d", line)
            .attr("fill", "none")
            .attr("stroke", function (d) {
                var titlePrefix = d[0].title.split(".")[0];
                return barColorScale(titlePrefix);
            })
            .attr("stroke-width", 1.5)
            .attr("stroke-opacity", function (d) {
                if (d[0].title.includes("ks_anchor")) {
                    return anchorsOpacity + 0.2;
                } else {
                    return ksOpacity + 0.2;
                }
            });
    });

    const colors = ["blue", "red", "green", "orange", "purple"];

    const componentData = eachKsMclustData;
    // console.log("componentData", componentData);

    // Function to calculate the standard deviation
    function calculateStandardDeviation(data) {
        const n = data.length;
        const mean = data.reduce((sum, value) => sum + value, 0) / n;
        const variance = data.reduce((sum, value) => sum + (value - mean) ** 2, 0) / n;
        const standardDeviation = Math.sqrt(variance);
        return standardDeviation;
    }

    const propZScores = componentData.map((d) => {
        const prop = d.prop;
        const mean = d.mean;
        const sigmasq = d.sigmasq;
        const zScore = (prop - mean) / Math.sqrt(sigmasq);
        return Math.abs(zScore);
    });

    const thresholdMultiplier = 2;
    const propThreshold = thresholdMultiplier * calculateStandardDeviation(propZScores);

    const filteredComponentData = componentData.filter((d, index) => {
        const propZScore = propZScores[index];
        return propZScore <= propThreshold && d.mode < KsXlimit;
    });

    const colorModeScale = d3.scaleOrdinal()
        .domain(filteredComponentData.map((d, i) => i))
        .range(["red", "blue", "green", "orange", "purple"]);

    const paths = subplot.selectAll(".line")
        .data(filteredComponentData);

    var ySimHeight;
    if (paralogData.some(d => d.title.includes("ks_anchors"))) {
        ySimHeight = d3.max(paralogData.filter(d => d.title.includes("ks_anchors")), function (d) { return d.x; });
    } else {
        ySimHeight = d3.max(paralogData, function (d) { return d.x; });
    }

    paths.enter()
        .append("path")
        .attr("class", "line")
        .merge(paths)
        .attr("d", (d) => {
            const prop = d.prop;
            const mean = d.mean;
            const sigmasq = d.sigmasq;
            const sim = d3.range(0.05, KsXlimit, 0.01).map((x) => ({
                x,
                y: ySimHeight * prop * logNormalPDF(x, mean, Math.sqrt(sigmasq)),
            }));
            return d3.line()
                .x((d) => xScale(d.x))
                .y((d) => yScale(d.y))(sim);
        })
        .style("stroke", (d, i) => colorModeScale(i))
        .style("stroke-width", 2.6)
        .style("fill", "none")
        .attr("data-tippy-content", function (d, i) {
            const prop = floatFormatter(d.prop);
            const mean = floatFormatter(d.mean);
            const sigmasq = floatFormatter(d.sigmasq);
            const mode = floatFormatter(d.mode);
            content = "<b>Mode: " + mode + "</b><br>Prop: " + prop +
                "<br>Mean: " + mean;
            return content;
        })
        .on("mouseover", function (event, d) {
            tippy(this, {
                theme: "light",
                placement: "top-start",
                allowHTML: true,
                animation: "scale",
                delay: [1000, 0],
                duration: [200, 200]
            });
        })
        .on("mouseout", function (event, d) {
            tippy.hideAll();
        });

    // Remove unnecessary paths
    paths.exit().remove();

    var legendData = [...new Set(paralogData.map((d) => d.title))];

    // Merge the two legends
    const mergedLegend = subplot.append("g")
        .attr("class", "legend")
        .attr("transform", `translate(${ subplotWidth - 120 }, 30)`);

    // Add mode value to the legend
    const modeLegendItems = mergedLegend.selectAll(".mode-legend-item")
        .data(filteredComponentData)
        .enter()
        .append("g")
        .attr("class", "mode-legend-item")
        .attr("transform", (d, i) => `translate(0, ${ (legendData.length + i) * 20 + 5 })`);

    modeLegendItems.append("line")
        .attr("x1", 0)
        .attr("y1", 10)
        .attr("x2", 20)
        .attr("y2", 10)
        .style("stroke", (d, i) => colorModeScale(i))
        .style("stroke-width", 2.6);

    modeLegendItems.append("text")
        .attr("x", 30)
        .attr("y", 15)
        .text((d) => `Mode: ${ floatFormatter(d.mode) }`)
        .attr("font-family", "calibri")
        .attr("font-size", "12px")
        .attr("fill", "#333");

    // Data legend
    const pairLegendItems = mergedLegend.selectAll(".pair-legend-item")
        .data(legendData)
        .enter()
        .append("g")
        .attr("class", "pair-legend-item")
        .attr("transform", (d, i) => `translate(0, ${ i * 20 })`);

    pairLegendItems.append("rect")
        .attr("x", 0)
        .attr("y", 10)
        .attr("width", 20)
        .attr("height", 10)
        .attr("fill", (d) => {
            const titlePrefix = d.split(".")[0];
            return barColorScale(titlePrefix);
        })
        .attr("fill-opacity", (d) => {
            if (d.includes("ks_anchor")) {
                return anchorsOpacity;
            } else {
                return ksOpacity;
            }
        });

    pairLegendItems.append("text")
        .attr("x", 30)
        .attr("y", 20)
        .text((d) => {
            if (d.includes("ks_anchor")) {
                return "Anchor pairs";
            } else {
                return "All pairs";
            }
        })
        .attr("font-family", "calibri")
        .attr("font-size", "12px")
        .attr("fill", "#333");

    // Add the title of the figure
    subplot.append("g")
        .attr("class", "figureTitle")
        .append("text")
        .text(latinName)
        .attr("y", 50)
        .attr("x", leftPadding + 145)
        .attr("text-anchor", "middle")
        .attr("font-size", "14px")
        .attr("font-family", "times")
        .attr("font-style", "italic")
        .attr("fill", "#8E549E");

}

function siZerPlot(data, svg, subplotWidth, sizerHeight, KsXlimit) {
    let topPadding = 50;
    let bottomPadding = 40;
    let leftPadding = 80;
    let rightPadding = 30;

    // console.log("sizer");
    // console.log(data);
    // Select data based on max Ks
    const chooseNum = KsXlimit * 100;
    const sizerSubset = data.sizer.slice(0, chooseNum);
    const mapSubset = data.map.slice(0, chooseNum);

    const svgHeight = sizerHeight;
    const rectWidth = (subplotWidth - leftPadding - rightPadding) / sizerSubset.length;
    const rectHeight = (svgHeight - bottomPadding) / data.bw.length;

    const colorScale = d3.scaleOrdinal()
        .domain([0, 1, 2, 3])
        .range(["grey", "purple", "blue", "red"]);

    const group = svg.selectAll("g")
        .data(mapSubset)
        .enter()
        .append("g")
        .attr("transform", (_, i) => `translate(${ i * rectWidth }, 0)`);

    group.selectAll("rect")
        .data((d) => d)
        .enter()
        .append("rect")
        .attr("x", leftPadding)
        .attr("y", (_, i) => svgHeight - bottomPadding - (i + 1) * rectHeight)
        .attr("width", rectWidth)
        .attr("height", rectHeight)
        .attr("fill", (d) => colorScale(d));

    svg.append("g")
        .attr("class", "xSizerTitle")
        .append("text")
        .attr("x", d3.mean([leftPadding - 30, subplotWidth]))
        .attr("y", svgHeight - 10)
        .attr("text-anchor", "middle")
        .append("tspan")
        .attr("font-family", "times")
        .html("<tspan style='font-style: italic;'>K</tspan>")
        .style("font-size", "14px")
        .append("tspan")
        .text("s")
        .style("font-size", "12px")
        .attr("dx", "1px")
        .attr("dy", "2px");

    svg.append("g")
        .attr("class", "ySizerTitle")
        .append("text")
        .attr("y", d3.mean([0, svgHeight - bottomPadding]))
        .attr("x", leftPadding - 50)
        .attr("text-anchor", "middle")
        .attr("font-family", "times")
        .attr("transform", function () {
            return `rotate(-90, ${ d3.select(this).attr("x") }, ${ d3.select(this).attr("y") })`;
        })
        .append("tspan")
        .style("font-size", "14px")
        .text("log")
        .append("tspan")
        .style("font-size", "8px")
        .text("10")
        .attr("dx", "1px")
        .attr("dy", "5px")
        .append("tspan")
        .style("font-size", "14px")
        .text("(h)");

    const bwMin = d3.min(data.bw);
    const bwMax = d3.max(data.bw);

    const yScale = d3.scaleLinear()
        .domain([bwMin, bwMax])
        .range([svgHeight - bottomPadding, 0]);

    /* const yAxis = d3.axisLeft(yScale)
        .tickValues([data.bw[0], 0, data.bw[data.bw.length - 1]])
        .tickFormat(d3.format(".1f")); */

    const yAxis = d3.axisLeft(yScale)
        .tickValues([-1.5, -1, -0.5, 0, 0.5])
        .tickFormat(d3.format(".1f"))
        .tickSizeInner(4)
        .tickSizeOuter(0);

    const yAxisGroup = svg.append("g")
        .attr("class", "axis sizer--y")
        .attr("transform", `translate(${ leftPadding }, 0)`)
        .call(yAxis)
        .attr("font-size", "10px")
        .attr("font-family", "calibri");
/* 
    yAxisGroup.selectAll(".tick line")
        .attr("transform", `translate(6, 0)`)
        .style("stroke", "black");
    
    yAxisGroup.selectAll(".tick text")
        .attr("transform", `translate(3, 0)`); */

    var xScale = d3.scaleLinear()
        .domain([0, KsXlimit])
        .range([0 + leftPadding, subplotWidth - rightPadding]);

    var xtickValues = d3.range(0, KsXlimit + 1, 1);
    var xAxis = d3.axisBottom(xScale)
        .tickValues(xtickValues)
        .tickFormat(d3.format("d"));

    svg.append("g")
        .attr("class", "axis axis--x")
        .attr("transform", `translate(0, ${ svgHeight - bottomPadding })`)
        .call(xAxis)
        .attr("font-size", "10px")
        .attr("font-family", "calibri");

    // Calculate the middle point of the plot
    const xMidpoint = KsXlimit / 2;

    // Calculate the line coordinates
    const lineRightData = data.bw.map((bw) => {
        const x = xMidpoint + Math.pow(10, bw);
        return { x, y: bw };
    });

    for (let i = 1; i < lineRightData.length - 1; i++) {
        const point1 = lineRightData[i];
        const point2 = lineRightData[i + 1];

        if (point1.x > KsXlimit) {
            break;
        }

        if (point2.x > KsXlimit) {
            const xIntercept = KsXlimit;
            const slope = (point2.y - point1.y) / (point2.x - point1.x);
            const yIntercept = point1.y + slope * (xIntercept - point1.x);

            svg.append("line")
                .attr("x1", xScale(point1.x))
                .attr("y1", yScale(point1.y))
                .attr("x2", xScale(xIntercept))
                .attr("y2", yScale(yIntercept))
                .attr("stroke", "white")
                .attr("stroke-width", 1.1)
                .style("stroke-dasharray", "4 2");

            break;
        }

        svg.append("line")
            .attr("x1", xScale(point1.x))
            .attr("y1", yScale(point1.y))
            .attr("x2", xScale(point2.x))
            .attr("y2", yScale(point2.y))
            .attr("stroke", "white")
            .attr("stroke-width", 1.1)
            .style("stroke-dasharray", "4 2");
    }

    const lineleftData = data.bw.map((bw) => {
        const x = xMidpoint - Math.pow(10, bw);
        return { x, y: bw };
    });

    for (let i = 1; i < lineleftData.length - 1; i++) {
        const point1 = lineleftData[i];
        const point2 = lineleftData[i + 1];

        if (point1.x < 0) {
            break;
        }

        if (point2.x < 0) {
            const xIntercept = 0;
            const slope = (point2.y - point1.y) / (point2.x - point1.x);
            const yIntercept = point1.y + slope * (xIntercept - point1.x);

            svg.append("line")
                .attr("x1", xScale(point1.x))
                .attr("y1", yScale(point1.y))
                .attr("x2", xScale(xIntercept))
                .attr("y2", yScale(yIntercept))
                .attr("stroke", "white")
                .attr("stroke-width", 1.1)
                .style("stroke-dasharray", "4 2");

            break;
        }

        svg.append("line")
            .attr("x1", xScale(point1.x))
            .attr("y1", yScale(point1.y))
            .attr("x2", xScale(point2.x))
            .attr("y2", yScale(point2.y))
            .attr("stroke", "white")
            .attr("stroke-width", 1.1)
            .style("stroke-dasharray", "4 2");
    }
}

function logNormalPDF(x, mean, sigma) {
    const exponent = -Math.pow(Math.log(x) - mean, 2) / (2 * Math.pow(sigma, 2));
    const coefficient = 1 / (x * sigma * Math.sqrt(2 * Math.PI));
    return coefficient * Math.exp(exponent);
}

Shiny.addCustomMessageHandler("Otholog_Density_Plotting", DensityPlotting);
function DensityPlotting(InputData) {
    var plotId = InputData.plot_id;
    var KsDensityInfo = convertShinyData(InputData.ks_density_df);
    var KsXlimit = InputData.xlim;
    var KsY2limit = InputData.ylim;
    var densityOpacity = InputData.opacity || 0.6;
    var height = InputData.height;
    var width = InputData.width;

    // console.log("KsDensity", KsDensityInfo);
    var titles = [...new Set(KsDensityInfo.map(d => d.title))];;
    const titleCount = titles.length;

    const colors = [
        "#32AEEC", "#E2AE79", "#8E549E", "#EA7500",
        "#D2352C", "#394A92", "#68AC57", "#F4C28F"
    ];

    const colorScale = d3.scaleOrdinal()
        .domain(KsDensityInfo.map(function (d) { return d.title; }))
        .range(colors);

    d3.select("#" + plotId).select("svg").remove();
    d3.selectAll("body svg").remove();

    let topPadding = 50;
    let bottomPadding = 40;
    let leftPadding = 80;
    let rightPadding = 50;
    var tooltipDelay = 500;

    const svg = d3.select("#" + plotId)
        .append("svg")
        .attr("width", width)
        .attr("height", height);

    var xScale = d3.scaleLinear()
        .domain([0, KsXlimit])
        .range([0 + leftPadding, width - rightPadding]);

    var xtickValues = d3.range(0, KsXlimit + 1, 1);
    var xAxis = d3.axisBottom(xScale)
        .tickValues(xtickValues)
        .tickFormat(d3.format("d"));

    svg.append("g")
        .attr("class", "axis axis--x")
        .attr("transform", `translate(0, ${ height - bottomPadding })`)
        .call(xAxis)
        .attr("font-size", "12px")
        .attr("font-family", "calibri");

    svg.append("g")
        .attr("class", "xTitle")
        .append("text")
        .attr("x", d3.mean([leftPadding - 30, width]))
        .attr("y", height - 10)
        .attr("text-anchor", "middle")
        .append("tspan")
        .attr("font-family", "times")
        .html("<tspan style='font-style: italic;'>K</tspan>")
        .style("font-size", "14px")
        .append("tspan")
        .text("s")
        .style("font-size", "12px")
        .attr("dx", "1px")
        .attr("dy", "2px");

    /* function kernelDensityEstimator(kernel, X) {
        return function (V) {
            return X.map(function (x) {
                return [x, d3.mean(V, function (v) { return kernel(x - v); })];
            });
        };
    }

    function kernelEpanechnikov(k) {
        return function (v) {
            return Math.abs(v /= k) <= 1 ? 0.75 * (1 - v * v) / k : 0;
        };
    } */

    var kde = kernelDensityEstimator(kernelEpanechnikov(0.25), xScale.ticks(500));

    var groupedData = Array.from(d3.group(KsDensityInfo, d => d.title), ([key, values]) => ({ key, values }));

    // Generate density data for each group
    var densityData = groupedData.map(function (d) {
        var density = kde(d.values.map(function (d) { return d.ks; }));
        return { key: d.key, density: density };
    });

    // Get the 95% CI of Ks peak from 100 iterations
    var iterations = 1000;
    var confidenceLevel = 0.95;
    var binWidth = 0.01;

    var confidenceIntervals = [];

    densityData.forEach(function (group) {
        var groupConfidenceIntervals = [];

        for (var i = 0; i < iterations; i++) {
            var peakPosition = null;
            var peakArea = 0;

            var sampledValues = group.density.map(function (point) {
                var randomIndex = Math.floor(Math.random() * group.density.length);
                return group.density[randomIndex];
            });

            var peakPoint = sampledValues.reduce(function (prevPoint, currPoint) {
                return currPoint[1] > prevPoint[1] ? currPoint : prevPoint;
            });

            var totalArea = sampledValues.reduce(function (sum, point) {
                return sum + point[1] * binWidth;
            }, 0);

            var cumulativeArea = 0;
            var cutoffIndex = 0;
            while (cumulativeArea < totalArea * confidenceLevel) {
                cumulativeArea += sampledValues[cutoffIndex][1] * binWidth;
                cutoffIndex++;
            }

            if (peakPoint[0] >= sampledValues[cutoffIndex][0] && peakPoint[0] <= sampledValues[cutoffIndex - 1][0]) {
                peakPosition = peakPoint[0];
                peakArea = peakPoint[1] * binWidth;
            }

            groupConfidenceIntervals.push({ position: peakPosition, area: peakArea });
        }

        groupConfidenceIntervals = groupConfidenceIntervals.filter(function (peak) {
            return peak.position !== null;
        });

        var sortedPositions = groupConfidenceIntervals.map(function (peak) {
            return peak.position;
        }).sort(function (a, b) {
            return a - b;
        });
        var lowerBoundIndex = Math.floor((1 - confidenceLevel) / 2 * groupConfidenceIntervals.length);
        var upperBoundIndex = Math.ceil((1 + confidenceLevel) / 2 * groupConfidenceIntervals.length);
        var lowerBound = sortedPositions[lowerBoundIndex];
        var upperBound = sortedPositions[upperBoundIndex];

        confidenceIntervals.push({ group: group.key, confidenceInterval: [lowerBound, upperBound] });
    });

    var y2Scale = d3.scaleLinear()
        .domain([0, KsY2limit])
        .range([height - bottomPadding, topPadding])
    var y2tickValues = d3.range(0, KsY2limit + 0.1, 0.2);
    var y2Axis = d3.axisLeft(y2Scale)
        .tickValues(y2tickValues)

    svg.append("g")
        .attr("class", "axis axis--y2")
        .attr("transform", `translate(${ leftPadding - 5 }, 0)`)
        .call(y2Axis)
        .attr("font-size", "12px")
        .attr("font-family", "calibri");

    svg.append("g")
        .attr("class", "y2Title")
        .append("text")
        .attr("y", d3.mean([topPadding, height - bottomPadding]))
        .attr("x", leftPadding - 45)
        .attr("text-anchor", "middle")
        .attr("font-size", "14px")
        .attr("font-family", "times")
        .attr("transform", function () {
            return `rotate(-90, ${ d3.select(this).attr("x") }, ${ d3.select(this).attr("y") })`;
        })
        .text("Ortholog Density");

    // Create the area generator
    var area = d3.area()
        .x(function (d) { return xScale(d[0]); })
        .y0(height - bottomPadding)
        .y1(function (d) { return y2Scale(d[1]); });

    // Append the areas for each group
    svg.selectAll(".area")
        .data(densityData)
        .enter()
        .append("path")
        .attr("class", "area path")
        .attr("d", function (d) {
            return area(d.density);
        })
        .style("fill", function (d) {
            return colorScale(d.key);
        })
        .attr("fill-opacity", densityOpacity)
        .attr("data-tippy-content", (d, i) => {
            var maxDensity = d3.max(d.density, function (m) {
                return m[1];
            });

            var maxDensityData = d.density.find(function (d) {
                return d[1] === maxDensity;
            });

            var maxDensityKs = maxDensityData ? maxDensityData[0] : undefined;

            svg.append("line")
                .attr("x1", xScale(maxDensityData[0]))
                .attr("y1", y2Scale(0))
                .attr("x2", xScale(maxDensityData[0]))
                .attr("y2", y2Scale(KsY2limit))
                .style("stroke", colorScale(d.key))
                .style("stroke-width", "1.4")
                .style("stroke-dasharray", "5, 5");

            var nintyfiveCI = confidenceIntervals[i].confidenceInterval;
            svg.append("rect")
                .attr("x", xScale(nintyfiveCI[0]))
                .attr("y", y2Scale(KsY2limit))
                .attr("width", xScale(nintyfiveCI[1]) - xScale(nintyfiveCI[0]))
                .attr("height", y2Scale(0) - 50)
                .style("fill", colorScale(d.key))
                .style("fill-opacity", 0.2)
                .attr("data-tippy-content", function () {
                    var peakContent = "Peak: <span style='color: " + colorScale(d.key.replace(".ks", "")) + ";'>" + maxDensityKs + "</span><br>" +
                        "95% CIs: <span style='color: " + highlightColor + "; background-color: " + color + "';>" +
                        nintyfiveCI[0].toFixed(2) + " <--> " + nintyfiveCI[1].toFixed(2) + "</span>";
                    return peakContent;
                })
                .on("mouseover", function (event, d) {
                    tippy(this, {
                        theme: "light",
                        placement: "right",
                        allowHTML: true,
                        animation: "scale",
                        delay: [1000, 0],
                        duration: [200, 200],
                        followCursor: true,
                        offset: [-15, 15]
                    });
                })
                .on("mouseout", function (event, d) {
                    tippy.hideAll();
                });

            var highlightColors = {
                "red": "yellow",
                "green": "cyan",
                "blue": "magenta",
                "yellow": "black",
                "cyan": "orange",
                "magenta": "lime",
                "black": "white"
            };

            var color = colorScale(d.key);
            var highlightColor = highlightColors[color] || "white";
            var name = d.key.replace(/\d+/g, "");
            var content = "<span style='color: " + highlightColor + "; background-color: " + color + ";'>" + name + "</span> <br> Peak: <span style='color: red;'>" +
                maxDensityKs + "</span> (Density: <span style='color: " + color + ";'>" + maxDensity.toFixed(2) + "</span>)<br>" +
                "95% CIs: <span style='color: " + highlightColor + "; background-color: " + color + "';>" + nintyfiveCI[0].toFixed(2) + " <--> " + nintyfiveCI[1].toFixed(2) + "</span>";

            return content;
        })
        .on("mouseover", function (event, d) {
            tippy(this, {
                theme: "light",
                placement: "right",
                allowHTML: true,
                animation: "scale",
                delay: [1000, 0],
                duration: [200, 200],
                followCursor: true,
                offset: [-15, 15]
            });
        })
        .on("mouseout", function (event, d) {
            tippy.hideAll();
        });

    // add the legend
    var legendData = [...new Set(groupedData.map((d) => d.key))];
    var legend = svg.append("g")
        .attr("class", "legend")
        .attr("transform", `translate(${ width - 200 }, 20)`);
    var legendItems = legend.selectAll(".legend-item")
        .data(legendData)
        .enter()
        .append("g")
        .attr("class", "legend-item")
        .attr("transform", function (d, i) { return `translate(0, ${ i * 20 })`; });

    legendItems.append("rect")
        .attr("x", 0)
        .attr("y", 0)
        .attr("width", 10)
        .attr("height", 10)
        .attr("fill", function (d) { return colorScale(d); })
        .attr("fill-opacity", densityOpacity);

    legendItems.append("text")
        .attr("x", 20)
        .attr("y", 10)
        .text(function (d) { return d.replace(/\d+|\.ks/g, ""); });

    legend.selectAll("text")
        .attr("font-family", "calibri")
        .attr("font-size", "12px")
        .attr("fill", "#333");


    // Add the title of the figure
    /*     svg.append("g")
            .attr("class", "figureTitle")
            .append("text")
            .attr("y", 10)
            .attr("x", leftPadding + 145)
            .attr("text-anchor", "middle")
            .attr("font-size", "14px")
            .attr("font-family", "times")
            .html("")
            .append("tspan")
            .attr("font-weight", "bold")
            .attr("font-family", "times")
            .attr("fill", "#9B3A4D")
            .text("Orthologous ")
            .append("tspan")
            .attr("font-style", "italic")
            .text("K")
            .append("tspan")
            .attr("baseline-shift", "sub")
            .text("s")
            .attr("dy", "-5px")
            .append("tspan")
            .attr("font-weight", "normal")
            .attr("font-style", "normal")
            .text(" Distribution Plot")
            .attr("dy", "5px"); */

    // console.log("Done")

    // } else {
    /* var legendData = [...new Set(KsInfo.map((d) => d.title))];
    var legend = svg.append("g")
        .attr("class", "legend")
        .attr("transform", `translate(${ width - 200 }, 20)`);

    var legendItems = legend.selectAll(".legend-item")
        .data(legendData.map(function (d) {
            return d.replace(/\d+/g, "")
        }))
        .enter()
        .append("g")
        .attr("class", "legend-item")
        .attr("transform", function (d, i) { return `translate(0, ${ i * 20 })`; });
    legendItems.append("rect")
        .attr("x", 0)
        .attr("y", 0)
        .attr("width", 10)
        .attr("height", 10)
        .attr("fill", function () {
            if (inputColor !== null) {
                return inputColor
            } else {
                return colors[plotId - 1]
            }
        })
        .attr("opacity", barOpacity);
    legendItems.append("text")
        .attr("x", 20)
        .attr("y", 10)
        .text(function (d) { return d; });

    legend.selectAll("text")
        .attr("font-family", "calibri")
        .attr("font-size", "12px")
        .attr("fill", "#333"); */

    // }

    tippy(".rect bar", { trigger: "mouseenter", followCursor: "initial", delay: [tooltipDelay, null] });
    downloadSVG("ksPlotOrthologousDownload",
        plotId,
        plotId + ".svg"
    )
}

function MultipleBarPlottingOld(InputData) {
    var plotId = InputData.plot_id;
    var KsInfo = convertShinyData(InputData.ks_bar_df);
    var paralogSpecies = InputData.paralog_id;
    var KsXlimit = InputData.xlim;
    var KsYlimit = InputData.ylim;
    var KsY2limit = InputData.y2lim;
    var barOpacity = InputData.opacity;
    var inputColor = InputData.color;
    var height = InputData.height;
    var width = InputData.width;

    // console.log("KsInfo", KsInfo);

    // console.log("KsInfo", KsInfo);
    /*     KsInfo = KsInfo.sort(function (a, b) {
            return a.ks - b.ks;
        }); */

    var titles = [...new Set(KsInfo.map(d => d.title))];;
    const titleCount = titles.length;

    const colors = [
        "#9B3A4D", "#32AEEC", "#E2AE79", "#8E549E", "#EA7500",
        "#566CA5", "#D2352C", "#394A92", "#68AC57", "#F4C28F"
    ];

    const colorScale = d3.scaleOrdinal()
        .domain(KsInfo.map(function (d) { return d.title; }))
        .range(colors);

    // draw a wgd bar plot
    d3.select("#Wgd_plot_" + plotId).select("svg").remove();

    // define plot dimension
    /*     if (titleCount > 1) {
            var width = 600;
            var height = 350;
        } else {
            var width = 500;
            var height = 350;
        } */
    let topPadding = 20;
    let bottomPadding = 40;
    let leftPadding = 80;
    let rightPadding = 50;
    var tooltipDelay = 500;

    const svg = d3.select("#Wgd_plot_" + plotId)
        .append("svg")
        .attr("width", width)
        .attr("height", height);

    // Define the x and y scales
    var xScale = d3.scaleLinear()
        .domain([0, KsXlimit])
        .range([0 + leftPadding, width - rightPadding]);

    // Create the x and y axes
    var xtickValues = d3.range(0, KsXlimit + 1, 1);
    var xAxis = d3.axisBottom(xScale)
        .tickValues(xtickValues)
        .tickFormat(d3.format("d"));

    // Add the x and y axes to the SVG element
    svg.append("g")
        .attr("class", "axis axis--x")
        .attr("transform", `translate(0, ${ height - bottomPadding })`)
        .call(xAxis)
        .attr("font-size", "12px")
        .attr("font-family", "calibri");

    svg.append("g")
        .attr("class", "xTitle")
        .append("text")
        .attr("x", d3.mean([leftPadding - 30, width]))
        .attr("y", height - 10)
        .attr("text-anchor", "middle")
        .append("tspan")
        .attr("font-family", "times")
        .html("<tspan style='font-style: italic;'>K</tspan>")
        .style("font-size", "14px")
        .append("tspan")
        .text("s")
        .style("font-size", "12px")
        .attr("dx", "1px")
        .attr("dy", "2px");

    svg.append("g")
        .attr("class", "yTitle")
        .append("text")
        .attr("y", d3.mean([topPadding, height - bottomPadding]))
        .attr("x", leftPadding - 45)
        .attr("text-anchor", "middle")
        .attr("font-size", "14px")
        .attr("font-family", "times")
        .attr("transform", function () {
            return `rotate(-90, ${ d3.select(this).attr("x") }, ${ d3.select(this).attr("y") })`;
        })
        .text("Number of retained duplicates");

    if (titleCount > 1) {
        // set Y limit
        var yScale = d3.scaleLinear()
            //.domain([0, Math.ceil(KsYlimit * 1.4 / 500) * 500])
            .domain([0, KsYlimit])
            .range([height - bottomPadding, topPadding]);

        //var ytickValues = d3.range(0, Math.ceil(KsYlimit * 1.4 / 500) * 500 + 1, 500);
        var ytickValues = d3.range(0, KsYlimit + 1, 500);
        var yAxis = d3.axisLeft(yScale)
            .tickValues(ytickValues);
        // .tickSizeInner(-width + leftPadding + rightPadding)
        // .tickSizeOuter(2);
        svg.append("g")
            .attr("class", "axis axis--y")
            .attr("transform", `translate(${ leftPadding - 5 }, 0)`)
            .call(yAxis)
            .attr("font-size", "12px")
            .attr("font-family", "calibri");

        // add bar plot for paralog species
        var paralogData = KsInfo.filter(function (d) {
            return d.title === paralogSpecies;
        });
        svg.append("g")
            .attr("class", "rect bar")
            .selectAll("rect")
            .data(paralogData)
            //.data(KsInfo)
            .join("rect")
            .attr("id", (d) => "Ks_" + d.ks)
            .attr("x", function (d, i) { return xScale(d.ks) - width / 100 * 0.9; })
            .attr("y", function (d) { return yScale(d.x); })
            .attr("width", width / 100 * 1.35)
            .attr("height", function (d) { return height - bottomPadding - yScale(d.x); })
            .attr("fill", "black")
            .attr("fill-opacity", barOpacity)
            // .style("fill", function (d) { return colorScale(d.key); })
            .attr("fill-opacity", barOpacity)
            .attr("data-tippy-content", (d) => {
                const xMatches = KsInfo.filter((item) => item.ks === d.ks);
                xMatches.sort(function (a, b) {
                    return b.x - a.x;
                });
                let content = "<font color='#ff7575'><i>K</i><sub>s</sub></font>: " + d.ks + "<br>";
                xMatches.forEach((match) => {
                    content += "<font color='#00BB00'><i>" + match.title + "</i></font>: " + numFormatter(match.x) + "<br>";
                });
                return content;
            })
            .on("mouseover", function (event, d) {
                tippy(this, {
                    theme: "light",
                    placement: "top-start",
                    allowHTML: true,
                    animation: "scale",
                    delay: [1000, 0],
                    duration: [200, 200],
                });
            })
            .on("mouseout", function (event, d) {
                tippy.hideAll();
            });

        // Add a line for paralog species
        var line = d3.line()
            .x(function (d) { return xScale(d.ks); })
            .y(function (d) { return yScale(d.x); })
            .curve(d3.curveCatmullRom.alpha(0.8));

        // Simplify the line by reducing the number of points
        var stepSize = Math.ceil(paralogData.length / 25); // Adjust the maximum number of points as needed
        var reducedData = paralogData.filter(function (d, i) {
            return i % stepSize === 0;
        });

        svg.append("path")
            .datum(reducedData)
            .attr("class", "line")
            .attr("d", line)
            .attr("fill", "none")
            .attr("stroke", "#4F4F4F")
            .attr("stroke-width", 1.5);

        // add density plot for all comparsion
        var KsDensityInfo = convertShinyData(InputData.ks_density_df);
        // Define the kernel density estimator function
        function kernelDensityEstimator(kernel, X) {
            return function (V) {
                return X.map(function (x) {
                    return [x, d3.mean(V, function (v) { return kernel(x - v); })];
                });
            };
        }

        // Define the Epanechnikov kernel funciton
        function kernelEpanechnikov(k) {
            return function (v) {
                return Math.abs(v /= k) <= 1 ? 0.75 * (1 - v * v) / k : 0;
            };
        }

        // Define the Gaussian kernel function
        function kernelGaussian(scale) {
            return function (u) {
                return Math.exp(-0.5 * u * u) / Math.sqrt(2 * Math.PI) / scale;
            };
        }
        // var kde = kernelDensityEstimator(kernelEpanechnikov(0.5), xScale.ticks(100));
        var kde = kernelDensityEstimator(kernelEpanechnikov(0.25), xScale.ticks(500));

        var groupedData = Array.from(d3.group(KsDensityInfo, d => d.title), ([key, values]) => ({ key, values }));
        groupedData = groupedData.filter(function (d) {
            return d.key !== paralogSpecies;
        });

        // Generate density data for each group
        var densityData = groupedData.map(function (d) {
            var density = kde(d.values.map(function (d) { return d.ks; }));
            return { key: d.key, density: density };
        });
        // console.log("densityData", densityData);

        // Get the 95% CIs of Ks peak from 1000 iterations
        /* var iterations = 1000;
        var confidenceLevel = 0.05;
        var binWidth = 0.01; // Specify the bin width used for density calculation

        // Array to store the bootstrap peak ranges for each group
        var bootstrapCI = [];

        // Loop over each group in densityData
        densityData.forEach(function (group) {
            var lowerBounds = [];
            var upperBounds = [];

            for (var i = 0; i < iterations; i++) {
                // Sample with replacement from the group density
                var sampledValues = group.density.map(function (point) {
                    var randomIndex = Math.floor(Math.random() * group.density.length);
                    return group.density[randomIndex];
                });

                // Calculate the total area under the density curve
                var totalArea = sampledValues.reduce(function (sum, point) {
                    return sum + point[1] * binWidth; // point[1] represents the density value
                }, 0);

                // Sort the sampled values by density in descending order
                sampledValues.sort(function (a, b) {
                    return b[1] - a[1]; // Sort in descending order of density
                });

                // Calculate the cumulative area and find the cutoff index
                var cumulativeArea = 0;
                var cutoffIndex = 0;
                while (cumulativeArea < totalArea * confidenceLevel) {
                    cumulativeArea += sampledValues[cutoffIndex][1] * binWidth;
                    cutoffIndex++;
                }

                // Get the range of values within the cutoff range as the confidence interval
                var confidenceIntervalRange = sampledValues.slice(0, cutoffIndex).map(function (point) {
                    return point[0]; // point[0] represents the x-value of the density point
                });
                // console.log(sampledValues);
                // console.log("confidenceIntervalRange", confidenceIntervalRange)
                // Store the CI range for the group
                var lowerBound = Math.min(...confidenceIntervalRange);
                var upperBound = Math.max(...confidenceIntervalRange);

                // Store the lower and upper bounds of the CI
                lowerBounds.push(lowerBound);
                upperBounds.push(upperBound);
            }

            // Calculate the mean of the lower and upper bounds to obtain a single value for the CI
            var lowerBoundMean = lowerBounds.reduce((sum, value) => sum + value, 0) / lowerBounds.length;
            var upperBoundMean = upperBounds.reduce((sum, value) => sum + value, 0) / upperBounds.length;

            // Store the final confidence interval as an array
            var confidenceInterval = [lowerBoundMean, upperBoundMean];

            // Store the bootstrap CI ranges for the group
            bootstrapCI.push(confidenceInterval);
        }); */

        // Get the 95% CI of Ks peak from 1000 iterations
        var iterations = 1000;
        var confidenceLevel = 0.95;
        var binWidth = 0.01; // Specify the bin width used for density calculation

        // Array to store the confidence intervals for each group
        var confidenceIntervals = [];

        // Loop over each group in densityData
        densityData.forEach(function (group) {
            var groupConfidenceIntervals = [];

            for (var i = 0; i < iterations; i++) {
                var peakPosition = null;
                var peakArea = 0;

                // Sample with replacement from the group density
                var sampledValues = group.density.map(function (point) {
                    var randomIndex = Math.floor(Math.random() * group.density.length);
                    return group.density[randomIndex];
                });

                // Find the point with the maximum density
                var peakPoint = sampledValues.reduce(function (prevPoint, currPoint) {
                    return currPoint[1] > prevPoint[1] ? currPoint : prevPoint;
                });

                // Calculate the total area under the density curve
                var totalArea = sampledValues.reduce(function (sum, point) {
                    return sum + point[1] * binWidth; // point[1] represents the density value
                }, 0);

                // Calculate the cumulative area and find the cutoff index
                var cumulativeArea = 0;
                var cutoffIndex = 0;
                while (cumulativeArea < totalArea * confidenceLevel) {
                    cumulativeArea += sampledValues[cutoffIndex][1] * binWidth;
                    cutoffIndex++;
                }

                // Check if the peak point is within the confidence interval range
                if (peakPoint[0] >= sampledValues[cutoffIndex][0] && peakPoint[0] <= sampledValues[cutoffIndex - 1][0]) {
                    peakPosition = peakPoint[0];
                    peakArea = peakPoint[1] * binWidth;
                }

                // Store the peak position and area
                groupConfidenceIntervals.push({ position: peakPosition, area: peakArea });
            }

            // Filter out null peak positions
            groupConfidenceIntervals = groupConfidenceIntervals.filter(function (peak) {
                return peak.position !== null;
            });

            // Calculate the lower and upper bounds of the confidence interval
            var sortedPositions = groupConfidenceIntervals.map(function (peak) {
                return peak.position;
            }).sort(function (a, b) {
                return a - b;
            });
            var lowerBoundIndex = Math.floor((1 - confidenceLevel) / 2 * groupConfidenceIntervals.length);
            var upperBoundIndex = Math.ceil((1 + confidenceLevel) / 2 * groupConfidenceIntervals.length);
            var lowerBound = sortedPositions[lowerBoundIndex];
            var upperBound = sortedPositions[upperBoundIndex];

            // Store the confidence interval for the group
            confidenceIntervals.push({ group: group.key, confidenceInterval: [lowerBound, upperBound] });
        });

        var y2Scale = d3.scaleLinear()
            .domain([0, KsY2limit])
            .range([height - bottomPadding, topPadding])
        var y2tickValues = d3.range(0, KsY2limit + 0.1, 0.2);
        var y2Axis = d3.axisRight(y2Scale)
            .tickValues(y2tickValues)
        svg.append("g")
            .attr("class", "axis axis--y2")
            .attr("transform", `translate(${ width - rightPadding + 5 }, 0)`)
            .call(y2Axis)
            .attr("font-size", "12px")
            .attr("font-family", "calibri");

        svg.append("g")
            .attr("class", "y2Title")
            .append("text")
            .attr("y", d3.mean([topPadding, height - bottomPadding]))
            .attr("x", width - rightPadding + 45)
            .attr("text-anchor", "middle")
            .attr("font-size", "14px")
            .attr("font-family", "times")
            .attr("transform", function () {
                return `rotate(-90, ${ d3.select(this).attr("x") }, ${ d3.select(this).attr("y") })`;
            })
            .text("Ortholog Density");

        // Create the area generator
        var area = d3.area()
            .x(function (d) { return xScale(d[0]); })
            .y0(height - bottomPadding)
            .y1(function (d) { return y2Scale(d[1]); });

        // Append the areas for each group
        svg.selectAll(".area")
            .data(densityData)
            .enter()
            .append("path")
            .attr("class", "area path")
            .attr("d", function (d) { return area(d.density); })
            .style("fill", function (d) { return colorScale(d.key); })
            .attr("fill-opacity", barOpacity)
            .attr("data-tippy-content", (d, i) => {
                var maxDensity = d3.max(d.density, function (m) {
                    return m[1];
                });

                var maxDensityData = d.density.find(function (d) {
                    return d[1] === maxDensity;
                });

                var maxDensityKs = maxDensityData ? maxDensityData[0] : undefined;

                svg.append("line")
                    .attr("x1", xScale(maxDensityData[0]))
                    .attr("y1", y2Scale(0))
                    .attr("x2", xScale(maxDensityData[0]))
                    .attr("y2", y2Scale(KsY2limit) + 30)
                    .style("stroke", colorScale(d.key))
                    .style("stroke-width", "1.4")
                    .style("stroke-dasharray", "5, 5");

                // console.log("confidenceIntervals", bootstrapCI[i]);
                var nintyfiveCI = confidenceIntervals[i].confidenceInterval;
                svg.append("rect")
                    .attr("x", xScale(nintyfiveCI[0]))
                    .attr("y", y2Scale(KsY2limit) + 30)
                    .attr("width", xScale(nintyfiveCI[1]) - xScale(nintyfiveCI[0]))
                    .attr("height", y2Scale(0) - 50)
                    .style("fill", colorScale(d.key))
                    .style("fill-opacity", 0.2)
                    .attr("data-tippy-content", function () {
                        var peakContent = "Peak: <span style='color: " + colorScale(d.key) + ";'>" + maxDensityKs + "</span><br>" +
                            "95% CIs: <span style='color: " + highlightColor + "; background-color: " + color + "';>" +
                            nintyfiveCI[0].toFixed(2) + " <--> " + nintyfiveCI[1].toFixed(2) + "</span>";
                        return peakContent;
                    })
                    .on("mouseover", function (event, d) {
                        tippy(this, {
                            theme: "light",
                            placement: "right",
                            allowHTML: true,
                            animation: "scale",
                            delay: [1000, 0],
                            duration: [200, 200],
                            followCursor: true,
                            offset: [-15, 15]
                        });
                    })
                    .on("mouseout", function (event, d) {
                        tippy.hideAll();
                    });

                var highlightColors = {
                    "red": "yellow",
                    "green": "cyan",
                    "blue": "magenta",
                    "yellow": "black",
                    "cyan": "orange",
                    "magenta": "lime",
                    "black": "white"
                };

                var color = colorScale(d.key);
                var highlightColor = highlightColors[color] || "white"; // Use white as default highlight color
                var name = d.key.replace(/\d+/g, "");
                var content = "<span style='color: " + highlightColor + "; background-color: " + color + ";'>" + name + "</span> <br> Peak: <span style='color: red;'>" +
                    maxDensityKs + "</span> (Density: <span style='color: " + color + ";'>" + maxDensity.toFixed(2) + "</span>)<br>" +
                    "95% CIs: <span style='color: " + highlightColor + "; background-color: " + color + "';>" + nintyfiveCI[0].toFixed(2) + " <--> " + nintyfiveCI[1].toFixed(2) + "</span>";

                return content;
            })
            .on("mouseover", function (event, d) {
                tippy(this, {
                    theme: "light",
                    placement: "right",
                    allowHTML: true,
                    animation: "scale",
                    delay: [1000, 0],
                    duration: [200, 200],
                    followCursor: true,
                    offset: [-15, 15]
                });
            })
            .on("mouseout", function (event, d) {
                tippy.hideAll();
            });

        // Append the confidence interval line to the plot
        /*         svg.selectAll(".area")
                    .data(densityData)
                    .enter()
                    .append("path")
                    .attr("class", "area path")
                    .attr("d", function (d) {
                        var areaPath = area(d.density);
                        var confidenceLinePath = "";
        
                        // Find the confidence interval for the current group
                        var confidenceInterval = confidenceIntervals.find(function (interval) {
                            return interval.key === d.key;
                        });
        
                        if (confidenceInterval) {
                            var lineData = [confidenceInterval.lowerBound, confidenceInterval.upperBound];
                            confidenceLinePath = d3.line()(lineData);
                        }
        
                        return areaPath + confidenceLinePath; // Append the confidence interval line to the area path
                    })
                    .style("fill", function (d) { return colorScale(d.key); })
                    .attr("fill-opacity", barOpacity) */

        //tippy(".area.path", { trigger: "mouseenter", followCursor: "initial", delay: [tooltipDelay, null] });
    } else {
        var yScale = d3.scaleLinear()
            .domain([0, KsYlimit])
            .range([height - bottomPadding, topPadding]);
        var ytickValues = d3.range(0, KsYlimit + 1, 500);
        var yAxis = d3.axisLeft(yScale)
            .tickValues(ytickValues)
            .tickSizeInner(-width + leftPadding + rightPadding)
            .tickSizeOuter(2);
        svg.append("g")
            .attr("class", "axis axis--y")
            .attr("transform", `translate(${ leftPadding - 5 }, 0)`)
            .call(yAxis)
            .attr("font-size", "12px")
            .attr("font-family", "calibri")
            .selectAll(".tick line")
            .style("z-index", "-100")
            .attr("stroke", "black")
            .attr("stroke-dasharray", "4 2")
            .attr("stroke-width", 0.46)
            .attr("stroke-opacity", 0.2)
            .filter(function (d) { return d === d3.max(ytickValues); })
            .remove()
            .filter(function (d) { return d === d3.min(ytickValues); })
            .remove();

        svg.append("g")
            .attr("class", "rect bar")
            .selectAll("rect")
            .data(KsInfo)
            .join("rect")
            .attr("id", (d) => "Ks_" + d.ks)
            .attr("x", function (d, i) { return xScale(d.ks) - width / 100 * 0.9; })
            .attr("y", function (d) { return yScale(d.x); })
            .attr("width", width / 100 * 1.35)
            .attr("height", function (d) { return height - bottomPadding - yScale(d.x); })
            .attr("fill", function () {
                if (inputColor !== null) {
                    return inputColor
                } else {
                    return colors[plotId - 1]
                }
            })
            .attr("fill-opacity", barOpacity)
            .attr("data-tippy-content", (d) => {
                const xMatches = KsInfo.filter((item) => item.ks === d.ks);
                xMatches.sort(function (a, b) {
                    return b.x - a.x;
                });
                let content = "<font color='#ff7575'><i>K</i><sub>s</sub></font>: " + d.ks + "<br>";
                xMatches.forEach((match) => {
                    content += "<font color='#00BB00'><i>" + match.title + "</i></font>: " + numFormatter(match.x) + "<br>";
                });
                return content;
            })
            .on("mouseover", function (event, d) {
                tippy(this, {
                    theme: "light",
                    placement: "top-start",
                    allowHTML: true,
                    animation: "scale",
                    delay: [1000, 0],
                    duration: [200, 200],
                });
            })
            .on("mouseout", function (event, d) {
                tippy.hideAll();
            });
    }

    // add the vertical lines
    // Define the vertical line data
    var verticalLineData = InputData.vlines;

    // Append the vertical lines to the SVG
    if (verticalLineData.length > 0) {
        svg.selectAll(".vertical-line")
            .data(verticalLineData)
            .enter()
            .append("line")
            .attr("class", "vertical-line")
            .attr("x1", function (d) { return xScale(d); })
            .attr("x2", function (d) { return xScale(d); })
            .attr("y1", topPadding)
            .attr("y2", height - bottomPadding)
            .attr("stroke", "orange")
            .attr("stroke-width", 2)
            .attr("stroke-dasharray", "5,5");
    }

    // add the legend
    if (titleCount > 1) {
        var legendData = [...new Set(groupedData.map((d) => d.key))];
        // console.log(legendData);
        var legend = svg.append("g")
            .attr("class", "legend")
            .attr("transform", `translate(${ width - 200 }, 20)`);
        var legendItems = legend.selectAll(".legend-item")
            .data(legendData)
            .enter()
            .append("g")
            .attr("class", "legend-item")
            .attr("transform", function (d, i) { return `translate(0, ${ i * 20 })`; });

        // console.log(legendItems);

        legendItems.append("rect")
            .attr("x", 0)
            .attr("y", 0)
            .attr("width", 10)
            .attr("height", 10)
            .attr("fill", function (d) { return colorScale(d); })
            .attr("fill-opacity", barOpacity);

        legendItems.append("text")
            .attr("x", 20)
            .attr("y", 10)
            .text(function (d) { return d.replace(/\d+/g, ""); });

        legend.selectAll("text")
            .attr("font-family", "calibri")
            .attr("font-size", "12px")
            .attr("fill", "#333");

        d3.select("#Wgd_plot_correct_" + plotId).select("svg").remove();
        /*         // Clone the existing SVG and modify the ID
                function clone(selector) {
                    var node = d3.select(selector).node();
                    return d3.select(node.cloneNode(true));
                }
        
                var correctSvg = clone("#Wgd_plot_" + plotId); //.attr("transform", "translate(120,100)");
                correctSvg.attr("id", "#Wgd_plot_correct_" + plotId);
                // Append the new SVG to the desired location
                d3.select("#Wgd_plot_correct_" + plotId)
                    .node()
                    .appendChild(correctSvg.node()); */

        // Add the title of the original figure
        svg.append("g")
            .attr("class", "figureTitle")
            .append("text")
            .attr("y", 10)
            .attr("x", leftPadding + 145)
            .attr("text-anchor", "middle")
            .attr("font-size", "14px")
            .attr("font-family", "times")
            .html("")
            .append("tspan")
            .attr("font-weight", "bold")
            .attr("font-family", "times")
            .attr("fill", "#00AEAE")
            .text("Original ")
            .append("tspan")
            .attr("font-style", "italic")
            .text("K")
            .append("tspan")
            .attr("baseline-shift", "sub")
            .text("s")
            .attr("dy", "-5px")
            .append("tspan")
            .attr("font-weight", "normal")
            .attr("font-style", "normal")
            //.attr("fill", "black")
            .text(" Distribution Plot")
            .attr("dy", "5px");
        // Add the title of the correct figure
        /* correctSvg.append("g")
            .attr("class", "figureTitle")
            .append("text")
            .attr("y", 10)
            .attr("x", leftPadding + 45)
            .attr("text-anchor", "middle")
            .attr("font-size", "14px")
            .attr("font-family", "times")
            .html("Corrected <b><i>K</b></i><sub>s</sub> Distribution Plot"); */

    } else {
        var legendData = [...new Set(KsInfo.map((d) => d.title))];
        var legend = svg.append("g")
            .attr("class", "legend")
            .attr("transform", `translate(${ width - 200 }, 20)`);

        var legendItems = legend.selectAll(".legend-item")
            .data(legendData.map(function (d) {
                return d.replace(/\d+/g, "")
            }))
            .enter()
            .append("g")
            .attr("class", "legend-item")
            .attr("transform", function (d, i) { return `translate(0, ${ i * 20 })`; });
        legendItems.append("rect")
            .attr("x", 0)
            .attr("y", 0)
            .attr("width", 10)
            .attr("height", 10)
            .attr("fill", function () {
                if (inputColor !== null) {
                    return inputColor
                } else {
                    return colors[plotId - 1]
                }
            })
            .attr("opacity", barOpacity);
        legendItems.append("text")
            .attr("x", 20)
            .attr("y", 10)
            .text(function (d) { return d; });

        legend.selectAll("text")
            .attr("font-family", "calibri")
            .attr("font-size", "12px")
            .attr("fill", "#333");

    }

    tippy(".rect bar", { trigger: "mouseenter", followCursor: "initial", delay: [tooltipDelay, null] });

    if (titleCount > 1) {
        downloadSVG("ks_download_correct_" + plotId,
            "Wgd_plot_correct_" + plotId,
            "corrected_Ks_" + plotId + ".svg"
        )
    }
    downloadSVG("ks_download_" + plotId,
        "Wgd_plot_" + plotId,
        "Ks_" + plotId + ".svg"
    )
}


// Covert shiny transferred data to desired format
function convertShinyData(inObj) {
    const properties = Object.keys(inObj);

    let outArray = [];
    for (let i = 0; i < inObj[properties[0]].length; i++) {
        outArray[i] = {};
        for (let j = 0; j < properties.length; j++) {
            outArray[i][properties[j]] = inObj[properties[j]][i];
        }
    }
    return outArray;
}

// calculate accumulate length for parallel chr plot
function calc_accumulate_len(inputChrInfo, innerPadding_xScale, innerPadding) {
    let acc_len = 0;
    let total_chr_len = d3.sum(inputChrInfo.map(e => e.len));
    let ratio = innerPadding_xScale.invert(innerPadding);
    inputChrInfo.forEach((e, i) => {
        e.idx = i;
        e.accumulate_start = acc_len + 1;
        e.accumulate_end = e.accumulate_start + e.len - 1;
        acc_len = e.accumulate_end + total_chr_len * ratio;
    });
    return inputChrInfo;
}

// calculate dynamic accumulate length for each chromosome
function calc_accumulate_len_dynamic(inputChrInfo, innerfold, innerPadding_xScale, innerPadding) {
    let acc_len = 0;
    let total_chr_len = d3.sum(inputChrInfo.map(e => e.len));
    let ratio = innerPadding_xScale.invert(innerPadding * innerfold)
    inputChrInfo.forEach((e, i) => {
        e.idx = i;
        e.accumulate_start = acc_len + 1;
        e.accumulate_end = e.accumulate_start + e.len - 1;
        acc_len = e.accumulate_end + total_chr_len * ratio;
    });
    return inputChrInfo;
}

// calculate accumulate gene numberr for parallel chr plot
function calc_accumulate_num(inputChrInfo, innerPadding_xScale, innerPadding) {
    let acc_len = 0;
    let total_chr_num = d3.sum(inputChrInfo.map(e => e.num));
    let ratio = innerPadding_xScale.invert(innerPadding);
    inputChrInfo.forEach((e, i) => {
        e.idx = i;
        e.accumulate_start = acc_len + 1;
        e.accumulate_end = e.accumulate_start + e.num - 1;
        acc_len = e.accumulate_end + total_chr_num * ratio;
    });
    return inputChrInfo;
}

function downloadSVG(downloadButtonID, svgDivID, svgOutFile) {
    // Add event listener to the button
    // since some button are generated dynamically
    // need to be called each time the button was generated
    d3.select("#" + downloadButtonID)
        .on("click", function (e) {
            const chart = d3.select("#" + svgDivID)
                .select("svg").node();
            const svgData = new XMLSerializer().serializeToString(chart);
            const blob = new Blob([svgData], { type: "image/svg+xml;charset=utf-8" });
            const url = URL.createObjectURL(blob);
            // const url = URL.createObjectURL(serialize(chart));
            d3.select(this)
                .attr("download", svgOutFile)
                .attr("href", url);
        });
}

function arraysOfObjectsAreEqual(arr1, arr2) {
    if (arr1.length !== arr2.length) {
        return false; // arrays are different lengths, so they can't be the same
    }

    for (let i = 0; i < arr1.length; i++) {
        const obj1 = arr1[i];
        const obj2 = arr2[i];

        if (obj1.seqchr !== obj2.seqchr ||
            obj1.num !== obj2.num ||
            obj1.sp !== obj2.sp ||
            obj1.idx !== obj2.idx ||
            obj1.accumulate_start !== obj2.accumulate_start ||
            obj1.accumulate_end !== obj2.accumulate_end) {
            return false;
        }
    }

    return true;
}

// The following codes are derived from https://www.samproell.io/posts/signal/peak-finding-python-js/

/**
 * Get indices of all local maxima in a sequence.
 * @param {number[]} xs - sequence of numbers
 * @returns {number[]} indices of local maxima
 */
function find_local_maxima(xs) {
    let maxima = [];
    // iterate through all points and compare direct neighbors
    for (let i = 1; i < xs.length - 1; ++i) {
        if (xs[i] > xs[i - 1] && xs[i] > xs[i + 1])
            maxima.push(i);
    }
    return maxima;
}

/**
 * Remove peaks below minimum height.
 * @param {number[]} indices - indices of peaks in xs
 * @param {number[]} xs - original signal
 * @param {number} height - minimum peak height
 * @returns {number[]} filtered peak index list
 */
function filter_by_height(indices, xs, height) {
    return indices.filter(i => xs[i] > height);
}

/**
 * Remove peaks that are too close to higher ones.
 * @param {number[]} indices - indices of peaks in xs
 * @param {number[]} xs - original signal
 * @param {number} dist - minimum distance between peaks
 * @returns {number[]} filtered peak index list
 */
function filter_by_distance(indices, xs, dist) {
    let to_remove = Array(indices.length).fill(false);
    let heights = indices.map(i => xs[i]);
    let sorted_index_positions = argsort(heights).reverse();

    // adapted from SciPy find_peaks
    for (let current of sorted_index_positions) {
        if (to_remove[current]) {
            continue;  // peak will already be removed, move on.
        }

        let neighbor = current - 1;  // check on left side of peak
        while (neighbor >= 0 && (indices[current] - indices[neighbor]) < dist) {
            to_remove[neighbor] = true;
            --neighbor;
        }

        neighbor = current + 1;  // check on right side of peak
        while (neighbor < indices.length
            && (indices[neighbor] - indices[current]) < dist) {
            to_remove[neighbor] = true;
            ++neighbor;
        }
    }
    return indices.filter((v, i) => !to_remove[i]);
}

/**
 * Filter peaks by required properties.
 * @param {number[]}} indices - indices of peaks in xs
 * @param {number[]} xs - original signal
 * @param {number} distance - minimum distance between peaks
 * @param {number} height - minimum height of peaks
 * @returns {number[]} filtered peak indices
 */
function filter_maxima(indices, xs, distance, height) {
    let new_indices = indices;
    if (height != undefined) {
        new_indices = filter_by_height(indices, xs, height);
    }
    if (distance != undefined) {
        new_indices = filter_by_distance(new_indices, xs, distance);
    }
    return new_indices;
}

/**
 * Simplified version of SciPy's find_peaks function.
 * @param {number[]} xs - input signal
 * @param {number} distance - minimum distance between peaks
 * @param {number} height - minimum height of peaks
 * @returns {number[]} peak indices
 */
function minimal_find_peaks(xs, distance, height) {
    let indices = find_local_maxima(xs)
    return filter_maxima(indices, xs, distance, height);
}
