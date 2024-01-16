var numFormatter = d3.format(".0f");
const floatFormatter = d3.format(".2f");

Shiny.addCustomMessageHandler("Bar_Density_Plotting", mixBarDensityPlotting);
function mixBarDensityPlotting(InputData) {
    // Load D3.js version 7
    var scriptV7 = document.createElement('script');
    scriptV7.src = 'https://d3js.org/d3.v7.min.js';
    document.head.appendChild(scriptV7);

    scriptV7.onload = function () {

        var plotId = InputData.plot_id;
        var KsDensityInfo = convertShinyData(InputData.ks_density_df);
        var KsDensityCorrectionInfo = convertShinyData(InputData.ks_density_for_correct_df);
        var rateCorrectionInfo = convertShinyData(InputData.rate_correction_df);
        var ref2outgroupId = InputData.ref2outgroup_id;
        var paralogId = InputData.paralog_id;
        var paralogSpecies = InputData.paralogSpecies;
        var KsXlimit = InputData.xlim;
        var KsYlimit = InputData.ylim;
        var KsY2limit = InputData.y2lim;
        var barOpacity = InputData.opacity;
        var height = InputData.height;
        var width = InputData.width;
        var namesInfo = convertShinyData(InputData.species_list);

        const colors = [
            "#9B3A4D", "#32AEEC", "#E2AE79", "#8E549E", "#EA7500",
            "#566CA5", "#D2352C", "#394A92", "#68AC57", "#F4C28F"
        ];

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
            .range([0 + leftPadding, (width - rightPadding - leftPadding) / 2]);

        var xtickValues = d3.range(0, KsXlimit + 1, 1);
        var xAxis = d3.axisBottom(xScale)
            .tickValues(xtickValues)
            .tickFormat(d3.format("d"));

        svg.append("g")
            .attr("class", "axis axis--x")
            .attr("transform", `translate(0, ${ height - bottomPadding })`)
            .call(xAxis)
            .attr("font-size", "12px");

        svg.append("g")
            .attr("class", "xTitle")
            .append("text")
            .attr("x", d3.mean([leftPadding - 30, (width - rightPadding - leftPadding) / 2]))
            .attr("y", height - 10)
            .attr("text-anchor", "middle")
            .append("tspan")
            .html("<tspan style='font-style: italic;'>K</tspan>")
            .style("font-size", "14px")
            .append("tspan")
            .text("s")
            .style("font-size", "12px")
            .attr("dx", "1px")
            .attr("dy", "2px");

        var KsInfo = convertShinyData(InputData.ks_bar_df);
        var titles = [...new Set(KsInfo.map(d => d.title))];

        const colorScale = d3.scaleOrdinal()
            .domain(KsInfo.map(function (d) { return d.title; }))
            .range(colors);

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

        var yScale = d3.scaleLinear()
            .domain([0, KsY2limit])
            .range([height - bottomPadding, topPadding]);
        var ytickValues = d3.range(0, KsY2limit + 0.1, 0.2);
        var yAxis = d3.axisLeft(yScale)
            .tickValues(ytickValues);

        svg.append("g")
            .attr("class", "axis axis--y2")
            .attr("transform", `translate(${ leftPadding - 5 }, 0)`)
            .call(yAxis)
            .attr("font-size", "12px");

        svg.append("g")
            .attr("class", "y2Title")
            .append("text")
            .attr("y", d3.mean([topPadding, height - bottomPadding]))
            .attr("x", leftPadding - 50)
            .attr("text-anchor", "middle")
            .attr("font-size", "14px")
            .attr("transform", function () {
                return `rotate(-90, ${ d3.select(this).attr("x") }, ${ d3.select(this).attr("y") })`;
            })
            .text("Ortholog Density");

        var area = d3.area()
            .x(function (d) { return xScale(d[0]); })
            .y0(height - bottomPadding)
            .y1(function (d) { return yScale(d[1]); });

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
        );

        // Add relative rate test output to plot
        rateCorrectionInfo.forEach(function (each, i) {
            var ref_full = parseFloat(each.a_mode) + parseFloat(each.c_mode);
            var cal_full = parseFloat(each.b_mode) + parseFloat(each.c_mode);

            var firstOutgroupElement = namesInfo.find(function (info) {
                return info.latin_name === each.outgroup.replace("_", " ");
            });
            var firstRefElement = namesInfo.find(function (info) {
                return info.latin_name === each.ref.replace("_", " ");
            });
            var firstStudyElement = namesInfo.find(function (info) {
                return info.latin_name === each.study.replace("_", " ");
            });

            var matchingTitles = titles.filter(function (item) {
                return item.includes(firstOutgroupElement.informal_name);
            });
            var study2outgroup = matchingTitles.find(function (item) {
                return item.includes(firstStudyElement.informal_name);
            });
            var ref2outgroup = matchingTitles.find(function (item) {
                return item.includes(firstRefElement.informal_name);
            });

            var study2outgroupYpos = maxYvalueInfo.find(function (item) {
                var pos = item.group.includes(study2outgroup);
                return pos;
            });

            var ref2outgroupYpos = maxYvalueInfo.find(function (item) {
                var pos = item.group.includes(ref2outgroup);
                return pos;
            });

            var rateYpos = d3.max(highestYValues) + 0.1;

            svg.append('circle')
                .attr("class", "rate test")
                .attr("r", 2)
                .attr("cx", xScale(parseFloat(each.c_mode)))
                .attr("cy", yScale(rateYpos + i * 0.3))
                .attr("fill", "black")
                .attr("fill-opacity", "0.7");

            svg.append("rect")
                .attr("class", "rate test")
                .attr("id", "rate_correction_" + each.study)
                .attr("x", xScale(each.c_low_bound))
                .attr("y", yScale(rateYpos + i * 0.3) - 4)
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
                if (each.outgroup.includes("_")) {
                    var ref2outgroupLabel = each.outgroup.replace(/(\w)\w+_(\w+)/, "$1. $2") +
                        " - " + each.ref.replace(/(\w)\w+_(\w+)/, "$1. $2");
                } else {
                    var ref2outgroupLabel = each.outgroup.replace(/(\w)\w+\s(\w+)/, "$1. $2") +
                        " - " + each.ref.replace(/(\w)\w+\s(\w+)/, "$1. $2");
                }
                svg.append('text')
                    .attr('x', xScale(maxModeSum + 0.1))
                    .attr('y', yScale(rateYpos + i * 0.3) + 3)
                    .text(ref2outgroupLabel)
                    .attr('fill', colorScale(ref2outgroup))
                    .attr("font-size", "10px")
                    .attr('text-anchor', 'start')
                    // .attr("font-family", "calibri")
                    .attr("font-style", "italic");
            }

            svg.append('line')
                .attr("class", "rate test")
                .attr('x1', xScale(parseFloat(each.c_mode)))
                .attr('y1', yScale(rateYpos + i * 0.3))
                .attr('x2', xScale(0))
                .attr('y2', yScale(rateYpos + i * 0.3))
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
                .attr('y1', yScale(rateYpos + i * 0.3))
                .attr('x2', xScale(ref_full))
                .attr('y2', yScale(rateYpos + i * 0.3))
                .attr('stroke', colorScale(ref2outgroup))
                .attr('marker-end', 'url(#triangle-marker-2)');

            svg.append("line")
                .attr("class", "rate test")
                .attr('x1', xScale(ref_full))
                .attr('y1', yScale(rateYpos + i * 0.3))
                .attr('x2', xScale(ref_full))
                .attr('y2', yScale(ref2outgroupYpos.Yvalue))
                .attr('stroke', colorScale(ref2outgroup))
                .attr('opacity', '0.6')
                .attr("stroke-dasharray", "5 3");

            svg.append('line')
                .attr('x1', xScale(parseFloat(each.c_mode)))
                .attr('y1', yScale(rateYpos + i * 0.3))
                .attr('x2', xScale(parseFloat(each.c_mode)))
                .attr('y2', yScale(rateYpos + i * 0.3 + 0.15))
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
                .attr('y1', yScale(rateYpos + i * 0.3 + 0.15))
                .attr('x2', xScale(cal_full))
                .attr('y2', yScale(rateYpos + i * 0.3 + 0.15))
                .attr('stroke', colorScale(study2outgroup))
                .attr('marker-end', 'url(#triangle-marker-3)');

            svg.append("line")
                .attr("class", "rate test")
                .attr('x1', xScale(cal_full))
                .attr('y1', yScale(rateYpos + i * 0.3 + 0.15))
                .attr('x2', xScale(cal_full))
                .attr('y2', yScale(study2outgroupYpos.Yvalue))
                .attr('stroke', colorScale(study2outgroup))
                .attr('opacity', '0.6')
                .attr("stroke-dasharray", "5 3");

            if (each.outgroup.includes("_")) {
                var study2outgroupLabel = each.outgroup.replace(/(\w)\w+_(\w+)/, "$1. $2") +
                    " - " + each.study.replace(/(\w)\w+_(\w+)/, "$1. $2");
            } else {
                var study2outgroupLabel = each.outgroup.replace(/(\w)\w+\s(\w+)/, "$1. $2") +
                    " - " + each.study.replace(/(\w)\w+\s(\w+)/, "$1. $2");
            }

            svg.append('text')
                .attr('x', xScale(maxModeSum + 0.1))
                .attr('y', yScale(rateYpos + i * 0.3 + 0.15) + 3)
                .text(study2outgroupLabel)
                .attr('fill', colorScale(study2outgroup))
                .attr("font-size", "10px")
                .attr('text-anchor', 'start')
                .attr("font-style", "italic");

            svg.append('text')
                .attr('x', xScale(parseFloat(each.c_mode) - 0.2))
                .attr('y', yScale(rateYpos + i * 0.3 + 0.05))
                .text(floatFormatter(parseFloat(each.c_mode)))
                .attr('fill', 'grey')
                .attr("font-size", "10px")
                .attr('text-anchor', 'end');

            svg.append('text')
                .attr('x', xScale(parseFloat(each.c_mode) + 0.2))
                .attr('y', yScale(rateYpos + i * 0.3 + 0.05))
                .text(floatFormatter(each.a_mode))
                .attr('fill', colorScale(ref2outgroup))
                .attr("font-size", "10px");

            svg.append('text')
                .attr('x', xScale(parseFloat(each.c_mode) + 0.2))
                .attr('y', yScale(rateYpos + i * 0.3 + 0.2))
                .text(floatFormatter(each.b_mode))
                .attr('fill', colorScale(study2outgroup))
                .attr("font-size", "10px");
        });

        // Add the right figure
        var x2Start = (width - leftPadding - rightPadding) / 2 + 80;
        var x2End = width - leftPadding - rightPadding;
        var x2Scale = d3.scaleLinear()
            .domain([0, KsXlimit])
            .range([x2Start, x2End]);

        var x2tickValues = d3.range(0, KsXlimit + 1, 1);
        var x2Axis = d3.axisBottom(x2Scale)
            .tickValues(x2tickValues)
            .tickFormat(d3.format("d"));

        svg.append("g")
            .attr("class", "axis axis--x2")
            .attr("transform", `translate(0, ${ height - bottomPadding })`)
            .call(x2Axis)
            .attr("font-size", "12px");

        svg.append("g")
            .attr("class", "x2Title")
            .append("text")
            .attr("x", d3.mean([(width - rightPadding - leftPadding) / 2 - 30, width - rightPadding]))
            .attr("y", height - 10)
            .attr("text-anchor", "middle")
            .append("tspan")
            .html("<tspan style='font-style: italic;'>K</tspan>")
            .style("font-size", "14px")
            .append("tspan")
            .text("s")
            .style("font-size", "12px")
            .attr("dx", "1px")
            .attr("dy", "2px");

        svg.append("g")
            .attr("class", "y2Title")
            .append("text")
            .attr("y", d3.mean([topPadding, height - bottomPadding]))
            .attr("x", x2Start - 50)
            .attr("text-anchor", "middle")
            .attr("font-size", "14px")
            .attr("transform", function () {
                return `rotate(-90, ${ d3.select(this).attr("x") }, ${ d3.select(this).attr("y") })`;
            })
            .text("Number of retained duplicates");

        var y2Scale = d3.scaleLinear()
            .domain([0, KsYlimit])
            .range([height - bottomPadding, topPadding]);

        var desiredTickCount = 7;
        var possibleIntervals = [500, 200, 100, 50, 20, 10];

        var interval;
        for (const tickInterval of possibleIntervals) {
            if (KsYlimit / tickInterval >= (desiredTickCount - 1)) {
                interval = tickInterval;
                break;
            }
        }

        var y2tickValues = d3.range(0, KsYlimit + 1, interval);

        var y2Axis = d3.axisLeft(y2Scale)
            .tickValues(y2tickValues);

        svg.append("g")
            .attr("class", "axis axis--y")
            .attr("transform", `translate(${ x2Start - 5 }, 0)`)
            .call(y2Axis)
            .attr("font-size", "12px");

        var paralogData = KsInfo.filter(function (d) {
            var paralogIdFile = paralogId + ".ks";
            var paralogIdAnchorsFile = paralogId + ".ks_anchors";
            return (d.title === paralogIdFile) || (d.title === paralogIdAnchorsFile);
        });

        var barColorScale = d3.scaleOrdinal()
            .domain(paralogData.map(function (d) { return d.title.split(".")[0]; }))
            .range(["black", "#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "#9467bd"]);

        var y3Scale = d3.scaleLinear()
            .domain([0, KsY2limit])
            .range([height - bottomPadding, topPadding]);
        var y3tickValues = d3.range(0, KsY2limit + 0.1, 0.2);
        var y3Axis = d3.axisRight(y3Scale)
            .tickValues(y3tickValues);

        svg.append("g")
            .attr("class", "axis axis--y3")
            .attr("transform", `translate(${ x2End + 5 }, 0)`)
            .call(y3Axis)
            .attr("font-size", "12px");

        svg.append("g")
            .attr("class", "y2Title")
            .append("text")
            .attr("y", d3.mean([topPadding, height - bottomPadding]))
            .attr("x", x2End + 50)
            .attr("text-anchor", "middle")
            .attr("font-size", "14px")
            .attr("transform", function () {
                return `rotate(-90, ${ d3.select(this).attr("x") }, ${ d3.select(this).attr("y") })`;
            })
            .text("Ortholog Density");

        var areaTwo = d3.area()
            .x(function (d) { return x2Scale(d[0]); })
            .y0(height - bottomPadding)
            .y1(function (d) { return y3Scale(d[1]); });

        var peaksInfo = [];

        // corrected density data
        var ref2outgrouKsInfo = KsDensityInfo.filter(item => item.title === ref2outgroupId);
        KsDensityCorrectionInfo = KsDensityCorrectionInfo.concat(ref2outgrouKsInfo);

        var groupedCorrectionData = Array.from(
            d3.group(KsDensityCorrectionInfo, d => d.title), ([key, values]) => ({ key, values })
        );

        var densityCorrectionData = groupedCorrectionData.map(function (d) {
            var density = kde(d.values.map(function (d) { return d.ks; }));
            return { key: d.key, density: density };
        });

        var iterations = 1000;
        var confidenceLevel = 0.95;
        var binWidth = 0.01;

        var CorrectConfidenceIntervals = [];
        var groupCorrectionConfidenceIntervals = [];

        densityCorrectionData.forEach(function (group) {
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

                groupCorrectionConfidenceIntervals.push({ position: peakPosition, area: peakArea });
            }

            groupCorrectionConfidenceIntervals = groupCorrectionConfidenceIntervals.filter(function (peak) {
                return peak.position !== null;
            });

            var sortedPositions = groupCorrectionConfidenceIntervals.map(function (peak) {
                return peak.position;
            }).sort(function (a, b) {
                return a - b;
            });
            var lowerBoundIndex = Math.floor((1 - confidenceLevel) / 2 * groupCorrectionConfidenceIntervals.length);
            var upperBoundIndex = Math.ceil((1 + confidenceLevel) / 2 * groupCorrectionConfidenceIntervals.length);
            var lowerBound = sortedPositions[lowerBoundIndex];
            var upperBound = sortedPositions[upperBoundIndex];

            CorrectConfidenceIntervals.push({ group: group.key, confidenceInterval: [lowerBound, upperBound] });
        });

        svg.selectAll(".area-two")
            .data(densityCorrectionData)
            .enter()
            .append("path")
            .attr("class", "area-two path")
            .attr("d", function (d) { return areaTwo(d.density); })
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

                var nintyfiveCI = CorrectConfidenceIntervals[i].confidenceInterval;

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
        tippy(".rect bar", { trigger: "mouseenter", followCursor: "initial", delay: [tooltipDelay, null] });

        console.log("rateCorrectionInfo", rateCorrectionInfo);

        var maxYvalueInfo = [];
        densityCorrectionData.forEach(function (d) {
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
                var sumAB = parseFloat(item.a_mode) + parseFloat(item.b_mode);
                return Math.max(sumAC, sumBC, sumAB);
            })
        );

        /** 
         * The function for dragging elements in SVG
        */
        // Function to make SVG text elements draggable
        function makeDraggable(element) {
            var offsetX, offsetY, isDragging = false;

            element.on('mousedown', function (e) {
                isDragging = true;
                offsetX = e.clientX - parseFloat(element.attr('x'));
                offsetY = e.clientY - parseFloat(element.attr('y'));
            });

            d3.select(document).on('mousemove', function (e) {
                if (isDragging) {
                    element.attr('x', e.clientX - offsetX);
                    element.attr('y', e.clientY - offsetY);
                }
            });

            d3.select(document).on('mouseup', function () {
                isDragging = false;
            });
        }

        function makeDraggable(element) {
            var offsetX, offsetY, isDragging = false;

            element.on('mousedown', function (e) {
                isDragging = true;
                var currentElement = d3.select(this);
                offsetX = e.clientX - parseFloat(currentElement.attr('x'));
                offsetY = e.clientY - parseFloat(currentElement.attr('y'));

                // Prevent text selection during drag
                currentElement.attr('pointer-events', 'none');
            });

            d3.select(document).on('mousemove.' + element.attr("class"), function (e) {
                if (isDragging) {
                    element.attr('x', e.clientX - offsetX);
                    element.attr('y', e.clientY - offsetY);
                }
            });

            d3.select(document).on('mouseup.' + element.attr("class"), function () {
                isDragging = false;

                // Restore pointer events after drag
                element.attr('pointer-events', 'auto');
            });
        }

        function dragstarted(event, d) {
            d3.select(this).raise().attr("fill", "black");
        }

        function dragged(event, d) {
            d3.select(this).attr("x", x = event.x).attr("y", y = event.y);
        }

        function dragended(event, d) {
            d3.select(this).attr("font-size", "9px");
        }

        // Create a drag behavior
        var drag = d3.drag()
            // .on("start", dragstarted)
            .on("drag", dragged)
            // .on("end", dragended);


        // Add relative rate test output to plot
        const titlesCorrection = [...new Set(densityCorrectionData.map(info => info.key))];

        rateCorrectionInfo.forEach(function (each, i) {
            var ref_full = parseFloat(each.a_mode) + parseFloat(each.c_mode);
            var cal_full = parseFloat(each.b_mode) + parseFloat(each.c_mode);
            var study_full = parseFloat(each.a_mode) + parseFloat(each.b_mode);

            var firstOutgroupElement = namesInfo.find(function (info) {
                return info.latin_name === each.outgroup.replace("_", " ");
            });
            var firstRefElement = namesInfo.find(function (info) {
                return info.latin_name === each.ref.replace("_", " ");
            });
            var firstStudyElement = namesInfo.find(function (info) {
                return info.latin_name === each.study.replace("_", " ");
            });

            var matchingTitles = titlesCorrection.filter(function (item) {
                return item.includes(firstRefElement.informal_name);
            });
            var ref2study = matchingTitles.find(function (item) {
                return item.includes(firstStudyElement.informal_name);
            });
            var ref2outgroup = matchingTitles.find(function (item) {
                return item.includes(firstOutgroupElement.informal_name);
            });

            console.log("maxYvalueInfo", maxYvalueInfo);
            var ref2studyYpos = maxYvalueInfo.find(function (item) {
                var pos = item.group.includes(ref2study);
                return pos;
            });

            var ref2outgroupYpos = maxYvalueInfo.find(function (item) {
                var pos = item.group.includes(ref2outgroup);
                return pos;
            });

            if (i === 0) {
                if (each.outgroup.includes("_")) {
                    var ref2outgroupLabel = each.ref.replace(/(\w)\w+_(\w+)/, "$1. $2") +
                        " - " + each.outgroup.replace(/(\w)\w+_(\w+)/, "$1. $2");
                } else {
                    var ref2outgroupLabel = each.ref.replace(/(\w)\w+\s(\w+)/, "$1. $2") +
                        " - " + each.outgroup.replace(/(\w)\w+\s(\w+)/, "$1. $2");
                }

                /*                 svg.append('text')
                                    .attr("class", "rate2 ref2outgroup")
                                    .attr('x', x2Scale(ref_full + 0.1))
                                    .attr('y', y3Scale(ref2outgroupYpos.Yvalue) * 0.95 + 6)
                                    .text(ref2outgroupLabel)
                                    .attr('fill', colorScale(ref2outgroup))
                                    .attr("font-size", "9px")
                                    .attr('text-anchor', 'start')
                                    .attr("font-style", "italic"); */

                var textElement = svg.append('text')
                    .attr("class", "rate2 ref2outgroup")
                    .attr('x', x2Scale(ref_full + 0.1))
                    .attr('y', y3Scale(ref2outgroupYpos.Yvalue) * 0.95 + 6)
                    .text(ref2outgroupLabel)
                    .attr('fill', colorScale(ref2outgroup))
                    .attr("font-size", "10px")
                    .attr('text-anchor', 'start')
                    .attr("font-style", "italic")
                    .call(drag);


                /*                 svg.append('line')
                                    .attr("class", "rate2 ref2outgroup")
                                    .attr('x1', x2Scale(ref_full))
                                    .attr('y1', y3Scale(ref2outgroupYpos.Yvalue) * 0.8)
                                    .attr('x2', x2Scale(ref_full))
                                    .attr('y2', y3Scale(ref2outgroupYpos.Yvalue))
                                    .attr('stroke', colorScale(ref2outgroup)); */
            }

            svg.append("line")
                .attr("class", "rate2 ref2study")
                .attr('x1', x2Scale(study_full))
                .attr('y1', y3Scale(ref2studyYpos.Yvalue) * 0.8)
                .attr('x2', x2Scale(study_full))
                .attr('y2', y3Scale(ref2studyYpos.Yvalue))
                .attr('stroke', colorScale(ref2study));

            if (each.outgroup.includes("_")) {
                var ref2studyLabel = each.ref.replace(/(\w)\w+_(\w+)/, "$1. $2") +
                    " - " + each.study.replace(/(\w)\w+_(\w+)/, "$1. $2");
            } else {
                var ref2studyLabel = each.ref.replace(/(\w)\w+\s(\w+)/, "$1. $2") +
                    " - " + each.study.replace(/(\w)\w+\s(\w+)/, "$1. $2");
            }

            var textRef2studyLabel = svg.append('text')
                .attr("class", "rate2 ref2study")
                .attr('x', function () {
                    if (each.a_mode < each.b_mode) {
                        return x2Scale(study_full + 0.1);
                    } else {
                        return x2Scale(study_full - 0.1);
                    }
                })
                .attr('y', y3Scale(ref2studyYpos.Yvalue) * 0.8 + 6)
                .text(ref2studyLabel)
                .attr('fill', colorScale(ref2study))
                .attr("font-size", "10px")
                .attr('text-anchor', function () {
                    if (each.a_mode < each.b_mode) {
                        return "start";
                    } else {
                        return "end";
                    }
                })
                .attr("font-style", "italic")
                .call(drag);

            // makeDraggable(textRef2studyLabel);

            if (each.a_mode < each.b_mode) {
                svg.append('marker')
                    .attr('id', 'arrow-marker-left')
                    .attr('viewBox', '0 0 10 10')
                    .attr('refX', 1)
                    .attr('refY', 5)
                    .attr('markerWidth', 6)
                    .attr('markerHeight', 9)
                    .attr('orient', 'auto')
                    .append('path')
                    .attr('d', 'M 0 0 L 10 5 L 0 10 z')
                    .attr('fill', colorScale(ref2study));

                svg.append('line')
                    .attr('x1', x2Scale(study_full))
                    .attr('y1', y3Scale(ref2studyYpos.Yvalue) * 0.8)
                    .attr('x2', x2Scale(study_full - parseFloat(each.b_mode - each.a_mode)))
                    .attr('y2', y3Scale(ref2studyYpos.Yvalue) * 0.8)
                    .attr('stroke', colorScale(ref2study))
                    .attr('marker-end', 'url(#arrow-marker-left)');
            } else {
                svg.append('marker')
                    .attr('id', 'arrow-marker-right')
                    .attr('viewBox', '0 0 10 10')
                    .attr('refX', 1)
                    .attr('refY', 5)
                    .attr('markerWidth', 6)
                    .attr('markerHeight', 9)
                    .attr('orient', 'auto')
                    .append('path')
                    .attr('d', 'M 0 0 L 10 5 L 0 10 z')
                    .attr('fill', colorScale(ref2study));

                svg.append('line')
                    .attr('x1', x2Scale(study_full))
                    .attr('y1', y3Scale(ref2studyYpos.Yvalue) * 0.8)
                    .attr('x2', x2Scale(study_full + parseFloat(each.a_mode - each.b_mode)))
                    .attr('y2', y3Scale(ref2studyYpos.Yvalue) * 0.8)
                    .attr('stroke', colorScale(ref2study))
                    .attr('marker-end', 'url(#arrow-marker-right)');
            }
        })

        var ksOpacity = 0.2;
        var anchorsOpacity = 0.5;

        svg.append("g")
            .attr("class", "rect-bar-reference")
            .selectAll("rect")
            .data(paralogData)
            .join("rect")
            .attr("id", (d) => "Ks_" + d.ks)
            .attr("x", function (d, i) { return x2Scale(d.ks) - width / 200 * 0.9; })
            .attr("y", function (d) { return y2Scale(d.x); })
            .attr("width", width / 200 * 1.35)
            .attr("height", function (d) { return height - bottomPadding - y2Scale(d.x); })
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
                var xMatches = KsInfo.filter(function (item) { return item.ks === d.ks && item.title.startsWith(d.title.split(".")[0]); });
                xMatches.sort(function (a, b) { return b.x - a.x; });
                let content = "<font color='#ff7575'><i>K</i><sub>s</sub></font>: " + d.ks + "<br>";
                xMatches.forEach(function (match) {
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
                    duration: [200, 200]
                });
            })
            .on("mouseout", function (event, d) {
                tippy.hideAll();
            });

        var line = d3.line()
            .x(function (d) { return x2Scale(d.ks); })
            .y(function (d) { return y2Scale(d.x); })
            .curve(d3.curveCatmullRom.alpha(0.8));

        var groupedLineData = d3.group(paralogData, function (d) {
            return d.title;
        });

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

        var paralogIdData = titles.filter(function (d) {
            var paralogIdFile = paralogId + ".ks";
            var paralogIdAnchorsFile = paralogId + ".ks_anchors";
            return (d === paralogIdFile) || (d === paralogIdAnchorsFile);
        });

        var legend = svg.append("g")
            .attr("class", "legend")
            .attr("transform", `translate(${ width - leftPadding - 200 }, 40)`);

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
        downloadSVG("ksPlotRateDownload",
            plotId,
            plotId + ".svg"
        )
    }
}

