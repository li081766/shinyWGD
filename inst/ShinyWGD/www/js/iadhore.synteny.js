var numFormatter = d3.format(".2f");
/* var colorScale = d3.scaleLinear()
    .domain([0, 5])
    .range(["#e08214", "#b2abd2"]);  */

// var colorScale = d3.scaleSequential()
//    .domain([0, 5])
//    .interpolator(d3.interpolateRgb("red", "blue"));

var colorScale = d3.scaleLinear()
    .domain([0, 1, 2, 3, 5])
    .range(["red", "orange", "green", "#018571", "blue"]);


var script = document.createElement('script');
script.src = 'https://d3js.org/d3.v7.min.js';
document.head.appendChild(script);
script.onload = function () {
    // Your D3 v7 code goes here
    console.log("iadhore d3 version:", d3.version);

    Shiny.addCustomMessageHandler("Parallel_Plotting", ParallelPlottingV2);
    function ParallelPlottingV2(InputData) {
        var plotId = InputData.plot_id;
        var segmentInfo = convertShinyData(InputData.segs);
        var queryChrInfo = convertShinyData(InputData.query_chr_lens);
        var subjectChrInfo = convertShinyData(InputData.subject_chr_lens);
        var width = InputData.width;
        var height = InputData.height;
        var querySpecies = InputData.query_sp;
        var subjectSpecies = InputData.subject_sp;
        var scaleRatio = width / 800;

        /* console.log("segmentInfo", segmentInfo);
        console.log("queryChrInfo", queryChrInfo);
        console.log("subjectChrInfo", subjectChrInfo); */

        queryChrInfo = queryChrInfo.sort(function (a, b) {
            return b.len - a.len;
        });

        subjectChrInfo = subjectChrInfo.sort(function (a, b) {
            return b.len - a.len;
        });

        segmentInfo.sort(function (a, b) {
            return (b.endX - b.startX) - (a.endY - a.startY);
        });

        const query_chr_colors = [
            "#9B3A4D", "#32AEEC", "#E2AE79", "#8E549E", "#EA7500",
            "#566CA5", "#D2352C", "#394A92", "#68AC57", "#F4C28F"
        ];
        const subject_chr_colors = ["#9D9D9D", "#3C3C3C"]

        // draw a parallel syntenic plot
        d3.select("#SyntenicBlock_" + plotId).select("svg").remove();

        var segsRibbonsId = "segsRibbons_" + plotId;
        // console.log(segsRibbonsId);

        // define syntenic plot dimension
        // let width = 850;
        // let height = 250;
        let topPadding = 50;
        let bottomPadding = 20;
        let leftPadding = 10;
        let rightPadding = 50;
        let chrRectHeight = 10;
        var tooltipDelay = 500;

        if (queryChrInfo === subjectChrInfo) {
            var innerPaddingSubject = 10;
            var innerPaddingQuery = 10;
        } else {
            var queryChrLenSum = d3.sum(queryChrInfo.map(e => e.len));
            var subjectChrLenSum = d3.sum(subjectChrInfo.map(e => e.len));
            // console.log("queryChrLenSum", queryChrLenSum);
            // console.log("subjectChrLenSum", subjectChrLenSum);
            if (queryChrLenSum * 0.8 > subjectChrLenSum) {
                var innerPaddingSubject = 10 * queryChrLenSum / subjectChrLenSum * 0.8;
                var innerPaddingQuery = 10;
                var maxChrLen = queryChrLenSum * 0.8;
            } else if (subjectChrLenSum * 0.8 > queryChrLenSum) {
                var innerPaddingQuery = 10 * subjectChrLenSum / queryChrLenSum * 0.8;
                var innerPaddingSubject = 10;
                var maxChrLen = subjectChrLenSum * 0.8;
            } else {
                var innerPaddingSubject = 10;
                var innerPaddingQuery = 10;
                var maxChrLen = queryChrLenSum;
            }
        }
        // console.log("innerPaddingSubject", innerPaddingSubject);
        // console.log("innerPaddingQuery", innerPaddingQuery);

        var middlePoint = (width - leftPadding - rightPadding) / 2;
        const svg = d3.select("#SyntenicBlock_" + plotId)
            .append("svg")
            .attr("width", width)
            .attr("height", height);
        //.attr("viewBox", "0 0 " + width + " " + height);
        // .attr("viewBox", [0, 0, width, height]);

        const innerScale = d3.scaleLinear()
            .domain([0, 1])
            .range([
                0,
                width - leftPadding - rightPadding
            ]);

        function calc_accumulate_len_t(inputChrInfo, maxChrLen, innerPadding_xScale, innerPadding) {
            let acc_len = 0;
            let total_chr_len = d3.sum(inputChrInfo.map(e => e.len));
            let ratio = innerPadding_xScale.invert(innerPadding);
            // console.log("ratio", ratio);
            inputChrInfo.forEach((e, i) => {
                e.idx = i;
                e.accumulate_start = acc_len + 1;
                e.accumulate_end = e.accumulate_start + e.len - 1;
                acc_len = e.accumulate_end + maxChrLen * ratio;
            });
            return inputChrInfo;
        }

        // calculate accumulate chromosome length
        queryChrInfo = calc_accumulate_len_t(queryChrInfo, maxChrLen, innerScale, innerPaddingQuery);
        subjectChrInfo = calc_accumulate_len_t(subjectChrInfo, maxChrLen, innerScale, innerPaddingSubject);
        // plot query chromosomes
        const queryGroup = svg.append("g").attr("class", "queryChrs");
        const subjectGroup = svg.append("g").attr("class", "subjectChrs");

        // choose the sp with larger width to make the scaler
        var queryWidth = d3.max(queryChrInfo, function (d) { return d.accumulate_end; });
        var subjectWidth = d3.max(subjectChrInfo, function (d) { return d.accumulate_end; });
        if (queryWidth >= subjectWidth) {
            var scaleData = queryChrInfo;
        } else {
            var scaleData = subjectChrInfo;
        }

        const ChrScaler = d3
            .scaleLinear()
            .domain([
                scaleData[0].accumulate_start,
                scaleData[scaleData.length - 1].accumulate_end
            ])
            .range([
                0 + leftPadding,
                width - rightPadding
            ]);

        if (queryWidth > subjectWidth) {
            var startX = middlePoint - ChrScaler(subjectWidth) / 2;
        } else if (queryWidth < subjectWidth) {
            var startX = middlePoint - ChrScaler(queryWidth) / 2;
        } else {
            var startX = 0;
        }

        queryGroup.append("text")
            .text(querySpecies)
            .attr("id", "queryMainLabel")
            .attr("x", 5 + leftPadding)
            .attr("y", topPadding - 10) // + d3.select("#queryMainLabel").node().getBBox().height)
            .attr("font-weight", "bold")
            .attr("font-size", 14 * scaleRatio + "px")
            .attr("font-style", "italic")
            // .attr("font-family", "times")
            .style("fill", "#68AC57");

        queryGroup.selectAll("text")
            .attr("class", "queryChrLabel")
            .filter(":not(#queryMainLabel)")
            .data(queryChrInfo)
            .join("text")
            .text((d) => d.seqchr)
            .attr("text-anchor", "left")
            .attr("transform", function (d) {
                if (queryWidth >= subjectWidth) {
                    return "rotate(-30 " + Number(30 + d3.mean([ChrScaler(d.accumulate_start), ChrScaler(d.accumulate_end)])) + "," + (topPadding + 30) + ")";
                } else {
                    return "rotate(-30 " + (Number(startX) + 30 + d3.mean([ChrScaler(d.accumulate_start), ChrScaler(d.accumulate_end)])) + "," + (topPadding + 30) + ")";
                }
            })
            .attr("x", function (d) {
                if (queryWidth >= subjectWidth) {
                    return d3.mean([ChrScaler(d.accumulate_end), ChrScaler(d.accumulate_start)]);
                } else {
                    return Number(startX) + d3.mean([ChrScaler(d.accumulate_end), ChrScaler(d.accumulate_start)]);
                }
            })
            .attr("y", function () {
                return Number(d3.select("#queryMainLabel").attr("y")) + Number(d3.select(this).node().getBBox().height) + 10;
            })
            .attr("font-size", 12 * scaleRatio + "px");
        // .attr("font-family", "calibri")

        const query_chr_colorScale = d3.scaleOrdinal()
            .domain(queryChrInfo.map((d) => d.idx))
            .range(query_chr_colors);

        queryGroup
            .selectAll("rect")
            .data(queryChrInfo)
            .join("rect")
            .attr("class", "queryChrShape")
            .attr("id", (d) => "queryChr_" + d.idx)
            .attr("x", function (d) {
                if (queryWidth >= subjectWidth) {
                    return ChrScaler(d.accumulate_start);
                } else {
                    return Number(startX) + ChrScaler(d.accumulate_start);
                }
            })
            .attr("y", topPadding + d3.select("#queryMainLabel").node().getBBox().height + 5 + d3.selectAll(".queryChrs text").filter(":not(#queryMainLabel)").node().getBBox().height + 5)
            .attr(
                "width",
                (d) => ChrScaler(d.accumulate_end) - ChrScaler(d.accumulate_start)
            )
            .attr("height", chrRectHeight)
            .attr("opacity", 1)
            .attr("fill", (d) => query_chr_colorScale(d.idx))
            .attr("ry", 3)
            // .attr("data-tippy-content", (d) => "Query: " + d.seqchr)
            .on("mouseover", (e, d) => {
                let selector_chrID = d.seqchr.replaceAll(".", "\\.");
                ribbonEnterTime = new Date().getTime();
                d3.select("." + segsRibbonsId)
                    .selectAll("path")
                    //d3.selectAll(".from_" + plotId + "_" + selector_chrID)
                    .filter(".from_" + plotId + "_" + selector_chrID)
                    .transition()
                    .delay(tooltipDelay)
                    .duration(50);

                d3.select("." + segsRibbonsId)
                    .selectAll("path")
                    .filter(":not(.from_" + plotId + "_" + selector_chrID + ")")
                    .transition()
                    .delay(tooltipDelay)
                    .duration(50)
                    .attr("opacity", 0);
            })
            .on("mouseout", (e, d) => {
                let selector_chrID = d.seqchr.replaceAll(".", "\\.");
                ribbonOutTime = new Date().getTime();
                if (ribbonOutTime - ribbonEnterTime <= 8000) {
                    d3.selectAll(".from_" + plotId + "_" + selector_chrID)
                        .transition()
                        .duration(50);
                }
                d3.select("." + segsRibbonsId)
                    .selectAll("path")
                    .filter(":not(.from_" + plotId + "_" + selector_chrID + ")")
                    .transition()
                    .duration(50)
                    .attr("opacity", 0.6);
            });

        subjectGroup.append("text")
            .text(subjectSpecies)
            .attr("id", "subjectMainLabel")
            .attr("x", 5 + leftPadding)
            .attr("y", height - bottomPadding + 15)
            .attr("font-weight", "bold")
            .attr("font-size", 14 * scaleRatio + "px")
            .attr("font-style", "italic")
            // .attr("font-family", "times")
            .style("fill", "#8E549E");

        subjectGroup.selectAll("text")
            .filter(":not(#subjectMainLabel)")
            .data(subjectChrInfo)
            .join("text")
            .text((d) => d.seqchr)
            .attr("text-anchor", "start")
            .attr("x", function (d) {
                if (queryWidth >= subjectWidth) {
                    return Number(startX) + d3.mean([ChrScaler(d.accumulate_end), ChrScaler(d.accumulate_start)]);
                } else {
                    return d3.mean([ChrScaler(d.accumulate_end), ChrScaler(d.accumulate_start)]);
                }
            })
            // .attr("y", d3.select("#subjectMainLabel").attr("y") - d3.select("#subjectMainLabel").node().getBBox().height - 25)
            .attr("y", height - bottomPadding - 25)
            .attr("transform", function (d) {
                if (queryWidth >= subjectWidth) {
                    return "rotate(30 " + Number(startX + 5 + d3.mean([ChrScaler(d.accumulate_start), ChrScaler(d.accumulate_end)])) + "," + (height - bottomPadding - 30) + ")";
                } else {
                    return "rotate(30 " + Number(5 + d3.mean([ChrScaler(d.accumulate_start), ChrScaler(d.accumulate_end)])) + "," + (height - bottomPadding - 30) + ")";
                }
            })
            .attr("font-size", 12 * scaleRatio + "px")
            // .attr("font-family", "calibri")
            .attr("class", "queryChrLabel");

        const subject_chr_colorScale = d3.scaleOrdinal()
            .domain(subjectChrInfo.map((d) => d.idx))
            .range(subject_chr_colors);

        subjectGroup
            .selectAll("rect")
            .data(subjectChrInfo)
            .join("rect")
            .attr("class", "subjectChrShape")
            .attr("id", (d) => "subjectChr_" + d.idx)
            .attr("x", function (d) {
                if (queryWidth >= subjectWidth) {
                    return Number(startX) + ChrScaler(d.accumulate_start);
                } else {
                    return ChrScaler(d.accumulate_start);
                }
            })
            .attr("y", height - bottomPadding - d3.select("#subjectMainLabel").node().getBBox().height - 5 - d3.selectAll(".subjectChrs text").filter(":not(#subjectMainLabel)").node().getBBox().height - 5 - chrRectHeight)
            .attr(
                "width",
                (d) => ChrScaler(d.accumulate_end) - ChrScaler(d.accumulate_start)
            )
            .attr("height", chrRectHeight)
            .attr("opacity", 1)
            .attr("fill", (d) => subject_chr_colorScale(d.idx))
            .attr("ry", 3)
            // .attr("data-tippy-content", (d) => "Subject: " + d.seqchr)
            .on("mouseover", (e, d) => {
                let selector_chrID = d.seqchr.replaceAll(".", "\\.");
                ribbonEnterTime = new Date().getTime();
                d3.select("." + segsRibbonsId)
                    .selectAll("path")
                    .filter(".to_" + plotId + "_" + selector_chrID)
                    //d3.selectAll(".to_" + plotId + "_" + selector_chrID)
                    .transition()
                    .delay(tooltipDelay)
                    .duration(50);

                d3.select("." + segsRibbonsId)
                    .selectAll("path")
                    .filter(":not(.to_" + plotId + "_" + selector_chrID + ")")
                    .transition()
                    .delay(tooltipDelay)
                    .duration(50)
                    .attr("opacity", 0);
            })
            .on("mouseout", (e, d) => {
                let selector_chrID = d.seqchr.replaceAll(".", "\\.");
                ribbonOutTime = new Date().getTime();
                if (ribbonOutTime - ribbonEnterTime <= 8000) {
                    d3.selectAll(".to_" + plotId + "_" + selector_chrID)
                        .transition()
                        .duration(50)
                }
                d3.select("." + segsRibbonsId)
                    .selectAll("path")
                    .filter(":not(.to_" + plotId + "_" + selector_chrID + ")")
                    .transition()
                    .duration(50)
                    .attr("opacity", 0.6);
            });

        // prepare segments data
        segmentInfo.forEach((d) => {
            let queryChr = queryChrInfo.find(e => e.seqchr === d.listX);
            let subjectChr = subjectChrInfo.find(e => e.seqchr === d.listY);
            let queryAccumulateStart = queryChr.accumulate_start + d.startX + 1;
            let queryAccumulateEnd = queryChr.accumulate_start + d.endX + 1;
            let subjectAccumulateStart = subjectChr.accumulate_start + d.startY + 1;
            let subjectAccumulateEnd = subjectChr.accumulate_start + d.endY + 1;
            if (queryWidth >= subjectWidth) {
                queryX = ChrScaler(queryAccumulateStart);
                queryX1 = ChrScaler(queryAccumulateEnd);
                subjectX = startX + ChrScaler(subjectAccumulateStart);
                subjectX1 = startX + ChrScaler(subjectAccumulateEnd);
            } else {
                queryX = startX + ChrScaler(queryAccumulateStart);
                queryX1 = startX + ChrScaler(queryAccumulateEnd);
                subjectX = ChrScaler(subjectAccumulateStart);
                subjectX1 = ChrScaler(subjectAccumulateEnd);
            }
            d.ribbonPosition = {
                source: {
                    x: queryX,
                    x1: queryX1,
                    y: topPadding + d3.select("#queryMainLabel").node().getBBox().height + 5 + d3.selectAll(".queryChrs text").filter(":not(#queryMainLabel)").node().getBBox().height + 5 + chrRectHeight,
                    y1: topPadding + d3.select("#queryMainLabel").node().getBBox().height + 5 + d3.selectAll(".queryChrs text").filter(":not(#queryMainLabel)").node().getBBox().height + 5 + chrRectHeight
                },
                target: {
                    x: subjectX,
                    x1: subjectX1,
                    y: height - bottomPadding - d3.select("#subjectMainLabel").node().getBBox().height - 5 - d3.selectAll(".subjectChrs text").filter(":not(#subjectMainLabel)").node().getBBox().height - 5 - chrRectHeight,
                    y1: height - bottomPadding - d3.select("#subjectMainLabel").node().getBBox().height - 5 - d3.selectAll(".subjectChrs text").filter(":not(#subjectMainLabel)").node().getBBox().height - 5 - chrRectHeight
                }
            };
        });

        svg.append("g")
            .attr("class", segsRibbonsId)
            .selectAll("path")
            .data(segmentInfo)
            .join("path")
            .attr("d", d => createLinkPolygonPath(d.ribbonPosition))
            .attr("class", d => "from_" + plotId + "_" + d.listX + " to_" + plotId + "_" + d.listY)
            //.attr("fill", (d) => query_chr_colorScale(d.idx))
            .attr("fill", (d) => {
                const seqchr = d.listX;
                const matchingObj = queryChrInfo.find((obj) => obj.seqchr === seqchr);
                if (matchingObj) {
                    return query_chr_colorScale(matchingObj.idx);
                } else {
                    return "gray";
                }
            })
            .attr("opacity", 0.6)
            .attr("data-tippy-content", d => {
                return "<b><font color='#FFE153'>Query:</font></b> " + d.firstX + " &#8594 " + d.lastX + "<br>" +
                    "<font color='red'><b>&#8595</b></font><br>" +
                    "<b><font color='#4DFFFF'>Subject:</font></b> " + d.firstY + " &#8594 " + d.lastY;
            })
            .on("mouseover", function () {
                ribbonEnterTime = new Date().getTime();
                d3.select(this)
                    .transition()
                    .delay(tooltipDelay)
                    .duration(50)
                    .style("fill", "red");
            })
            .on("mouseout", function () {
                ribbonOutTime = new Date().getTime();
                if (ribbonOutTime - ribbonEnterTime <= 8000) {
                    d3.select(this)
                        .transition()
                        .duration(50)
                        .style("fill", (d) => {
                            const seqchr = d.listX;
                            const matchingObj = queryChrInfo.find((obj) => obj.seqchr === seqchr);
                            if (matchingObj) {
                                return query_chr_colorScale(matchingObj.idx);
                            } else {
                                return "gray";
                            }
                        })
                }
            })
        /* .on("click", function () {
            const data = d3.select(this)
                .data();
            const microQueryChr = data[0].queryChr;
            const microQueryStart = data[0].queryStart;
            const microQueryEnd = data[0].queryEnd;
            const microSubjectChr = data[0].subjectChr;
            const microSubjectStart = data[0].subjectStart;
            const microSubjectEnd = data[0].subjectEnd;
            Shiny.setInputValue("selected_microRegion",
                {
                    "microQueryChr": microQueryChr,
                    "microQueryStart": microQueryStart,
                    "microQueryEnd": microQueryEnd,
                    "microSubjectChr": microSubjectChr,
                    "microSubjectStart": microSubjectStart,
                    "microSubjectEnd": microSubjectEnd
                }
            );
        }); */

        // Activate tooltips
        // tippy(".microQueryArc path", {trigger: "mouseenter", followCursor: "initial", delay: [tooltipDelay, null]});
        // tippy(".microSubjectArc path", {trigger: "mouseenter", followCursor: "initial",  delay: [tooltipDelay, null]});
        // tippy(".queryChrs rect", { trigger: "mouseenter", followCursor: "initial", delay: [tooltipDelay, null] });
        // tippy(".subjectChrs rect", { trigger: "mouseenter", followCursor: "initial", delay: [tooltipDelay, null] });
        tippy(".segsRibbons path", { trigger: "mouseenter", followCursor: "initial", allowHTML: true, delay: [tooltipDelay, null] });
        querySpecies = querySpecies.replace(" ", "_");
        subjectSpecies = subjectSpecies.replace(" ", "_");
        downloadSVG("Synteny_download_" + plotId,
            "SyntenicBlock_" + plotId,
            querySpecies + "_vs_" + subjectSpecies + ".Parallel.svg");
        // downloadSVGwithForeign("dotView_download", "dotView");
    }

    Shiny.addCustomMessageHandler("Parallel_Multiple_Plotting", parallelMultiplePlotting);
    function parallelMultiplePlotting(InputData) {
        var plotId = InputData.plot_id;
        var segmentInfo = convertShinyData(InputData.segs);
        var chrLenInfo = convertShinyData(InputData.chr_lens);
        var chrOrder = convertShinyData(InputData.chr_order);
        var overlapCutOff = Number(InputData.overlap_cutoff) / 100;
        var spOrder = InputData.sp_order;
        var width = InputData.width;
        var height = InputData.height;

        /*         console.log("plotID", plotId);
                console.log("segmentInfo", segmentInfo);
                console.log("chrLenInfo", chrLenInfo);
                console.log("chrOrder", chrOrder);
                console.log("overlapCutOff", overlapCutOff);
                console.log("spOrder", spOrder); */

        const query_chr_colors = [
            "#9B3A4D", "#32AEEC", "#E2AE79", "#8E549E", "#EA7500",
            "#566CA5", "#D2352C", "#394A92", "#68AC57", "#F4C28F"];
        const subject_chr_colors = ["#9D9D9D", "#6C6C6C"]

        // draw a parallel syntenic plot
        d3.select("#parallel_plot_multiple_species").select("svg").remove();

        // define syntenic plot dimension
        // let width = 850;
        var heightOriginal = 150 * (spOrder.length - 1);
        var heightRatio = height / heightOriginal;
        let topPadding = 20;
        let bottomPadding = 20;
        let leftPadding = 50;
        let rightPadding = 50;
        let innerPadding = 10;
        let chrRectHeight = 15;
        var tooltipDelay = 100;

        var middlePoint = width / 2;
        const innerScale = d3.scaleLinear()
            .domain([0, 1])
            .range([
                0,
                width - leftPadding - rightPadding
            ]);

        function calc_accumulate_len(inputChrInfo, chrOrder, innerPadding_xScale, innerPadding) {
            chrOrder.forEach(d => {
                chrList = d.chrOrder.split(',');
                var chrOrderLenData = inputChrInfo.filter(a => chrList.includes(a.seqchr) && a.sp === d.species.replace(/\_/, " "));
                var chrSortedLenData = chrOrderLenData.sort((a, b) => {
                    return chrList.indexOf(a.seqchr) - chrList.indexOf(b.seqchr);
                });
                let acc_len = 0;
                let total_chr_len = d3.sum(chrSortedLenData.map(e => e.len));
                let ratio = innerPadding_xScale.invert(innerPadding);
                chrSortedLenData.forEach((e, i) => {
                    e.idx = i;
                    e.accumulate_start = acc_len + 1;
                    e.accumulate_end = e.accumulate_start + e.len - 1;
                    acc_len = e.accumulate_end + total_chr_len * ratio;
                });
                d.accumulateLen = chrSortedLenData;
            });
            return chrOrder;
        }
        // calculate accumulate chromosome length
        var accumulateLenInfo = calc_accumulate_len(chrLenInfo, chrOrder, innerScale, innerPadding);
        var maxChrLen = 0;
        accumulateLenInfo.forEach(d => {
            var maxLen = d.accumulateLen.reduce((maxEnd, obj) => {
                return Math.max(maxEnd, obj.accumulate_end);
            }, -Infinity);
            maxChrLen = Math.max(maxChrLen, maxLen);
        })

        const ChrScaler = d3
            .scaleLinear()
            .domain([1, maxChrLen])
            .range([
                0,
                width - rightPadding - leftPadding * 2
            ]);

        // decide the start point for each species
        accumulateLenInfo.forEach((d, i) => {
            var maxLen = d.accumulateLen.reduce((maxEnd, obj) => {
                return Math.max(maxEnd, obj.accumulate_end);
            }, -Infinity);
            if (maxLen === maxChrLen) {
                d.startX = 0;
            } else {
                d.startX = middlePoint - ChrScaler(maxLen) / 2 - leftPadding - rightPadding;
            }
            d.idx = i;
        });

        const svg = d3.select("#parallel_plot_multiple_species")
            .append("svg")
            .attr("width", width)
            .attr("height", height);

        d3.select('.pop-up-menu').remove();
        var popUpMenu = d3.select('body').append('div')
            .classed('pop-up-menu', true)
            .style('position', 'absolute')
            .style('top', 0)
            .style('left', 0)
            .style('visibility', 'hidden')
            .style('background-color', 'white')
            .style('border', '1px solid black')
            .style('padding', '5px');

        const speciesColorScale = d3.scaleOrdinal()
            .domain(accumulateLenInfo.map((d) => d.species))
            .range(subject_chr_colors);

        const speciesGroup = svg.append("g").attr("class", "species");
        // add species name
        speciesGroup.selectAll("text")
            .data(accumulateLenInfo)
            .join("text")
            .attr("class", "myText")
            .text(function (d) {
                return d.species.replace(/\_/, " ");
            })
            .attr("x", function (d) {
                return d.startX + leftPadding * 3 - 4;
            })
            .attr("y", function (d, i) {
                return i * 90 * heightRatio + 10 + topPadding;
            })
            .attr("font-weight", "bold")
            .attr("font-size", "14px")
            .attr("font-style", "italic")
            // .attr("font-family", "times")
            .attr("text-anchor", "end")
            .style("fill", (d) => speciesColorScale(d.species))
            .on('click', function (e, d) {
                if (popUpMenu.style('visibility') == 'visible') {
                    popUpMenu.style('visibility', 'hidden');
                } else {
                    var name = d.species.replace(/\_/, " ");
                    popUpMenu.html("<p>Set a Color for <i><b>" + name +
                        "</i></b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" +
                        "<button id='close-btn' onclick='closePopUp()'>&times;</button></p>" +
                        "<div id='color-options'></div>");

                    d3.select('#close-btn').on('click', closePopUp);
                    function closePopUp() {
                        popUpMenu.style('visibility', 'hidden');
                    };

                    var colors = ['#FF0000', '#00FF00', '#0000FF', '#FFA500', '#800080', '#FFC0CB', '#008080'];
                    var textElement = d3.select(this)._groups[0][0];
                    var colorOptions = d3.select('#color-options')
                        .selectAll('div')
                        .data(colors)
                        .enter()
                        .append('div')
                        .style('cursor', 'pointer')
                        .style('background-color', function (d) { return d; })
                        .style('width', '20px')
                        .style('height', '20px')
                        .style('margin-right', '5px')
                        .style('display', 'inline-block')
                        .on('click', function () {
                            var color = d3.select(this).style('background-color');
                            d3.select(textElement).style('fill', color);
                            // closePopUp();
                        });

                    var mouseX = event.pageX || event.clientX + document.body.scrollLeft + document.documentElement.scrollLeft;
                    var mouseY = event.pageY || event.clientY + document.body.scrollTop + document.documentElement.scrollTop;
                    popUpMenu.style('left', (mouseX + 10) + 'px')
                        .style('top', (mouseY - 10) + 'px')
                        .style('visibility', 'visible')
                }
            });

        const chrGroup = svg.append("g")
            .attr("class", "chrRect");

        accumulateLenInfo.forEach((d, i) => {
            const rects = chrGroup.selectAll(".chrRect")
                .data(d.accumulateLen);

            var spColor = speciesColorScale(d.species);
            rects.enter()
                .append("rect")
                .merge(rects)
                .attr("x", (e) => leftPadding * 3 + Number(d.startX) + ChrScaler(e.accumulate_start))
                .attr("y", i * 90 * heightRatio - 1 + topPadding)
                .attr("width", (e) => ChrScaler(e.accumulate_end) - ChrScaler(e.accumulate_start))
                .attr("height", chrRectHeight)
                .attr("opacity", 1)
                .attr("fill", spColor)
                .attr("ry", 3)
                .attr("data-tippy-content", (e) => "chrId: " + e.seqchr)
                .on("mouseover", (e, z) => {
                    let selector_chrID = z.seqchr.replaceAll(".", "\\.");
                    ribbonEnterTime = new Date().getTime();
                    d3.selectAll(".from_" + plotId + "_" + selector_chrID)
                        .transition()
                        .delay(tooltipDelay)
                        .duration(50)
                    d3.select(".segsRibbons")
                        .selectAll("path")
                        .filter(":not(.to_" + plotId + "_" + selector_chrID + ")")
                        .transition()
                        .delay(tooltipDelay)
                        .duration(50)
                        .attr("opacity", 0);
                })
                .on("mouseout", (e, z) => {
                    let selector_chrID = z.seqchr.replaceAll(".", "\\.");
                    ribbonOutTime = new Date().getTime();
                    if (ribbonOutTime - ribbonEnterTime <= 1000) {
                        d3.selectAll(".to_" + plotId + "_" + selector_chrID)
                            .transition()
                            .duration(50)
                    }
                    d3.select(".segsRibbons")
                        .selectAll("path")
                        .filter(":not(.to_" + plotId + "_" + selector_chrID + ")")
                        .transition()
                        .duration(50)
                        .attr("opacity", 0.51);
                });
            rects.exit().remove();
        });

        const chrLabel = svg.append("g")
            .attr("class", "chrLabel")

        function getCommonPart(inAarry) {
            let commonPrefix = "";
            for (let i = 0; i < inAarry[0].length; i++) {
                const char = inAarry[0][i];
                for (let j = 1; j < inAarry.length; j++) {
                    if (inAarry[j][i] !== char) {
                        commonPrefix = inAarry[0].substring(0, i);
                        break;
                    }
                }
                if (commonPrefix !== "") {
                    break;
                }
            }
            commonPrefix = inAarry[0].substring(0, commonPrefix.length);
            return commonPrefix;
        }

        accumulateLenInfo.forEach((d, i) => {
            // Append text labels
            var seqchrArray = d.accumulateLen.map(function (e) {
                return e.seqchr;
            });
            var commonPart = getCommonPart(seqchrArray);
            const lables = chrGroup.selectAll(".chrLabel")
                .data(d.accumulateLen);
            var labelAarry = lables.enter()
                .append("text")
                .merge(lables)
                .attr("x", function (e) {
                    return Number(d.startX) + leftPadding * 3 +
                        d3.mean([ChrScaler(e.accumulate_end), ChrScaler(e.accumulate_start)])
                })
                .attr("y", i * 90 * heightRatio + chrRectHeight / 2 + 3 + topPadding)
                .text(function (e) {
                    if (e.seqchr.includes("_")) {
                        var parts = e.seqchr.split("_");
                        return parts[parts.length - 1].replace(/^chr/i, "");
                    } else {
                        return (e.seqchr.replace(commonPart, ""))
                    }
                })
                .attr("font-size", "12px")
                // .attr("font-family", "calibri")
                .attr("fill", "#FFF7FB")
                .attr("text-anchor", "middle");
        });

        // console.log(segmentInfo);
        segmentInfo.forEach((d, i) => {
            let queryChrLen = accumulateLenInfo.find(e => e.species === d.genomeX);
            let queryChr = queryChrLen.accumulateLen.find(e => e.seqchr === d.listX);
            let queryAccumulateStart = leftPadding * 3 + Number(queryChrLen.startX) + ChrScaler(queryChr.accumulate_start + d.startX + 1);
            let queryAccumulateEnd = leftPadding * 3 + Number(queryChrLen.startX) + ChrScaler(queryChr.accumulate_start + d.endX + 1);

            let subjectChrLen = accumulateLenInfo.find(e => e.species === d.genomeY);
            let subjectChr = subjectChrLen.accumulateLen.find(e => e.seqchr === d.listY);
            let subjectAccumulateStart = leftPadding * 3 + Number(subjectChrLen.startX) + ChrScaler(subjectChr.accumulate_start + d.startY + 1);
            let subjectAccumulateEnd = leftPadding * 3 + Number(subjectChrLen.startX) + ChrScaler(subjectChr.accumulate_start + d.endY + 1);

            if (queryChrLen.idx > subjectChrLen.idx) {
                var queryY = queryChrLen.idx * 90 * heightRatio - 1 + topPadding;
                var subjectY = subjectChrLen.idx * 90 * heightRatio + chrRectHeight - 1 + topPadding;
            } else {
                var queryY = queryChrLen.idx * 90 * heightRatio + chrRectHeight - 1 + topPadding;
                var subjectY = subjectChrLen.idx * 90 * heightRatio - 1 + topPadding;
            }
            d.ribbonPosition = {
                source: {
                    x: queryAccumulateStart,
                    x1: queryAccumulateEnd,
                    y: queryY,
                    y1: queryY
                },
                target: {
                    x: subjectAccumulateStart,
                    x1: subjectAccumulateEnd,
                    y: subjectY,
                    y1: subjectY
                }
            }
        })

        svg.append("g")
            .attr("class", "segsRibbons")
            .selectAll("path")
            .data(segmentInfo)
            .join("path")
            .attr("d", d => createLinkPolygonPath(d.ribbonPosition))
            .attr("class", d => "from_" + plotId + "_" + d.listX + " to_" + plotId + "_" + d.listY)
            .attr("fill", "#BEBEBE")
            .attr("opacity", 0.51)
            /* .attr("data-tippy-content", d => {
                return "<b><font color='#FFE153'>" + d.listX + ":</font></b> " + d.firstX + " &#8594 " + d.lastX + "<br>" +
                    "<font color='red'><b>&#8595</b></font><br>" +
                    "<b><font color='#4DFFFF'>" + d.listY + ":</font></b> " + d.firstY + " &#8594 " + d.lastY;
            }) */
            .on("mouseover", function (e, d) {
                ribbonEnterTime = new Date().getTime();
                d3.select(this)
                    .transition()
                    .delay(tooltipDelay)
                    .duration(50)
                    .attr("fill", "red")
                    .attr("opacity", 0.51);

                d3.selectAll("path")
                    .transition()
                    .delay(tooltipDelay)
                    .duration(50)
                    .attr("fill", function (otherPathData) {
                        if (otherPathData === d) {
                            return "red";
                        } else if (
                            (otherPathData.listX === d.listX &&
                                ((otherPathData.StartX > d.startX && otherPathData.startX < d.endX && otherPathData.endX > d.endX &&
                                    (d.endX - otherPathData.startX) > overlapCutOff * (d.endX - d.startX)) ||
                                    (otherPathData.startX < d.starX && otherPathData.endX > d.startX && otherPathData.endX < d.endX &&
                                        (otherPathData.endX - d.startX) > overlapCutOff * (d.endX - d.startX)) ||
                                    d.startX < otherPathData.startX && d.endX > otherPathData.endX ||
                                    d.startX > otherPathData.startX && d.endX < otherPathData.endX)) ||
                            (otherPathData.listX === d.listY &&
                                ((otherPathData.StartX > d.startY && otherPathData.startX < d.endY && otherPathData.endX > d.startY &&
                                    (d.endY - otherPathData.startX) > overlapCutOff * (d.endY - d.startY)) ||
                                    (otherPathData.startX < d.starY && otherPathData.endX > d.startY && otherPathData.endX < d.endY &&
                                        (otherPathData.endY - d.startX) > overlapCutOff * (d.endY - d.startY)) ||
                                    d.startY < otherPathData.startX && d.endY > otherPathData.endX ||
                                    d.startY > otherPathData.startX && d.endY < otherPathData.endX)) ||
                            (otherPathData.listY === d.listY &&
                                ((otherPathData.StartY > d.startY && otherPathData.startY < d.endY && otherPathData.endY > d.endY &&
                                    (d.endY - otherPathData.startY) > overlapCutOff * (d.endY - d.startY)) ||
                                    (otherPathData.startY < d.starY && otherPathData.endY > d.startY && otherPathData.endY < d.endY &&
                                        (otherPathData.endY - d.startY) > overlapCutOff * (d.endY - d.startY)) ||
                                    d.startY < otherPathData.startY && d.endY > otherPathData.endY ||
                                    d.startY > otherPathData.startY && d.endY < otherPathData.endY)) ||
                            (otherPathData.listY === d.listX &&
                                ((otherPathData.StartY > d.startX && otherPathData.startY < d.endX && otherPathData.endY > d.startX &&
                                    (d.endX - otherPathData.startY) > overlapCutOff * (d.endX - d.startX)) ||
                                    (otherPathData.startY < d.startX && otherPathData.endY > d.startX && otherPathData.endY < d.endX &&
                                        (otherPathData.endY - d.startX) > overlapCutOff * (d.endX - d.startX)) ||
                                    d.startX < otherPathData.startY && d.endX > otherPathData.endY ||
                                    d.startX > otherPathData.startY && d.endX < otherPathData.endY))
                        ) {
                            return "blue";
                        } else {
                            return "#BEBEBE";
                        }
                    })
                    .attr("opacity", function (otherPathData) {
                        if (otherPathData === d) {
                            return 0.51;
                        } else if (
                            (otherPathData.listX === d.listX &&
                                ((otherPathData.StartX > d.startX && otherPathData.startX < d.endX && otherPathData.endX > d.endX &&
                                    (d.endX - otherPathData.startX) > overlapCutOff * (d.endX - d.startX)) ||
                                    (otherPathData.startX < d.starX && otherPathData.endX > d.startX && otherPathData.endX < d.endX &&
                                        (otherPathData.endX - d.startX) > overlapCutOff * (d.endX - d.startX)) ||
                                    d.startX < otherPathData.startX && d.endX > otherPathData.endX ||
                                    d.startX > otherPathData.startX && d.endX < otherPathData.endX)) ||
                            (otherPathData.listX === d.listY &&
                                ((otherPathData.StartX > d.startY && otherPathData.startX < d.endY && otherPathData.endX > d.startY &&
                                    (d.endY - otherPathData.startX) > overlapCutOff * (d.endY - d.startY)) ||
                                    (otherPathData.startX < d.starY && otherPathData.endX > d.startY && otherPathData.endX < d.endY &&
                                        (otherPathData.endY - d.startX) > overlapCutOff * (d.endY - d.startY)) ||
                                    d.startY < otherPathData.startX && d.endY > otherPathData.endX ||
                                    d.startY > otherPathData.startX && d.endY < otherPathData.endX)) ||
                            (otherPathData.listY === d.listY &&
                                ((otherPathData.StartY > d.startY && otherPathData.startY < d.endY && otherPathData.endY > d.endY &&
                                    (d.endY - otherPathData.startY) > overlapCutOff * (d.endY - d.startY)) ||
                                    (otherPathData.startY < d.starY && otherPathData.endY > d.startY && otherPathData.endY < d.endY &&
                                        (otherPathData.endY - d.startY) > overlapCutOff * (d.endY - d.startY)) ||
                                    d.startY < otherPathData.startY && d.endY > otherPathData.endY ||
                                    d.startY > otherPathData.startY && d.endY < otherPathData.endY)) ||
                            (otherPathData.listY === d.listX &&
                                ((otherPathData.StartY > d.startX && otherPathData.startY < d.endX && otherPathData.endY > d.startX &&
                                    (d.endX - otherPathData.startY) > overlapCutOff * (d.endX - d.startX)) ||
                                    (otherPathData.startY < d.startX && otherPathData.endY > d.startX && otherPathData.endY < d.endX &&
                                        (otherPathData.endY - d.startX) > overlapCutOff * (d.endX - d.startX)) ||
                                    d.startX < otherPathData.startY && d.endX > otherPathData.endY ||
                                    d.startX > otherPathData.startY && d.endX < otherPathData.endY))
                        ) {
                            return 0.51;
                        } else {
                            return 0;
                        }
                    });
            })
            .on("mouseout", function (e, d) {
                ribbonOutTime = new Date().getTime();
                if (ribbonOutTime - ribbonEnterTime <= 5000) {
                    d3.select(this)
                        .transition()
                        .duration(50)
                        .delay(tooltipDelay)
                        .attr("fill", "#BEBEBE");
                }
            })
            .on("click", function (e, d) {
                if (popUpMenu.style('visibility') == 'visible') {
                    popUpMenu.style('visibility', 'hidden');
                    popUpMenu.style('opacity', 1);
                } else {
                    popUpMenu.html("<p><font color='#3C3C3C'>Set a Color for the Link</font>: " +
                        "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" +
                        "<button id='close-btn' onclick='closePopUp()'>&times;</button></p>" +
                        "<p><div id='color-options'></div>");

                    d3.select('#close-btn').on('click', closePopUp);
                    function closePopUp() {
                        popUpMenu.style('visibility', 'hidden');
                        popUpMenu.style('opacity', 1);
                    };

                    var selectedPath = d3.select(this.parentNode).selectAll("path");
                    var testPath = d3.select("this");
                    var colors = ['#FF0000', '#00FF00', '#0000FF', '#FFA500', '#BEBEBE'];
                    var colorOptions = d3.select('#color-options')
                        .selectAll('div')
                        .data(colors)
                        .enter()
                        .append('div')
                        .style('cursor', 'pointer')
                        .style('background-color', function (d) { return d; })
                        .style('width', '20px')
                        .style('height', '20px')
                        .style('margin-right', '5px')
                        .style('display', 'inline-block')
                        .on('click', function () {
                            var color = d3.select(this).style('background-color');
                            selectedPath.each(function (pathData) {
                                if (pathData === d ||
                                    (pathData.listX === d.listX &&
                                        ((pathData.StartX > d.startX && pathData.startX < d.endX && pathData.endX > d.endX &&
                                            (d.endX - pathData.startX) > overlapCutOff * (d.endX - d.startX)) ||
                                            (pathData.startX < d.starX && pathData.endX > d.startX && pathData.endX < d.endX &&
                                                (pathData.endX - d.startX) > overlapCutOff * (d.endX - d.startX)) ||
                                            d.startX < pathData.startX && d.endX > pathData.endX ||
                                            d.startX > pathData.startX && d.endX < pathData.endX)) ||
                                    (pathData.listX === d.listY &&
                                        ((pathData.StartX > d.startY && pathData.startX < d.endY && pathData.endX > d.startY &&
                                            (d.endY - pathData.startX) > overlapCutOff * (d.endY - d.startY)) ||
                                            (pathData.startX < d.starY && pathData.endX > d.startY && pathData.endX < d.endY &&
                                                (pathData.endY - d.startX) > overlapCutOff * (d.endY - d.startY)) ||
                                            d.startY < pathData.startX && d.endY > pathData.endX ||
                                            d.startY > pathData.startX && d.endY < pathData.endX)) ||
                                    (pathData.listY === d.listY &&
                                        ((pathData.StartY > d.startY && pathData.startY < d.endY && pathData.endY > d.endY &&
                                            (d.endY - pathData.startY) > overlapCutOff * (d.endY - d.startY)) ||
                                            (pathData.startY < d.starY && pathData.endY > d.startY && pathData.endY < d.endY &&
                                                (pathData.endY - d.startY) > overlapCutOff * (d.endY - d.startY)) ||
                                            d.startY < pathData.startY && d.endY > pathData.endY ||
                                            d.startY > pathData.startY && d.endY < pathData.endY)) ||
                                    (pathData.listY === d.listX &&
                                        ((pathData.StartY > d.startX && pathData.startY < d.endX && pathData.endY > d.startX &&
                                            (d.endX - pathData.startY) > overlapCutOff * (d.endX - d.startX)) ||
                                            (pathData.startY < d.startX && pathData.endY > d.startX && pathData.endY < d.endX &&
                                                (pathData.endY - d.startX) > overlapCutOff * (d.endX - d.startX)) ||
                                            d.startX < pathData.startY && d.endX > pathData.endY ||
                                            d.startX > pathData.startY && d.endX < pathData.endY))
                                ) {
                                    d3.select(this).raise().style('fill', color).attr("opacity", 0.9);
                                }
                            });
                        });

                    var mouseX = event.pageX || event.clientX + document.body.scrollLeft + document.documentElement.scrollLeft;
                    var mouseY = event.pageY || event.clientY + document.body.scrollTop + document.documentElement.scrollTop;
                    popUpMenu.style('left', (mouseX + 10) + 'px')
                        .style('top', (mouseY - 10) + 'px')
                        .style('visibility', 'visible')
                        .style('opacity', 0.9);
                }
            });

        downloadSVG("parallel_download_last",
            "parallel_plot_multiple_species",
            "Multiple_Species_Alignment.Parallel.svg");
        // downloadSVGwithForeign("dotView_download", "dotView");
    }

    Shiny.addCustomMessageHandler("Dot_Plotting_paranome", DotPlotting_original_paranome);
    function DotPlotting_original_paranome(InputData) {
        var plotId = InputData.plot_id
        var anchorpointsInfo = convertShinyData(InputData.anchorpoints);
        var queryChrInfo = convertShinyData(InputData.query_chr_lens);
        var subjectChrInfo = convertShinyData(InputData.subject_chr_lens);
        var querySpecies = InputData.query_sp;
        var subjectSpecies = InputData.subject_sp;

        // sort the chromosome position based on the len
        queryChrInfo = queryChrInfo.sort(function (a, b) {
            return b.len - a.len;
        });

        subjectChrInfo = subjectChrInfo.sort(function (a, b) {
            return b.len - a.len;
        });
        // define plot dimension
        var width = 600;
        var height = 600;
        let innerPadding = 0;
        let topPadding = 10;
        const longestXLabelLength = d3.max(queryChrInfo, d => d.seqchr.toString().length);
        const xAxisTitlePadding = longestXLabelLength * 4;
        let bottomPadding = 50 + xAxisTitlePadding;
        const longestYLabelLength = d3.max(subjectChrInfo, d => d.seqchr.toString().length);
        const yAxisTitlePadding = longestYLabelLength * 6;
        let leftPadding = 50 + yAxisTitlePadding;
        let rightPadding = 10;
        var tooltipDelay = 400;

        // define innerPadding xscale
        const innerScale = d3.scaleLinear()
            .domain([0, 1])
            .range([
                0,
                width - leftPadding - rightPadding
            ]);
        // calc accumulate chr length
        queryChrInfo = calc_accumulate_len(queryChrInfo, innerScale, innerPadding);
        subjectChrInfo = calc_accumulate_len(subjectChrInfo, innerScale, innerPadding);
        // choose the sp with larger width to make the scaler
        var queryWidth = d3.max(queryChrInfo, function (d) { return d.accumulate_end; });
        var subjectWidth = d3.max(subjectChrInfo, function (d) { return d.accumulate_end; });

        if (queryWidth >= subjectWidth) {
            var xyscale = subjectWidth / queryWidth;
            var xScaler = d3
                .scaleLinear()
                .domain([
                    queryChrInfo[0].accumulate_start,
                    queryChrInfo[queryChrInfo.length - 1].accumulate_end
                ])
                .range([
                    0 + leftPadding,
                    width - rightPadding
                ]);
            var yScaler = d3
                .scaleLinear()
                .domain([
                    subjectChrInfo[0].accumulate_start,
                    subjectChrInfo[subjectChrInfo.length - 1].accumulate_end
                ])
                .range([
                    height * xyscale - bottomPadding,
                    topPadding
                ])
        } else {
            var xyscale = queryWidth / subjectWidth;
            var xScaler = d3
                .scaleLinear()
                .domain([
                    queryChrInfo[0].accumulate_start,
                    queryChrInfo[queryChrInfo.length - 1].accumulate_end
                ])
                .range([
                    0 + leftPadding,
                    width * xyscale - rightPadding
                ]);
            var yScaler = d3
                .scaleLinear()
                .domain([
                    subjectChrInfo[0].accumulate_start,
                    subjectChrInfo[subjectChrInfo.length - 1].accumulate_end
                ])
                .range([
                    height - bottomPadding,
                    topPadding
                ]);
        }

        // prepare segments data
        // console.log(queryChrInfo);
        // console.log(anchorpointsInfo);
        anchorpointsInfo.forEach((d) => {
            let queryChr = queryChrInfo.find(e => e.seqchr === d.listX);
            let subjectChr = subjectChrInfo.find(e => e.seqchr === d.listY);
            let queryAccumulateStart = queryChr.accumulate_start + d.startX + 1;
            let queryAccumulateEnd = queryChr.accumulate_start + d.endX + 1;
            let subjectAccumulateStart = subjectChr.accumulate_start + d.startY + 1;
            let subjectAccumulateEnd = subjectChr.accumulate_start + d.endY + 1;
            d.queryPos = {
                x: queryAccumulateStart,
                y: queryAccumulateEnd
            };
            d.subjectPos = {
                x: subjectAccumulateStart,
                y: subjectAccumulateEnd
            };
        });

        const xAxis = d3.axisBottom(xScaler)
            .tickValues(queryChrInfo.map(e => e.accumulate_end).slice(0, -1));
        const yAxis = d3.axisLeft(yScaler)
            .tickValues(subjectChrInfo.map(e => e.accumulate_end).slice(0, -1));

        // create svg viewBox
        d3.select("#dotView_" + plotId)
            .select("svg").remove();
        const svg = d3.select("#dotView_" + plotId)
            .append("svg")
            .attr("width", 650)
            .attr("height", 650);
        //.attr("viewBox", [0, 0, width, height]);

        // add x axis
        svg.append("g")
            .attr("class", "axis axis--x")
            .attr("transform", function () {
                if (queryWidth >= subjectWidth) {
                    return `translate(0, ${ height * xyscale - bottomPadding })`
                } else {
                    return `translate(0, ${ height - bottomPadding })`
                }
            })
            .call(xAxis)
            .attr("stroke-width", 0.66)
            .call(g => g.selectAll(".tick text").remove())
            .call(g => g.selectAll(".tick line").clone()
                .attr("y2", function () {
                    if (queryWidth >= subjectWidth) {
                        return topPadding + bottomPadding - height * xyscale
                        //                return -((height - bottomPadding) * xyscale) - topPadding;
                    } else {
                        return topPadding + bottomPadding - height
                        //return -(height - bottomPadding) - topPadding;
                    }
                })
                .attr("stroke-dasharray", "4 1")
                .attr("stroke-width", 0.66)
                .attr("stroke-opacity", 0.5)
                .attr("stroke", "blue")
            );

        // add y axis;
        svg.append("g")
            .attr("class", "axis axis--y")
            .attr("transform", `translate(${ leftPadding }, 0)`)
            .call(yAxis)
            .attr("stroke-width", 0.66)
            .call(g => g.selectAll(".tick text").remove())
            .call(g => g.selectAll(".tick line").clone()
                .attr("x2", function () {
                    if (queryWidth >= subjectWidth) {
                        return width - leftPadding - rightPadding;
                    } else {
                        return width * xyscale - leftPadding - rightPadding; // - outterPadding
                    }
                })
                .attr("stroke-dasharray", "4 1")
                .attr("stroke-opacity", 0.5)
                .attr("stroke", "blue")
                .attr("stroke-width", 0.66)
            );

        // add a diagonal line
        svg.append("g")
            .append("line")
            .attr("x1", leftPadding)
            .attr("y1", bottomPadding)
            .attr("x2", function () {
                if (queryWidth >= subjectWidth) {
                    return width - leftPadding - rightPadding
                } else {
                    return width * xyscale - leftPadding - rightPadding
                }
            })
            .attr("y2", function () {
                if (queryWidth >= subjectWidth) {
                    return height * xyscale - topPadding - bottomPadding
                } else {
                    return height - topPadding - bottomPadding
                }
            })
            .attr("stroke", "#BB5E00")
            .attr("stroke-dasharray", "4 1")
            .attr("stroke-width", 0.46)
            .attr("stroke-opacity", 0.6);

        // add top and right border
        svg.append("g")
            .append("line")
            .attr("transform", `translate(${ leftPadding }, ${ topPadding })`)
            .attr("x2", function () {
                if (queryWidth >= subjectWidth) {
                    return width - leftPadding - rightPadding
                } else {
                    return width * xyscale - leftPadding - rightPadding
                }
            })
            .attr("stroke", "black")
            .attr("stroke-width", 0.66)
            .attr("stroke-opacity", 1);
        svg.append("g")
            .append("line")
            .attr("transform", function () {
                if (queryWidth >= subjectWidth) {
                    return `translate(${ width - rightPadding }, ${ topPadding })`
                } else {
                    return `translate(${ width * xyscale - rightPadding }, ${ topPadding })`
                }
            })

            .attr("y2", function () {
                if (queryWidth >= subjectWidth) {
                    return height * xyscale - topPadding - bottomPadding
                } else {
                    return height - topPadding - bottomPadding
                }
            })
            .attr("stroke", "black")
            .attr("stroke-width", 0.66)
            .attr("stroke-opacity", 1);

        // add text labels on axises
        svg.append("g")
            .attr("class", "xLabel")
            .selectAll("text")
            .data(queryChrInfo)
            .join("text")
            .attr("x", d => {
                return xScaler(d3.mean([d.accumulate_start, d.accumulate_end]));
            })
            .attr("y", function () {
                if (queryWidth >= subjectWidth) {
                    return height * xyscale - bottomPadding + 15
                } else {
                    return height - bottomPadding + 15
                }
            })
            .attr("font-size", "12px")
            // .attr("font-family", "calibri")
            .text(d => d.seqchr)
            .attr("text-anchor", "left")
            .attr("data-tippy-content", (d) => {
                const filteredachorpoints = anchorpointsInfo.filter(function (ppx) {
                    return ppx.listX === d.seqchr
                });
                const count = filteredachorpoints.length;
                return d.seqchr + "<br>Anchor points: <font color='red'><b>" + count + "</b></font>"
            })
            .attr("transform", (d) => {
                return "rotate(30 " + xScaler(d3.mean([d.accumulate_start, d.accumulate_end])) + "," + ((queryWidth >= subjectWidth) ? height * xyscale - bottomPadding + 15 : height - bottomPadding + 15) + ")";
            })
            .on("mouseover", (e, d) => {
                let selector_chrID = d.seqchr.replaceAll(".", "\\.");
                ribbonEnterTime = new Date().getTime();
                d3.selectAll(".dfrom_" + plotId + "_" + selector_chrID)
                    .transition()
                    .delay(tooltipDelay)
                    .duration(50)
                    .style("stroke-width", "6");
                d3.select(".anchorPoints")
                    .selectAll("path")
                    .filter(":not(.dfrom_" + plotId + "_" + selector_chrID + ")")
                    .transition()
                    .delay(tooltipDelay)
                    .duration(50)
                    .attr("opacity", 0);
            })
            .on("mouseout", (e, d) => {
                //escape dot in the chromose id
                let selector_chrID = d.seqchr.replaceAll(".", "\\.");
                ribbonOutTime = new Date().getTime();
                if (ribbonOutTime - ribbonEnterTime <= 8000) {
                    d3.selectAll(".dfrom_" + plotId + "_" + selector_chrID)
                        .transition()
                        .duration(50)
                        .style("stroke-width", "3");
                }
                d3.select(".anchorPoints")
                    .selectAll("path")
                    .filter(":not(.dfrom_" + plotId + "_" + selector_chrID + ")")
                    .transition()
                    .duration(50)
                    .attr("opacity", 1);
            });

        svg.append("g")
            .attr("class", "yLabel")
            .attr("transform", `translate(${ leftPadding }, ${ topPadding })`)
            .selectAll("g")
            .data(subjectChrInfo)
            .join("g")
            .attr("transform", d => `translate(-15 ${ yScaler(d3.mean([d.accumulate_start, d.accumulate_end])) - topPadding })`)
            .append("text")
            .attr("font-size", "12px")
            // .attr("font-family", "calibri")
            .text(d => d.seqchr)
            .attr("text-anchor", "end")
            /*         .attr("transform", function(){
                        return `rotate(-90)`;
                    }) */
            .attr("data-tippy-content", (d) => {
                const filteredachorpoints = anchorpointsInfo.filter(function (ppx) {
                    return ppx.listY === d.seqchr
                });
                const count = filteredachorpoints.length;
                return d.seqchr + "<br>Anchor points: <font color='orange'><b>" + count + "</b></font>"
            })
            .on("mouseover", (e, d) => {
                ribbonEnterTime = new Date().getTime();
                d3.selectAll(".dto_" + plotId + "_" + d.seqchr)
                    .transition()
                    .delay(tooltipDelay)
                    .duration(50)
                    .style("stroke-width", "6");
                d3.select(".anchorPoints")
                    .selectAll("path")
                    .filter(":not(.dto_" + plotId + "_" + d.seqchr + ")")
                    .transition()
                    .delay(tooltipDelay)
                    .duration(50)
                    .attr("opacity", 0);
            })
            .on("mouseout", (e, d) => {
                //escape dot in the chromose id
                ribbonOutTime = new Date().getTime();
                if (ribbonOutTime - ribbonEnterTime <= 8000) {
                    d3.selectAll(".dto_" + plotId + "_" + d.seqchr)
                        .transition()
                        .duration(50)
                        .style("stroke-width", "3");
                }
                d3.select(".anchorPoints")
                    .selectAll("path")
                    .filter(":not(.dto_" + plotId + "_" + d.seqchr + ")")
                    .transition()
                    .duration(50)
                    .attr("opacity", 1);
            });

        // Add title for x and y
        const xLabelY = queryWidth >= subjectWidth ? height * xyscale - bottomPadding + 25 : height - bottomPadding + 25;
        svg.append("g")
            .attr("class", "xTitle")
            .append("text")
            .attr("x", function () {
                if (queryWidth > subjectWidth) {
                    return d3.mean([leftPadding, width])
                } else {
                    return d3.mean([leftPadding, width * xyscale])
                }
            })
            .attr("y", xLabelY + 35)
            .attr("text-anchor", "middle")
            .attr("font-size", "14px")
            .attr("font-weight", "bold")
            .attr("font-style", "italic")
            // .attr("font-family", "times")
            .text(querySpecies)
            .style("fill", "#68AC57");

        svg.append("g")
            .attr("class", "yTitle")
            .append("text")
            .attr("y", function () {
                if (queryWidth > subjectWidth) {
                    return d3.mean([topPadding, height * xyscale - bottomPadding])
                } else {
                    return d3.mean([topPadding, height - bottomPadding])
                }
            })
            .attr("x", leftPadding - yAxisTitlePadding - 30)
            .attr("text-anchor", "middle")
            .attr("font-size", "14px")
            .attr("font-weight", "bold")
            .attr("font-style", "italic")
            // .attr("font-family", "times")
            .attr("transform", function () {
                return `rotate(-90, ${ d3.select(this).attr("x") }, ${ d3.select(this).attr("y") })`;
            })
            .text(subjectSpecies)
            .style("fill", "#8E549E");

        function segPlotor(context, data) {
            context.fillStyle = "red";
            if (queryWidth >= subjectWidth) {
                context.moveTo(xScaler(data.queryPos.x), yScaler(data.subjectPos.x));
                context.lineTo(xScaler(data.queryPos.y), yScaler(data.subjectPos.y));
            } else {
                context.moveTo(xScaler(data.queryPos.x), yScaler(data.subjectPos.x));
                context.lineTo(xScaler(data.queryPos.y), yScaler(data.subjectPos.y));
            }
            context.closePath();
            return context;
        }
        // console.log(anchorpointsInfo);

        svg.append('g')
            .attr("class", "anchorPoints")
            .selectAll("line")
            .data(anchorpointsInfo)
            .join("line")
            .attr("x1", d => xScaler(d.queryPos.x))
            .attr("y1", d => yScaler(d.subjectPos.x))
            .attr("x2", d => xScaler(d.queryPos.y))
            .attr("y2", d => yScaler(d.subjectPos.y))
            .attr("class", d => "dfrom_" + plotId + "_" + d.listX + " dto_" + plotId + "_" + d.listY)
            .attr("stroke", "green")
            .attr("stroke-width", 3)
            .attr("fill", "green")
            .attr("data-tippy-content", d => {
                return "<b><font color='#FFE153'>Multiplicon ID</font></b> " + d.multiplicon +
                    "<br>Anchored Pair: " + d.geneX + " <=> " + d.geneY;
            });;

        tippy(".xLabel text", { trigger: "mouseenter", followCursor: "initial", allowHTML: true, delay: [tooltipDelay, null] });
        tippy(".yLabel text", { trigger: "mouseenter", followCursor: "initial", allowHTML: true, delay: [tooltipDelay, null] });

        querySpecies = querySpecies.replace(" ", "_");
        subjectSpecies = subjectSpecies.replace(" ", "_");
        downloadSVG("Dot_download_" + plotId,
            "dotView_" + plotId,
            querySpecies + "_vs_" + subjectSpecies + ".dot_plot.svg");
    }

    Shiny.addCustomMessageHandler("Dot_Num_Plotting_paranome", DotNumPlotting_paranome)
    function DotNumPlotting_paranome(InputData) {
        var plotId = InputData.plot_id;
        var multipliconInfo = convertShinyData(InputData.multiplicons);
        var anchorpointInfo = convertShinyData(InputData.anchorpoints);
        var queryChrInfo = convertShinyData(InputData.query_chr_gene_nums);
        var subjectChrInfo = convertShinyData(InputData.subject_chr_gene_nums);
        var queryDepthInfo = convertShinyData(InputData.query_depths);
        var subjectDepthInfo = convertShinyData(InputData.subject_depths);
        var querySpecies = InputData.query_sp;
        var subjectSpecies = InputData.subject_sp;
        var plotSize = InputData.size

        const scaleRatio = plotSize / 400;

        /*         console.log("multipliconInfo", multipliconInfo);
                console.log("anchorpointInfo", anchorpointInfo);
                console.log("queryChrInfo", queryChrInfo);
                console.log("subjectChrInfo", subjectChrInfo);
                console.log("queryDepthInfo", queryDepthInfo);
                console.log("subjectDepthInfo", subjectDepthInfo);
                console.log("querySpecies", querySpecies);
                console.log("subjectSpecies", subjectSpecies); */

        // sort the chromosome position based on the gene number
        queryChrInfo = queryChrInfo.sort(function (a, b) {
            return b.num - a.num;
        });

        subjectChrInfo = subjectChrInfo.sort(function (a, b) {
            return b.num - a.num;
        });

        // define plot dimension
        let topPadding = 150 * scaleRatio;
        const longestXLabelLength = d3.max(queryChrInfo, d => d.seqchr.toString().length);
        const xAxisTitlePadding = longestXLabelLength * 4;
        let bottomPadding = (50 + xAxisTitlePadding) * scaleRatio;
        const longestYLabelLength = d3.max(subjectChrInfo, d => d.seqchr.toString().length);
        const yAxisTitlePadding = longestYLabelLength * 6;
        let leftPadding = (80 + yAxisTitlePadding) * scaleRatio;
        // if( leftPadding - yAxisTitlePadding - 20 )
        let rightPadding = 100 * scaleRatio;
        var tooltipDelay = 400;

        function calc_accumulate_num_renew(inputChrInfo) {
            let acc_len = 0;
            inputChrInfo.forEach((e, i) => {
                e.idx = i;
                e.accumulate_start = acc_len + 1;
                e.accumulate_end = e.accumulate_start + e.gene_num;
                acc_len = e.accumulate_end;
            });
            return inputChrInfo;
        }

        // calc accumulate chr length
        queryChrInfo = calc_accumulate_num_renew(queryChrInfo);
        subjectChrInfo = calc_accumulate_num_renew(subjectChrInfo);

        // choose the sp with larger width to make the scaler
        var queryWidth = d3.max(queryChrInfo, function (d) { return d.accumulate_end; });
        var subjectWidth = d3.max(subjectChrInfo, function (d) { return d.accumulate_end; });

        // define plot area size
        if (subjectWidth < queryWidth) {
            var xyscale = subjectWidth / queryWidth;
            var width = plotSize + leftPadding + rightPadding;
            var height = plotSize * xyscale + topPadding + bottomPadding;
        } else {
            var xyscale = queryWidth / subjectWidth;
            var width = plotSize * xyscale + leftPadding + rightPadding;
            var height = plotSize + topPadding + bottomPadding;
        }

        var xScaler = d3.scaleLinear()
            .domain([queryChrInfo[0].accumulate_start, queryChrInfo[queryChrInfo.length - 1].accumulate_end])
            .range([leftPadding, width - rightPadding])

        var yScaler = d3.scaleLinear()
            .domain([subjectChrInfo[0].accumulate_start, subjectChrInfo[subjectChrInfo.length - 1].accumulate_end])
            .range([height - bottomPadding, topPadding])

        // prepare anchorpoints data
        anchorpointInfo.forEach((d) => {
            let queryChr = queryChrInfo.find(e => e.seqchr === d.listX);
            let subjectChr = subjectChrInfo.find(e => e.seqchr === d.listY);
            let queryAccumulateStart = queryChr.accumulate_start + d.coordX + 1;
            let subjectAccumulateStart = subjectChr.accumulate_start + d.coordY + 1;
            d.queryPos = {
                x: queryAccumulateStart
            };
            d.subjectPos = {
                x: subjectAccumulateStart
            };
        });

        // prepare segments data
        multipliconInfo.forEach((d) => {
            let queryChr = queryChrInfo.find(e => e.seqchr === d.listX);
            let subjectChr = subjectChrInfo.find(e => e.seqchr === d.listY);
            let queryAccumulateStart = queryChr.accumulate_start + d.startX + 1;
            let queryAccumulateEnd = queryChr.accumulate_start + d.endX + 1;
            let subjectAccumulateStart = subjectChr.accumulate_start + d.startY + 1;
            let subjectAccumulateEnd = subjectChr.accumulate_start + d.endY + 1;
            d.queryPos = {
                x: queryAccumulateStart,
                y: queryAccumulateEnd
            };
            d.subjectPos = {
                x: subjectAccumulateStart,
                y: subjectAccumulateEnd
            };
        });

        const xAxis = d3.axisBottom(xScaler)
            .tickValues(queryChrInfo.map(e => e.accumulate_end).slice(0, -1));
        const yAxis = d3.axisLeft(yScaler)
            .tickValues(subjectChrInfo.map(e => e.accumulate_end).slice(0, -1));

        // remove old svgs
        d3.select("#dotView_" + plotId)
            .select("svg").remove();
        // create svg viewBox
        const svg = d3.select("#dotView_" + plotId)
            .append("svg")
            .attr("width", width)
            .attr("height", height)
        // .style("display", "none");

        // add x axis
        svg.append("g")
            .attr("class", "axis axis--x")
            .attr("transform", function () {
                return `translate(0, ${ height - bottomPadding })`;
            })
            .call(xAxis)
            .attr("stroke-width", 0.66)
            .call(g => g.selectAll(".tick text").remove())
            .call(g => g.selectAll(".tick line").clone()
                .attr("y2", function () {
                    return topPadding + bottomPadding - height;
                })
                .attr("stroke-dasharray", "4 1")
                .attr("stroke-width", 0.66)
                .attr("stroke-opacity", 0.3)
                .attr("stroke", "blue")
            );

        // add y axis;
        svg.append("g")
            .attr("class", "axis axis--y")
            .attr("transform", `translate(${ leftPadding }, 0)`)
            .call(yAxis)
            .attr("stroke-width", 0.66)
            .call(g => g.selectAll(".tick text").remove())
            .call(g => g.selectAll(".tick line").clone()
                .attr("x2", function () {
                    return width - leftPadding - rightPadding;
                })
                .attr("stroke-dasharray", "4 1")
                .attr("stroke-opacity", 0.3)
                .attr("stroke", "blue")
                .attr("stroke-width", 0.66)
            );

        // add a diagonal line
        if (arraysOfObjectsAreEqual(queryChrInfo, subjectChrInfo)) {
            svg.append("g")
                .append("line")
                .attr("x1", leftPadding)
                .attr("y1", function () {
                    return height - bottomPadding;
                })
                .attr("x2", function () {
                    return width * xyscale - rightPadding;
                })
                .attr("y2", topPadding)
                .attr("stroke", "black")
                .attr("stroke-dasharray", "4 1")
                .attr("stroke-width", 0.46)
                .attr("stroke-opacity", 0.6);
        }
        // add top and right border
        svg.append("g")
            .append("line")
            .attr("transform", `translate(${ leftPadding }, ${ topPadding })`)
            .attr("x2", function () {
                return width - leftPadding - rightPadding;
            })
            .attr("stroke", "black")
            .attr("stroke-width", 0.66)
            .attr("stroke-opacity", 1);

        svg.append("g")
            .append("line")
            .attr("transform", function () {
                return `translate(${ width - rightPadding }, ${ topPadding })`;
            })
            .attr("y2", function () {
                return height - topPadding - bottomPadding;
            })
            .attr("stroke", "black")
            .attr("stroke-width", 0.66)
            .attr("stroke-opacity", 1);

        // add text labels on axises
        svg.append("g")
            .attr("class", "xLabel")
            .selectAll("text")
            .data(queryChrInfo)
            .join("text")
            .attr("x", d => {
                return xScaler(d3.mean([d.accumulate_start, d.accumulate_end]));
            })
            .attr("y", function () {
                return height - bottomPadding + 15;
            })
            .attr("font-size", 10 * scaleRatio + "px")
            // .attr("font-family", "calibri")
            .text(d => d.seqchr)
            .attr("text-anchor", "left")
            .attr("data-tippy-content", (d) => {
                const filteredmultiplicons = multipliconInfo.filter(function (ppx) {
                    return ppx.listX === d.seqchr
                });
                const count = filteredmultiplicons.length;
                return d.seqchr + "<br>Multiplicons nums: <font color='red'><b>" + count + "</b></font>"
            })
            .attr("transform", (d) => {
                return "rotate(30 " + xScaler(d3.mean([d.accumulate_start, d.accumulate_end])) + ","
                    + (height - bottomPadding + 15) + ")";
            })
            .on("mouseover", (e, d) => {
                let selector_chrID = d.seqchr.replaceAll(".", "\\.");
                multipliconEnterTime = new Date().getTime();
                d3.selectAll(".mfrom_" + plotId + "_" + selector_chrID)
                    .transition()
                    .delay(tooltipDelay)
                    .duration(50)
                    .attr("r", 3);
                //.style("stroke-width", "6");
                d3.select(".anchorpoints")
                    .selectAll("path")
                    .filter(":not(.mfrom_" + plotId + "_" + selector_chrID + ")")
                    .transition()
                    .delay(tooltipDelay)
                    .duration(50)
                    .attr("opacity", 0);
            })
            .on("mouseout", (e, d) => {
                //escape dot in the chromose id
                let selector_chrID = d.seqchr.replaceAll(".", "\\.");
                multipliconOutTime = new Date().getTime();
                if (multipliconOutTime - multipliconEnterTime <= 8000) {
                    d3.selectAll(".mfrom_" + plotId + "_" + selector_chrID)
                        .transition()
                        .duration(50)
                        .attr("r", 1);
                    //.style("stroke-width", "2");
                }
                d3.select(".anchorpoints")
                    .selectAll("path")
                    .filter(":not(.mfrom_" + plotId + "_" + selector_chrID + ")")
                    .transition()
                    .duration(50)
                    .attr("opacity", 1);
            });

        svg.append("g")
            .attr("class", "yLabel")
            .attr("transform", `translate(${ leftPadding }, ${ topPadding })`)
            .selectAll("g")
            .data(subjectChrInfo)
            .join("g")
            .attr("transform", d => `translate(-15 ${ yScaler(d3.mean([d.accumulate_start, d.accumulate_end])) - topPadding })`)
            .append("text")
            .attr("font-size", 10 * scaleRatio + "px")
            // .attr("font-family", "calibri")
            .text(d => d.seqchr)
            .attr("text-anchor", "end")
            .attr("data-tippy-content", (d) => {
                const filteredmultiplicons = multipliconInfo.filter(function (ppx) {
                    return ppx.listY === d.seqchr
                });
                const count = filteredmultiplicons.length;
                return d.seqchr + "<br>Multiplicons nums: <font color='orange'><b>" + count + "</b></font>"
            })
            .on("mouseover", (e, d) => {
                let selector_chrID = d.seqchr.replaceAll(".", "\\.");
                multipliconEnterTime = new Date().getTime();
                d3.selectAll(".mto_" + plotId + "_" + selector_chrID)
                    .transition()
                    .delay(tooltipDelay)
                    .duration(50)
                    .attr("r", 3);
                //.style("stroke-width", "6");
                d3.select(".anchorpoints")
                    .selectAll("path")
                    .filter(":not(.mto_" + plotId + "_" + selector_chrID + ")")
                    .transition()
                    .delay(tooltipDelay)
                    .duration(50)
                    .attr("opacity", 0);
            })
            .on("mouseout", (e, d) => {
                //escape dot in the chromose id
                let selector_chrID = d.seqchr.replaceAll(".", "\\.");
                multipliconOutTime = new Date().getTime();
                if (multipliconOutTime - multipliconEnterTime <= 8000) {
                    d3.selectAll(".mto_" + plotId + "_" + selector_chrID)
                        .transition()
                        .duration(50)
                        .attr("r", 1);
                }
                d3.select(".anchorpoints")
                    .selectAll("path")
                    .filter(":not(.mto_" + plotId + "_" + selector_chrID + ")")
                    .transition()
                    .duration(50)
                    .attr("opacity", 1);

            });

        // Add title for x and y
        const xLabelY = height - bottomPadding + 25 * scaleRatio;
        svg.append("g")
            .attr("class", "xTitle")
            .append("text")
            .attr("x", function () {
                return d3.mean([leftPadding, width]);
            })
            .attr("y", xLabelY + 38 * scaleRatio)
            .attr("text-anchor", "middle")
            .attr("font-size", 14 * scaleRatio + "px")
            .attr("font-weight", "bold")
            .attr("font-style", "italic")
            // .attr("font-family", "times")
            .text(querySpecies)
            .style("fill", "#68AC57");

        svg.append("g")
            .attr("class", "yTitle")
            .append("text")
            .attr("y", function () {
                return d3.mean([topPadding, height - bottomPadding]);
            })
            .attr("x", leftPadding - yAxisTitlePadding * scaleRatio - 20 * scaleRatio)
            .attr("text-anchor", "middle")
            .attr("font-size", 14 * scaleRatio + "px")
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
            .data(anchorpointInfo)
            .join("circle")
            .attr("id", (d) => "multiplicon_" + d.multiplicon)
            .attr("cx", d => xScaler(d.queryPos.x))
            .attr("cy", d => yScaler(d.subjectPos.x))
            .attr("r", 1 * scaleRatio)
            .attr("fill", function (d) {
                return colorScale(d.Ks);
            });
        svg.append('g')
            .attr("class", "anchorpoints")
            .selectAll("circle")
            .data(anchorpointInfo)
            .join("circle")
            .attr("id", (d) => "multiplicon_" + d.multiplicon)
            .attr("cx", d => xScaler(d.subjectPos.x))
            .attr("cy", d => yScaler(d.queryPos.x))
            .attr("r", 1 * scaleRatio)
            .attr("fill", function (d) {
                return colorScale(d.Ks);
            });

        // prepare depth data
        queryDepthInfo.forEach((d) => {
            let queryChr = queryChrInfo.find(e => e.seqchr === d.listX);
            let queryAccumulatePos = queryChr.accumulate_start + d.coordX;
            d.queryAccumulatePos = queryAccumulatePos;
        });

        // console.log("queryDepthInfo", queryDepthInfo);
        var queryDepthMax = d3.max(queryDepthInfo, function (d) { return d.count; });
        var numTicks = queryDepthMax > 12 ? Math.floor(queryDepthMax / 2) : queryDepthMax;
        var queryDepthScale = d3.scaleLinear()
            .domain([0, queryDepthMax])
            .range([0, topPadding - 60]);
        var yAxisQueryDepth = d3.axisLeft()
            .scale(d3.scaleLinear()
                .domain([0, queryDepthMax])
                .range([topPadding - 5 * scaleRatio, 55]))
            .ticks(numTicks);

        svg.append('g')
            .attr("class", "queryDepth")
            .selectAll("rect")
            .data(queryDepthInfo)
            .join("rect")
            .attr("x", function (d) { return xScaler(d.queryAccumulatePos); })
            .attr("y", function (d) { return topPadding - 5 * scaleRatio - queryDepthScale(d.count); })
            .attr("width", 1 * scaleRatio)
            .attr("height", function (d) {
                return queryDepthScale(d.count);
            })
            .style("fill", "#68AC57")
            .attr("opacity", 0.8)
            .style("stroke", "#68AC57")
            .style("stroke-width", 0.5);

        svg.append("g")
            .attr("class", "axis")
            .attr("transform", `translate(${ leftPadding - 5 }, 0)`)
            .call(yAxisQueryDepth)
            .attr("font-size", 10 * scaleRatio + "px");
        // .attr("font-family", "calibri");

        svg.append("g")
            .append("text")
            .attr("y", d3.mean([topPadding, 50]))
            .attr("x", leftPadding - 32 * scaleRatio)
            .attr("text-anchor", "middle")
            .attr("font-size", 12 * scaleRatio + "px")
            // .attr("font-family", "times")
            .attr("transform", function () {
                return `rotate(-90, ${ d3.select(this).attr("x") }, ${ d3.select(this).attr("y") })`;
            })
            .text("Depth")
            .style("fill", "#68AC57");

        // console.log("subjectDepthInfo", subjectDepthInfo);
        // console.log("subjectChrInfo", subjectChrInfo);
        subjectDepthInfo.forEach((d) => {
            let subjectChr = subjectChrInfo.find(e => e.seqchr === d.listX);
            let subjectAccumulatePos = subjectChr.accumulate_start + d.coordX;
            d.subjectAccumulatePos = subjectAccumulatePos;
        });

        var subjectDepthMax = d3.max(subjectDepthInfo, function (d) { return d.count; });
        var subjectDepthScale = d3.scaleLinear()
            .domain([0, subjectDepthMax])
            .range([0, 90 * scaleRatio]);

        var numTicks = subjectDepthMax > 12 ? Math.floor(subjectDepthMax / 2) : subjectDepthMax;
        var yAxisSubjectDepth = d3.axisTop()
            .scale(d3.scaleLinear()
                .domain([0, subjectDepthMax])
                .range([xScaler(queryWidth) + 5 * scaleRatio, xScaler(queryWidth) + 95 * scaleRatio]))
            .ticks(numTicks)
            .tickFormat(d3.format(".0f"));

        svg.append('g')
            .attr("class", "subjectDepth")
            .selectAll("rect")
            .data(subjectDepthInfo)
            .join("rect")
            .attr("x", function (d) { return xScaler(queryWidth) + 5 * scaleRatio; })
            .attr("y", function (d) {
                return yScaler(d.subjectAccumulatePos);
            })
            .attr("width", function (d) {
                return subjectDepthScale(d.count);
            })
            .attr("height", 1 * scaleRatio)
            .style("fill", "#8E549E")
            .attr("opacity", 1)
            .style("stroke", "#8E549E")
            .style("stroke-width", 0.5);

        svg.append("g")
            .attr("class", "axis")
            .attr("transform", `translate(0, ${ topPadding - 5 })`)
            .call(yAxisSubjectDepth)
            .attr("font-size", 10 * scaleRatio + "px");
        // .attr("font-family", "calibri");

        svg.append("g")
            .append("text")
            .attr("y", 120 * scaleRatio)
            .attr("x", d3.mean([xScaler(queryWidth) + 5 * scaleRatio, xScaler(queryWidth) + 95 * scaleRatio]))
            .attr("text-anchor", "middle")
            .attr("font-size", 12 * scaleRatio + "px")
            // .attr("font-family", "times")
            .text("Depth")
            .style("fill", "#8E549E");

        // Create a legend for the color scale
        var defs = svg.append("defs")
        var gradient = defs.append("linearGradient")
            .attr("id", "color-scale")
            .attr("x1", "0%").attr("y1", "0%")
            .attr("x2", "0%").attr("y2", "100%");
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
            .attr("stop-color", colorScale(5));

        // Add the legend rectangle with the gradient fill
        var legendGroup = svg.append("g")
            .attr("class", "legend")
            .attr("transform", "translate(" + (leftPadding) + "," + 5 + ")");

        legendGroup.append("rect")
            .attr("x", -65 * scaleRatio)
            .attr("y", 50 * scaleRatio)
            .attr("width", 15 * scaleRatio)
            .attr("height", 80 * scaleRatio)
            .attr("fill", "url(#color-scale)")
            .attr("fill-opacity", 0.7);

        var axisScale = d3.scaleLinear()
            .domain([0, 5])
            .range([50 * scaleRatio, 130 * scaleRatio]);

        // Create the axis
        var axis = d3.axisLeft(axisScale)
            .ticks(5);

        var axisGroup = legendGroup.append("g")
            .attr("class", "axis")
            .attr("transform", "translate(" + (-70 * scaleRatio) + "," + 0 + ")")
            .call(axis)
            .attr("text-anchor", "middle")
            .attr("dominant-baseline", "hanging")
            .attr("font-size", 10 * scaleRatio + "px");
        // .attr("font-family", "calibri");

        legendGroup.append("text")
            .attr("x", -100 * scaleRatio)
            .attr("y", 90 * scaleRatio)
            .append("tspan")
            // .attr("font-family", "times")
            .html("<tspan style='font-style: italic;'>K</tspan>")
            .style("font-size", 13 * scaleRatio + "px")
            .append("tspan")
            .text("s")
            .style("font-size", 12 * scaleRatio + "px")
            .attr("dx", 1 * scaleRatio + "px")
            .attr("dy", 2 * scaleRatio + "px");

        tippy(".xLabel text", { trigger: "mouseenter", followCursor: "initial", allowHTML: true, delay: [tooltipDelay, null] });
        tippy(".yLabel text", { trigger: "mouseenter", followCursor: "initial", allowHTML: true, delay: [tooltipDelay, null] });
        tippy(".multiplicons line", { trigger: "mouseenter", followCursor: "initial", allowHTML: true, delay: [tooltipDelay, null] });
        tippy(".multipliconsT line", { trigger: "mouseenter", followCursor: "initial", allowHTML: true, delay: [tooltipDelay, null] });

        querySpecies = querySpecies.replace(" ", "_");
        downloadSVG("Dot_download_" + plotId,
            "dotView_" + plotId,
            querySpecies + ".self.dot_plot.svg");
        /*     var viewBoxWidth = width;
            var viewBoxHeight = (height + 100) * xyscale;
            svg.attr("viewBox", "0 0 " + viewBoxWidth + " " + viewBoxHeight)
                .attr("height", viewBoxHeight); */
        // Convert the SVG to PNG
        /* const svgXml = new XMLSerializer().serializeToString(svg.node());
        const img = new Image();
        img.src = 'data:image/svg+xml;base64,' + btoa(svgXml);

        img.onload = function () {
            var canvas = document.createElement("canvas");
            var scale = 2;
            canvas.style.width = width / 2 + 'px';
            canvas.style.height = height / 2 + 'px';
            canvas.width = width;
            canvas.height = height;

            const ctx = canvas.getContext('2d');
            ctx.drawImage(img, 0, 0);

            const pngDataUrl = canvas.toDataURL('image/png');

            const previousPngImg = document.querySelector("#dotView_png_" + plotId + " img");
            if (previousPngImg) {
                previousPngImg.remove();
            }

            const pngImg = new Image();
            pngImg.src = pngDataUrl;
            document.querySelector("#dotView_png_" + plotId).appendChild(pngImg);
        }; */
    }

    Shiny.addCustomMessageHandler("Dot_Num_Plotting", DotNumPlotting);
    function DotNumPlotting(InputData) {
        var plotId = InputData.plot_id;
        var multipliconInfo = convertShinyData(InputData.multiplicons);
        var anchorpointInfo = convertShinyData(InputData.anchorpoints);
        var queryChrInfo = convertShinyData(InputData.query_chr_gene_nums);
        var subjectChrInfo = convertShinyData(InputData.subject_chr_gene_nums);
        var queryDepthInfo = convertShinyData(InputData.query_depths);
        var subjectDepthInfo = convertShinyData(InputData.subject_depths);
        var querySpecies = InputData.query_sp;
        var subjectSpecies = InputData.subject_sp;
        var plotSize = InputData.size;

        const scaleRatio = plotSize / 400;

        // console.log("queryChrInfo", queryChrInfo);
        // sort the chromosome position based on the gene number
        queryChrInfo = queryChrInfo.sort(function (a, b) {
            return b.num - a.num;
        });

        subjectChrInfo = subjectChrInfo.sort(function (a, b) {
            return b.num - a.num;
        });

        // define plot dimension
        let topPadding = 150 * scaleRatio;
        const longestXLabelLength = d3.max(queryChrInfo, d => d.seqchr.toString().length);
        const xAxisTitlePadding = longestXLabelLength * 4;
        let bottomPadding = (50 + xAxisTitlePadding) * scaleRatio;
        const longestYLabelLength = d3.max(subjectChrInfo, d => d.seqchr.toString().length);
        const yAxisTitlePadding = longestYLabelLength * 6;
        let leftPadding = (80 + yAxisTitlePadding) * scaleRatio;
        let rightPadding = 100 * scaleRatio;
        var tooltipDelay = 400;

        // console.log("leftPadding", leftPadding);
        // console.log("topPadding", topPadding);

        function calc_accumulate_num_renew(inputChrInfo) {
            let acc_len = 0;
            inputChrInfo.forEach((e, i) => {
                e.idx = i;
                e.accumulate_start = acc_len + 1;
                e.accumulate_end = e.accumulate_start + e.gene_num;
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
            var width = plotSize + leftPadding + rightPadding;
            var height = plotSize * xyscale + topPadding + bottomPadding;
        } else {
            var xyscale = queryWidth / subjectWidth;
            var width = plotSize * xyscale + leftPadding + rightPadding;
            var height = plotSize + topPadding + bottomPadding;
        }


        var xScaler = d3.scaleLinear()
            .domain([queryChrInfo[0].accumulate_start, queryChrInfo[queryChrInfo.length - 1].accumulate_end])
            .range([leftPadding, width - rightPadding])

        var yScaler = d3.scaleLinear()
            .domain([subjectChrInfo[0].accumulate_start, subjectChrInfo[subjectChrInfo.length - 1].accumulate_end])
            .range([height - bottomPadding, topPadding])

        // prepare anchorpoints data
        anchorpointInfo.forEach((d) => {
            let queryChr = queryChrInfo.find(e => e.seqchr === d.listX);
            let subjectChr = subjectChrInfo.find(e => e.seqchr === d.listY);
            let queryAccumulateStart = queryChr.accumulate_start + d.coordX + 1;
            let subjectAccumulateStart = subjectChr.accumulate_start + d.coordY + 1;
            d.queryPos = {
                x: queryAccumulateStart
            };
            d.subjectPos = {
                x: subjectAccumulateStart
            };
        });

        // prepare multiplicons data
        multipliconInfo.forEach((d) => {
            let queryChr = queryChrInfo.find(e => e.seqchr === d.listX);
            let subjectChr = subjectChrInfo.find(e => e.seqchr === d.listY);
            let queryAccumulateStart = queryChr.accumulate_start + d.startX + 1;
            let queryAccumulateEnd = queryChr.accumulate_start + d.endX + 1;
            let subjectAccumulateStart = subjectChr.accumulate_start + d.startY + 1;
            let subjectAccumulateEnd = subjectChr.accumulate_start + d.endY + 1;
            d.queryPos = {
                x: queryAccumulateStart,
                y: queryAccumulateEnd
            };
            d.subjectPos = {
                x: subjectAccumulateStart,
                y: subjectAccumulateEnd
            };
        });

        const xAxis = d3.axisBottom(xScaler)
            .tickValues(queryChrInfo.map(e => e.accumulate_end).slice(0, -1));
        const yAxis = d3.axisLeft(yScaler)
            .tickValues(subjectChrInfo.map(e => e.accumulate_end).slice(0, -1));

        // remove old svgs
        d3.select("#dotView_" + plotId)
            .select("svg").remove();
        const svg = d3.select("#dotView_" + plotId)
            .append("svg")
            .attr("width", width)
            .attr("height", height);
        // .style("display", "none");

        // add x axis
        svg.append("g")
            .attr("class", "axis axis--x")
            .attr("transform", function () {
                return `translate(0, ${ height - bottomPadding })`;
            })
            .call(xAxis)
            .attr("stroke-width", 0.66)
            .call(g => g.selectAll(".tick text").remove())
            .call(g => g.selectAll(".tick line").clone()
                .attr("y2", function () {
                    return topPadding + bottomPadding - height;
                })
                .attr("stroke-dasharray", "4 1")
                .attr("stroke-width", 0.66)
                .attr("stroke-opacity", 0.3)
                .attr("stroke", "blue")
            );

        // add y axis;
        svg.append("g")
            .attr("class", "axis axis--y")
            .attr("transform", `translate(${ leftPadding }, 0)`)
            .call(yAxis)
            .attr("stroke-width", 0.66)
            .call(g => g.selectAll(".tick text").remove())
            .call(g => g.selectAll(".tick line").clone()
                .attr("x2", function () {
                    return width - leftPadding - rightPadding;
                })
                .attr("stroke-dasharray", "4 1")
                .attr("stroke-opacity", 0.3)
                .attr("stroke", "blue")
                .attr("stroke-width", 0.66)
            );

        // add top and right border
        svg.append("g")
            .append("line")
            .attr("transform", `translate(${ leftPadding }, ${ topPadding })`)
            .attr("x2", function () {
                return width - leftPadding - rightPadding;
            })
            .attr("stroke", "black")
            .attr("stroke-width", 0.66)
            .attr("stroke-opacity", 1);

        svg.append("g")
            .append("line")
            .attr("transform", function () {
                return `translate(${ width - rightPadding }, ${ topPadding })`;
            })
            .attr("y2", function () {
                return height - topPadding - bottomPadding
            })
            .attr("stroke", "black")
            .attr("stroke-width", 0.66)
            .attr("stroke-opacity", 1);

        // add text labels on axises
        svg.append("g")
            .attr("class", "xLabel")
            .selectAll("text")
            .data(queryChrInfo)
            .join("text")
            .attr("x", d => {
                return xScaler(d3.mean([d.accumulate_start, d.accumulate_end]));
            })
            .attr("y", function () {
                return height - bottomPadding + 15;
            })
            .attr("font-size", "12px")
            // .attr("font-family", "calibri")
            .text(d => d.seqchr)
            .attr("text-anchor", "left")
            .attr("data-tippy-content", (d) => {
                const filteredmultiplicons = multipliconInfo.filter(function (ppx) {
                    return ppx.listX === d.seqchr;
                });
                const count = filteredmultiplicons.length;
                return d.seqchr + "<br>Multiplicons nums: <font color='red'><b>" + count + "</b></font>"
            })
            .attr("transform", (d) => {
                return "rotate(30 " + xScaler(d3.mean([d.accumulate_start, d.accumulate_end])) + ","
                    + (height - bottomPadding + 15) + ")";
            })
            .on("mouseover", (e, d) => {
                let selector_chrID = d.seqchr.replaceAll(".", "\\.");
                multipliconEnterTime = new Date().getTime();
                d3.selectAll(".mfrom_" + plotId + "_" + selector_chrID)
                    .transition()
                    .delay(tooltipDelay)
                    .duration(50)
                    .style("stroke-width", "6");
                d3.select(".multiplicons")
                    .selectAll("path")
                    .filter(":not(.mfrom_" + plotId + "_" + selector_chrID + ")")
                    .transition()
                    .delay(tooltipDelay)
                    .duration(50)
                    .attr("opacity", 0);
            })
            .on("mouseout", (e, d) => {
                //escape dot in the chromose id
                let selector_chrID = d.seqchr.replaceAll(".", "\\.");
                multipliconOutTime = new Date().getTime();
                if (multipliconOutTime - multipliconEnterTime <= 8000) {
                    d3.selectAll(".mfrom_" + plotId + "_" + selector_chrID)
                        .transition()
                        .duration(50)
                        .style("stroke-width", "2");
                }
                d3.select(".multiplicons")
                    .selectAll("path")
                    .filter(":not(.mfrom_" + plotId + "_" + selector_chrID + ")")
                    .transition()
                    .duration(50)
                    .attr("opacity", 1);
            });

        svg.append("g")
            .attr("class", "yLabel")
            .attr("transform", `translate(${ leftPadding }, ${ topPadding })`)
            .selectAll("g")
            .data(subjectChrInfo)
            .join("g")
            .attr("transform", d => `translate(-15 ${ yScaler(d3.mean([d.accumulate_start, d.accumulate_end])) - topPadding })`)
            .append("text")
            .attr("font-size", "12px")
            // .attr("font-family", "calibri")
            .text(d => d.seqchr)
            .attr("text-anchor", "end")
            .attr("data-tippy-content", (d) => {
                const filteredmultiplicons = multipliconInfo.filter(function (ppx) {
                    return ppx.listY === d.seqchr
                });
                const count = filteredmultiplicons.length;
                return d.seqchr + "<br>Multiplicons nums: <font color='orange'><b>" + count + "</b></font>"
            })
            .on("mouseover", (e, d) => {
                let selector_chrID = d.seqchr.replaceAll(".", "\\.");
                multipliconEnterTime = new Date().getTime();
                d3.selectAll(".mto_" + plotId + "_" + selector_chrID)
                    .transition()
                    .delay(tooltipDelay)
                    .duration(50)
                    .style("stroke-width", "6");
                d3.select(".multiplicons")
                    .selectAll("path")
                    .filter(":not(.mto_" + plotId + "_" + selector_chrID + ")")
                    .transition()
                    .delay(tooltipDelay)
                    .duration(50)
                    .attr("opacity", 0);
            })
            .on("mouseout", (e, d) => {
                //escape dot in the chromose id
                let selector_chrID = d.seqchr.replaceAll(".", "\\.");
                multipliconOutTime = new Date().getTime();
                if (multipliconOutTime - multipliconEnterTime <= 8000) {
                    d3.selectAll(".mto_" + plotId + "_" + selector_chrID)
                        .transition()
                        .duration(50)
                        .style("stroke-width", "2");
                }
                d3.select(".multiplicons")
                    .selectAll("path")
                    .filter(":not(.mto_" + plotId + "_" + selector_chrID + ")")
                    .transition()
                    .duration(50)
                    .attr("opacity", 1);

            });

        // Add title for x and y
        const xLabelY = height - bottomPadding + 25;
        svg.append("g")
            .attr("class", "xTitle")
            .append("text")
            .attr("x", function () {
                return d3.mean([leftPadding, width])
            })
            .attr("y", xLabelY + 45)
            .attr("text-anchor", "middle")
            .attr("font-size", "14px")
            .attr("font-weight", "bold")
            .attr("font-style", "italic")
            // .attr("font-family", "times")
            .text(querySpecies)
            .style("fill", "#68AC57");

        svg.append("g")
            .attr("class", "yTitle")
            .append("text")
            .attr("y", function () {
                return d3.mean([topPadding, height - bottomPadding])
            })
            .attr("x", leftPadding - yAxisTitlePadding - 30)
            .attr("text-anchor", "middle")
            .attr("font-size", "14px")
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
            .data(anchorpointInfo)
            .join("circle")
            .attr("cx", d => xScaler(d.queryPos.x))
            .attr("cy", d => yScaler(d.subjectPos.x))
            .attr("r", 0.87)
            .attr("id", (d) => "multiplicon_" + d.multiplicon)
            .attr("fill", function (d) {
                if (d.Ks > -1) {
                    return colorScale(d.Ks);
                } else {
                    return "#898989"
                }
            });

        // prepare depth data
        queryDepthInfo.forEach((d) => {
            let queryChr = queryChrInfo.find(e => e.seqchr === d.listX);
            let queryAccumulatePos = queryChr.accumulate_start + d.coordX;
            d.queryAccumulatePos = queryAccumulatePos;
        });

        var queryDepthMax = d3.max(queryDepthInfo, function (d) { return d.count; });
        var numTicks = queryDepthMax > 12 ? Math.floor(queryDepthMax / 4) : queryDepthMax;
        var queryDepthScale = d3.scaleLinear()
            .domain([0, queryDepthMax])
            .range([0, topPadding - 60]);
        var yAxisQueryDepth = d3.axisLeft()
            .scale(d3.scaleLinear()
                .domain([0, queryDepthMax])
                .range([topPadding - 5, 55]))
            .ticks(numTicks);

        svg.append('g')
            .attr("class", "queryDepth")
            .selectAll("rect")
            .data(queryDepthInfo)
            .join("rect")
            .attr("x", function (d) { return xScaler(d.queryAccumulatePos); })
            .attr("y", function (d) { return topPadding - 5 - queryDepthScale(d.count); })
            .attr("width", 1)
            .attr("height", function (d) {
                return queryDepthScale(d.count);
            })
            .style("fill", "#68AC57")
            .attr("opacity", 1)
            .style("stroke", "#68AC57")
            .style("stroke-width", 0.5);

        svg.append("g")
            .attr("class", "axis")
            .attr("transform", `translate(${ leftPadding - 5 }, 0)`)
            .call(yAxisQueryDepth)
            .attr("font-size", "10px");
        // .attr("font-family", "calibri");

        svg.append("g")
            .append("text")
            .attr("y", d3.mean([topPadding, 50]))
            .attr("x", leftPadding - 32)
            .attr("text-anchor", "middle")
            .attr("font-size", "12px")
            // .attr("font-family", "times")
            .attr("transform", function () {
                return `rotate(-90, ${ d3.select(this).attr("x") }, ${ d3.select(this).attr("y") })`;
            })
            .text("Depth")
            .style("fill", "#68AC57");

        subjectDepthInfo.forEach((d) => {
            let subjectChr = subjectChrInfo.find(e => e.seqchr === d.listY);
            let subjectAccumulatePos = subjectChr.accumulate_start + d.coordY;
            d.subjectAccumulatePos = subjectAccumulatePos;
        });

        var subjectDepthMax = d3.max(subjectDepthInfo, function (d) { return d.count; });
        var subjectDepthScale = d3.scaleLinear()
            .domain([0, subjectDepthMax])
            .range([0, 90]);

        var numTicks = subjectDepthMax > 12 ? Math.floor(subjectDepthMax / 4) : subjectDepthMax;
        var yAxisSubjectDepth = d3.axisTop()
            .scale(d3.scaleLinear()
                .domain([0, subjectDepthMax])
                .range([xScaler(queryWidth) + 5, xScaler(queryWidth) + 95]))
            .ticks(numTicks)
            .tickFormat(d3.format(".0f"));

        svg.append('g')
            .attr("class", "subjectDepth")
            .selectAll("rect")
            .data(subjectDepthInfo)
            .join("rect")
            .attr("x", function (d) { return xScaler(queryWidth) + 5; })
            .attr("y", function (d) {
                return yScaler(d.subjectAccumulatePos);
            })
            .attr("width", function (d) {
                return subjectDepthScale(d.count);
            })
            .attr("height", 1)
            .style("fill", "#8E549E")
            .attr("opacity", 1)
            .style("stroke", "#8E549E")
            .style("stroke-width", 0.5);

        svg.append("g")
            .attr("class", "axis")
            .attr("transform", `translate(0, ${ topPadding - 5 })`)
            .call(yAxisSubjectDepth)
            .attr("font-size", "10px");
        // .attr("font-family", "calibri");

        svg.append("g")
            .append("text")
            .attr("y", 120 * scaleRatio)
            .attr("x", d3.mean([xScaler(queryWidth) + 5, xScaler(queryWidth) + 95]))
            .attr("text-anchor", "middle")
            .attr("font-size", "12px")
            // .attr("font-family", "times")
            .text("Depth")
            .style("fill", "#8E549E");

        // Create a legend for the color scale
        var defs = svg.append("defs")
        var gradient = defs.append("linearGradient")
            .attr("id", "color-scale")
            .attr("x1", "0%").attr("y1", "0%")
            .attr("x2", "0%").attr("y2", "100%");
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
            .attr("stop-color", colorScale(5));

        // Add the legend rectangle with the gradient fill
        var legendGroup = svg.append("g")
            .attr("class", "legend")
            .attr("transform", "translate(" + (leftPadding) + "," + (5 * scaleRatio) + ")");

        legendGroup.append("rect")
            .attr("x", -65)
            .attr("y", 50)
            .attr("width", 15)
            .attr("height", 80)
            .attr("fill", "url(#color-scale)")
            .attr("fill-opacity", 0.7);

        var axisScale = d3.scaleLinear()
            .domain([0, 5])
            .range([50, 130]);

        // Create the axis
        var axis = d3.axisLeft(axisScale)
            .ticks(5);

        var axisGroup = legendGroup.append("g")
            .attr("class", "axis")
            .attr("transform", "translate(" + (-70) + "," + 0 + ")")
            .call(axis)
            .attr("text-anchor", "middle")
            .attr("dominant-baseline", "hanging")
            .attr("font-size", "10px");
        // .attr("font-family", "calibri");

        legendGroup.append("text")
            .attr("x", -100)
            .attr("y", 90)
            .append("tspan")
            // .attr("font-family", "times")
            .html("<tspan style='font-style: italic;'>K</tspan>")
            .style("font-size", "13px")
            .append("tspan")
            .text("s")
            .style("font-size", "12px")
            .attr("dx", "1px")
            .attr("dy", "2px");

        /* svg.append("rect")
            .attr("class", "legend")
            .attr("transform", "translate(" + (leftPadding * scaleRatio) + "," + 5 + ")")
            .attr("x", -65 * scaleRatio)
            .attr("y", 50 * scaleRatio)
            .attr("width", 15 * scaleRatio)
            .attr("height", 80 * scaleRatio)
            .attr("fill", "url(#color-scale)")
            .attr("fill-opacity", 0.7);

        var axisScale = d3.scaleLinear()
            .domain([0, 5])
            .range([50 * scaleRatio, 130 * scaleRatio]);

        // Create the axis
        var axis = d3.axisLeft(axisScale)
            .ticks(5);

        var axisGroup = svg.append("g")
            .attr("class", "axis")
            .attr("transform", "translate(" + (leftPadding * scaleRatio - 70) + "," + 5 + ")")
            .call(axis)
            .attr("text-anchor", "middle")
            .attr("dominant-baseline", "hanging")
            .attr("font-size", "10px")
            .attr("font-family", "calibri");

        svg.append("text")
            .attr("class", "legend")
            .attr("transform", "translate(" + (leftPadding * scaleRatio) + "," + 5 + ")")
            .attr("x", -100 * scaleRatio)
            .attr("y", 90 * scaleRatio)
            .append("tspan")
            // .attr("font-family", "times")
            .html("<tspan style='font-style: italic;'>K</tspan>")
            .style("font-size", "13px")
            .append("tspan")
            .text("s")
            .style("font-size", "12px")
            .attr("dx", "1px")
            .attr("dy", "2px"); */

        //tippy(".multipliscons path", {trigger: "mouseenter", followCursor: "initial",  delay: [tooltipDelay, null]});
        tippy(".xLabel text", { trigger: "mouseenter", followCursor: "initial", allowHTML: true, delay: [tooltipDelay, null] });
        tippy(".yLabel text", { trigger: "mouseenter", followCursor: "initial", allowHTML: true, delay: [tooltipDelay, null] });
        tippy(".multiplicons line", { trigger: "mouseenter", followCursor: "initial", allowHTML: true, delay: [tooltipDelay, null] });

        querySpecies = querySpecies.replace(" ", "_");
        subjectSpecies = subjectSpecies.replace(" ", "_");
        downloadSVG("Dot_download_" + plotId,
            "dotView_" + plotId,
            querySpecies + "_vs_" + subjectSpecies + ".dot_plot.svg");

        // Convert the SVG to PNG
        /* const svgXml = new XMLSerializer().serializeToString(svg.node());
        const img = new Image();
        img.src = 'data:image/svg+xml;base64,' + btoa(svgXml);

        img.onload = function () {
            var canvas = document.createElement("canvas");
            var scale = 2;
            canvas.style.width = width + 'px';
            canvas.style.height = height + 'px';
            canvas.width = width;
            canvas.height = height;

            const ctx = canvas.getContext('2d');
            ctx.drawImage(img, 0, 0);

            const pngDataUrl = canvas.toDataURL('image/png');

            const previousPngImg = document.querySelector("#dotView_png_" + plotId + " img");
            if (previousPngImg) {
                previousPngImg.remove();
            }

            const pngImg = new Image();
            pngImg.src = pngDataUrl;
            document.querySelector("#dotView_png_" + plotId).appendChild(pngImg);
        }; */
    }

    Shiny.addCustomMessageHandler("searchGene", searchGene);
    function searchGene(InputData) {
        var plotId = InputData.plot_id;
        var searchMultiplicon = convertShinyData(InputData.geneId);

        var svg = d3.select("#dotView_" + plotId)
            .select("svg")
        var foundMultiplicons = new Set();
        var foundItems = 0;
        svg.selectAll("circle")
            .each(function (d) {
                var circle = d3.select(this);
                var multiplicon = circle.attr("id").split("_")[1];
                if (searchMultiplicon.find(function (obj) {
                    return obj.multiplicon == multiplicon;
                })) {
                    //circle.attr("visibility", "visible");
                    foundItems++;
                    foundMultiplicons.add(multiplicon);
                } // else {
                //  circle.attr("visibility", "hidden");
                // }
                /* if (searchMultiplicon.find(function (obj) { return obj.multiplicon == multiplicon; })) {
                    circle.attr("r", 4);
                } */
            });
        if (foundItems > 0) {
            var message = "<span style='color: #FF79BC; font-weight: bold;'>" + foundItems + " Anchor Point" + (foundItems === 1 ? "</span> is" : "s</span> are") + " found in Multiplicon (ID: <span style='color: #EA7500; font-weight: bold;'>" + Array.from(foundMultiplicons).join(", ") + "</span>)";
            Shiny.onInputChange("foundMultiplicons_" + plotId, Array.from(foundMultiplicons));
        } else {
            var message = "<span style='color: #FF79BC; font-weight: bold;'> No Anchor Point</span> is found!";
        }
        Shiny.onInputChange("foundItemsMessage_" + plotId, message);
    }

    Shiny.addCustomMessageHandler("microSynPlotting", microSynPlotting);
    function microSynPlotting(InputData) {
        var plotId = InputData.plot_id;
        var anchorPointInfo = convertShinyData(InputData.anchorpoints);
        var queryChrInfo = convertShinyData(InputData.query_chr_info);
        var queryGeneInfo = convertShinyData(InputData.query_chr_genes);
        var subjectChrInfo = convertShinyData(InputData.subject_chr_info);
        var subjectGeneInfo = convertShinyData(InputData.subject_chr_genes);
        var querySpecies = InputData.query_sp;
        var subjectSpecies = InputData.subject_sp;
        var targeGene = InputData.targe_gene;
        var width = InputData.width;
        var height = InputData.height;

        const query_chr_colors = [
            "#9B3A4D", "#32AEEC", "#E2AE79", "#8E549E", "#EA7500",
            "#566CA5", "#D2352C", "#394A92", "#68AC57", "#F4C28F"
        ];
        const subject_chr_colors = ["#9D9D9D", "#3C3C3C"]

        // console.log("width", width);
        // console.log("height", height);

        // console.log("anchorPointInfo", anchorPointInfo);
        // console.log("queryChrInfo", queryChrInfo);
        // console.log("subjectChrInfo", subjectChrInfo);

        // Group the data by multiplicon
        const groupedQueryChr = queryChrInfo.reduce((groups, obj) => {
            const { multiplicon, max, min } = obj;
            if (!groups[multiplicon]) {
                groups[multiplicon] = { multiplicon, sum: max - min };
            } else {
                groups[multiplicon].sum += max - min;
            }
            return groups;
        }, {});
        let maxQueryChrSum = -Infinity;
        let maxQueryChrMultiplicon = null;
        Object.values(groupedQueryChr).forEach((group) => {
            if (group.sum > maxQueryChrSum) {
                maxQueryChrSum = group.sum;
                maxQueryChrMultiplicon = group.multiplicon;
            }
        });
        // const maxQueryChrSum = Math.max(...Object.values(groupedQueryChr).map((group) => group.sum));
        // console.log("maxQueryChrMultiplicon", maxQueryChrMultiplicon, "maxQueryChrSum", maxQueryChrSum);

        const groupedSubjectChr = subjectChrInfo.reduce((groups, obj) => {
            const { multiplicon, max, min } = obj;
            if (!groups[multiplicon]) {
                groups[multiplicon] = { multiplicon, sum: max - min };
            } else {
                groups[multiplicon].sum += max - min;
            }
            return groups;
        }, {});
        let maxSubjectChrSum = -Infinity;
        let maxSubjectChrMultiplicon = null;
        Object.values(groupedSubjectChr).forEach((group) => {
            if (group.sum > maxSubjectChrSum) {
                maxSubjectChrSum = group.sum;
                maxSubjectChrMultiplicon = group.multiplicon;
            }
        });
        // const maxSubjectChrSum = Math.max(...Object.values(groupedSubjectChr).map((group) => group.sum));
        // console.log("maxSubjectChrMultiplicon", maxSubjectChrMultiplicon, "maxSubjectChrSum", maxSubjectChrSum);

        if (maxQueryChrSum > maxSubjectChrSum) {
            var scaleData = queryChrInfo.filter(item => item.multiplicon === maxQueryChrMultiplicon);
        } else {
            var scaleData = subjectChrInfo.filter(item => item.multiplicon === maxSubjectChrMultiplicon);
        }

        const allMultiplicons = anchorPointInfo.map(item => item.multiplicon);
        const uniqueMultiplicons = [...new Set(allMultiplicons)];
        // console.log("uniqueMultiplicons", uniqueMultiplicons);

        // define syntenic plot dimension
        let topPadding = 50 * height / 200;
        let bottomPadding = 30 * height / 200;
        let leftPadding = 10;
        let rightPadding = 50;
        let chrRectHeight = 4;
        let innerPadding = 20;
        var tooltipDelay = 500;

        var middlePoint = (width - leftPadding - rightPadding) / 2;
        d3.select("#microSyntenicBlock_" + plotId)
            .select("svg").remove();
        const svg = d3.select("#microSyntenicBlock_" + plotId)
            .append("svg")
            .attr("width", width)
            .attr("height", height * uniqueMultiplicons.length);

        const innerScale = d3.scaleLinear()
            .domain([0, 1])
            .range([
                0,
                width - leftPadding - rightPadding
            ]);

        var scaleChrData = calc_micro_accumulate_len(scaleData, innerScale, innerPadding);
        const ChrScaler = d3
            .scaleLinear()
            .domain([
                scaleChrData[0].accumulate_start,
                scaleChrData[scaleChrData.length - 1].accumulate_end
            ])
            .range([
                0 + leftPadding,
                width - rightPadding
            ]);

        uniqueMultiplicons.forEach((multipliconIdx, each) => {
            const strMultipliconIdx = multipliconIdx.toString();
            const matchedAnchorPointsInfo = anchorPointInfo.filter(item => item.multiplicon === multipliconIdx);
            var matchedQueryChrInfo = queryChrInfo.filter(item => item.multiplicon === strMultipliconIdx);
            matchedQueryChrInfo = calc_micro_accumulate_len(matchedQueryChrInfo, innerScale, innerPadding);
            var matchedSubjectChrInfo = subjectChrInfo.filter(item => item.multiplicon === strMultipliconIdx);
            matchedSubjectChrInfo = calc_micro_accumulate_len(matchedSubjectChrInfo, innerScale, innerPadding);
            var matchedQueryGeneInfo = queryGeneInfo.filter(item => item.multiplicon === strMultipliconIdx);
            var matchedSubjectGeneInfo = subjectGeneInfo.filter(item => item.multiplicon === strMultipliconIdx);

            const queryGroup = svg.append("g")
                .attr("class", "queryChrs")
                .attr("transform", `translate(0, ${ 200 * each })`);
            const subjectGroup = svg.append("g")
                .attr("class", "subjectChrs")
                .attr("transform", `translate(0, ${ 200 * each })`);

            var queryWidth = d3.max(matchedQueryChrInfo, function (d) { return d.accumulate_end; });
            var subjectWidth = d3.max(matchedSubjectChrInfo, function (d) { return d.accumulate_end; });

            if (queryWidth > subjectWidth) {
                // var startX = middlePoint - ChrScaler(subjectWidth) / 2;
                var startX = ChrScaler(queryWidth) / 2 - ChrScaler(subjectWidth) / 2;
            } else if (queryWidth < subjectWidth) {
                var startX = ChrScaler(subjectWidth) / 2 - ChrScaler(queryWidth) / 2;
            } else {
                var startX = 0;
            }

            // add main lebel for each chromosome
            queryGroup.append("text")
                .text(querySpecies)
                .attr("id", "queryMainLabel")
                .attr("x", 5 + leftPadding)
                .attr("y", topPadding - 10)
                .attr("font-weight", "bold")
                .attr("font-size", "14px")
                .attr("font-style", "italic")
                // .attr("font-family", "times")
                .style("fill", "#68AC57");

            const querySpeciesLabelLength = querySpecies.toString().length;
            const queryTitlePadding = querySpeciesLabelLength * 4;

            svg.append("text")
                .text("Multiplicon: " + multipliconIdx)
                .attr("class", "multipliconId")
                .attr("id", "multipliconId")
                .attr("x", queryTitlePadding + 120 + leftPadding)
                .attr("y", topPadding - 10 + 200 * each)
                .attr("font-weight", "bold")
                .attr("font-size", "13px")
                // .attr("font-family", "Calibri")
                .style("fill", "#4A4AFF");

            queryGroup.selectAll("text")
                .attr("class", "queryChrLabel")
                .filter(":not(#queryMainLabel)")
                .data(matchedQueryChrInfo)
                .join("text")
                .text((d) => d.listX)
                .attr("text-anchor", "middle")
                .attr("x", function (d) {
                    if (queryWidth >= subjectWidth) {
                        return d3.mean([ChrScaler(d.accumulate_end), ChrScaler(d.accumulate_start)]);
                    } else {
                        return Number(startX) + d3.mean([ChrScaler(d.accumulate_end), ChrScaler(d.accumulate_start)]);
                    }
                })
                .attr("y", function () {
                    return Number(d3.select("#queryMainLabel").attr("y")) + Number(d3.select(this).node().getBBox().height) + 10;
                })
                .attr("font-size", "12px")
            // .attr("font-family", "Calibri")

            const query_chr_colorScale = d3.scaleOrdinal()
                .domain(matchedQueryChrInfo.map((d) => d.idx))
                .range(query_chr_colors);

            queryGroup.selectAll(".queryChrShape")
                .data(matchedQueryChrInfo)
                .join("rect")
                .attr("class", "queryChrShape")
                .attr("id", (d) => "queryChr_" + d.idx)
                .attr("x", function (d) {
                    if (queryWidth >= subjectWidth) {
                        return ChrScaler(d.accumulate_start);
                    } else {
                        return Number(startX) + ChrScaler(d.accumulate_start);
                    }
                })
                .attr("y", topPadding + d3.select("#queryMainLabel").node().getBBox().height + 5 + d3.selectAll(".queryChrs text").filter(":not(#queryMainLabel)").node().getBBox().height + 5)
                .attr(
                    "width",
                    (d) => ChrScaler(d.accumulate_end) - ChrScaler(d.accumulate_start)
                )
                .attr("height", chrRectHeight)
                .attr("opacity", 0.6)
                .attr("fill", (d) => query_chr_colorScale(d.idx))
                .attr("ry", 3);

            // Add position labels and connecting lines
            const positionLabels = queryGroup.selectAll(".queryPosLabel")
                .data(matchedQueryChrInfo);

            // console.log("matchedQueryChrInfo", matchedQueryChrInfo);
            positionLabels.enter()
                .append("text")
                .attr("class", "queryPosLabel")
                .merge(positionLabels)
                .text(function (d) {
                    return numFormatter(d.min / 1000000);
                })
                .attr("x", function (d) {
                    if (queryWidth >= subjectWidth) {
                        if (ChrScaler(d.len) < 60) {
                            return ChrScaler(d.accumulate_start) - 5;
                        } else {
                            return ChrScaler(d.accumulate_start) + 5;
                        }
                    } else {
                        if (ChrScaler(d.len) < 60) {
                            return startX + ChrScaler(d.accumulate_start) - 5;
                        } else {
                            return startX + ChrScaler(d.accumulate_start) + 5;
                        }
                    }
                })
                .attr("y", topPadding + d3.select("#queryMainLabel").node().getBBox().height + d3.selectAll(".queryChrs text").filter(":not(#queryMainLabel)").node().getBBox().height)
                .attr("text-anchor", function (d) {
                    if (ChrScaler(d.len) < 60) {
                        return "end";
                    } else {
                        return "start";
                    }
                })
                .attr("font-size", "10px")
                // .attr("font-family", "Calibri")
                .attr('fill', 'blue')
                .attr('opacity', 0.5);

            positionLabels.enter()
                .append("text")
                .attr("class", "queryPosLabel")
                .merge(positionLabels)
                .text(function (d, idx) {
                    if (idx === (matchedQueryChrInfo.length - 1)) {
                        return numFormatter((d.len + d.min) / 1000000) + " Mb";
                    } else {
                        return numFormatter((d.len + d.min) / 1000000);
                    }
                })
                .attr("x", function (d) {
                    if (queryWidth >= subjectWidth) {
                        if (ChrScaler(d.len) < 60) {
                            return ChrScaler(d.accumulate_start) + 5;
                        } else {
                            return ChrScaler(d.accumulate_end) - 5;
                        }
                    } else {
                        if (ChrScaler(d.len) < 60) {
                            return startX + ChrScaler(d.accumulate_end) + 5;
                        } else {
                            return startX + ChrScaler(d.accumulate_end) - 5;
                        }
                    }
                })
                .attr("y", topPadding + d3.select("#queryMainLabel").node().getBBox().height + d3.selectAll(".queryChrs text").filter(":not(#queryMainLabel)").node().getBBox().height)
                .attr("text-anchor", function (d) {
                    if (ChrScaler(d.len) < 60) {
                        return "start";
                    } else {
                        return "end";
                    }
                })
                .attr("font-size", "10px")
                // .attr("font-family", "Calibri")
                .attr('fill', 'blue')
                .attr('opacity', 0.5);

            positionLabels.enter()
                .append("line")
                .attr("class", "queryPosLabelLine")
                .merge(positionLabels)
                .attr("x1", function (d) {
                    if (queryWidth >= subjectWidth) {
                        return ChrScaler(d.accumulate_start);
                    } else {
                        return startX + ChrScaler(d.accumulate_start);
                    }
                })
                .attr("y1", topPadding + d3.select("#queryMainLabel").node().getBBox().height + 5 + d3.selectAll(".queryChrs text").filter(":not(#queryMainLabel)").node().getBBox().height + 5 + chrRectHeight / 2)
                .attr("x2", function (d) {
                    if (queryWidth >= subjectWidth) {
                        return ChrScaler(d.accumulate_start);
                    } else {
                        return startX + ChrScaler(d.accumulate_start);
                    }
                })
                .attr("y2", topPadding + d3.select("#queryMainLabel").node().getBBox().height + d3.selectAll(".queryChrs text").filter(":not(#queryMainLabel)").node().getBBox().height - 12 + chrRectHeight / 2)
                .attr("stroke-width", 0.86)
                .attr("stroke-opacity", 0.5)
                .attr("stroke", "blue");

            positionLabels.enter()
                .append("line")
                .attr("class", "queryPosLabelLine")
                .merge(positionLabels)
                .attr("x1", function (d) {
                    if (queryWidth >= subjectWidth) {
                        return ChrScaler(d.accumulate_end);
                    } else {
                        return startX + ChrScaler(d.accumulate_end);
                    }
                })
                .attr("y1", topPadding + d3.select("#queryMainLabel").node().getBBox().height + 5 + d3.selectAll(".queryChrs text").filter(":not(#queryMainLabel)").node().getBBox().height + 5 + chrRectHeight / 2)
                .attr("x2", function (d) {
                    if (queryWidth >= subjectWidth) {
                        return ChrScaler(d.accumulate_end);
                    } else {
                        return startX + ChrScaler(d.accumulate_end);
                    }
                })
                .attr("y2", topPadding + d3.select("#queryMainLabel").node().getBBox().height + d3.selectAll(".queryChrs text").filter(":not(#queryMainLabel)").node().getBBox().height - 12 + chrRectHeight / 2)
                .attr("stroke-width", 0.86)
                .attr("stroke-opacity", 0.5)
                .attr("stroke", "blue");

            // plot genes to chr 
            matchedQueryGeneInfo.forEach((d) => {
                let queryChr = matchedQueryChrInfo.find(e => e.listX === d.seqchr);
                let queryAccumulateStart = queryChr.accumulate_start + d.start + 1;
                let queryAccumulateEnd = queryChr.accumulate_start + d.end + 1;
                if (queryWidth >= subjectWidth) {
                    d.queryX = ChrScaler(queryAccumulateStart);
                    d.queryX1 = ChrScaler(queryAccumulateEnd);
                } else {
                    d.queryX = startX + ChrScaler(queryAccumulateStart);
                    d.queryX1 = startX + ChrScaler(queryAccumulateEnd);
                }
            })

            queryGroup.selectAll(".queryGeneShape")
                .data(matchedQueryGeneInfo)
                .join("polygon")
                .attr("class", "queryGeneShape")
                .attr("id", (d) => "queryGene_" + d.gene)
                .attr("points", (d) => {
                    const x = d.queryX;
                    const y = topPadding + d3.select("#queryMainLabel").node().getBBox().height + d3.selectAll(".queryChrs text").filter(":not(#queryMainLabel)").node().getBBox().height + 7;
                    const width = d.queryX1 - d.queryX;

                    // Point out the targetGene                                
                    if (d.gene === targeGene) {
                        svg.append("line")
                            .attr("class", "targe-gene")
                            .attr('x1', x)
                            .attr('y1', y + 200 * each)
                            .attr('x2', x)
                            .attr('y2', y + 200 * each - 30)
                            .attr('stroke', 'orange')
                            .attr('opacity', '0.7')
                            .attr('stroke-width', "0.8")
                            .attr("stroke-dasharray", "5 3");

                        svg.append("text")
                            .attr('x', x)
                            .attr('y', y + 200 * each - 35)
                            .text(targeGene)
                            .attr('fill', 'orange')
                            .attr("font-size", "9px")
                            .attr('text-anchor', 'start')
                        // .attr("font-family", "Calibri")
                        // .attr("transform", `rotate(30, ${x}, ${y + 200 * each - 25})`);
                    }

                    if (d.strand === "+") {
                        if (width > 10) {
                            return `${ x },${ y } ${ x + 10 },${ y } ${ x + width },${ y + 5 } ${ x + 10 },${ y + 10 } ${ x },${ y + 10 }`;
                        } else {
                            return `${ x },${ y } ${ x + width },${ y + 5 } ${ x },${ y + 10 }`;
                        }
                    } else {
                        if (width > 10) {
                            return `${ x },${ y + 5 } ${ x + 10 },${ y } ${ x + width },${ y } ${ x + width },${ y + 10 } ${ x + 10 },${ y + 10 }`;
                        } else {
                            return `${ x },${ y + 5 } ${ x + width },${ y } ${ x + width },${ y + 10 }`;
                        }
                    }
                })
                .attr("fill", d => (d.strand === "+") ? "green" : "#A6A600")
                .attr("opacity", 0.8)
                .attr("data-tippy-content", d => {
                    return "Gene: <font color='#FFE153'><b>" + d.gene + "</font></b><br>" +
                        "Chr: <font color='#FFE153'><b>" + d.seqchr + "</font></b><br>" +
                        "Position: <font color='#FFE153'><b>" + d.start + " -> " + d.end + "</font></b><br>" +
                        "Strand: <font color='#9AFF02'><b>" + d.strand + "</font></b>";
                });
            tippy(".queryGeneShape", { trigger: "mouseenter", followCursor: "initial", allowHTML: true, delay: [tooltipDelay, null] });

            subjectGroup.selectAll("text")
                .filter(":not(#subjectMainLabel)")
                .data(matchedSubjectChrInfo)
                .join("text")
                .text((d) => d.listY)
                .attr("text-anchor", "middle")
                .attr("x", function (d) {
                    if (queryWidth >= subjectWidth) {
                        return Number(startX) + d3.mean([ChrScaler(d.accumulate_end), ChrScaler(d.accumulate_start)]);
                    } else {
                        return d3.mean([ChrScaler(d.accumulate_end), ChrScaler(d.accumulate_start)]);
                    }
                })
                .attr("y", height - bottomPadding - d3.select("#subjectMainLabel").node().getBBox().height - d3.selectAll(".subjectChrs text").filter(":not(#subjectMainLabel)").node().getBBox().height + 20)
                .attr("font-size", "12px")
                // .attr("font-family", "Calibri")
                .attr("class", "queryChrLabel");

            const subject_chr_colorScale = d3.scaleOrdinal()
                .domain(matchedSubjectChrInfo.map((d) => d.idx))
                .range(subject_chr_colors);

            subjectGroup.selectAll(".subjectChrShape")
                .data(matchedSubjectChrInfo)
                .join("rect")
                .attr("class", "subjectChrShape")
                .attr("id", (d) => "subjectChr_" + d.idx)
                .attr("x", function (d) {
                    if (queryWidth >= subjectWidth) {
                        return Number(startX) + ChrScaler(d.accumulate_start);
                    } else {
                        return ChrScaler(d.accumulate_start);
                    }
                })
                .attr("y", height - bottomPadding - d3.select("#subjectMainLabel").node().getBBox().height - 5 - d3.selectAll(".subjectChrs text").filter(":not(#subjectMainLabel)").node().getBBox().height - 5 - chrRectHeight)
                .attr(
                    "width",
                    (d) => ChrScaler(d.accumulate_end) - ChrScaler(d.accumulate_start)
                )
                .attr("height", chrRectHeight)
                .attr("opacity", 0.6)
                .attr("fill", (d) => subject_chr_colorScale(d.idx))
                .attr("ry", 3);


            const subjectPositionLabels = subjectGroup.selectAll(".subjectPosLabel")
                .data(matchedSubjectChrInfo);

            subjectPositionLabels.enter()
                .append("text")
                .attr("class", "subjectPosLabel")
                .merge(subjectPositionLabels)
                .text(function (d) {
                    return numFormatter(d.min / 1000000);
                })
                .attr("x", function (d) {
                    if (queryWidth >= subjectWidth) {
                        if (ChrScaler(d.len) < 60) {
                            return startX + ChrScaler(d.accumulate_start) - 5;
                        } else {
                            return startX + ChrScaler(d.accumulate_start) + 5;
                        }
                    } else {
                        if (ChrScaler(d.len) < 60) {
                            return ChrScaler(d.accumulate_start) - 5;
                        } else {
                            return ChrScaler(d.accumulate_start) + 5;
                        }
                    }
                })
                .attr("y", height - bottomPadding - d3.select("#subjectMainLabel").node().getBBox().height - 5 - d3.selectAll(".subjectChrs text").filter(":not(#subjectMainLabel)").node().getBBox().height + 20 - chrRectHeight - 2)
                .attr("text-anchor", function (d) {
                    if (ChrScaler(d.len) < 60) {
                        return "end";
                    } else {
                        return "start";
                    }
                })
                .attr("font-size", "10px")
                // .attr("font-family", "Calibri")
                .attr('fill', 'blue')
                .attr('opacity', 0.5);

            subjectPositionLabels.enter()
                .append("text")
                .attr("class", "subjectPosLabel")
                .merge(subjectPositionLabels)
                .text(function (d, idx) {
                    if (idx === (matchedSubjectChrInfo.length - 1)) {
                        return numFormatter((d.len + d.min) / 1000000) + " Mb";
                    } else {
                        return numFormatter((d.len + d.min) / 1000000);
                    }
                })
                .attr("x", function (d) {
                    if (queryWidth >= subjectWidth) {
                        if (ChrScaler(d.len) < 60) {
                            return startX + ChrScaler(d.accumulate_end) + 5;
                        } else {
                            return startX + ChrScaler(d.accumulate_end) - 5;
                        }
                    } else {
                        if (ChrScaler(d.len) < 60) {
                            return ChrScaler(d.accumulate_end) + 5;
                        } else {
                            return ChrScaler(d.accumulate_end) - 5;
                        }
                    }
                })
                .attr("y", height - bottomPadding - d3.select("#subjectMainLabel").node().getBBox().height - 5 - d3.selectAll(".subjectChrs text").filter(":not(#subjectMainLabel)").node().getBBox().height + 20 - chrRectHeight - 2)
                .attr("text-anchor", function (d) {
                    if (ChrScaler(d.len) < 60) {
                        return "start";
                    } else {
                        return "end";
                    }
                })
                .attr("font-size", "10px")
                // .attr("font-family", "Calibri")
                .attr('fill', 'blue')
                .attr('opacity', 0.5);

            subjectPositionLabels.enter()
                .append("line")
                .attr("class", "subjectPosLabelLine")
                .merge(subjectPositionLabels)
                .attr("x1", function (d) {
                    if (queryWidth >= subjectWidth) {
                        return startX + ChrScaler(d.accumulate_start);
                    } else {
                        return ChrScaler(d.accumulate_start);
                    }
                })
                .attr("y1", height - bottomPadding - d3.select("#subjectMainLabel").node().getBBox().height - 5 - d3.selectAll(".subjectChrs text").filter(":not(#subjectMainLabel)").node().getBBox().height - chrRectHeight / 2 - 5)
                .attr("x2", function (d) {
                    if (queryWidth >= subjectWidth) {
                        return startX + ChrScaler(d.accumulate_start);
                    } else {
                        return ChrScaler(d.accumulate_start);
                    }
                })
                .attr("y2", height - bottomPadding - d3.select("#subjectMainLabel").node().getBBox().height - d3.selectAll(".subjectChrs text").filter(":not(#subjectMainLabel)").node().getBBox().height + 20 - chrRectHeight / 2 - 5)
                .attr("stroke-width", 0.86)
                .attr("stroke-opacity", 0.5)
                .attr("stroke", "blue");

            subjectPositionLabels.enter()
                .append("line")
                .attr("class", "subjectPosLabelLine")
                .merge(subjectPositionLabels)
                .attr("x1", function (d) {
                    if (queryWidth >= subjectWidth) {
                        return startX + ChrScaler(d.accumulate_end);
                    } else {
                        return ChrScaler(d.accumulate_end);
                    }
                })
                .attr("y1", height - bottomPadding - d3.select("#subjectMainLabel").node().getBBox().height - 5 - d3.selectAll(".subjectChrs text").filter(":not(#subjectMainLabel)").node().getBBox().height - chrRectHeight / 2 - 5)
                .attr("x2", function (d) {
                    if (queryWidth >= subjectWidth) {
                        return startX + ChrScaler(d.accumulate_end);
                    } else {
                        return ChrScaler(d.accumulate_end);
                    }
                })
                .attr("y2", height - bottomPadding - d3.select("#subjectMainLabel").node().getBBox().height - d3.selectAll(".subjectChrs text").filter(":not(#subjectMainLabel)").node().getBBox().height + 20 - chrRectHeight / 2 - 5)
                .attr("stroke-width", 0.86)
                .attr("stroke-opacity", 0.5)
                .attr("stroke", "blue");


            matchedSubjectGeneInfo.forEach((d) => {
                let subjectChr = matchedSubjectChrInfo.find(e => e.listY === d.seqchr);
                let subjectAccumulateStart = subjectChr.accumulate_start + d.start + 1;
                let subjectAccumulateEnd = subjectChr.accumulate_start + d.end + 1;
                if (queryWidth < subjectWidth) {
                    d.subjectX = ChrScaler(subjectAccumulateStart);
                    d.subjectX1 = ChrScaler(subjectAccumulateEnd);
                } else {
                    d.subjectX = startX + ChrScaler(subjectAccumulateStart);
                    d.subjectX1 = startX + ChrScaler(subjectAccumulateEnd);
                }
            })

            subjectGroup.selectAll(".subjectGeneShape")
                .data(matchedSubjectGeneInfo)
                .join("polygon")
                .attr("class", "subjectGeneShape")
                .attr("id", (d) => "subjectGene_" + d.gene)
                .attr("points", (d) => {
                    const x = d.subjectX;
                    const y = height - bottomPadding - d3.select("#subjectMainLabel").node().getBBox().height - 10 - d3.selectAll(".subjectChrs text").filter(":not(#subjectMainLabel)").node().getBBox().height - 3 - chrRectHeight;
                    const width = d.subjectX1 - d.subjectX;

                    // Point out the targetGene                                
                    if (d.gene === targeGene) {
                        svg.append("line")
                            .attr("class", "targe-gene")
                            .attr('x1', x)
                            .attr('y1', y + 200 * each)
                            .attr('x2', x)
                            .attr('y2', y + 200 * each + 45)
                            .attr('stroke', 'orange')
                            .attr('opacity', '0.7')
                            .attr('stroke-width', "0.8")
                            .attr("stroke-dasharray", "5 3");

                        svg.append("text")
                            .attr('x', x)
                            .attr('y', y + 200 * each + 50)
                            .text(targeGene)
                            .attr('fill', 'orange')
                            .attr("font-size", "9px")
                            .attr('text-anchor', 'start')
                        // .attr("font-family", "Calibri");
                        // .attr("transform", `rotate(-30, ${x}, ${y + 200 * each + 25})`);
                    }

                    if (d.strand === "+") {
                        if (width > 10) {
                            return `${ x },${ y } ${ x + 10 },${ y } ${ x + width },${ y + 5 } ${ x + 10 },${ y + 10 } ${ x },${ y + 10 }`;
                        } else {
                            return `${ x },${ y } ${ x + width },${ y + 5 } ${ x },${ y + 10 }`;
                        }
                    } else {
                        if (width > 10) {
                            return `${ x },${ y + 5 } ${ x + 10 },${ y } ${ x + width },${ y } ${ x + width },${ y + 10 } ${ x + 10 },${ y + 10 }`;
                        } else {
                            return `${ x },${ y + 5 } ${ x + width },${ y } ${ x + width },${ y + 10 }`;
                        }
                    }
                })
                .attr("fill", d => (d.strand === "+") ? "green" : "#A6A600")
                .attr("opacity", 0.8)
                .attr("data-tippy-content", d => {
                    const fillColor = d.strand === "+" ? "green" : "#A6A600";
                    return "Gene: <font color='#4DFFFF'><b>" + d.gene + "</font></b><br>" +
                        "Chr: <font color='#4DFFFF'><b>" + d.seqchr + "</font></b><br>" +
                        "Position: <font color='#4DFFFF'><b>" + d.start + " -> " + d.end + "</font></b><br>" +
                        "Strand: <font color='#4DFFFF'><b>" + d.strand + "</font></b>";
                });

            tippy(".subjectGeneShape", { trigger: "mouseenter", followCursor: "initial", allowHTML: true, delay: [tooltipDelay, null] });

            // prepare anchorpoint data
            matchedAnchorPointsInfo.forEach((d) => {
                let queryChr = matchedQueryChrInfo.find(e => e.listX === d.listX);
                let subjectChr = matchedSubjectChrInfo.find(e => e.listY === d.listY);
                let queryAccumulateStart = queryChr.accumulate_start + d.startX - queryChr.min + 1;
                let queryAccumulateEnd = queryChr.accumulate_start + d.endX - queryChr.min + 1;
                let subjectAccumulateStart = subjectChr.accumulate_start + d.startY - subjectChr.min + 1;
                let subjectAccumulateEnd = subjectChr.accumulate_start + d.endY - subjectChr.min + 1;
                if (queryWidth >= subjectWidth) {
                    queryX = ChrScaler(queryAccumulateStart);
                    queryX1 = ChrScaler(queryAccumulateEnd);
                    subjectX = startX + ChrScaler(subjectAccumulateStart);
                    subjectX1 = startX + ChrScaler(subjectAccumulateEnd);
                } else {
                    queryX = startX + ChrScaler(queryAccumulateStart);
                    queryX1 = startX + ChrScaler(queryAccumulateEnd);
                    subjectX = ChrScaler(subjectAccumulateStart);
                    subjectX1 = ChrScaler(subjectAccumulateEnd);
                }

                d.ribbonPosition = {
                    source: {
                        x: queryX,
                        x1: queryX1,
                        y: topPadding + d3.select("#queryMainLabel").node().getBBox().height + 5 + d3.selectAll(".queryChrs text").filter(":not(#queryMainLabel)").node().getBBox().height + 5 + chrRectHeight + 200 * each,
                        y1: topPadding + d3.select("#queryMainLabel").node().getBBox().height + 5 + d3.selectAll(".queryChrs text").filter(":not(#queryMainLabel)").node().getBBox().height + 5 + chrRectHeight + 200 * each
                    },
                    target: {
                        x: subjectX,
                        x1: subjectX1,
                        y: height - bottomPadding - d3.select("#subjectMainLabel").node().getBBox().height - 5 - d3.selectAll(".subjectChrs text").filter(":not(#subjectMainLabel)").node().getBBox().height - 5 - chrRectHeight + 200 * each,
                        y1: height - bottomPadding - d3.select("#subjectMainLabel").node().getBBox().height - 5 - d3.selectAll(".subjectChrs text").filter(":not(#subjectMainLabel)").node().getBBox().height - 5 - chrRectHeight + 200 * each
                    }
                };
            })

            subjectGroup.append("text")
                .text(subjectSpecies)
                .attr("id", "subjectMainLabel")
                .attr("x", 5 + leftPadding)
                .attr("y", height - bottomPadding + 20)
                .attr("font-weight", "bold")
                .attr("font-size", "14px")
                .attr("font-style", "italic")
                // .attr("font-family", "times")
                .style("fill", "#8E549E");

            // console.log("anchorpoint", anchorPointInfo);
            svg.append("g")
                .attr("class", "segsRibbons")
                .selectAll("path")
                .data(matchedAnchorPointsInfo)
                .join("path")
                .attr("d", d => createLinkPolygonPath(d.ribbonPosition))
                .attr("class", d => "from_" + plotId + "_" + d.listX + " to_" + plotId + "_" + d.listY)
                //.attr("fill", (d) => query_chr_colorScale(d.idx))
                .attr("fill", function (d) {
                    return colorScale(d.Ks);
                })
                .attr("opacity", 0.6)
                .attr("data-tippy-content", d => {
                    return "Query: <b><font color='#FFE153'>" + d.geneX + "</font></b><br>" +
                        "<font color='red'><b>&#8595</b></font><br>" +
                        "Subject: <b><font color='#4DFFFF'>" + d.geneY + "</font></b><br>" +
                        "<b><font color='orange'><i>K</i><sub>s</sub>: " + d.Ks + "<b></font>";
                });
        });

        tippy(".segsRibbons path", { trigger: "mouseenter", followCursor: "initial", allowHTML: true, delay: [tooltipDelay, null] });

        querySpecies = querySpecies.replace(" ", "_");
        subjectSpecies = subjectSpecies.replace(" ", "_");
        downloadSVGs("microSyn_download_" + plotId,
            "microSyntenicBlock_" + plotId,
            querySpecies + "_vs_" + subjectSpecies + ".microSyn");
    }

    Shiny.addCustomMessageHandler("Cluster_Synteny_Plotting_v7", ClusterSyntenyPlottingV7);
    function ClusterSyntenyPlottingV7(InputData) {
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

        console.log("treeByCol", treeByCol);
        console.log("treeByRow", treeByRow);

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

        const scaleRatio = plotSize / 800;
        // define plot dimension
        let topPadding = 100;
        const longestXLabelLength = d3.max(queryChrInfo, d => d.list.toString().length);
        const xAxisTitlePadding = longestXLabelLength * 6;
        let bottomPadding = 80 + xAxisTitlePadding;
        const longestYLabelLength = d3.max(subjectChrInfo, d => d.list.toString().length);
        const yAxisTitlePadding = longestYLabelLength * 6;
        let leftPadding = 80 + yAxisTitlePadding;
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

        /*         console.log("queryChrOrder", queryChrOrder);
                console.log("queryChrUn", segmentedChrInfo.filter(item => item.genome === querySpeciesTmp))
                console.log("queryChrInfo", queryChrInfo);
                console.log("subjectChrOrder", subjectChrOrder);
                console.log("subjectChrUn", segmentedChrInfo.filter(item => item.genome === subjectSpeciesTmp))
                console.log("subjectChrInfo", subjectChrInfo);
         */
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

        var xScaler = d3.scaleLinear()
            .domain([queryChrInfo[0].accumulate_start, queryChrInfo[queryChrInfo.length - 1].accumulate_end])
            .range([leftPadding, width - rightPadding])

        var yScaler = d3.scaleLinear()
            .domain([subjectChrInfo[0].accumulate_start, subjectChrInfo[subjectChrInfo.length - 1].accumulate_end])
            .range([height - bottomPadding, topPadding])

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

        const xAxis = d3.axisBottom(xScaler)
            .tickValues(queryChrInfo.map(e => e.accumulate_end).slice(0, -1));
        const yAxis = d3.axisLeft(yScaler)
            .tickValues(subjectChrInfo.map(e => e.accumulate_end).slice(0, -1));

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
            .attr("transform", function () {
                return `translate(0, ${ height - bottomPadding })`;
            })
            .call(xAxis)
            .attr("stroke-width", 0.26)
            .call(g => g.selectAll(".tick text").remove())
            .call(g => g.selectAll(".tick line").clone()
                .attr("y2", function () {
                    return topPadding + bottomPadding - height;
                })
                .attr("stroke-dasharray", "4 1")
                .attr("stroke-width", 0.26)
                .attr("stroke-opacity", 0.3)
                .attr("stroke", "blue")
            );

        // add y axis;
        svg.append("g")
            .attr("class", "axis axis--y")
            .attr("transform", `translate(${ leftPadding }, 0)`)
            .call(yAxis)
            .attr("stroke-width", 0.26)
            .call(g => g.selectAll(".tick text").remove())
            .call(g => g.selectAll(".tick line").clone()
                .attr("x2", function () {
                    return width - leftPadding - rightPadding;
                })
                .attr("stroke-dasharray", "4 1")
                .attr("stroke-opacity", 0.3)
                .attr("stroke", "blue")
                .attr("stroke-width", 0.26)
            );

        // add top and right border
        svg.append("g")
            .append("line")
            .attr("transform", `translate(${ leftPadding }, ${ topPadding })`)
            .attr("x2", function () {
                return width - leftPadding - rightPadding;
            })
            .attr("stroke", "black")
            .attr("stroke-width", 0.26)
            .attr("stroke-opacity", 0.3);

        svg.append("g")
            .append("line")
            .attr("transform", function () {
                return `translate(${ width - rightPadding }, ${ topPadding })`;
            })
            .attr("y2", function () {
                return height - topPadding - bottomPadding
            })
            .attr("stroke", "black")
            .attr("stroke-width", 0.26)
            .attr("stroke-opacity", 0.3);

        // add text labels on axises
        svg.append("g")
            .attr("class", "xLabel")
            .selectAll("text")
            .data(queryChrInfo)
            .join("text")
            .attr("x", d => {
                return xScaler(d3.mean([d.accumulate_start, d.accumulate_end]));
            })
            .attr("y", function () {
                return height - bottomPadding + 15;
            })
            .attr("font-size", function () {
                return 8 * scaleRatio + "px";
            })
            // .attr("font-family", "calibri")
            .text(d => d.list)
            .attr("id", function (d) {
                var chrName = d.list.replace(":", "_");
                chrName = chrName.replace("-", "_");
                return "xLabel_" + chrName;
            })
            .attr("text-anchor", "left")
            .attr("data-tippy-content", (d) => {
                return "<font color='#68AC57'>" + d.list
                    + "</font><br>num_gene_remapped: <font color='#68AC57'><b>"
                    + d.num_gene_remapped + "</b></font>";
            })
            .attr("transform", (d) => {
                return "rotate(90 " + xScaler(d3.mean([d.accumulate_start, d.accumulate_end])) + ","
                    + (height - bottomPadding + 15) + ")";
            });

        svg.append("g")
            .attr("class", "yLabel")
            .attr("transform", `translate(${ leftPadding }, ${ topPadding })`)
            .selectAll("g")
            .data(subjectChrInfo)
            .join("g")
            .attr("transform", d => `translate(-15 ${ yScaler(d3.mean([d.accumulate_start, d.accumulate_end])) - topPadding })`)
            .append("text")
            .attr("font-size", function () {
                return 8 * scaleRatio + "px";
            })
            // .attr("font-family", "calibri")
            .text(d => d.list)
            .attr("id", (d) => d.list)
            .attr("text-anchor", "end")
            .attr("data-tippy-content", (d) => {
                return "<font color='#8E549E'>" + d.list
                    + "</font><br>num_gene_remapped: <font color='#8E549E'><b>"
                    + d.num_gene_remapped + "</b></font>";
            });

        // Add title for x and y
        //const xLabelY = height - 25;
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
            .attr("x", leftPadding - yAxisTitlePadding - 10)
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
            .join("circle")
            .attr("cx", d => xScaler(d.queryPos.x))
            .attr("cy", d => yScaler(d.subjectPos.x))
            .attr("r", 0.87 * scaleRatio)
            .attr("id", (d) => "multiplicon_" + d.multiplicon)
            .attr("fill", function (d) {
                if (d.Ks > -1) {
                    return colorScale(d.Ks);
                } else {
                    return "#898989"
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

        var legendGroup = svg.append("g")
            .attr("class", "legend")
            .attr("transform", "translate(" + 5 + "," + 10 + ")");

        legendGroup.append("rect")
            .attr("x", (width - 200) * scaleRatio)
            .attr("y", 15 * scaleRatio)
            .attr("width", 200 * scaleRatio)
            .attr("height", 15 * scaleRatio)
            .attr("fill", "url(#color-scale)")
            .attr("fill-opacity", 0.7);

        var axisScale = d3.scaleLinear()
            .domain([0, 5])
            .range([(width - 200) * scaleRatio, width * scaleRatio]);

        // Create the horizontal axis
        var axis = d3.axisBottom(axisScale)
            .ticks(5);

        var axisGroup = legendGroup.append("g")
            .attr("class", "axis")
            .attr("transform", "translate(" + 0 + "," + 30 + ")")
            .call(axis)
            .attr("text-anchor", "middle")
            .attr("dominant-baseline", "hanging")
            .attr("font-size", function () {
                return 11 * scaleRatio + "px";
            });
        // .attr("font-family", "calibri");

        legendGroup.append("text")
            .attr("x", (width - 103) * scaleRatio)
            .attr("y", 70 * scaleRatio)
            .append("tspan")
            // .attr("font-family", "times")
            .html("<tspan style='font-style: italic;'>K</tspan>")
            .style("font-size", function () {
                return 13 * scaleRatio + "px";
            })
            .append("tspan")
            .text("s")
            .style("font-size", function () {
                return 12 * scaleRatio + "px";
            })
            .attr("dx", function () {
                return 1 * scaleRatio + "px";
            })
            .attr("dy", function () {
                return 2 * scaleRatio + "px";
            });

        //tippy(".multipliscons path", {trigger: "mouseenter", followCursor: "initial",  delay: [tooltipDelay, null]});
        tippy(".xLabel text", { trigger: "mouseenter", followCursor: "initial", allowHTML: true, delay: [tooltipDelay, null] });
        tippy(".yLabel text", { trigger: "mouseenter", followCursor: "initial", allowHTML: true, delay: [tooltipDelay, null] });
        tippy(".multiplicons line", { trigger: "mouseenter", followCursor: "initial", allowHTML: true, delay: [tooltipDelay, null] });

        // Add PARs borders
        if (typeof parInfo !== "undefined") {

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
                        .attr("stroke-dasharray", "5, 5")
                        .lower();

                    svg.append("text")
                        .attr("class", "ParRectangle")
                        .attr("x", (minX + maxX) / 2)
                        .attr("y", minY - 12)
                        .attr("text-anchor", "middle")
                        .attr("alignment-baseline", "hanging")
                        .attr("font-size", function () {
                            return 8 * scaleRatio + "px";
                        })
                        .attr("font-style", "bold")
                        //// .attr("font-family", "times")
                        .style("fill", "#04AFEA")
                        .text(parIdArray[0].replace("PAR ", "P"));
                }
            }
        }

        // Add the clustering tree
        colTreeJson = parseTree(treeByCol);
        console.log("colTreeJson", colTreeJson);

        var treeColJsonCopy = JSON.parse(JSON.stringify(colTreeJson));

        /* dendrogram(
            "#dendrogramTreeView",
            treeColJsonCopy,
            {
                hideLabels: false,
                h: 0.4
            }
        ); */
        // buildTree("#dendrogramTreeView", colTreeJson, 300, 300, 'right');
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

        querySpecies = querySpecies.replace(" ", "_");
        subjectSpecies = subjectSpecies.replace(" ", "_");
        downloadSVG("cluster_download",
            plotId,
            querySpecies + "_vs_" + subjectSpecies + ".cluster.svg");

        // Convert the SVG to PNG
        /* const svgXml = new XMLSerializer().serializeToString(svg.node());
        const img = new Image();
        img.src = 'data:image/svg+xml;base64,' + btoa(svgXml);

        img.onload = function () {
            var canvas = document.createElement("canvas");
            var scale = 2;
            canvas.style.width = width + 'px';
            canvas.style.height = height + 'px';
            canvas.width = width;
            canvas.height = height;

            const ctx = canvas.getContext('2d');
            ctx.drawImage(img, 0, 0);

            const pngDataUrl = canvas.toDataURL('image/png');

            const previousPngImg = document.querySelector("#dotView_png_" + plotId + " img");
            if (previousPngImg) {
                previousPngImg.remove();
            }

            const pngImg = new Image();
            pngImg.src = pngDataUrl;
            document.querySelector("#dotView_png_" + plotId).appendChild(pngImg);
        }; */
    }

    Shiny.addCustomMessageHandler("Cluster_Zoom_In_Plotting_V7", ClusterZoomInPlottingV7);
    function ClusterZoomInPlottingV7(InputData) {
        var plotId = InputData.plot_id;
        var parId = InputData.par_id;
        var segmentedChrInfo = convertShinyData(InputData.segmented_chr);
        var segmentedAnchorpointsInfo = convertShinyData(InputData.segmented_anchorpoints);
        var querySpecies = InputData.query_sp;
        var subjectSpecies = InputData.subject_sp;
        var plotSize = InputData.size;

        // console.log("parInfo", parInfo);

        var querySpeciesTmp = querySpecies.replace(" ", "_");
        var queryChrInfo = segmentedChrInfo
            .filter(item => item.genome === querySpeciesTmp);

        var subjectSpeciesTmp = subjectSpecies.replace(" ", "_");
        var subjectChrInfo = segmentedChrInfo
            .filter(item => item.genome === subjectSpeciesTmp);

        const scaleRatio = plotSize / 400;
        // define plot dimension
        let topPadding = 100;
        const longestXLabelLength = d3.max(queryChrInfo, d => d.list.toString().length);
        const xAxisTitlePadding = longestXLabelLength * 6;
        let bottomPadding = 80 + xAxisTitlePadding;
        const longestYLabelLength = d3.max(subjectChrInfo, d => d.list.toString().length);
        const yAxisTitlePadding = longestYLabelLength * 6;
        let leftPadding = 80 + yAxisTitlePadding;
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

        var xScaler = d3.scaleLinear()
            .domain([queryChrInfo[0].accumulate_start, queryChrInfo[queryChrInfo.length - 1].accumulate_end])
            .range([leftPadding, width - rightPadding])

        var yScaler = d3.scaleLinear()
            .domain([subjectChrInfo[0].accumulate_start, subjectChrInfo[subjectChrInfo.length - 1].accumulate_end])
            .range([height - bottomPadding, topPadding])

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

        const xAxis = d3.axisBottom(xScaler)
            .tickValues(queryChrInfo.map(e => e.accumulate_end).slice(0, -1));
        const yAxis = d3.axisLeft(yScaler)
            .tickValues(subjectChrInfo.map(e => e.accumulate_end).slice(0, -1));

        d3.select("#" + plotId)
            .select("svg").remove();
        const svg = d3.select("#" + plotId)
            .append("svg")
            .attr("width", width)
            .attr("height", height);

        svg.append("g")
            .attr("class", "axis axis--x")
            .attr("transform", function () {
                return `translate(0, ${ height - bottomPadding })`;
            })
            .call(xAxis)
            .attr("stroke-width", 0.46)
            .call(g => g.selectAll(".tick text").remove())
            .call(g => g.selectAll(".tick line").clone()
                .attr("y2", function () {
                    return topPadding + bottomPadding - height;
                })
                .attr("stroke-dasharray", "4 1")
                .attr("stroke-width", 0.46)
                .attr("stroke-opacity", 0.5)
                .attr("stroke", "blue")
            );

        svg.append("g")
            .attr("class", "axis axis--y")
            .attr("transform", `translate(${ leftPadding }, 0)`)
            .call(yAxis)
            .attr("stroke-width", 0.46)
            .call(g => g.selectAll(".tick text").remove())
            .call(g => g.selectAll(".tick line").clone()
                .attr("x2", function () {
                    return width - leftPadding - rightPadding;
                })
                .attr("stroke-dasharray", "4 1")
                .attr("stroke-opacity", 0.5)
                .attr("stroke", "blue")
                .attr("stroke-width", 0.46)
            );

        svg.append("g")
            .append("line")
            .attr("transform", `translate(${ leftPadding }, ${ topPadding })`)
            .attr("x2", function () {
                return width - leftPadding - rightPadding;
            })
            .attr("stroke", "black")
            .attr("stroke-width", 0.46)
            .attr("stroke-opacity", 0.5);

        svg.append("g")
            .append("line")
            .attr("transform", function () {
                return `translate(${ width - rightPadding }, ${ topPadding })`;
            })
            .attr("y2", function () {
                return height - topPadding - bottomPadding
            })
            .attr("stroke", "black")
            .attr("stroke-width", 0.46)
            .attr("stroke-opacity", 0.5);

        svg.append("g")
            .attr("class", "xLabel")
            .selectAll("text")
            .data(queryChrInfo)
            .join("text")
            .attr("x", d => {
                return xScaler(d3.mean([d.accumulate_start, d.accumulate_end]));
            })
            .attr("y", function () {
                return height - bottomPadding + 15;
            })
            .attr("font-size", function () {
                return 10 * scaleRatio + "px";
            })
            .text(d => d.list)
            .attr("id", function (d) {
                var chrName = d.list.replace(":", "_");
                chrName = chrName.replace("-", "_");
                return "xLabel_" + chrName;
            })
            .attr("text-anchor", "left")
            .attr("data-tippy-content", (d) => {
                return "<font color='#68AC57'>" + d.list
                    + "</font><br>num_gene_remapped: <font color='#68AC57'><b>"
                    + d.num_gene_remapped + "</b></font>";
            })
            .attr("transform", (d) => {
                return "rotate(90 " + xScaler(d3.mean([d.accumulate_start, d.accumulate_end])) + ","
                    + (height - bottomPadding + 15) + ")";
            });

        svg.append("g")
            .attr("class", "yLabel")
            .attr("transform", `translate(${ leftPadding }, ${ topPadding })`)
            .selectAll("g")
            .data(subjectChrInfo)
            .join("g")
            .attr("transform", d => `translate(-15 ${ yScaler(d3.mean([d.accumulate_start, d.accumulate_end])) - topPadding })`)
            .append("text")
            .attr("font-size", function () {
                return 10 * scaleRatio + "px";
            })
            // .attr("font-family", "calibri")
            .text(d => d.list)
            .attr("id", (d) => d.list)
            .attr("text-anchor", "end")
            .attr("data-tippy-content", (d) => {
                return "<font color='#8E549E'>" + d.list
                    + "</font><br>num_gene_remapped: <font color='#8E549E'><b>"
                    + d.num_gene_remapped + "</b></font>";
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
            .attr("x", leftPadding - yAxisTitlePadding - 10)
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
            .join("circle")
            .attr("cx", d => xScaler(d.queryPos.x))
            .attr("cy", d => yScaler(d.subjectPos.x))
            .attr("r", 2.37 * scaleRatio)
            .attr("id", (d) => "multiplicon_" + d.multiplicon)
            .attr("fill", function (d) {
                if (d.Ks > -1) {
                    return colorScale(d.Ks);
                } else {
                    return "#898989"
                }
            });

        svg.append("text")
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
            //// .attr("font-family", "times")
            .style("fill", "#04AFEA")
            .text(parId);

        //tippy(".multipliscons path", {trigger: "mouseenter", followCursor: "initial",  delay: [tooltipDelay, null]});
        tippy(".xLabel text", { trigger: "mouseenter", followCursor: "initial", allowHTML: true, delay: [tooltipDelay, null] });
        tippy(".yLabel text", { trigger: "mouseenter", followCursor: "initial", allowHTML: true, delay: [tooltipDelay, null] });
        tippy(".multiplicons line", { trigger: "mouseenter", followCursor: "initial", allowHTML: true, delay: [tooltipDelay, null] });

        querySpecies = querySpecies.replace(" ", "_");
        subjectSpecies = subjectSpecies.replace(" ", "_");
        downloadSVG("PAR_download",
            plotId,
            querySpecies + "_vs_" + subjectSpecies + "." + parId.replace(" ", "_") + ".cluster.svg");

        // Convert the SVG to PNG
        /* const svgXml = new XMLSerializer().serializeToString(svg.node());
        const img = new Image();
        img.src = 'data:image/svg+xml;base64,' + btoa(svgXml);

        img.onload = function () {
            var canvas = document.createElement("canvas");
            var scale = 2;
            canvas.style.width = width + 'px';
            canvas.style.height = height + 'px';
            canvas.width = width;
            canvas.height = height;

            const ctx = canvas.getContext('2d');
            ctx.drawImage(img, 0, 0);

            const pngDataUrl = canvas.toDataURL('image/png');

            const previousPngImg = document.querySelector("#dotView_png_" + plotId + " img");
            if (previousPngImg) {
                previousPngImg.remove();
            }

            const pngImg = new Image();
            pngImg.src = pngDataUrl;
            document.querySelector("#dotView_png_" + plotId).appendChild(pngImg);
        }; */
    }
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
    // console.log("renew_ratio", ratio)
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

function calc_micro_accumulate_len(inputChrInfo, innerPadding_xScale, innerPadding) {
    inputChrInfo.forEach((e) => {
        e.len = e.max - e.min;
    });
    let acc_len = 0;
    let total_chr_len = d3.sum(inputChrInfo.map(e => e.len));
    let ratio = innerPadding_xScale.invert(innerPadding);
    inputChrInfo.forEach((e, i) => {
        e.idx = i;
        e.accumulate_start = acc_len + 1;
        e.accumulate_end = e.accumulate_start + e.len - 1;
        acc_len = e.accumulate_end + 200000;
    });
    return inputChrInfo;
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

function downloadSVGs(downloadButtonID, svgDivID, svgOutFile) {
    // Add event listener to the button
    // since some buttons are generated dynamically
    // need to be called each time the button is generated
    d3.select("#" + downloadButtonID)
        .on("click", function (e) {
            e.preventDefault();
            const charts = d3.select("#" + svgDivID)
                .selectAll("svg")
                .nodes();

            if (charts.length === 0) {
                console.log("No SVG found.");
                return;
            }

            let currentIndex = 0;

            function downloadNextSVG() {
                if (currentIndex >= charts.length) {
                    // All SVGs have been downloaded
                    return;
                }
                const chart = charts[currentIndex];
                const svgData = new XMLSerializer().serializeToString(chart);
                const blob = new Blob([svgData], { type: "image/svg+xml;charset=utf-8" });
                const url = URL.createObjectURL(blob);

                // const svgFileName = svgOutFile + "_" + (currentIndex + 1) + ".svg";
                svgOutFile = svgOutFile.replace(" ", "_");
                const svgFileName = svgOutFile + "." + getModifiedFileName(chart) + ".svg";

                const tempLink = document.createElement("a");
                tempLink.href = url;
                tempLink.download = svgFileName;
                tempLink.style.display = "none";
                document.body.appendChild(tempLink);
                tempLink.click();
                document.body.removeChild(tempLink);

                currentIndex++;
                setTimeout(downloadNextSVG, 100);
            }

            function getModifiedFileName(chart) {
                const textElement = d3.select(chart).select(".multipliconId");
                const originalText = textElement.text();
                const modifiedText = originalText.replace("Multiplicon: ", "Multiplicon_");
                return modifiedText;
            }

            downloadNextSVG();
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

function buildTreeV3(selector, ksTreeJson, w, h, ori) {
    var script = document.createElement('script');
    script.src = 'https://d3js.org/d3.v3.min.js';
    document.head.appendChild(script);
    script.onload = function () {
        var vis = d3.select(selector)
            .append("svg")
            .attr("width", w)
            .attr("height", h);

        if (ori === "right") {
            var tree = d3.layout.cluster()
                .size([h, w])
                .separation(function (a, b) {
                    return 1;
                })
                .sort(function (node) {
                    return node.children ? node.children.length : -1;
                });

            var diagonal = rightAngleDiagonal();
            var ksTreeNodes = tree(ksTreeJson);
            var yscale = scaleBranchLengths(ksTreeNodes, w).range([0, w]);
        } else {
            var tree = d3.layout.cluster()
                .size([h, w / 2])
                .separation(function (a, b) {
                    return 1;
                })
                .sort(function (node) {
                    return node.children ? node.children.length : -1;
                });

            var diagonal = rightAngleDiagonal();
            var ksTreeNodes = tree(ksTreeJson);
            var yscale = scaleBranchLengths(ksTreeNodes, w).range([0, w]);
        }

        var ksNode = vis.selectAll("g.ks-node")
            .data(ksTreeNodes)
            .enter().append("svg:g")
            .attr("class", function (n) {
                if (n.children) {
                    if (n.depth == 0) {
                        return "ks-root-node";
                    } else {
                        return "ks-inner-node";
                    }
                } else {
                    return "ks-leaf-node";
                }
            })
            .attr("transform", function (d) { return "translate(" + d.y + "," + d.x + ")"; });

        vis.selectAll('g.ks-root-node')
            .append('line')
            .attr('stroke', '#aaa')
            .attr('stroke-width', 2.45)
            .attr('x1', 0)
            .attr('y1', 0)
            .attr('x2', -10)
            .attr('y2', 0)

        if (ori === 'right') {
            vis.selectAll('g.ks-leaf-node')
                .append("svg:text")
                .attr("class", "my-text")
                .attr("dx", function () {
                    if (ori === "right") {
                        return 8;
                    } else {
                        return -8;
                    }
                })
                .attr("dy", 3)
                .attr("text-anchor", function () {
                    if (ori === "right") {
                        return "start";
                    } else {
                        return "end";
                    }
                })
                .attr("font-size", "12px")
                .attr('fill', 'black')
                .text(function (d) {
                    var name = d.name.replace(/_/g, ' ');
                    return name;
                })
                .attr('font-style', function (d) {
                    if (d.name.match(/\_/)) {
                        return 'italic';
                    } else {
                        return 'normal';
                    }
                });
        }

        var link = vis.selectAll("path.ks-link")
            .data(tree.links(ksTreeNodes))
            .enter().append("svg:path")
            .attr("class", "ks-link")
            .attr("d", diagonal)
            .attr("fill", "none")
            .attr("stroke", "#aaa")
            .attr("stroke-width", "2.45px")

        // Move the created paths to the bottom of the SVG
        vis.selectAll("path.ks-link").each(function () {
            var firstChild = this.parentNode.firstChild;
            if (firstChild) {
                this.parentNode.insertBefore(this, firstChild);
            }
        });
    }
}