Shiny.addCustomMessageHandler("Bar_Density_Plotting_OLD", mixBarDensityPlottingOLD);
function mixBarDensityPlottingOLD(InputData) {
    // Load D3.js version 7
    var scriptV7 = document.createElement('script');
    scriptV7.src = 'https://d3js.org/d3.v7.min.js';
    document.head.appendChild(scriptV7);

    scriptV7.onload = function () {

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
        var namesInfo = convertShinyData(InputData.species_list);

        const colors = [
            "#9B3A4D", "#32AEEC", "#E2AE79", "#8E549E", "#EA7500",
            "#566CA5", "#D2352C", "#394A92", "#68AC57", "#F4C28F"
        ];


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
            .attr("font-size", "12px");

        svg.append("g")
            .attr("class", "xTitle")
            .append("text")
            .attr("x", d3.mean([leftPadding - 30, width]))
            .attr("y", height - 10)
            .attr("text-anchor", "middle")
            .append("tspan")
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
                .attr("transform", function () {
                    return `rotate(-90, ${ d3.select(this).attr("x") }, ${ d3.select(this).attr("y") })`;
                })
                .text("Number of retained duplicates");

            var yScale = d3.scaleLinear()
                .domain([0, KsYlimit])
                .range([height - bottomPadding, topPadding]);
            var ytickValues = d3.range(0, KsYlimit + 1, 200);
            var yAxis = d3.axisLeft(yScale)
                .tickValues(ytickValues);

            svg.append("g")
                .attr("class", "axis axis--y")
                .attr("transform", `translate(${ leftPadding - 5 }, 0)`)
                .call(yAxis)
                .attr("font-size", "12px");

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

            console.log("d3.version", d3.version);

            console.log("KsDensityInfo", KsDensityInfo)
            var groupedData = Array.from(d3.group(KsDensityInfo, d => d.title), ([key, values]) => ({ key, values }));
            console.log("groupedData", groupedData);
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
                .attr("font-size", "12px");

            svg.append("g")
                .attr("class", "y2Title")
                .append("text")
                .attr("y", d3.mean([topPadding, height - bottomPadding]))
                .attr("x", width - rightPadding + 50)
                .attr("text-anchor", "middle")
                .attr("font-size", "14px")
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
            );

            // Add relative rate test output to plot
            rateCorrectionInfo.forEach(function (each, i) {
                var ref_full = parseFloat(each.a_mode) + parseFloat(each.c_mode);
                var cal_full = parseFloat(each.b_mode) + parseFloat(each.c_mode);

                var firstOutgroupElement = namesInfo.find(function (info) {
                    return info.latin_name === each.outgroup.replace("_", " ");
                });
                var firstRefElement = namesInfo.find(function (info) {
                    return info.latin_name === each.ref.replace("_", " ");
                });
                var firstStudyElement = namesInfo.find(function (info) {
                    return info.latin_name === each.study.replace("_", " ");
                });

                var matchingTitles = titles.filter(function (item) {
                    return item.includes(firstOutgroupElement.informal_name);
                });
                var study2outgroup = matchingTitles.find(function (item) {
                    return item.includes(firstStudyElement.informal_name);
                });
                var ref2outgroup = matchingTitles.find(function (item) {
                    return item.includes(firstRefElement.informal_name);
                });

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
                    if (each.outgroup.includes("_")) {
                        var ref2outgroupLabel = each.outgroup.replace(/(\w)\w+_(\w+)/, "$1. $2") +
                            " - " + each.ref.replace(/(\w)\w+_(\w+)/, "$1. $2");
                    } else {
                        var ref2outgroupLabel = each.outgroup.replace(/(\w)\w+\s(\w+)/, "$1. $2") +
                            " - " + each.ref.replace(/(\w)\w+\s(\w+)/, "$1. $2");
                    }
                    svg.append('text')
                        .attr('x', xScale(maxModeSum + 0.1))
                        .attr('y', y2Scale(rateYpos + i * 0.4) + 3)
                        .text(ref2outgroupLabel)
                        .attr('fill', colorScale(ref2outgroup))
                        .attr("font-size", "10px")
                        .attr('text-anchor', 'start')
                        // .attr("font-family", "calibri")
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

                if (each.outgroup.includes("_")) {
                    var study2outgroupLabel = each.outgroup.replace(/(\w)\w+_(\w+)/, "$1. $2") +
                        " - " + each.study.replace(/(\w)\w+_(\w+)/, "$1. $2");
                } else {
                    var study2outgroupLabel = each.outgroup.replace(/(\w)\w+\s(\w+)/, "$1. $2") +
                        " - " + each.study.replace(/(\w)\w+\s(\w+)/, "$1. $2");
                }

                svg.append('text')
                    .attr('x', xScale(maxModeSum + 0.1))
                    .attr('y', y2Scale(rateYpos + i * 0.4 + 0.15) + 3)
                    .text(study2outgroupLabel)
                    .attr('fill', colorScale(study2outgroup))
                    .attr("font-size", "10px")
                    .attr('text-anchor', 'start')
                    // .attr("font-family", "calibri")
                    .attr("font-style", "italic");

                svg.append('text')
                    .attr('x', xScale(parseFloat(each.c_mode) - 0.2))
                    .attr('y', y2Scale(rateYpos + i * 0.4 + 0.05))
                    .text(floatFormatter(parseFloat(each.c_mode)))
                    .attr('fill', 'grey')
                    .attr("font-size", "10px")
                    .attr('text-anchor', 'end')
                // .attr("font-family", "calibri");

                svg.append('text')
                    .attr('x', xScale(parseFloat(each.c_mode) + 0.2))
                    .attr('y', y2Scale(rateYpos + i * 0.4 + 0.05))
                    .text(floatFormatter(each.a_mode))
                    .attr('fill', colorScale(ref2outgroup))
                    .attr("font-size", "10px")
                // .attr("font-family", "calibri");

                svg.append('text')
                    .attr('x', xScale(parseFloat(each.c_mode) + 0.2))
                    .attr('y', y2Scale(rateYpos + i * 0.4 + 0.2))
                    .text(floatFormatter(each.b_mode))
                    .attr('fill', colorScale(study2outgroup))
                    .attr("font-size", "10px")
                // .attr("font-family", "calibri");
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
                .attr("font-size", "12px");

            svg.append("g")
                .attr("class", "y2Title")
                .append("text")
                .attr("y", d3.mean([topPadding, height - bottomPadding]))
                .attr("x", leftPadding - 50)
                .attr("text-anchor", "middle")
                .attr("font-size", "14px")
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

            // Add relative rate test output to plot
            rateCorrectionInfo.forEach(function (each, i) {

                var ref_full = parseFloat(each.a_mode) + parseFloat(each.c_mode);
                var cal_full = parseFloat(each.b_mode) + parseFloat(each.c_mode);

                var firstOutgroupElement = namesInfo.find(function (info) {
                    return info.latin_name === each.outgroup.replace("_", " ");
                });
                var firstRefElement = namesInfo.find(function (info) {
                    return info.latin_name === each.ref.replace("_", " ");
                })
                var firstStudyElement = namesInfo.find(function (info) {
                    return info.latin_name === each.study.replace("_", " ");
                })

                var matchingTitles = titles.filter(function (item) {
                    return item.includes(firstOutgroupElement.informal_name);
                });
                var study2outgroup = matchingTitles.find(function (item) {
                    return item.includes(firstStudyElement.informal_name);
                });
                var ref2outgroup = matchingTitles.find(function (item) {
                    return item.includes(firstRefElement.informal_name);
                });

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
                    if (each.outgroup.includes("_")) {
                        var ref2outgroupLabel = each.outgroup.replace(/(\w)\w+_(\w+)/, "$1. $2") +
                            " - " + each.ref.replace(/(\w)\w+_(\w+)/, "$1. $2");
                    } else {
                        var ref2outgroupLabel = each.outgroup.replace(/(\w)\w+\s(\w+)/, "$1. $2") +
                            " - " + each.ref.replace(/(\w)\w+\s(\w+)/, "$1. $2");
                    }
                    svg.append('text')
                        .attr('x', xScale(maxModeSum + 0.1))
                        .attr('y', y2Scale(rateYpos + i * 0.4) + 3)
                        .text(ref2outgroupLabel)
                        .attr('fill', colorScale(ref2outgroup))
                        .attr("font-size", "10px")
                        .attr('text-anchor', 'start')
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

                if (each.outgroup.includes("_")) {
                    var study2outgroupLabel = each.outgroup.replace(/(\w)\w+_(\w+)/, "$1. $2") +
                        " - " + each.study.replace(/(\w)\w+_(\w+)/, "$1. $2");
                } else {
                    var study2outgroupLabel = each.outgroup.replace(/(\w)\w+\s(\w+)/, "$1. $2") +
                        " - " + each.study.replace(/(\w)\w+\s(\w+)/, "$1. $2");
                }

                svg.append('text')
                    .attr('x', xScale(maxModeSum + 0.1))
                    .attr('y', y2Scale(rateYpos + i * 0.4 + 0.15) + 3)
                    .text(study2outgroupLabel)
                    .attr('fill', colorScale(study2outgroup))
                    .attr("font-size", "10px")
                    .attr('text-anchor', 'start')
                    .attr("font-style", "italic");

                svg.append('text')
                    .attr('x', xScale(parseFloat(each.c_mode) - 0.2))
                    .attr('y', y2Scale(rateYpos + i * 0.4 + 0.05))
                    .text(floatFormatter(parseFloat(each.c_mode)))
                    .attr('fill', 'grey')
                    .attr("font-size", "10px")
                    .attr('text-anchor', 'end');

                svg.append('text')
                    .attr('x', xScale(parseFloat(each.c_mode) + 0.2))
                    .attr('y', y2Scale(rateYpos + i * 0.4 + 0.05))
                    .text(floatFormatter(each.a_mode))
                    .attr('fill', colorScale(ref2outgroup))
                    .attr("font-size", "10px");

                svg.append('text')
                    .attr('x', xScale(parseFloat(each.c_mode) + 0.2))
                    .attr('y', y2Scale(rateYpos + i * 0.4 + 0.2))
                    .text(floatFormatter(each.b_mode))
                    .attr('fill', colorScale(study2outgroup))
                    .attr("font-size", "10px");
            });
        }

        tippy(".rect bar", { trigger: "mouseenter", followCursor: "initial", delay: [tooltipDelay, null] });

        downloadSVG("ksPlotRateDownload",
            plotId,
            plotId + ".svg"
        )
    }
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

Shiny.addCustomMessageHandler("Paralog_Bar_Plotting", MultipleBarPlotting);
function MultipleBarPlotting(InputData) {
    var plotId = InputData.plot_id;
    var KsInfo = convertShinyData(InputData.ks_bar_df);
    if (typeof InputData.mclust_df !== 'undefined') {
        var KsMclust = convertShinyData(InputData.mclust_df);
    }
    var KsSizerInfo = InputData.sizer_list;
    var KsXlimit = InputData.xlim;
    var KsYlimit = InputData.ylim;
    var barOpacity = InputData.opacity;
    var height = InputData.height;
    var width = InputData.width;
    var ksTitle = InputData.ks_title;
    var namesInfo = convertShinyData(InputData.species_list);
    var dataType = InputData.dataType;

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

    // Load D3.js version 7
    var scriptV7 = document.createElement('script');
    scriptV7.src = 'https://d3js.org/d3.v7.min.js';
    document.head.appendChild(scriptV7);

    scriptV7.onload = function () {

        // Create a div for the modal
        /* var modal = d3.select("body")
            .append("div")
            .attr("class", "modal")
            .style("display", "none");

        // Style the modal
        modal.style("position", "fixed")
            .style("z-index", "1")
            .style("left", "50%")
            .style("top", "50%")
            .style("transform", "translate(-50%, -50%)")
            .style("width", "200px")
            .style("height", "80px")
            .style("background-image", "linear-gradient(to right, #007bff 50%, #f5f5f5 50%)")
            .style("background-size", "200% 100%")
            .style("text-align", "center")
            .style("border-radius", "10px")
            .style("box-shadow", "0px 0px 10px rgba(0, 123, 255, 0.5)");

        // Create a div for the modal content
        var modalContent = modal.append("div")
            .attr("class", "modal-content");

        // Style the modal content
        modalContent.style("position", "absolute")
            .style("top", "0")
            .style("left", "0")
            .style("width", "100%")
            .style("height", "100%")
            .style("background-color", "#f5f5f5")
            .style("border-radius", "10px")
            .style("opacity", "0.9")
            .style("text-align", "center")
            .style("padding", "20px");


        modalContent.append("div")
            .style("text-align", "center")
            .style("font-size", "20px")
            .style("font-weight", "bold")
            .text("Updating ...");

        // Show the modal
        modal.style("display", "block"); */

        setTimeout(function () {
            var subplotWidth = width;
            var subplotHeight = height / numRows;

            d3.select("#" + plotId).selectAll("svg").remove();
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

                var eachKsMclustData;
                if (typeof KsMclust !== 'undefined') {
                    var eachKsMclustData = KsMclust.filter(function (d) {
                        var titleParts = d.title.split(".");
                        return titleParts[0] === species;
                    })
                }

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

                barSubplot(paralogData, eachKsMclustData, latinName, subplot, subplotWidth, subplotHeight * (3 / 4), KsXlimit, maxHeight, barOpacity, ksTitle, KsYlimit, dataType);

                var sizerPlot = KsSizerInfo[ksTitle];

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
            // modal.style("display", "none");
        }, 10);

        downloadSVG("ksPlotParalogousDownload",
            plotId,
            "Paralogous_Ks." + ksTitle + ".svg"
        )
    }
}

function barSubplot(paralogData, eachKsMclustData, latinName, subplot, subplotWidth, subplotHeight, KsXlimit, maxHeight, barOpacity, ksTitle, KsYlimit, dataType) {
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
    // .attr("font-family", "calibri");

    subplot.append("g")
        .attr("class", "xTitle")
        .append("text")
        .attr("x", d3.mean([leftPadding - 30, subplotWidth]))
        .attr("y", subplotHeight - 10)
        .attr("text-anchor", "middle")
        .append("tspan")
        // .attr("font-family", "calibri")
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
        // .attr("font-family", "calibri")
        .attr("transform", function () {
            return `rotate(-90, ${ d3.select(this).attr("x") }, ${ d3.select(this).attr("y") })`;
        })
        .text("Number of retained duplicates");

    // console.log("maxHeight", maxHeight);
    // var KsYlimit = Math.ceil(maxHeight / 500) * 500;
    // console.log("KsYlimit", KsYlimit);

    var yScale = d3.scaleLinear()
        .domain([0, KsYlimit])
        .range([subplotHeight - bottomPadding, topPadding]);

    var desiredTickCount = 7;
    var possibleIntervals = [500, 200, 100, 50, 20, 10];

    var interval;
    for (const tickInterval of possibleIntervals) {
        if (KsYlimit / tickInterval >= (desiredTickCount - 1)) {
            interval = tickInterval;
            break;
        }
    }

    var ytickValues = d3.range(0, KsYlimit + 1, interval);

    var yAxis = d3.axisLeft(yScale)
        .tickValues(ytickValues);

    subplot.append("g")
        .attr("class", "axis axis--y")
        .attr("transform", `translate(${ leftPadding - 5 }, 0)`)
        .call(yAxis)
        .attr("font-size", "12px");

    var barWidth;
    if (paralogData.length > 70) {
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

    const colors = ["blue", "red", "green", "orange", "purple"];
    var legendData = [...new Set(paralogData.map((d) => d.title))];

    // Merge the two legends
    const mergedLegend = subplot.append("g")
        .attr("class", "legend")
        .attr("transform", `translate(${ subplotWidth - 120 }, 30)`);

    if (typeof eachKsMclustData !== 'undefined') {
        const componentData = eachKsMclustData;
        // console.log("componentData", componentData);

        // Function to calculate the standard deviation
        /* function calculateStandardDeviation(data) {
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
        }); */

        // console.log("propZscore", propZScores);

        // const thresholdMultiplier = 2;
        // const propThreshold = thresholdMultiplier * calculateStandardDeviation(propZScores);
        // console.log("propThreshold", propThreshold);

        /* const filteredComponentData = componentData.filter((d, index) => {
            // const propZScore = propZScores[index];
            // console.log("d", d);
            return (d.mode < 2 && d.mode > 0.1);
            // return propZScore <= propThreshold && d.mode < KsXlimit;
        }); */
        const filteredComponentData = componentData;

        // console.log("filteredComponentData", filteredComponentData);

        const colorModeScale = d3.scaleOrdinal()
            .domain(filteredComponentData.map((d, i) => i))
            .range(["#F08080", "skyblue", "#98FB98", "orange", "purple", "#F4A460", "#8B4513", "#7FFFD4"]);

        const paths = subplot.selectAll(".line")
            .data(filteredComponentData);

        paths.enter()
            .append("path")
            .attr("class", "line")
            .merge(paths)
            .attr("d", (d) => {
                // console.log("d", d);
                const prop = d.prop;
                const mean = d.mean;
                const sigmasq = d.sigmasq;

                if (dataType === "Paranome") {
                    var tmpParalogData = paralogData.filter(function (item) {
                        return !item.title.includes("ks_anchors");
                    });
                } else {
                    var tmpParalogData = paralogData.filter(function (item) {
                        return item.title.includes("ks_anchors");
                    });
                }

                var foundItems = tmpParalogData.filter(function (item) {
                    try {
                        var ksBinRange = JSON.parse(item['ks.bin'].replace('(', '[').replace(')', ']'));
                        return d.mode >= ksBinRange[0] && d.mode < ksBinRange[1];
                    } catch (error) {
                        console.error('Error parsing ks.bin:', error.message);
                        return false;
                    }
                });
                /* 
                                var max_x = Math.max(...foundItems.map(item => item.x));
                                var max_x_index = tmpParalogData.findIndex(item => item.x === max_x);
                
                                var leftTwoRows = tmpParalogData.slice(Math.max(0, max_x_index - 2), max_x_index);
                                var rightTwoRows = tmpParalogData.slice(max_x_index + 1, max_x_index + 3);
                
                                var allFiveRows = [...leftTwoRows, foundItems[0], ...rightTwoRows];
                
                                var max_x_item = allFiveRows.reduce((maxItem, currentItem) => (currentItem.x > maxItem.x ? currentItem : maxItem), allFiveRows[0]);
                
                                console.log("max_x_item", max_x_item);
                                console.log("foundItems", foundItems); */
                var ySimHeight = foundItems[0].x;

                const maxProduct = Math.max(...d3.range(0.01, 5, 0.01).map((x) => prop * logNormalPDF(x, mean, Math.sqrt(sigmasq))));
                const scalingFactor = ySimHeight / maxProduct;

                const simulationData = d3.range(0.01, 5, 0.01).map((x) => ({
                    x,
                    y: scalingFactor * prop * logNormalPDF(x, mean, Math.sqrt(sigmasq)),
                }));
                /* 
                                function logNormalPDF(x, mean, sigma) {
                                    return (1 / (x * sigma * Math.sqrt(2 * Math.PI))) * Math.exp(-(Math.pow(Math.log(x) - mean, 2) / (2 * sigma * sigma)));
                                } */

                return d3.line()
                    .x((d) => xScale(d.x))
                    .y((d) => yScale(d.y))(simulationData);
            })
            .style("stroke", (d, i) => colorModeScale(i))
            .style("stroke-width", 2.3)
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
            .text((d) => `Peak: ${ floatFormatter(d.mode) }`)
            // .attr("font-family", "calibri")
            .attr("font-size", "12px")
            .attr("fill", "#333");
    }

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
        // .attr("font-family", "calibri")
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
        // .attr("font-family", "calibri")
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
        // .attr("font-family", "calibri")
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
        // .attr("font-family", "calibri")
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
    // .attr("font-family", "calibri");
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
    // .attr("font-family", "calibri");

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
    // Load D3.js version 7
    var scriptV7 = document.createElement('script');
    scriptV7.src = 'https://d3js.org/d3.v7.min.js';
    document.head.appendChild(scriptV7);

    scriptV7.onload = function () {
        var plotId = InputData.plot_id;
        var KsDensityInfo = convertShinyData(InputData.ks_density_df);
        var KsXlimit = InputData.xlim;
        var KsY2limit = InputData.ylim;
        var densityOpacity = InputData.opacity || 0.6;
        var height = InputData.height;
        var width = InputData.width;
        var namesInfo = convertShinyData(InputData.names_df);

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
        // console.log(d3.version);

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
        // .attr("font-family", "calibri");

        svg.append("g")
            .attr("class", "xTitle")
            .append("text")
            .attr("x", d3.mean([leftPadding - 30, width]))
            .attr("y", height - 10)
            .attr("text-anchor", "middle")
            .append("tspan")
            // .attr("font-family", "calibri")
            .html("<tspan style='font-style: italic;'>K</tspan>")
            .style("font-size", "14px")
            .append("tspan")
            .text("s")
            .style("font-size", "12px")
            .attr("dx", "1px")
            .attr("dy", "2px");

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
        // .attr("font-family", "calibri");

        svg.append("g")
            .attr("class", "y2Title")
            .append("text")
            .attr("y", d3.mean([topPadding, height - bottomPadding]))
            .attr("x", leftPadding - 45)
            .attr("text-anchor", "middle")
            .attr("font-size", "14px")
            // .attr("font-family", "calibri")
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

                var speciesList = d.key.replace(/\.ks/, "").split('_');
                var speciesOne = namesInfo.find(info => info.informal_name === speciesList[0]).latin_name;
                var speciesTwo = namesInfo.find(info => info.informal_name === speciesList[1]).latin_name;

                var name = speciesOne.replace(/(\w)\w+\s(\w+)/, "$1. $2") +
                    " - " + speciesTwo.replace(/(\w)\w+\s(\w+)/, "$1. $2");

                var content = "<span style='color: " + highlightColor + "; background-color: " + color + ";'><i>" + name + "</i></span> <br> Peak: <span style='color: red;'>" +
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
            .text(function (d) {
                var speciesList = d.replace(/\.ks/, "").split('_');
                var speciesOne = namesInfo.find(info => info.informal_name === speciesList[0]).latin_name;
                var speciesTwo = namesInfo.find(info => info.informal_name === speciesList[1]).latin_name;

                var label = speciesOne.replace(/(\w)\w+\s(\w+)/, "$1. $2") +
                    " - " + speciesTwo.replace(/(\w)\w+\s(\w+)/, "$1. $2");

                return label;
            })
            .attr('text-anchor', 'start')
            // .attr("font-family", "calibri")
            .attr("font-size", "12px")
            .attr("font-style", "italic");

        tippy(".rect bar", { trigger: "mouseenter", followCursor: "initial", delay: [tooltipDelay, null] });
        downloadSVG("ksPlotOrthologousDownload",
            plotId,
            plotId + ".svg"
        )
    }
};


Shiny.addCustomMessageHandler("Otholog_Density_Tree_Plotting", DensityTreePlotting);
function DensityTreePlotting(InputData) {
    var script = document.createElement('script');
    script.src = 'https://d3js.org/d3.v3.min.js';
    document.head.appendChild(script);
    script.onload = function () {
        var plotId = InputData.plot_id;
        var KsDensityInfo = convertShinyData(InputData.ks_density_df);
        var KsXlimit = InputData.xlim;
        var KsYlimit = InputData.ylim;
        var densityOpacity = InputData.opacity;
        var height = InputData.height;
        var width = InputData.width;
        var namesInfo = convertShinyData(InputData.names_df);
        var treeTopology = InputData.tree_topology;

        var paralogBarData = InputData.ks_bar_df;
        var paralogSpecies = InputData.ortholog_paralog_species;
        var y2Limit = InputData.y2lim;

        let topPadding = 50;
        let bottomPadding = 50;
        let leftPadding = 80;
        let rightPadding = 50;
        var tooltipDelay = 500;

        d3.select("#" + plotId).select("svg").remove();
        d3.selectAll("body svg").remove();

        var svg = d3.select("#" + plotId)
            .append("svg")
            .attr("width", width)
            .attr("height", height);

        var xScale = d3.scale.linear()
            .domain([0, KsXlimit])
            .range([0 + leftPadding, (width - rightPadding) / 2]);

        var kde = kernelDensityEstimator(kernelEpanechnikov(0.25), xScale.ticks(500));

        var nest = d3.nest()
            .key(function (d) { return d.title; });

        var groupedData = nest.map(KsDensityInfo);
        groupedData = Object.keys(groupedData).map(function (key) {
            return { key: key, values: groupedData[key] };
        });

        var densityData = groupedData.map(function (d) {
            var density = kde(d.values.map(function (d) { return d.ks; }));
            return { key: d.key, density: density };
        });

        var treeTopologyJson = parseTreeTopology(treeTopology);

        var treeLayoutSize = [height - bottomPadding - topPadding - 50, (width - leftPadding - rightPadding) / 2 - 200];

        var tree = d3.layout.cluster()
            .size(treeLayoutSize)
            .separation(function (a, b) {
                return 1;
            })
            .sort(function (node) {
                return node.children ? node.children.length : -1;
            })
            .children(function (node) {
                return node.branchset;
            });

        var diagonal = rightAngleDiagonal();
        var treeNodes = tree(treeTopologyJson);
        var links = tree.links(treeNodes);

        var speciesToNodeMap = {};
        tree.nodes(treeTopologyJson).forEach(function (node) {
            if (node.children) {
                return;
            }
            var speciesName = node.name.replace("_", " ");
            speciesToNodeMap[speciesName] = node;
        });

        function findLowestCommonAncestor(node1, node2) {
            var ancestors1 = new Set();
            while (node1) {
                ancestors1.add(node1);
                node1 = node1.parent;
            }

            while (node2) {
                if (ancestors1.has(node2)) {
                    return node2;
                }
                node2 = node2.parent;
            }

            return null;
        }

        var ancestorCounts = {};
        var nodeGroupedSpecies = {}
        densityData.forEach(function (data, index) {
            var speciesList = data.key.replace(/\.ks/, "").split('_');
            var speciesOne = namesInfo.find(function (info) {
                return info.informal_name === speciesList[0];
            }).latin_name;
            var speciesTwo = namesInfo.find(function (info) {
                return info.informal_name === speciesList[1];
            }).latin_name;

            var nodeOne = speciesToNodeMap[speciesOne];
            var nodeTwo = speciesToNodeMap[speciesTwo];

            var commonAncestor = findLowestCommonAncestor(nodeOne, nodeTwo);
            var ancestorKey = commonAncestor.id;
            if (!ancestorCounts[ancestorKey]) {
                ancestorCounts[ancestorKey] = 1;
                nodeGroupedSpecies[ancestorKey] = [data.key];
            } else {
                ancestorCounts[ancestorKey]++;
                nodeGroupedSpecies[ancestorKey].push(data.key);
            }
        });

        var colorSchemes = {
            "NewGreens": ['#1B7837', '#5AAE61', '#ACD39E', '#D9F0D3', "#edf8e9"],
            "newBlues": ['#364B9A', '#4A7BB7', '#6EA6CD', '#98CAE1', '#C2E4EF'],
            "newPurples": ['#762A83', '#9970AB', '#C2A5CF', '#E7D4E8', '#F7F7F7'],
            "newReds": ['#EAECCC', '#FEDA8B', '#FDB366', '#F67E4B', '#DD3D2D'],
            "blacks": ["#252525", "#636363", "#969696", "#cccccc", "#f7f7f7"]
        }
        var groupColorKeys = Object.keys(colorSchemes);

        var finalColorList = [];
        var finalValueList = [];
        Object.keys(nodeGroupedSpecies).forEach(function (mainGroup, index) {
            var subvalues = nodeGroupedSpecies[mainGroup];

            var colorSchemeKey = groupColorKeys[index];
            var colorScheme = colorSchemes[colorSchemeKey];
            var colorSelected = colorScheme.slice(0, subvalues.length);

            finalColorList = finalColorList.concat(colorSelected);
            finalValueList = finalValueList.concat(subvalues);
        });

        var colorScale = d3.scale.ordinal()
            .domain(finalValueList)
            .range(finalColorList);

        var titles = [...new Set(KsDensityInfo.map(d => d.title))];;
        const titleCount = titles.length;

        var xtickValues = d3.range(0, KsXlimit + 1, 1);
        var xAxis = d3.svg.axis()
            .scale(xScale)
            .tickValues(xtickValues)
            .tickFormat(d3.format("d"))
            .tickSize(1)
            .tickPadding(7)
            .orient("bottom");

        svg.append("g")
            .attr("class", "axis axis--x")
            .attr("transform", "translate(0," + (height - bottomPadding) + ")")
            .call(xAxis)
            .selectAll("text")
            .attr("font-size", "12px");

        d3.selectAll(".axis--x line")
            .attr("y2", 6)
            .style("stroke-width", 1)
            .style("stroke", "black");

        svg.append("g")
            .attr("class", "xTitle")
            .append("text")
            .attr("x", d3.mean([leftPadding - 30, (width - rightPadding) / 2]))
            .attr("y", height - 10)
            .attr("text-anchor", "middle")
            .append("tspan")
            .html("<tspan style='font-style: italic;'>K</tspan>")
            .style("font-size", "14px")
            .append("tspan")
            .text("s")
            .style("font-size", "12px")
            .attr("dx", "1px")
            .attr("dy", "2px");

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

        var yScale = d3.scale.linear()
            .domain([0, KsYlimit])
            .range([height - bottomPadding, topPadding]);

        var ytickValues = d3.range(0, KsYlimit + 0.1, 0.2);
        if (typeof paralogBarData !== 'undefined') {
            var yAxis = d3.svg.axis()
                .scale(yScale)
                .tickValues(ytickValues)
                .tickPadding(7)
                .tickSize(1)
                .orient("right");

            svg.append("g")
                .attr("class", "axis axis--yt")
                .attr("transform", "translate(" + ((width - rightPadding) / 2 + 5) + ", 0)")
                .call(yAxis)
                .attr("font-size", "12px");

            d3.selectAll(".axis--yt line")
                .attr("x2", 6)
                .style("stroke-width", 1)
                .style("stroke", "black");

            svg.append("g")
                .attr("class", "y2Title")
                .append("text")
                .attr("y", d3.mean([topPadding, height - bottomPadding]))
                .attr("x", (width - rightPadding) / 2 + 60)
                .attr("text-anchor", "middle")
                .attr("font-size", "14px")
                .attr("transform", function () {
                    return `rotate(-90, ${ d3.select(this).attr("x") }, ${ d3.select(this).attr("y") })`;
                })
                .text("Ortholog Density");
        } else {
            var yAxis = d3.svg.axis()
                .scale(yScale)
                .tickValues(ytickValues)
                .tickPadding(7)
                .tickSize(1)
                .orient("left");

            svg.append("g")
                .attr("class", "axis axis--yt")
                .attr("transform", "translate(" + (leftPadding - 5) + ", 0)")
                .call(yAxis)
                .attr("font-size", "12px");

            d3.selectAll(".axis--yt line")
                .attr("x2", -6)
                .style("stroke-width", 1)
                .style("stroke", "black");

            svg.append("g")
                .attr("class", "y2Title")
                .append("text")
                .attr("y", d3.mean([topPadding, height - bottomPadding]))
                .attr("x", leftPadding - 45)
                .attr("text-anchor", "middle")
                .attr("font-size", "14px")
                .attr("transform", function () {
                    return `rotate(-90, ${ d3.select(this).attr("x") }, ${ d3.select(this).attr("y") })`;
                })
                .text("Ortholog Density");
        }

        // Create the area generator
        var area = d3.svg.area()
            .x(function (d) { return xScale(d[0]); })
            .y0(height - bottomPadding)
            .y1(function (d) { return yScale(d[1]); });

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
            .attr("data-tippy-content", function (d, i) {
                var maxDensity = d3.max(d.density, function (m) {
                    return m[1];
                });

                var maxDensityData = d.density.find(function (d) {
                    return d[1] === maxDensity;
                });

                var maxDensityKs = maxDensityData ? maxDensityData[0] : undefined;

                svg.append("line")
                    .attr("x1", xScale(maxDensityData[0]))
                    .attr("y1", yScale(0))
                    .attr("x2", xScale(maxDensityData[0]))
                    .attr("y2", yScale(maxDensity) - 20)
                    .style("stroke", colorScale(d.key))
                    .style("stroke-width", "1.4")
                    .style("stroke-dasharray", "5, 5");

                var nintyfiveCI = confidenceIntervals[i].confidenceInterval;
                svg.append("rect")
                    .attr("x", xScale(nintyfiveCI[0]))
                    .attr("y", yScale(maxDensity) - 20)
                    .attr("width", xScale(nintyfiveCI[1]) - xScale(nintyfiveCI[0]))
                    .attr("height", yScale(0) - yScale(maxDensity))
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

                var speciesList = d.key.replace(/\.ks/, "").split('_');
                var speciesOne = namesInfo.find(function (info) {
                    return info.informal_name === speciesList[0];
                }).latin_name;
                var speciesTwo = namesInfo.find(function (info) {
                    return info.informal_name === speciesList[1];
                }).latin_name;

                var name = speciesOne.replace(/(\w)\w+\s(\w+)/, "$1. $2") +
                    " - " + speciesTwo.replace(/(\w)\w+\s(\w+)/, "$1. $2");

                var content = "<span style='color: " + highlightColor + "; background-color: " + color + ";'><i>" + name + "</i></span> <br> Peak: <span style='color: red;'>" +
                    maxDensityKs + "</span> (Density: <span style='color: " + color + ";'>" + maxDensity.toFixed(2) + "</span>)<br>" +
                    "95% CIs: <span style='color: " + highlightColor + "; background-color: " + color + "';>" + nintyfiveCI[0].toFixed(2) + " <--> " + nintyfiveCI[1].toFixed(2) + "</span>";

                var circleRadius = 5;
                var circleY = yScale(maxDensity) - 40;
                svg.append("circle")
                    .attr("cx", xScale(maxDensityData[0]))
                    .attr("cy", circleY)
                    .attr("r", circleRadius)
                    .style("fill", colorScale(d.key))
                    .style("fill-opacity", 0.6)
                    .style("stroke", colorScale(d.key))
                    .style("stroke-opacity", 1)
                    .attr("stroke-width", "1.2")
                    .attr("data-tippy-content", content)
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
        var legendData = [...new Set(groupedData.map(function (d) { return d.key; }))];

        var longestLabel = legendData.reduce(function (max, currentValue) {
            if (currentValue.length > max.length) {
                return { value: currentValue, length: currentValue.length };
            } else {
                return max;
            }
        }, { value: "", length: 0 });

        var legend = svg.append("g")
            .attr("class", "legend")
            .attr("transform", "translate(" + (width / 2 - longestLabel.length * 8) + ", 20)");

        var legendItems = legend.selectAll(".legend-item")
            .data(legendData)
            .enter()
            .append("g")
            .attr("class", "legend-item")
            .attr("transform", function (d, i) { return "translate(0," + (i * 20) + ")"; });

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
            .text(function (d) {
                var speciesList = d.replace(/\.ks/, "").split('_');
                var speciesOne = namesInfo.find(function (info) { return info.informal_name === speciesList[0]; }).latin_name;
                var speciesTwo = namesInfo.find(function (info) { return info.informal_name === speciesList[1]; }).latin_name;

                var label = speciesOne.replace(/(\w)\w+\s(\w+)/, "$1. $2") +
                    " - " + speciesTwo.replace(/(\w)\w+\s(\w+)/, "$1. $2");

                return label;
            })
            .attr('text-anchor', 'start')
            .attr("font-size", "12px")
            .attr("font-style", "italic");

        tippy(".rect bar", { trigger: "mouseenter", followCursor: "initial", delay: [tooltipDelay, null] });

        if (typeof paralogBarData !== 'undefined') {
            var paralogBarInfo = convertShinyData(paralogBarData);
            var titles = [...new Set(paralogBarInfo.map(d => d.title))];

            const colors = ["#696969", "#2F4F4F"];

            var barColorScale = d3.scale.ordinal()
                .domain(titles)
                .range(colors);

            var y2Scale = d3.scale.linear()
                .domain([0, y2Limit])
                .range([height - bottomPadding, topPadding]);

            var desiredTickCount = 7;
            var possibleIntervals = [500, 200, 100, 50, 20, 10];

            var interval;
            for (const tickInterval of possibleIntervals) {
                if (y2Limit / tickInterval >= (desiredTickCount - 1)) {
                    interval = tickInterval;
                    break;
                }
            }

            var y2tickValues = d3.range(0, y2Limit + 1, interval);

            var y2Axis = d3.svg.axis()
                .scale(y2Scale)
                .tickValues(y2tickValues)
                .tickFormat(d3.format("d"))
                .tickSize(1)
                .tickPadding(7)
                .orient("left");

            svg.append("g")
                .attr("class", "axis axis--y2")
                .attr("transform", "translate(" + (leftPadding - 5) + ", 0)")
                .call(y2Axis)
                .attr("font-size", "12px");

            d3.selectAll(".axis--y2 line")
                .attr("x2", -6)
                .style("stroke-width", 1)
                .style("stroke", "black");

            svg.append("g")
                .attr("class", "yTitle")
                .append("text")
                .attr("y", d3.mean([topPadding, height - bottomPadding]))
                .attr("x", leftPadding - 45)
                .attr("text-anchor", "middle")
                .attr("font-size", "14px")
                .attr("transform", function () {
                    return `rotate(-90, ${ d3.select(this).attr("x") }, ${ d3.select(this).attr("y") })`;
                })
                .text("Number of retained duplicates");

            var ksOpacity = 0.4;
            var anchorsOpacity = 0.6;

            var bars = svg.append("g")
                .attr("class", "rect bar")
                .selectAll("rect")
                .data(paralogBarInfo);

            bars.enter().append("rect")
                .attr("x", function (d) {
                    return xScale(d.ks) - (width - rightPadding) / 2 / 100 * 0.9;
                })
                .attr("y", function (d) {
                    return y2Scale(d.x);
                })
                .attr("width", (width - rightPadding) / 2 / 100 * 1.35)
                .attr("height", function (d) { return height - bottomPadding - y2Scale(d.x); })
                .attr("fill", function (d) {
                    return barColorScale(d.title);
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
                    var xMatches = paralogBarInfo.filter(function (item) { return item.ks === d.ks && item.title.startsWith(d.title.split(".")[0]); });
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

            var orthologLegendNum = legendData.length;

            var paraloglegend = svg.append("g")
                .attr("class", "legend")
                .attr("transform", "translate(" + (width / 2 - longestLabel.length * 8) + "," + (20 + 20 * orthologLegendNum) + ")");

            var legendItems = paraloglegend.selectAll(".legend-item-paralog")
                .data(titles)
                .enter()
                .append("g")
                .attr("class", "legend-item-paralog")
                .attr("transform", function (d, i) { return `translate(0, ${ i * 20 })`; });

            legendItems.append("rect")
                .attr("x", 0)
                .attr("y", 0)
                .attr("width", 10)
                .attr("height", 10)
                .attr("fill", function (d) {
                    return barColorScale(d.title);
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
        }

        // Create the tree plot
        var treeGroup = svg.append("g")
            .attr("transform", "translate(" + (width + leftPadding + rightPadding + 100) / 2 + "," + (topPadding + bottomPadding) + ")");

        var link = treeGroup.selectAll(".link")
            .data(links)
            .enter().append("path")
            .attr("class", "link")
            .attr("d", diagonal)
            .attr("fill", "none")
            .attr("stroke", "#aaa")
            .attr("stroke-width", "2.45px");

        var ksNode = treeGroup.selectAll("g.tree-node")
            .data(treeNodes)
            .enter().append("svg:g")
            .attr("class", function (n) {
                if (n.children) {
                    if (n.depth === 0) {
                        return "tree-root-node";
                    } else {
                        return "tree-inner-node";
                    }
                } else {
                    return "tree-leaf-node";
                }
            })
            .attr("transform", function (d) {
                return "translate(" + d.y + "," + d.x + ")";
            });

        treeGroup.selectAll('g.tree-leaf-node')
            .append("svg:text")
            .attr("class", "my-text")
            .attr("dx", 8)
            .attr("dy", 3)
            .attr("text-anchor", "start")
            .attr("font-size", "14px")
            .attr('fill', 'black')
            .text(function (d) {
                var name = d.name.replace(/_/g, ' ');
                name = name.replace(/(\w)\w+\s(\w+)/, "$1. $2")
                return name;
            })
            .attr('font-style', function (d) {
                if (d.name.match(/\_/)) {
                    return 'italic';
                } else {
                    return 'normal';
                }
            });

        d3.select('.circle-pop-up-menu').remove();
        var circlePopUpMenu = d3.select("#" + plotId)
            .append('div')
            .classed('circle-pop-up-menu', true)
            .style('position', 'absolute')
            .style('top', 0)
            .style('left', 0)
            .style('visibility', 'hidden')
            .style('background-color', 'white');

        Object.keys(nodeGroupedSpecies).forEach(function (eachNode, index) {
            var subvalues = nodeGroupedSpecies[eachNode];

            var selectedNode = treeNodes.filter(function (d) { return d.id == eachNode; });

            if (subvalues.length === 1) {
                var speciesList = subvalues[0].replace(/\.ks/, "").split('_');
                var speciesOne = namesInfo.find(function (info) {
                    return info.informal_name === speciesList[0];
                }).latin_name;
                var speciesTwo = namesInfo.find(function (info) {
                    return info.informal_name === speciesList[1];
                }).latin_name;

                var name = speciesOne.replace(/(\w)\w+\s(\w+)/, "$1. $2") +
                    " - " + speciesTwo.replace(/(\w)\w+\s(\w+)/, "$1. $2");

                var eachDensityData = densityData.filter(function (d) { return d.key === subvalues[0]; });

                var maxDensity = d3.max(eachDensityData[0].density, function (m) {
                    return m[1];
                });

                var maxDensityData = eachDensityData[0].density.find(function (d) {
                    return d[1] === maxDensity;
                });

                var maxDensityKs = maxDensityData ? maxDensityData[0] : undefined;

                treeGroup.append("circle")
                    .attr("class", "tree-circle")
                    .attr("cx", selectedNode[0].y)
                    .attr("cy", selectedNode[0].x)
                    .attr("r", 8)
                    .style("fill", colorScale(subvalues[0]))
                    .style("fill-opacity", 0.6)
                    .style("stroke", colorScale(subvalues[0]))
                    .style("stroke-opacity", 1)
                    .attr("stroke-width", "1.2")
                    .attr("data-tippy-content", function () {
                        var peakContent = "<i>" + name + "</i><br>Peak: <span style='color: " + colorScale(subvalues[0]) + ";'>" + maxDensityKs + "</span><br>";
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
                    })
                    .on('click', function (d) {
                        if (circlePopUpMenu.style('visibility') == 'visible') {
                            circlePopUpMenu.style('visibility', 'hidden');
                        } else {
                            circlePopUpMenu.html("<p><button id='deleteComparisonIcon'>&#128465;&nbsp;Delete " +
                                "<i><b><span style='color: " + colorScale(subvalues[0]) + ";'>" + name + "</b></i></span>" +
                                " comparison</button ></p>");

                            var fillColor = d3.select(this).style('fill');
                            var strokeColor = d3.select(this).style('stroke');
                            d3.select('#deleteComparisonIcon').on('click', function () {
                                d3.selectAll('*')
                                    .filter(function () {
                                        return d3.select(this).style('fill') === fillColor ||
                                            d3.select(this).style('stroke') === strokeColor;
                                    })
                                    .remove();

                                d3.selectAll('text')
                                    .filter(function () {
                                        return d3.select(this).text() === name;
                                    })
                                    .remove();

                                circlePopUpMenu.style('visibility', 'hidden');

                                legendData = legendData.filter(function (d) { return d !== subvalues[0]; });

                                legend.selectAll(".legend-item").remove();

                                var legendItems = legend.selectAll(".legend-item")
                                    .data(legendData)
                                    .enter()
                                    .append("g")
                                    .attr("class", "legend-item")
                                    .attr("transform", function (d, i) { return "translate(0," + (i * 20) + ")"; });

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
                                    .text(function (d) {
                                        var speciesList = d.replace(/\.ks/, "").split('_');
                                        var speciesOne = namesInfo.find(function (info) { return info.informal_name === speciesList[0]; }).latin_name;
                                        var speciesTwo = namesInfo.find(function (info) { return info.informal_name === speciesList[1]; }).latin_name;

                                        var label = speciesOne.replace(/(\w)\w+\s(\w+)/, "$1. $2") +
                                            " - " + speciesTwo.replace(/(\w)\w+\s(\w+)/, "$1. $2");

                                        return label;
                                    })
                                    .attr('text-anchor', 'start')
                                    .attr("font-size", "12px")
                                    .attr("font-style", "italic");

                                if (typeof paralogBarData !== 'undefined') {
                                    var orthologLegendNum = legendData.length;
                                    svg.selectAll(".legend-item-paralog").remove();

                                    var paraloglegend = svg.append("g")
                                        .attr("class", "legend")
                                        .attr("transform", "translate(" + (width / 2 - longestLabel.length * 8) + "," + (20 + 20 * orthologLegendNum) + ")");

                                    var legendItems = paraloglegend.selectAll(".legend-item-paralog")
                                        .data(titles)
                                        .enter()
                                        .append("g")
                                        .attr("class", "legend-item-paralog")
                                        .attr("transform", function (d, i) { return `translate(0, ${ i * 20 })`; });

                                    legendItems.append("rect")
                                        .attr("x", 0)
                                        .attr("y", 0)
                                        .attr("width", 10)
                                        .attr("height", 10)
                                        .attr("fill", function (d) {
                                            return barColorScale(d.title);
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
                                }

                            });

                            var circleX = parseFloat(d3.select(this).attr("cx")) + (width + leftPadding + rightPadding) / 2 + 30;
                            var circleY = parseFloat(d3.select(this).attr("cy")) + topPadding + 50;
                            circlePopUpMenu.style('left', circleX + 'px')
                                .style('top', circleY + 'px')
                                .style('visibility', 'visible');
                        }
                    });
            } else {
                var circleSpacing = 8;
                var totalCircles = subvalues.length;
                var startingPosition = selectedNode[0].y - (totalCircles + 1) * (circleSpacing / 2);

                subvalues.forEach(function (data, index) {
                    var speciesList = data.replace(/\.ks/, "").split('_');
                    var speciesOne = namesInfo.find(function (info) {
                        return info.informal_name === speciesList[0];
                    }).latin_name;
                    var speciesTwo = namesInfo.find(function (info) {
                        return info.informal_name === speciesList[1];
                    }).latin_name;

                    var name = speciesOne.replace(/(\w)\w+\s(\w+)/, "$1. $2") +
                        " - " + speciesTwo.replace(/(\w)\w+\s(\w+)/, "$1. $2");

                    var eachDensityData = densityData.filter(function (d) { return d.key === data; });

                    var maxDensity = d3.max(eachDensityData[0].density, function (m) {
                        return m[1];
                    });

                    var maxDensityData = eachDensityData[0].density.find(function (d) {
                        return d[1] === maxDensity;
                    });

                    var maxDensityKs = maxDensityData ? maxDensityData[0] : undefined;

                    // Adjust circleX calculation
                    var circleX = startingPosition + (index + 1) * circleSpacing;
                    treeGroup.append("circle")
                        .attr("class", "tree-circle-multiple-" + eachNode + '-' + data.replace(/\.ks/, ""))
                        .attr("cx", circleX)
                        .attr("cy", selectedNode[0].x)
                        .attr("r", 8)
                        .style("fill", colorScale(data))
                        .style("fill-opacity", 0.6)
                        .style("stroke", colorScale(data))
                        .style("stroke-opacity", 1)
                        .attr("stroke-width", "1.2")
                        .attr("data-tippy-content", function () {
                            var peakContent = "<i>" + name + "</i><br>Peak: <span style='color: " + colorScale(data) + ";'>" + maxDensityKs + "</span><br>";
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
                        })
                        .on('click', function (d) {
                            if (circlePopUpMenu.style('visibility') == 'visible') {
                                circlePopUpMenu.style('visibility', 'hidden');
                            } else {
                                circlePopUpMenu.html("<p><button id='deleteComparisonIcon'>&#128465;&nbsp;Delete " +
                                    "<i><b><span style='color: " + colorScale(data) + ";'>" + name + "</b></i></span>" +
                                    " comparison</button ></p>");

                                var fillColor = d3.select(this).style('fill');
                                var strokeColor = d3.select(this).style('stroke');
                                d3.select('#deleteComparisonIcon').on('click', function () {
                                    d3.selectAll('*')
                                        .filter(function () {
                                            return d3.select(this).style('fill') === fillColor ||
                                                d3.select(this).style('stroke') === strokeColor;
                                        })
                                        .remove();

                                    d3.selectAll('text')
                                        .filter(function () {
                                            return d3.select(this).text() === name;
                                        })
                                        .remove();

                                    circlePopUpMenu.style('visibility', 'hidden');

                                    legendData = legendData.filter(function (d) { return d !== data; });

                                    legend.selectAll(".legend-item").remove();

                                    var legendItems = legend.selectAll(".legend-item")
                                        .data(legendData)
                                        .enter()
                                        .append("g")
                                        .attr("class", "legend-item")
                                        .attr("transform", function (d, i) { return "translate(0," + (i * 20) + ")"; });

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
                                        .text(function (d) {
                                            var speciesList = d.replace(/\.ks/, "").split('_');
                                            var speciesOne = namesInfo.find(function (info) { return info.informal_name === speciesList[0]; }).latin_name;
                                            var speciesTwo = namesInfo.find(function (info) { return info.informal_name === speciesList[1]; }).latin_name;

                                            var label = speciesOne.replace(/(\w)\w+\s(\w+)/, "$1. $2") +
                                                " - " + speciesTwo.replace(/(\w)\w+\s(\w+)/, "$1. $2");

                                            return label;
                                        })
                                        .attr('text-anchor', 'start')
                                        .attr("font-size", "12px")
                                        .attr("font-style", "italic");

                                    if (typeof paralogBarData !== 'undefined') {
                                        var orthologLegendNum = legendData.length;

                                        svg.selectAll(".legend-item-paralog").remove();
                                        var paraloglegend = svg.append("g")
                                            .attr("class", "legend")
                                            .attr("transform", "translate(" + (width / 2 - longestLabel.length * 8) + "," + (20 + 20 * orthologLegendNum) + ")");

                                        var legendItems = paraloglegend.selectAll(".legend-item-paralog")
                                            .data(titles)
                                            .enter()
                                            .append("g")
                                            .attr("class", "legend-item-paralog")
                                            .attr("transform", function (d, i) { return `translate(0, ${ i * 20 })`; });

                                        legendItems.append("rect")
                                            .attr("x", 0)
                                            .attr("y", 0)
                                            .attr("width", 10)
                                            .attr("height", 10)
                                            .attr("fill", function (d) {
                                                return barColorScale(d.title);
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
                                    }

                                    subvalues = subvalues.filter(function (d) { return d !== data; });
                                    if (subvalues.length === 1) {
                                        d3.selectAll(".tree-circle-multiple-" + eachNode + '-' + subvalues[0].replace(/\.ks/, ""))
                                            .attr("cx", selectedNode[0].y);
                                    } else {
                                        var totalCircles = subvalues.length;
                                        var startingPosition = selectedNode[0].y - (totalCircles + 1) * (circleSpacing / 2);
                                        subvalues.forEach(function (each, xx) {
                                            var updatedStartX = startingPosition + (xx + 1) * circleSpacing;
                                            d3.selectAll(".tree-circle-multiple-" + eachNode + '-' + each.replace(/\.ks/, ""))
                                                .attr("cx", updatedStartX);
                                        })
                                    }
                                });

                                var circleX = parseFloat(d3.select(this).attr("cx")) + (width + leftPadding + rightPadding) / 2 + 30;
                                var circleY = parseFloat(d3.select(this).attr("cy")) + topPadding + 50;
                                circlePopUpMenu.style('left', circleX + 'px')
                                    .style('top', circleY + 'px')
                                    .style('visibility', 'visible');
                            }
                        });
                })
            }
        });

        downloadSVG("ksPlotOrthologousDownload",
            plotId,
            plotId + ".svg"
        )
    }
}

function parseTreeTopology(treeString) {
    var ancestors = [];
    var tree = {};
    var tokens = treeString
        .split(/\s*(;|\(|\)|,)\s*/)
        .map(token => token.trim())
        .filter(Boolean);
    var cid = 0;
    for (var i = 0; i < tokens.length; i++) {
        var token = tokens[i];
        switch (token) {
            case '(':
                var subtree = {};
                tree.id = cid;
                cid++;
                tree.branchset = [subtree];
                ancestors.push(tree);
                tree = subtree;
                break;
            case ',':
                var subtree = {};
                ancestors[ancestors.length - 1].branchset.push(subtree);
                tree = subtree;
                break;
            case ')':
                tree = ancestors.pop();
                break;
            default:
                var x = tokens[i - 1];
                if (x == ')' || x == '(' || x == ',') {
                    tree.name = token;
                    tree.id = cid;
                    cid++;
                } else {
                    tree.length = 1;
                }
        }
    }
    return tree;
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
