console.log("d3 version:", d3.version);
var numFormatter = d3.format(".2f");

Shiny.addCustomMessageHandler("Figtree_plot", plotFigtree)
function plotFigtree(InputData) {
    var figtree = InputData.tree;
    var wgdTable = InputData.wgdtable;
    var height = InputData.height;
    var width = InputData.width;
    const treeJson = pasreFigtreeUpdated(figtree);
    if (typeof wgdTable !== 'undefined') {
        var wgdTableInfo = convertShinyData(wgdTable);
    }
    // addScript("https://d3js.org/d3.v3.min.js");
    phylogramBuild("#timetree_plot", treeJson, wgdTableInfo, height, width);
    // downloadSVG("timetree_download", "timetree_plot");
    downloadSVG("Treeplot_download", "timetree_plot", "TimeTree.plot.svg")
}

Shiny.addCustomMessageHandler("timeTreeOrgPlot", timeTreeOrgPlot);
function timeTreeOrgPlot(InputData) {
    var timetreeOrg = InputData.timeTreeOrgTree;
    var height = InputData.height;
    var width = InputData.width;

    const treeLine = timetreeOrg.find(line => line.includes("\tTREE * UNTITLED ="));

    const timeTreeOrgString = treeLine.replace(/^\s*TREE \* UNTITLED = \[&R\]\s*/, "");

    const numbers = timeTreeOrgString.match(/\d+(\.\d+)?/g);

    if (numbers) {
        const dividedNumbers = numbers.map(number => {
            const parsedNumber = parseFloat(number);
            return isNaN(parsedNumber) ? number : (parsedNumber / 100).toFixed(2);
        });

        let index = 0;
        const modifiedString = timeTreeOrgString.replace(/\d+(\.\d+)?/g, () => dividedNumbers[index++]);

        var timeTreeOrgJson = parseKsTree(modifiedString);
        timeTreeOrgBuilding("#timetreeOrg_plot", timeTreeOrgJson, height, width);
    } else {
        console.log("No numbers found in the input string.");
    }
}

function timeTreeOrgBuilding(selector, timeTreeOrgJson, height, width) {

    var script = document.createElement('script');
    script.src = 'https://d3js.org/d3.v3.min.js';
    document.head.appendChild(script);
    script.onload = function () {
        var w = width;
        var h = height;
        d3.select(selector).select("svg").remove();

        var vis = d3.select(selector).append("svg:svg")
            .attr("width", w + 600)
            .attr("height", h + 100)
            .append("svg:g")
            .attr("transform", "translate(120, 20)");

        var ori = 'right';

        var tree = d3.layout.cluster()
            .size([h, w])
            .separation(function (a, b) {
                return 1;
            })
            .sort(function (node) {
                return node.children ? node.children.length : -1;
            })
            .children(function (node) {
                return node.branchset
            });

        var diagonal = rightAngleDiagonal();
        var nodes = tree(timeTreeOrgJson);
        var yscale = scaleBranchLengths(nodes, w).range([w, 0]);

        vis.selectAll('.rule-line')
            .data(yscale.ticks(11))
            .enter().append('svg:line')
            .attr('class', 'rule-line')
            .attr('y1', 0)
            .attr('y2', h)
            .attr('x1', yscale)
            .attr('x2', yscale)
            .attr("stroke-dasharray", "4 1")
            .attr("stroke-width", 0.66)
            .attr("stroke-opacity", 0.2)
            .attr("stroke", "blue");

        vis.selectAll("text.rule")
            .data(yscale.ticks(11))
            .enter().append("svg:text")
            .attr("class", "rule")
            .attr("x", yscale)
            .attr("y", h + 15)
            .attr("dy", -3)
            .attr("text-anchor", "middle")
            .attr("font-size", "10px")
            .attr('fill', 'blue')
            .attr('opacity', 0.3)
            .text(function (d) { return (Math.round(d * 100) / 100 * 100).toFixed(0); });

        var legend = vis.append('g')
            .attr('class', 'legend')
            .append('text')
            .attr('x', function () {
                return w + 8;
            })
            .attr('y', h + 12)
            .attr('text-anchor', 'start')
            .attr('font-size', '10px')
            .attr('fill', 'blue')
            .attr('opacity', 0.3)
            .text('million years ago');

        var node = vis.selectAll("g.node")
            .data(nodes)
            .enter().append("svg:g")
            .attr("class", function (n) {
                if (n.children) {
                    if (n.depth == 0) {
                        return "root node"
                    } else {
                        return "inner node"
                    }
                } else {
                    return "leaf node"
                }
            })
            .attr("transform", function (d) { return "translate(" + d.y + "," + d.x + ")"; });

        vis.selectAll('g.leaf.node')
            .append("svg:text")
            .attr("class", "my-text")
            .attr("dx", 8)
            .attr("dy", 3)
            .attr("text-anchor", "start")
            .attr("font-size", "14px")
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
            })
            .attr("data-tippy-content", (d) => {
                return "<font color='#00DB00'>" + d.name +
                    "</font>: <font color='orange'>" + numFormatter(d.length) + " Mya</font>";
            })
            .on("mouseover", function () {
                ribbonEnterTime = new Date().getTime();
                d3.select(this)
                    .transition()
                    .delay(100)
                    .duration(50)
                    .attr("fill", "#E1E100")
            })
            .on("mouseout", function () {
                ribbonOutTime = new Date().getTime();
                if (ribbonOutTime - ribbonEnterTime <= 1000) {
                    d3.select(this)
                        .transition()
                        .duration(50)
                        .attr("fill", "black")
                }
            })

        tippy(".my-text rect", { trigger: "mouseenter", followCursor: "initial", allowHTML: true, delay: [200, null] });

        const link = vis.selectAll("path.link")
            .data(tree.links(nodes))
            .enter().append("svg:path")
            .attr("class", "link")
            .attr("d", diagonal)
            .attr("fill", "none")
            .attr("stroke", "#aaa")
            .attr("stroke-width", "2.45px")
            // .attr("stroke-dasharray", d => (d.source.y === 0) ? "6 8" : "none")
            .on("mouseover", function () {
                ribbonEnterTime = new Date().getTime();
                d3.select(this)
                    .transition()
                    .delay(100)
                    .duration(50)
                    .attr("stroke", "#E1E100")
                    .attr("stroke-width", "4px")
            })
            .on("mouseout", function () {
                ribbonOutTime = new Date().getTime();
                if (ribbonOutTime - ribbonEnterTime <= 1000) {
                    d3.select(this)
                        .transition()
                        .duration(50)
                        .attr("stroke", "#aaa")
                        .attr("stroke-width", "2.45px")
                }
            })

        vis.selectAll("path.link").each(function () {
            var firstChild = this.parentNode.firstChild;
            if (firstChild) {
                this.parentNode.insertBefore(this, firstChild);
            }
        });

        var maxLength = getMaxNodeLength(nodes);
        drawGeologicTimeBar(maxLength, vis, yscale, h, ori);
    }
}

Shiny.addCustomMessageHandler("jointTreePlot", jointTreePlot)
function jointTreePlot(InputData) {
    var plotDiv = InputData.plot_id;
    var downloadDiv = InputData.download_id;
    var ksTree = InputData.ksTree;
    var timeTree = InputData.timeTree;
    var ultrametricTree = InputData.ultrametricTree;
    var wgdTable = InputData.wgdtable;
    var ksPeak = InputData.ksPeak;
    var height = InputData.height;
    var width = InputData.width;
    // var longestLen = InputData.longLetterLen;
    // console.log("height", height);

    var timeScale = InputData.timeScale;
    console.log("timeScale", timeScale);

    if (typeof ksTree !== 'undefined') {
        var treeTopolog = ksTree.replace(/[0-9:. ]/g, '');
        var treeTopologJson = parseTreeTopology(treeTopolog);
        var ksTreeJson = parseKsTree(ksTree);
    }
    if (typeof timeTree !== 'undefined') {
        if (timeScale === "100") {
            timeTree = timeTree.replace(/(\d+(\.\d+)?)/g, function (match, p1) {
                var numericValue = parseFloat(p1);
                if (!isNaN(numericValue)) {
                    var scaledValue = (numericValue / 100).toFixed(2);
                    return scaledValue;
                } else {
                    return match;
                }
            });
        }

        var timeTreeJson = parseTimeTree(timeTree);
    }
    if (typeof ksPeak !== 'undefined') {
        var ksPeakInfo = convertShinyData(ksPeak);
    }
    if (typeof wgdTable !== 'undefined') {
        var wgdTableInfo = convertShinyData(wgdTable);
        console.log("wgdTableInfo", wgdTableInfo);
        if (timeScale === "100") {
            wgdTableInfo = wgdTableInfo.map(function (item) {
                return {
                    species: item.species,
                    wgds: item.wgds.split('-').map(function (range) {
                        var numericValue = parseFloat(range);
                        return !isNaN(numericValue) ? (numericValue / 100).toFixed(4) : range;
                    }).join('-'),
                    color: item.color
                };
            });
        }
        console.log("renewed wgdTableInfo", wgdTableInfo);
    }
    if (typeof ultrametricTree !== 'undefined') {
        var ultrametricTreeJson = parseTreeTopology(ultrametricTree);
    }
    jointTreeBuilding("#" + plotDiv, ksTreeJson, ksPeakInfo, treeTopologJson, timeTreeJson, wgdTableInfo, ultrametricTreeJson, height, width, plotDiv, downloadDiv);
}

Shiny.addCustomMessageHandler("speciesTreePlot", speciesTreePlot)
function speciesTreePlot(InputData) {
    var speciesTree = InputData.speciesTree;

    // var hasFloatLargerThan20 = /(\d+\.\d+)/.test(speciesTree) && parseFloat(RegExp.$1) > 20;

    /* if (hasFloatLargerThan20) {
        speciesTree = speciesTree.replace(/(\d+\.\d+)/g, function (match, p1) {
            var numericValue = parseFloat(p1);
            if (!isNaN(numericValue)) {
                var scaledValue = (numericValue / 100).toFixed(2);
                return scaledValue;
            } else {
                return match;
            }
        });
    } */

    var wgdNodes = InputData.wgdNodes;
    var height = InputData.height;
    var width = InputData.width;

    var plotDiv = InputData.tree_plot_div;

    // console.log(speciesTree);

    if (typeof speciesTree !== 'undefined') {
        var speciesTreeJson;
        try {
            var speciesTree = speciesTree.replace(/[0-9:. ]/g, '');
            var speciesTreeJson = parseTreeTopology(speciesTree);
            // speciesTreeJson = parseKsTree(speciesTree);

            if (Object.keys(speciesTreeJson).length === 0 && speciesTreeJson.constructor === Object) {
                Swal.fire({
                    icon: 'error',
                    title: 'Oops...',
                    html: 'An error occurred while parsing the species tree. Please check the format and ensure the tree in <span style="color: #A6A600;">Newick</span> format.',
                });
            } else {
                if (typeof wgdNodes !== 'undefined') {
                    var wgdNodesInfo = convertShinyData(wgdNodes);
                }
                speciesTreeBuilding("#" + plotDiv, speciesTreeJson, wgdNodesInfo, height, width);
            }

        } catch (error) {
            Swal.fire({
                icon: 'error',
                title: 'Oops...',
                html: 'An error occurred while parsing the species tree. Please check the format and ensure the tree in <span style="color: #A6A600;">Newick</span> format.',
            });
        }
    }
}

Shiny.addCustomMessageHandler("speciesTreeUpdatedPlot", speciesTreeUpdatedPlot)
function speciesTreeUpdatedPlot(InputData) {
    var speciesTree = InputData.speciesTree;

    var hasFloatLargerThan20 = /(\d+\.\d+)/.test(speciesTree) && parseFloat(RegExp.$1) > 20;

    if (hasFloatLargerThan20) {
        speciesTree = speciesTree.replace(/(\d+\.\d+)/g, function (match, p1) {
            var numericValue = parseFloat(p1);
            if (!isNaN(numericValue)) {
                var scaledValue = (numericValue / 100).toFixed(2);
                return scaledValue;
            } else {
                return match;
            }
        });
    }

    var wgdInfo = InputData.wgdNote;
    var height = InputData.height;
    var width = InputData.width;

    var plotDiv = InputData.tree_plot_div;

    if (typeof speciesTree !== 'undefined') {
        var speciesTreeJson;
        try {
            speciesTreeJson = parseKsTree(speciesTree);

            if (Object.keys(speciesTreeJson).length === 0 && speciesTreeJson.constructor === Object) {
                Swal.fire({
                    icon: 'error',
                    title: 'Oops...',
                    html: 'An error occurred while parsing the species tree. Please check the format and ensure the tree in <span style="color: #A6A600;">Newick</span> format.',
                });
            } else {
                if (typeof wgdInfo !== 'undefined') {
                    var wgdNodesInfo = convertShinyData(wgdInfo);
                }
                speciesTreeReconBuilding("#" + plotDiv, speciesTreeJson, wgdNodesInfo, height, width);
            }

        } catch (error) {
            Swal.fire({
                icon: 'error',
                title: 'Oops...',
                html: 'An error occurred while parsing the species tree. Please check the format and ensure the tree in <span style="color: #A6A600;">Newick</span> format.',
            });
        }
    }
}

function speciesTreeReconBuilding(selector, speciesTreeJson, wgdNodesInfo, height, width) {
    var svgFile;
    var script = document.createElement('script');
    script.src = 'https://d3js.org/d3.v3.min.js';
    document.head.appendChild(script);
    script.onload = function () {
        var w = width;
        var h = height;
        d3.select(selector).select("svg").remove();
        var vis = d3.select(selector).append("svg:svg")
            .attr("width", w + 600)
            .attr("height", h + 100)
            .append("svg:g")
            .attr("transform", "translate(120, 20)");

        buildSpeciesTreeRecon(selector, vis, speciesTreeJson, wgdNodesInfo, w, h, 'right');
    }
}

function buildSpeciesTreeRecon(selector, vis, speciesTreeJson, wgdNodesInfo, w, h, ori) {
    console.log("wgdNodesInfo", wgdNodesInfo);
    var tree = d3.layout.cluster()
        .size([h, w])
        .separation(function (a, b) {
            return 1;
        })
        .sort(function (node) {
            return node.children ? node.children.length : -1;
        })
        .children(function (node) {
            return node.branchset
        });

    var diagonal = rightAngleDiagonal();
    var nodes = tree(speciesTreeJson);
    var yscale = scaleBranchLengths(nodes, w).range([w, 0]);

    var node = vis.selectAll("g.node")
        .data(nodes)
        .enter().append("svg:g")
        .attr("class", function (n) {
            if (n.children) {
                if (n.depth == 0) {
                    return "root node"
                } else {
                    return "inner node"
                }
            } else {
                return "leaf node"
            }
        })
        .attr("transform", function (d) { return "translate(" + d.y + "," + d.x + ")"; })

    vis.selectAll('g.root.node')
        .append('line')
        .attr('stroke', '#aaa')
        .attr('stroke-width', 2.45)
        .attr('x1', 0)
        .attr('y1', 0)
        .attr('x2', -10)
        .attr('y2', 0)

    d3.select('.leaf-pop-up-menu').remove();
    var leafPopUpMenu = d3.select(selector).append('div')
        .classed('leaf-pop-up-menu', true)
        .style('position', 'absolute')
        .style('top', 0)
        .style('left', 0)
        .style('visibility', 'hidden')
        .style('background-color', 'white')
        .style('border', '1px solid black')
        .style('padding', '5px');

    vis.selectAll('g.leaf.node')
        .append("svg:text")
        .attr("class", "my-text")
        .attr("dx", 8)
        .attr("dy", 3)
        .attr("text-anchor", "start")
        .attr("font-size", "14px")
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
        })
        .attr("data-tippy-content", (d) => {
            return "<font color='#00DB00'>" + d.name +
                "</font>: <font color='orange'>" + numFormatter(d.length) + " Mya</font>";
        })
        .on("mouseover", function () {
            ribbonEnterTime = new Date().getTime();
            d3.select(this)
                .transition()
                .delay(100)
                .duration(50)
                .attr("fill", "#E1E100")
        })
        .on("mouseout", function () {
            ribbonOutTime = new Date().getTime();
            if (ribbonOutTime - ribbonEnterTime <= 1000) {
                d3.select(this)
                    .transition()
                    .duration(50)
                    .attr("fill", "black")
            }
        })
        .on('click', function (d) {
            if (leafPopUpMenu.style('visibility') == 'visible') {
                leafPopUpMenu.style('visibility', 'hidden');
            } else {
                var name = d.name.replace(/_/g, ' ');
                if (d.name.match(/\_/)) {
                    leafPopUpMenu.html("<p><font color='#00DB00'><i>" + name + "</i></font>: <font color='orange'>" +
                        numFormatter(d.length * 100) + " Mya</font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" +
                        "<button id='close-btn' onclick='closePopUp()'>&times;</button></p>" +
                        "<p>Choose a color:</p>" +
                        "<div id='color-options'></div>" +
                        "<p></p>" +
                        "<p>Choose a symbol:" +
                        "<div id='symbol-options'></div>");
                } else {
                    leafPopUpMenu.html("<p><font color='#00DB00'>" + name + "</font>: <font color='orange'>" +
                        numFormatter(d.length * 100) + " Mya</font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" +
                        "<button id='close-btn' onclick='closePopUp()'>&times;</button></p>" +
                        "<p>Choose a color:" +
                        "<div id='color-options'></div>" +
                        "<p></p>" +
                        "<p>Choose a symbol:" +
                        "<div id='symbol-options'></div>");
                }
                d3.select('#close-btn').on('click', closePopUp);
                function closePopUp() {
                    leafPopUpMenu.style('visibility', 'hidden');
                };

                var colors = ['#FF0000', '#00FF00', '#0000FF', '#FFA500', '#800080', '#FFC0CB', 'black'];
                var textElement = d3.select(this.parentNode).select('.my-text').node();
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
                    .on('click', function (d) {
                        d3.select(textElement).style('fill', d);
                    });

                var symbols = [
                    { name: 'Circle', type: 'circle' },
                    { name: 'Cross', type: 'cross' },
                    { name: 'Diamond', type: 'diamond' },
                    { name: 'Square', type: 'square' },
                    { name: 'Triangle Up', type: 'triangle-up' }
                ];

                var clickedLeafNode = this;
                var symbolOptions = d3.select('#symbol-options')
                    .selectAll('div')
                    .data(symbols)
                    .enter()
                    .append('div')
                    .style('cursor', 'pointer')
                    .style('width', '30px')
                    .style('height', '30px')
                    .style('margin-right', '3px')
                    .style('float', 'left')
                    .append('svg')
                    .attr('width', '60')
                    .attr('height', '60')
                    .append('path')
                    .attr('transform', 'translate(15, 15)')
                    .attr('d', function (d) {
                        if (d.type === 'circle') {
                            return d3.svg.symbol().type('circle')();
                        } else if (d.type === 'cross') {
                            return d3.svg.symbol().type('cross')();
                        } else if (d.type === 'diamond') {
                            return d3.svg.symbol().type('diamond')();
                        } else if (d.type === 'square') {
                            return d3.svg.symbol().type('square')();
                        } else if (d.type === 'triangle-up') {
                            return d3.svg.symbol().type('triangle-up')();
                        }
                    })
                    .attr('stroke', '#707038')
                    .attr('fill', '#707038')
                    .on('click', function (d) {
                        var leafNode = clickedLeafNode.parentNode;
                        var symbol = d3.svg.symbol().type(d.type)
                        var styleAttr = d3.select(clickedLeafNode).attr('style');
                        var match = styleAttr.match(/fill:\s*(.*?);/);
                        var textColor = match[1];
                        d3.select(leafNode)
                            .append('path')
                            .attr('d', symbol)
                            .attr('stroke', textColor)
                            .attr('fill', textColor)
                            .attr('stroke-width', '1px');

                        leafPopUpMenu.style('visibility', 'hidden');
                    });

                const transformAttributeValue = d3.select(this.parentNode).attr("transform");
                const match = transformAttributeValue.match(/translate\(([\d.-]+),([\d.-]+)\)/);
                const xx = parseFloat(match[1]);
                const yy = parseFloat(match[2]);
                leafPopUpMenu.style('left', (xx + 200) + 'px')
                    .style('top', (yy - 5) + 'px')
                    .style('visibility', 'visible');
            }
        });
    tippy(".my-text rect", { trigger: "mouseenter", followCursor: "initial", allowHTML: true, delay: [200, null] });

    d3.select('.path-pop-up-menu').remove();
    var popUpMenu = d3.select(selector).append('div')
        .classed('path-pop-up-menu', true)
        .style('position', 'absolute')
        .style('top', 0)
        .style('left', 0)
        .style('visibility', 'hidden')
        .style('background-color', 'white')
        .style('border', '1px solid black')
        .style('padding', '5px');

    // console.log("node", nodes);
    var wgdInput = new Set();
    var link = vis.selectAll("path.link")
        .data(tree.links(nodes))
        .enter().append("svg:path")
        .attr("class", "link")
        .attr("d", diagonal)
        .attr("fill", "none")
        .attr("stroke", "#aaa")
        .attr("stroke-width", "2.45px")
        .on("mouseover", function () {
            ribbonEnterTime = new Date().getTime();
            d3.select(this)
                .transition()
                .delay(100)
                .duration(50)
                .attr("stroke", "#E1E100")
                .attr("stroke-width", "4px")
        })
        .on("mouseout", function () {
            ribbonOutTime = new Date().getTime();
            if (ribbonOutTime - ribbonEnterTime <= 1000) {
                d3.select(this)
                    .transition()
                    .duration(50)
                    .attr("stroke", "#aaa")
                    .attr("stroke-width", "2.45px")
            }
        });

    vis.selectAll("path.link").each(function () {
        var firstChild = this.parentNode.firstChild;
        if (firstChild) {
            this.parentNode.insertBefore(this, firstChild);
        }
    });

    function findCommonParentNode(treeNodes, species1, species2) {
        if (species1 === species2) {
            for (var i = 0; i < treeNodes.length; i++) {
                if (treeNodes[i].name === species1) {
                    return treeNodes[i];
                }
            }
        } else {
            for (var i = 0; i < treeNodes.length; i++) {
                var eachNode = treeNodes[i];
                if (eachNode.children) {
                    var commonParent = findCommonParentNode(eachNode.children, species1, species2);
                    if (commonParent) {
                        return commonParent;
                    }
                }
                if (eachNode.name === species1 || eachNode.name === species2) {
                    return eachNode;
                }
            }
        }
        return null;
    }

    for (var i = 0; i < wgdNodesInfo.length; i++) {
        var wgdInfoEach = wgdNodesInfo[i];
        var [species1, species2] = wgdInfoEach.comp.split(":");
        var parentNode = findCommonParentNode(nodes, species1, species2);

        var x, y;

        if (species1 == species2) {
            x = parentNode.x;
            y = (parentNode.y + parentNode.parent.y) / 2;
        } else {
            x = parentNode.parent.x;
            y = (parentNode.parent.y + parentNode.parent.parent.y) / 2;
        }

        vis.selectAll("wgds")
            .data([parentNode.parent])
            .enter()
            .append('rect')
            .attr('class', 'testWgd')
            .attr('x', y)
            .attr('y', x - 9)
            .attr('width', 18)
            .attr('height', 18)
            .style('fill', 'white')
            .style('stroke', '#F75000')
            .style('stroke-width', 2.5)
            .attr("data-tippy-content", wgdInfoEach.wgd);

        tippy(".testWgd rect", { trigger: "mouseenter", followCursor: "initial", allowHTML: true, delay: [200, null] });

        vis.append("text")
            .attr('class', 'testWgd-text')
            .attr("x", y + 9)
            .attr("y", x - 18)
            .text(wgdInfoEach.wgd)
            .attr("text-anchor", "middle")
            .attr("font-size", "12px")
            .attr("data-tippy-content", (d) => {
                return "text:" + wgdInfoEach.wgd;
            });


    }

    // var maxLength = getMaxNodeLength(nodes);
    // drawGeologicTimeBar(maxLength, vis, yscale, h, ori);

    downloadSVG("speciesWhaleTreeReconPlotDownload", "speciesWhaleTreeRecon_plot", "whale_TreeRecon.speciesTree.svg");
}

Shiny.addCustomMessageHandler("speciesTreeUpdatedPlotOLD", speciesTreeUpdatedPlotOLD)
function speciesTreeUpdatedPlotOLD(InputData) {
    var speciesTree = InputData.speciesTree;
    var wgdInfo = convertShinyData(InputData.wgdInfo);

    var treeSvg = d3.select("#speciesWhaleTreeRecon_plot")
        .select("svg")

    wgdInfo.forEach(function (entry) {
        var rectSelector = "[data-tippy-content='" + entry.wgdId + "']";
        var rectElement = treeSvg.select(rectSelector);
        var textSelector = "[data-tippy-content='text:" + entry.wgdId + "']";
        var textElement = treeSvg.select(textSelector);

        if (entry.K < -2) {
            rectElement.style("fill", "green");
            rectElement.style("stroke-width", "0");
            rectElement.style("opacity", "0.8");
            textElement.style("fill", "green");
            textElement.style("opacity", "0.7");
            textElement.style("font-weight", "bold");
        } else if (entry.K >= -2) {
            rectElement.style("fill", "white");
            rectElement.style("stroke-dasharray", "4 1");
            rectElement.style("stroke-width", "1.46");
            rectElement.style("stroke", "#6F6B0A");
            textElement.style("fill", "#6F6B0A");
        }
    });

    svgFile = "speciesTree.Plot.svg";
    downloadSVG("speciesTreePlotDownload", "speciesTree_plot", svgFile);
}

Shiny.addCustomMessageHandler("posteriorDistPlot", posteriorDistPlot)
function posteriorDistPlot(InputData) {
    var posteriorInfo = convertShinyData(InputData.posterior_dist_df);
    var w = InputData.width;
    var h = InputData.height;
    var plotId = InputData.posterior_plot_div;

    var wgdKeys = Object.keys(posteriorInfo[0]).filter(key => key.startsWith('wgd'));
    var numWgds = wgdKeys.length;
    var numRows = Math.ceil(numWgds / 4);

    var scriptV7 = document.createElement('script');
    scriptV7.src = 'https://d3js.org/d3.v7.min.js';
    document.head.appendChild(scriptV7);

    scriptV7.onload = function () {
        var margin = { top: 50, right: 50, bottom: 50, left: 50 },
            subplotMargin = { top: 10, right: 30, bottom: 30, left: 30 },
            subplotWidth = 200,
            subplotHeight = 200;

        d3.select("#" + plotId).select("svg").remove();
        var svg = d3.select('#' + plotId)
            .append('svg')
            .attr('width', w)
            .attr('height', h);

        var totalSubplotHeight = numRows * subplotHeight + (numRows - 1) * subplotMargin.bottom;

        var middleY = margin.top + totalSubplotHeight / 2;

        svg.append("text")
            .attr("x", margin.left - 35)
            .attr("y", middleY)
            .attr("text-anchor", "middle")
            .style("font-size", "14px")
            .attr("transform", function () {
                return `rotate(-90, ${ d3.select(this).attr("x") }, ${ d3.select(this).attr("y") })`;
            })
            .text("Density");

        var totalSubplotWidth = numWgds * subplotWidth + (numWgds - 1) * margin.right;

        var middleX = margin.left + totalSubplotWidth / 2;

        svg.append("text")
            .attr("x", middleX)
            .attr("y", h - margin.bottom + 35)
            .attr("text-anchor", "middle")
            .style("font-size", "14px")
            .text("Retention rates (q)");

        for (var i = 0; i < numWgds; i++) {
            var row = Math.floor(i / 4);
            var col = i % 4;

            var subplot = svg.append('g')
                .attr('transform', 'translate(' + (margin.left + col * (subplotWidth + subplotMargin.right)) + ',' + (margin.top + row * (subplotHeight + subplotMargin.bottom)) + ')');

            var x = d3.scaleLinear()
                .domain([0, 0.5])
                .range([0, subplotWidth]);

            var xAxis = d3.axisBottom(x).ticks(5);

            // Append x-axis to subplot
            subplot.append('g')
                .attr('transform', 'translate(0,' + subplotHeight + ')')
                .call(xAxis);

            var kde = kernelDensityEstimator(kernelEpanechnikov(0.05), x.ticks(100));

            var density = kde(posteriorInfo.map(entry => entry[wgdKeys[i]]));

            var y = d3.scaleLinear()
                .domain([0, 40])
                .range([subplotHeight, 0]);

            var yAxis = d3.axisLeft(y).ticks(4);

            subplot.append('g')
                .call(yAxis);

            subplot.append('path')
                .data([density])
                .attr('fill', 'steelblue')
                .attr('opacity', 0.7)
                .attr('stroke', '#000')
                .attr('stroke-width', 0.5)
                .attr('d', d3.area()
                    .x(function (d) { return x(d[0]); })
                    .y0(subplotHeight)
                    .y1(function (d) { return y(d[1]); }));

            subplot.append("text")
                .attr("x", subplotWidth / 2)
                .attr("y", -subplotMargin.top + 20)
                .attr("text-anchor", "middle")
                .style("font-size", "12px")
                .style("font-weight", "bold")
                .text(wgdKeys[i]);
        }
    }
    downloadSVG("posteriorDistPlotDownload", plotId, "posteriorDist.svg");
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

function addScript(url) {
    var script = document.createElement('script');
    script.setAttribute('type', 'text/javascript');
    script.setAttribute('src', url);
    document.getElementsByTagName('head')[0].appendChild(script);
}

function pasreFigtreeUpdated(figtreeTre) {
    /* 
    * The function to convert FigTree.tre into JSON
    * Example FigTree.tre which generated by MCMCTREE:
    *
    * #NEXUS
    * BEGIN TREES;
    *
    *            UTREE 1 = ((Oryzias: 2.24, Danio: 2.24) [&95%HPD={1.200, 2.515}]: 2.05, ((Mus: 0.86, (Homo: 0.054, Pan: 0.054) [&95%HPD={0.0300, 0.0750}]: 0.8080) [&95%HPD={0.813, 0.99}]: 0.93, Ornithorhynchus: 1.80) [&95%HPD={1.637, 1.859}]: 2.49) [&95%HPD={4.24, 4.40}];
    *
    * END;
    */

    const treeString = figtreeTre
        .replace(/#NEXUS[\s\S]*?BEGIN TREES;.*?\n\s*(UTREE\s*1.*?)\s*\n.*?\s*END;/i, '$1')
        .replace(/^UTREE\s+\d+\s+=\s+/, '');

    var ancestors = [];
    var tree = {};
    var tokens = treeString
        .split(/\s*(;|\(|\)|,|:|\[[^\]]*\])\s*/)
        .map(token => token.trim())
        .filter(Boolean);
    var cid = 0;
    var hpdRegex = /^\[&(.*)\]$/;
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
            case ':':
                break;
            case '[':
                var hpd = '';
                while (tokens[i].indexOf(']') === -1) {
                    hpd += tokens[i];
                    i++;
                }
                hpd += tokens[i];
                var testPattern = hpd.match(hpdRegex)[1];
                if (testPattern.includes("&95%HPD")) {
                    tree.branchHPD = hpd.match(hpdRegex)[1];
                } else {
                    tree.branchHPD = "";
                }
                break;
            default:
                var x = tokens[i - 1];
                if (x == ')' || x == '(' || x == ',') {
                    tree.name = token;
                    tree.id = cid;
                    cid++;
                } else if (x == ':') {
                    tree.length = parseFloat(token);
                }
                if (tokens[i].charAt(0) === '[') {
                    var hpd = '';
                    while (tokens[i].indexOf(']') === -1) {
                        hpd += tokens[i];
                        i++;
                    }
                    tree.name = '';
                    hpd += tokens[i];
                    var testPattern = hpd.match(hpdRegex)[1];
                    if (testPattern.includes("95%HPD")) {
                        tree.branchHPD = hpd.match(hpdRegex)[1];
                    } else {
                        tree.branchHPD = "";
                    }
                    // tree.branchHPD = hpd.match(hpdRegex)[1];
                    i++;
                }
        }
    }
    return tree;
}

function parseTimeTree(timeTree) {
    /* 
    * The function to convert FigTree.tre into JSON
    * Example FigTree.tre which generated by MCMCTREE:
    *
    * #NEXUS
    * BEGIN TREES;
    *
    *            UTREE 1 = ((Oryzias: 2.24, Danio: 2.24) [&95%HPD={1.200, 2.515}]: 2.05, ((Mus: 0.86, (Homo: 0.054, Pan: 0.054) [&95%HPD={0.0300, 0.0750}]: 0.8080) [&95%HPD={0.813, 0.99}]: 0.93, Ornithorhynchus: 1.80) [&95%HPD={1.637, 1.859}]: 2.49) [&95%HPD={4.24, 4.40}];
    *
    * END;
    */

    const treeString = timeTree
        .replace(/#NEXUS[\s\S]*?BEGIN TREES;.*?\n\s*(UTREE\s*1.*?)\s*\n.*?\s*END;/i, '$1')
        .replace(/^UTREE\s+\d+\s+=\s+/, '');

    var ancestors = [];
    var tree = {};
    var tokens = treeString
        .split(/\s*(;|\(|\)|,|:|\[[^\]]*\])\s*/)
        .map(token => token.trim())
        .filter(Boolean);
    var cid = 0;
    var hpdRegex = /^\[&(.*)\]$/;
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
            case ':':
                break;
            case '[':
                var hpd = '';
                while (tokens[i].indexOf(']') === -1) {
                    hpd += tokens[i];
                    i++;
                }
                hpd += tokens[i];
                var testPattern = hpd.match(hpdRegex)[1];
                if (testPattern.includes("&95%HPD")) {
                    tree.branchHPD = hpd.match(hpdRegex)[1];
                } else {
                    tree.branchHPD = "";
                }
                break;
            default:
                var x = tokens[i - 1];
                if (x == ')' || x == '(' || x == ',') {
                    tree.name = token;
                    tree.id = cid;
                    cid++;
                } else if (x == ':') {
                    tree.length = parseFloat(token);
                }
                if (tokens[i].charAt(0) === '[') {
                    var hpd = '';
                    while (tokens[i].indexOf(']') === -1) {
                        hpd += tokens[i];
                        i++;
                    }
                    tree.name = '';
                    hpd += tokens[i];
                    var testPattern = hpd.match(hpdRegex)[1];
                    if (testPattern.includes("95%HPD")) {
                        tree.branchHPD = hpd.match(hpdRegex)[1];
                    } else {
                        tree.branchHPD = "";
                    }
                    // tree.branchHPD = hpd.match(hpdRegex)[1];
                    i++;
                }
        }
    }
    return tree;
}

function parseKsTree(ksTree) {
    /* 
    * The function to convert ksTree in newick format into JSON
    * Example ksTree.newick which generated by codeml of PAML
    * You can reach the tree in the Orthofinder folder named by "singleCopyGene.ds_tree.newick"
    * ((Elaeis_guineensis: 0.343053, Oryza_sativa: 1.076133): 0.562976, Asparagus_officinalis: 0.132306);
    */

    var ancestors = [];
    var tree = {};
    // console.log("KsTree", ksTree);
    var tokens = ksTree
        .split(/\s*(;|\(|\)|,|:)\s*/)
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
            case ':':
                break;
            default:
                var x = tokens[i - 1];
                if (x == ')' || x == '(' || x == ',') {
                    tree.name = token;
                    tree.id = cid;
                    cid++;
                } else if (x == ':') {
                    tree.length = parseFloat(token);
                }
        }
    }
    return tree;
}

function pasreFigtree(figtreeTre) {
    /* 
    * The function to convert FigTree.tre into JSON
    * Example FigTree.tre which generated by MCMCTREE:
    *
    * #NEXUS
    * BEGIN TREES;
    *
    *            UTREE 1 = ((Oryzias: 2.24, Danio: 2.24) [&95%HPD={1.200, 2.515}]: 2.05, ((Mus: 0.86, (Homo: 0.054, Pan: 0.054) [&95%HPD={0.0300, 0.0750}]: 0.8080) [&95%HPD={0.813, 0.99}]: 0.93, Ornithorhynchus: 1.80) [&95%HPD={1.637, 1.859}]: 2.49) [&95%HPD={4.24, 4.40}];
    *
    * END;
    */

    const treeString = figtreeTre
        .replace(/#NEXUS[\s\S]*?BEGIN TREES;.*?\n\s*(UTREE\s*1.*?)\s*\n.*?\s*END;/i, '$1')
        .replace(/^UTREE\s+\d+\s+=\s+/, '');

    var ancestors = [];
    var tree = {};
    var tokens = treeString
        .split(/\s*(;|\(|\)|,|:|\[[^\]]*\])\s*/)
        .map(token => token.trim())
        .filter(Boolean);
    var cid = 0;
    var hpdRegex = /^\[&(.*)\]$/;
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
            case ':':
                break;
            case '[':
                var hpd = '';
                while (tokens[i].indexOf(']') === -1) {
                    hpd += tokens[i];
                    i++;
                }
                hpd += tokens[i];
                tree.branchHPD = hpd.match(hpdRegex)[1];
                break;
            default:
                var x = tokens[i - 1];
                if (x == ')' || x == '(' || x == ',') {
                    tree.name = token;
                    tree.id = cid;
                    cid++;
                } else if (x == ':') {
                    tree.length = parseFloat(token);
                }
                if (tokens[i].charAt(0) === '[') {
                    var hpd = '';
                    while (tokens[i].indexOf(']') === -1) {
                        hpd += tokens[i];
                        i++;
                    }
                    tree.name = '';
                    hpd += tokens[i];
                    tree.branchHPD = hpd.match(hpdRegex)[1];
                    i++;
                }
        }
    }
    return tree;
}

function speciesTreeBuilding(selector, speciesTreeJson, wgdNodesInfo, height, width) {
    var svgFile;
    var script = document.createElement('script');
    script.src = 'https://d3js.org/d3.v3.min.js';
    document.head.appendChild(script);
    script.onload = function () {
        var w = width;
        var h = height;
        d3.select(selector).select("svg").remove();
        var vis = d3.select(selector).append("svg:svg")
            .attr("width", w + 600)
            .attr("height", h + 100)
            .append("svg:g")
            .attr("transform", "translate(120, 20)");

        buildSpeciesTree(selector, vis, speciesTreeJson, wgdNodesInfo, w, h, 'right');
    }
}

function jointTreeBuilding(selector, ksTreeJson, ksPeakInfo, treeTopologJson, timeTreeJson, wgdTableInfo, ultrametricTreeJson, height, width, plotDiv, downloadDiv) {
    var svgFile;
    //load the d3 v3
    var script = document.createElement('script');
    script.src = 'https://d3js.org/d3.v3.min.js';
    document.head.appendChild(script);
    script.onload = function () {
        var w = width;
        var h = height;
        d3.selectAll(selector).select("svg").remove();
        var vis = d3.select(selector).append("svg:svg")
            .attr("width", w + 300)
            .attr("height", h + 100)
            .append("svg:g")
            .attr("transform", "translate(50, 20)");

        if (typeof ksTreeJson !== 'undefined') {
            var spNames = extractNames(ksTreeJson);
        } else if (typeof timeTreeJson !== 'undefined') {
            var spNames = extractNames(timeTreeJson);
        } else if (typeof ultrametricTreeJson !== 'undefined') {
            var spNames = extractNames(ultrametricTreeJson);
        }
        const longestXLabelLength = d3.max(spNames, d => d.toString().length);

        if (typeof ksTreeJson !== 'undefined' && typeof timeTreeJson !== 'undefined') {
            var timeTreeRatio = (w + 300 + 5 * longestXLabelLength) / 2 / (w + 300);
            buildKsTree(selector, vis, ksTreeJson, ksPeakInfo, (w + 150) / 2 - 5 * longestXLabelLength, h, 'left');
            buildTimeTree(selector, vis, timeTreeJson, wgdTableInfo, longestXLabelLength, w + 150, h, "left", timeTreeRatio);
            svgFile = "ksTree_timeTree.jointPlot.svg";
        } else if (typeof ksTreeJson === 'undefined' && typeof timeTreeJson !== 'undefined') {
            buildTimeTree(selector, vis, timeTreeJson, wgdTableInfo, longestXLabelLength, w, h, 'right');
            svgFile = "timeTree.Plot.svg";
        } else if (typeof ksTreeJson !== 'undefined' && typeof ultrametricTreeJson === 'undefined') {
            // buildKsTree(selector, vis, ksTreeJson, ksPeakInfo, w, h, 'right');
            buildKsTree(selector, vis, ksTreeJson, ksPeakInfo, (w + 150) / 2 - 5 * longestXLabelLength, h, 'left');
            var treeTopologRatio = (w + 300 + 5 * longestXLabelLength) / 2 / (w + 300);
            buildUltrametricTree(selector, vis, treeTopologJson, longestXLabelLength, w + 150, h, "left", treeTopologRatio);
            svgFile = "ksTree_ultrametricTree.jointPlot.svg";
        }

        if (typeof ultrametricTreeJson !== 'undefined' && typeof ksTreeJson !== 'undefined') {
            var ultrametricTreeRatio = (w + 300 + 5 * longestXLabelLength) / 2 / (w + 300);
            buildKsTree(selector, vis, ksTreeJson, ksPeakInfo, (w + 150) / 2 - 5 * longestXLabelLength, h, 'left');
            buildUltrametricTree(selector, vis, ultrametricTreeJson, longestXLabelLength, w + 150, h, "left", ultrametricTreeRatio);
            svgFile = "ksTree_ultrametricTree.jointPlot.svg";
        } else if (typeof ultrametricTreeJson !== 'undefined') {
            buildUltrametricTree(selector, vis, ultrametricTreeJson, longestXLabelLength, w, h, "right");
            svgFile = "ultrametricTree.Plot.svg";
        }


        downloadSVG(downloadDiv, plotDiv, svgFile);
    }
}

function buildKsTree(selector, vis, ksTreeJson, ksPeakInfo, w, h, ori) {
    if (ori === "right") {
        var tree = d3.layout.cluster()
            .size([h, w])
            .separation(function (a, b) {
                return 1;
            })
            .sort(function (node) {
                return node.children ? node.children.length : -1;
            })
            .children(function (node) {
                return node.branchset
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
            })
            .children(function (node) {
                return node.branchset
            });

        var diagonal = rightAngleDiagonal();
        var ksTreeNodes = tree(ksTreeJson);
        var yscale = scaleBranchLengths(ksTreeNodes, w).range([0, w]);
    }

    var legend = vis.append('g')
        .attr('class', 'ks-legend')
        .append('text')
        .attr('x', -10)
        .attr('y', h + 11)
        .attr('text-anchor', 'end')
        .attr('font-size', '10px')
        .attr('opacity', 0.6)
        .append("tspan")
        .attr("font-style", "italic")
        .text("K")
        .append("tspan")
        .attr("baseline-shift", "sub")
        .text("s")
        .attr("dy", "-5px")

    if (ori === "right") {
        var scaleBarLength = 0.1;
    } else {
        var scaleBarLength = 0.2;
    }

    vis.append("line")
        .attr("class", "ks-rule")
        .attr("x1", yscale(0))
        .attr("x2", yscale(scaleBarLength))
        .attr("y1", h + 8)
        .attr("y2", h + 8)
        .attr("stroke", "#aaa")
        .attr("stroke-width", 2.45);

    vis.append("g")
        .attr('class', 'ks-legend')
        .append('text')
        .attr('x', (yscale(scaleBarLength) - yscale(0)) / 2)
        .attr('y', h + 4)
        .attr('text-anchor', 'middle')
        .attr('font-size', '10px')
        .text(scaleBarLength);

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

    if (ori === 'right') {
        d3.select('.ks-leaf-pop-up-menu').remove();
        var leafPopUpMenu = d3.select(selector).append('div')
            .classed('ks-leaf-pop-up-menu', true)
            .style('position', 'absolute')
            .style('top', 0)
            .style('left', 0)
            .style('visibility', 'hidden')
            .style('background-color', 'white')
            .style('border', '1px solid black')
            .style('padding', '5px');

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
            .attr("font-size", "14px")
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
            })
            .attr("data-tippy-content", (d) => {
                return "<font color='#00DB00'>" + d.name +
                    "</font>: <font color='orange'><i>K</><sub>s</sub>: " + numFormatter(d.rootDist) + "</font>";
            })
            .on("mouseover", function () {
                ribbonEnterTime = new Date().getTime();
                d3.select(this)
                    .transition()
                    .delay(100)
                    .duration(50)
                    .attr("fill", "#E1E100")
            })
            .on("mouseout", function () {
                ribbonOutTime = new Date().getTime();
                if (ribbonOutTime - ribbonEnterTime <= 1000) {
                    d3.select(this)
                        .transition()
                        .duration(50)
                        .attr("fill", "black")
                }
            })
            .on('click', function (d) {
                if (leafPopUpMenu.style('visibility') == 'visible') {
                    leafPopUpMenu.style('visibility', 'hidden');
                } else {
                    var name = d.name.replace(/_/g, ' ');
                    if (d.name.match(/\_/)) {
                        leafPopUpMenu.html("<p><font color='#00DB00'><i>" + name + "</i></font>: <font color='orange'><i>K</i><sub>s</sub>: "
                            + numFormatter(d.rootDist) + "</font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" +
                            "<button id='close-btn-leaf' onclick='closeLeafPopUp()'>&times;</button></p>" +
                            "<p>Choose a color:</p>" +
                            "<div id='color-options'></div>" +
                            "<p></p>" +
                            "<p>Choose a symbol:" +
                            "<div id='symbol-options'></div>");
                        // "<button id='add-symbol' onclick='addSymbol(textElement)'>Add Symbol</button>");
                    } else {
                        leafPopUpMenu.html("<p><font color='#00DB00'>" + name + "</font>: <font color='orange'><i>K</i><sub>s</sub>: "
                            + numFormatter(d.rootDist) + "</font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" +
                            "<button id='close-btn-leaf' onclick='closeLeafPopUp()'>&times;</button></p>" +
                            "<p>Choose a color:" +
                            "<div id='color-options'></div>" +
                            "<p></p>" +
                            "<p>Choose a symbol:" +
                            "<div id='symbol-options'></div>");
                        // "<button id='add-symbol' onclick='addSymbol(textElement)'>Add Symbol</button>");
                    }
                    d3.select('#close-btn-leaf').on('click', closeLeafPopUp);
                    function closeLeafPopUp() {
                        leafPopUpMenu.style('visibility', 'hidden');
                    };

                    var colors = ['#FF0000', '#00FF00', '#0000FF', '#FFA500', '#800080', '#FFC0CB', 'black'];
                    var textElement = d3.select(this.parentNode).select('.my-text').node();
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
                        .on('click', function (d) {
                            d3.select(textElement).style('fill', d);
                            leafPopUpMenu.style('visibility', 'hidden');
                        });

                    var symbols = [
                        { name: 'Circle', type: 'circle' },
                        { name: 'Cross', type: 'cross' },
                        { name: 'Diamond', type: 'diamond' },
                        { name: 'Square', type: 'square' },
                        { name: 'Triangle Up', type: 'triangle-up' }
                    ];

                    var clickedLeafNode = this;
                    var symbolOptions = d3.select('#symbol-options')
                        .selectAll('div')
                        .data(symbols)
                        .enter()
                        .append('div')
                        .style('cursor', 'pointer')
                        .style('width', '30px')
                        .style('height', '30px')
                        .style('margin-right', '3px')
                        .style('float', 'left')
                        .append('svg')
                        .attr('width', '60')
                        .attr('height', '60')
                        .append('path')
                        .attr('transform', 'translate(15, 15)')
                        .attr('d', function (d) {
                            if (d.type === 'circle') {
                                return d3.svg.symbol().type('circle')();
                            } else if (d.type === 'cross') {
                                return d3.svg.symbol().type('cross')();
                            } else if (d.type === 'diamond') {
                                return d3.svg.symbol().type('diamond')();
                            } else if (d.type === 'square') {
                                return d3.svg.symbol().type('square')();
                            } else if (d.type === 'triangle-up') {
                                return d3.svg.symbol().type('triangle-up')();
                            }
                        })
                        .attr('stroke', '#707038')
                        .attr('fill', '#707038')
                        .on('click', function (d) {
                            var leafNode = clickedLeafNode.parentNode;
                            var symbol = d3.svg.symbol().type(d.type)
                            var styleAttr = d3.select(clickedLeafNode).attr('style');
                            var match = styleAttr.match(/fill:\s*(.*?);/);
                            var textColor = match[1];
                            d3.select(leafNode)
                                .append('path')
                                .attr('d', symbol)
                                .attr('stroke', textColor)
                                .attr('fill', textColor)
                                .attr('stroke-width', '1px');
                        });

                    const transformAttributeValue = d3.select(this.parentNode).attr("transform");
                    const match = transformAttributeValue.match(/translate\(([\d.-]+),([\d.-]+)\)/);
                    const xx = parseFloat(match[1]);
                    const yy = parseFloat(match[2]);
                    leafPopUpMenu.style('left', (xx + 200) + 'px')
                        .style('top', (yy - 5) + 'px')
                        .style('visibility', 'visible');
                }
            });
        tippy(".my-text rect", { trigger: "mouseenter", followCursor: "initial", allowHTML: true, delay: [200, null] });
    }

    /* d3.select('.ks-path-pop-up-menu').remove();
    var popUpMenu = d3.select(selector).append('div')
        .classed('ks-path-pop-up-menu', true)
        .style('position', 'absolute')
        .style('top', 0)
        .style('left', 0)
        .style('visibility', 'hidden')
        .style('background-color', 'white')
        .style('border', '1px solid black')
        .style('padding', '5px'); */

    var link = vis.selectAll("path.ks-link")
        .data(tree.links(ksTreeNodes))
        .enter().append("svg:path")
        .attr("class", "ks-link")
        .attr("d", diagonal)
        .attr("fill", "none")
        .attr("stroke", "#aaa")
        .attr("stroke-width", "2.45px")
        .attr("stroke-dasharray", d => (d.source.y === 0) ? "6 8" : "none")
        .on("mouseover", function () {
            ribbonEnterTime = new Date().getTime();
            d3.select(this)
                .transition()
                .delay(100)
                .duration(50)
                .attr("stroke", "#E1E100")
                .attr("stroke-width", "4px")
        })
        .on("mouseout", function () {
            ribbonOutTime = new Date().getTime();
            if (ribbonOutTime - ribbonEnterTime <= 1000) {
                d3.select(this)
                    .transition()
                    .duration(50)
                    .attr("stroke", "#aaa")
                    .attr("stroke-width", "2.45px")
            }
        })
    /*         .on('click', function (d) {
                if (popUpMenu.style('visibility') == 'visible') {
                    popUpMenu.style('visibility', 'hidden');
                } else {
                    popUpMenu.html("<p>Add a <font color='#00DB00'>WGD</font> event within this clade" +
                        "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<button id='close-btn' onclick='closePopUp()'>&times;</button></p>" +
                        "<p><font color='#A6A600'>Set a <i>K</i><sub>s</sub>: </font>" +
                        "<input type='text' id='time-input'>" +
                        "<p></p>" +
                        "<p>Set a Greek letter:" +
                        "<div id='symbol-selector'>" +
                        "<button class='symbol-btn'><font color='#66c2a5'><b>&alpha;</b></font></button>" +
                        "<button class='symbol-btn'><font color='#fc8d62'><b>&beta;</b></font></button>" +
                        "<button class='symbol-btn'><font color='#8da0cb'><b>&gamma;</b></font></button>" +
                        "<button class='symbol-btn'><font color='#e78ac3'><b>&delta;</b></font></button>" +
                        "<button class='symbol-btn'><font color='#a6d854'><b>&epsilon;</b></font></button>" +
                        "</div>" +
                        "</p>"
                    );
    
                    d3.select('#close-btn').on('click', closePopUp);
                    function closePopUp() {
                        popUpMenu.style('visibility', 'hidden');
                    };
    
                    var distanceToRoot = d.target.rootDist;
    
                    var clickedPath = this;
                    var pathData = clickedPath.getAttribute('d');
                    var pathArray = pathData.split(' ');
                    var yValue = pathArray[2].split(',')[1];
                    var middleXpos = (Number(pathArray[2].split(',')[0]) + Number(pathArray[1].split(',')[0])) / 2;
                    var timeInput = document.getElementById('time-input');
                    d3.selectAll('.symbol-btn').on('click', function () {
                        var symbolText = this.innerHTML;
                        var symbolText = this.innerHTML.match(/<b style=\"-webkit-user-select: auto;\">(.*?)<\/b>/)[1];
                        var buttonColor = this.innerHTML.match(/<font color=\"(.*?)\" style=\"-webkit-user-select: auto;\">/)[1];
                        var textElement = d3.select(clickedPath.parentNode).append('text')
                            .text(symbolText)
                            .attr('x', function () {
                                return (yscale(distanceToRoot) - yscale(timeInput.value));
                            })
                            .attr('y', Number(yValue) - 12)
                            .style('font-size', '18px')
                            .attr("text-anchor", "middle")
                            .style('fill', buttonColor);
    
                        var line = d3.select(clickedPath.parentNode).append('line')
                            .attr('x1', textElement.attr('x'))
                            .attr('x2', textElement.attr('x'))
                            .attr('y1', Number(yValue) - 1)
                            .attr('y2', Number(yValue) - 6)
                            .style('stroke', buttonColor)
                            .style('stroke-width', '2px');
    
                        var bbox = textElement.node().getBBox();
                        var padding = 5;
                        var rectElement = d3.select(clickedPath.parentNode).insert('rect', 'text')
                            .attr('x', bbox.x - padding)
                            .attr('y', bbox.y - padding)
                            .attr('width', bbox.width + (padding * 2))
                            .attr('height', bbox.height + (padding * 2))
                            .style('fill', 'white')
                            .style('stroke', 'none');
    
                        closePopUp();
                    });
    
                    d3.select('#close-btn').on('click', closePopUp);
                    function closePopUp() {
                        popUpMenu.style('visibility', 'hidden');
                    };
    
                    popUpMenu.style('left', (middleXpos + 100) + 'px')
                        .style('top', (Number(yValue) + 40) + 'px')
                        .style('visibility', 'visible');
                }
            }); */

    // Move the created paths to the bottom of the SVG
    vis.selectAll("path.ks-link").each(function () {
        var firstChild = this.parentNode.firstChild;
        if (firstChild) {
            this.parentNode.insertBefore(this, firstChild);
        }
    });

    // Add the Ks peak to the tree
    if (typeof ksPeakInfo !== "undefined") {
        var maxRootLen = getMaxNodeLength(ksTreeNodes)
        // console.log("ksTreeNodes", ksTreeNodes);
        // console.log(maxRootLen, "maxRootLen");
        // console.log("ksPeakInfo", ksPeakInfo);
        ksPeakInfo.forEach(function (item) {
            if (item.peak < maxRootLen) {
                if (item.species.includes(' ')) {
                    var speciesName = item.species.replace(/\s+/g, '_');
                } else {
                    var speciesName = item.species;
                }

                var branch = ksTreeNodes.find(function (node) {
                    return node.name === speciesName;
                });

                if (item.peak / 2 < branch.rootDist) {
                    var peak = item.peak / 2;
                    var color = item.color;
                    var peakX = yscale(branch.rootDist) - yscale(peak);
                    var peakY = branch.x;

                    // Add a line to link the rect and the branch
                    if (peak > branch.length) {
                        vis.append("line")
                            .attr("class", "link-line-rect-peak")
                            .attr("y1", peakY)
                            .attr("y2", peakY)
                            .attr("x1", peakX)
                            .attr("x2", yscale(branch.rootDist - branch.length))
                            .attr("stroke-dasharray", "4 1")
                            .attr("stroke-width", 1.36)
                            .attr("stroke-opacity", 0.51)
                            .attr("stroke", "#3C3C3C");
                    }

                    vis.append('svg:circle')
                        .attr("class", "ks-peak")
                        .attr("r", function () {
                            if (ori === "right") {
                                return 4;
                            } else {
                                return 3;
                            }
                        })
                        .attr("cx", peakX)
                        .attr("cy", peakY)
                        .attr("fill", color)
                        .attr("fill-opacity", "0.7");

                    var ciRange = item.confidence_interval;

                    var [min, max] = ciRange.split('-').map(Number);
                    var rectX = yscale(branch.rootDist) - yscale(max / 2);
                    var rectWidth = yscale(max / 2) - yscale(min / 2);

                    // Create a rectangle element
                    vis.append("rect")
                        .attr("class", "wgd_rect")
                        .attr("x", rectX)
                        .attr("y", peakY - 5)
                        .attr("width", rectWidth)
                        .attr("height", 10)
                        .attr("stroke-width", 1.31)
                        .attr("stroke-opacity", "0.6")
                        .attr("stroke", color)
                        .attr("fill", "white")
                        .attr("fill-opacity", "0.1")
                        .attr("data-tippy-content", () => {
                            return "WGD in <font color='red'><i><b>" + item.species + "</b></i></font>" +
                                "<br>Peak: <font color='#00EC00'>" + peak + "</font><br>Confidence interval: <font color='#73BF00'>" + numFormatter(min) / 2 +
                                "</font> - <font color='orange'>" + numFormatter(max) / 2 + "</font>";
                        });
                    tippy(".wgd_rect", { trigger: "mouseenter", followCursor: "initial", allowHTML: true, delay: [200, null] });
                }
            }
        });
    }
}

function buildTimeTree(selector, vis, timeTreeJson, wgdTableInfo, longestXLabelLength, w, h, ori, ratio) {
    if (ori === "right") {
        var tree = d3.layout.cluster()
            .size([h, w])
            .separation(function (a, b) {
                return 1;
            })
            .sort(function (node) {
                return node.children ? node.children.length : -1;
            })
            .children(function (node) {
                return node.branchset
            });

        var diagonal = rightAngleDiagonal();
        var nodes = tree(timeTreeJson);
        var yscale = scaleBranchLengths(nodes, w).range([w, 0]);
    } else {
        var tree = d3.layout.cluster()
            .size([h, w * ratio])
            .separation(function (a, b) {
                return 1;
            })
            .sort(function (node) {
                return node.children ? node.children.length : -1;
            })
            .children(function (node) {
                return node.branchset
            });

        var diagonal = leftAngleDiagonal();
        var nodes = tree(timeTreeJson);
        var yscale = scaleLeftBranchLengths(nodes, w, ratio).range([w * ratio, w]);
    }

    // console.log("timeTreeNodes", nodes);
    vis.selectAll('.rule-line')
        .data(yscale.ticks(11))
        .enter().append('svg:line')
        .attr('class', 'rule-line')
        .attr('y1', 0)
        .attr('y2', h)
        .attr('x1', yscale)
        .attr('x2', yscale)
        .attr("stroke-dasharray", "4 1")
        .attr("stroke-width", 0.66)
        .attr("stroke-opacity", 0.2)
        .attr("stroke", "blue");

    vis.selectAll("text.rule")
        .data(yscale.ticks(11))
        .enter().append("svg:text")
        .attr("class", "rule")
        .attr("x", yscale)
        .attr("y", h + 15)
        .attr("dy", -3)
        .attr("text-anchor", "middle")
        .attr("font-size", "10px")
        .attr('fill', 'blue')
        .attr('opacity', 0.3)
        .text(function (d) { return (Math.round(d * 100) / 100 * 100).toFixed(0); });

    var legend = vis.append('g')
        .attr('class', 'legend')
        .append('text')
        .attr('x', function () {
            if (ori === "right") {
                return w + 8;
            } else {
                return w + 2;
            }
        })
        .attr('y', h + 12)
        .attr('text-anchor', 'start')
        .attr('font-size', '10px')
        .attr('fill', 'blue')
        .attr('opacity', 0.3)
        .text('million years ago');

    var node = vis.selectAll("g.node")
        .data(nodes)
        .enter().append("svg:g")
        .attr("class", function (n) {
            if (n.children) {
                if (n.depth == 0) {
                    return "root node"
                } else {
                    return "inner node"
                }
            } else {
                return "leaf node"
            }
        })
        .attr("transform", function (d) { return "translate(" + d.y + "," + d.x + ")"; })

    vis.selectAll('g.root.node')
        .append('line')
        .attr('stroke', '#aaa')
        .attr('stroke-width', 2.45)
        .attr('x1', 0)
        .attr('y1', 0)
        .attr('x2', function () {
            if (ori === "right") {
                return -10;
            } else {
                return 10;
            }
        })
        .attr('y2', 0)

    d3.select('.leaf-pop-up-menu').remove();
    var leafPopUpMenu = d3.select(selector).append('div')
        .classed('leaf-pop-up-menu', true)
        .style('position', 'absolute')
        .style('top', 0)
        .style('left', 0)
        .style('visibility', 'hidden')
        .style('background-color', 'white')
        .style('border', '1px solid black')
        .style('padding', '5px');

    vis.selectAll('g.leaf.node')
        .append("svg:text")
        .attr("class", "my-text")
        .attr("dx", function () {
            if (ori === "right") {
                return 8;
            } else {
                return 25 - longestXLabelLength * 5;
            }
        })
        .attr("dy", 3)
        .attr("text-anchor", function () {
            if (ori === "right") {
                return "start";
            } else {
                return "middle";
            }
        })
        .attr("font-size", "14px")
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
        })
        .attr("data-tippy-content", (d) => {
            return "<font color='#00DB00'>" + d.name +
                "</font>: <font color='orange'>" + numFormatter(d.length * 100) + " Mya</font>";
        })
        .on("mouseover", function () {
            ribbonEnterTime = new Date().getTime();
            d3.select(this)
                .transition()
                .delay(100)
                .duration(50)
                .attr("fill", "#E1E100")
        })
        .on("mouseout", function () {
            ribbonOutTime = new Date().getTime();
            if (ribbonOutTime - ribbonEnterTime <= 1000) {
                d3.select(this)
                    .transition()
                    .duration(50)
                    .attr("fill", "black")
            }
        })
        .on('click', function (d) {
            if (leafPopUpMenu.style('visibility') == 'visible') {
                leafPopUpMenu.style('visibility', 'hidden');
            } else {
                var name = d.name.replace(/_/g, ' ');
                if (d.name.match(/\_/)) {
                    leafPopUpMenu.html("<p><font color='#00DB00'><i>" + name + "</i></font>: <font color='orange'>" +
                        numFormatter(d.length * 100) + " Mya</font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" +
                        "<button id='close-btn-leaf' onclick='closeLeafPopUp()'>&times;</button></p>" +
                        "<p>Choose a color:</p>" +
                        "<div id='color-options'></div>" +
                        "<p></p>" +
                        "<p>Choose a symbol:" +
                        "<div id='symbol-options'></div>");
                    // "<button id='add-symbol' onclick='addSymbol(textElement)'>Add Symbol</button>");
                } else {
                    leafPopUpMenu.html("<p><font color='#00DB00'>" + name + "</font>: <font color='orange'>" +
                        numFormatter(d.length * 100) + " Mya</font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" +
                        "<button id='close-btn-leaf' onclick='closeLeafPopUp()'>&times;</button></p>" +
                        "<p>Choose a color:" +
                        "<div id='color-options'></div>" +
                        "<p></p>" +
                        "<p>Choose a symbol:" +
                        "<div id='symbol-options'></div>");
                    // "<button id='add-symbol' onclick='addSymbol(textElement)'>Add Symbol</button>");
                }
                d3.select('#close-btn-leaf').on('click', closeLeafPopUp);
                function closeLeafPopUp() {
                    leafPopUpMenu.style('visibility', 'hidden');
                };

                var colors = ['#FF0000', '#00FF00', '#0000FF', '#FFA500', '#800080', '#FFC0CB', 'black'];
                var textElement = d3.select(this.parentNode).select('.my-text').node();
                // console.log("textElement", textElement)
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
                    .on('click', function (d) {
                        d3.select(textElement).style('fill', d);
                    });

                var symbols = [
                    { name: 'Circle', type: 'circle' },
                    { name: 'Cross', type: 'cross' },
                    { name: 'Diamond', type: 'diamond' },
                    { name: 'Square', type: 'square' },
                    { name: 'Triangle Up', type: 'triangle-up' }
                ];

                var clickedLeafNode = this;
                var symbolOptions = d3.select('#symbol-options')
                    .selectAll('div')
                    .data(symbols)
                    .enter()
                    .append('div')
                    .style('cursor', 'pointer')
                    .style('width', '30px')
                    .style('height', '30px')
                    .style('margin-right', '3px')
                    .style('float', 'left')
                    .append('svg')
                    .attr('width', '60')
                    .attr('height', '60')
                    .append('path')
                    .attr('transform', 'translate(15, 15)')
                    .attr('d', function (d) {
                        if (d.type === 'circle') {
                            return d3.svg.symbol().type('circle')();
                        } else if (d.type === 'cross') {
                            return d3.svg.symbol().type('cross')();
                        } else if (d.type === 'diamond') {
                            return d3.svg.symbol().type('diamond')();
                        } else if (d.type === 'square') {
                            return d3.svg.symbol().type('square')();
                        } else if (d.type === 'triangle-up') {
                            return d3.svg.symbol().type('triangle-up')();
                        }
                    })
                    .attr('stroke', '#707038')
                    .attr('fill', '#707038')
                    .on('click', function (d) {
                        var leafNode = clickedLeafNode.parentNode;
                        var symbol = d3.svg.symbol().type(d.type)
                        var styleAttr = d3.select(clickedLeafNode).attr('style');
                        var match = styleAttr.match(/fill:\s*(.*?);/);
                        var textColor = match[1];
                        /* var textColor = d3.select(clickedLeafNode).select('my-text').style('fill');
                        console.log(textColor); */
                        d3.select(leafNode)
                            .append('path')
                            .attr('d', symbol)
                            .attr('stroke', textColor)
                            .attr('fill', textColor)
                            .attr('stroke-width', '1px');

                        leafPopUpMenu.style('visibility', 'hidden');
                    });

                const transformAttributeValue = d3.select(this.parentNode).attr("transform");
                const match = transformAttributeValue.match(/translate\(([\d.-]+),([\d.-]+)\)/);
                const xx = parseFloat(match[1]);
                const yy = parseFloat(match[2]);
                leafPopUpMenu.style('left', (xx + 200) + 'px')
                    .style('top', (yy - 5) + 'px')
                    .style('visibility', 'visible');
            }
        });
    tippy(".my-text rect", { trigger: "mouseenter", followCursor: "initial", allowHTML: true, delay: [200, null] });

    d3.select('.path-pop-up-menu').remove();
    var popUpMenu = d3.select(selector).append('div')
        .classed('path-pop-up-menu', true)
        .style('position', 'absolute')
        .style('top', 0)
        .style('left', 0)
        .style('visibility', 'hidden')
        .style('background-color', 'white')
        .style('border', '1px solid black')
        .style('padding', '5px');

    var link = vis.selectAll("path.link")
        .data(tree.links(nodes))
        .enter().append("svg:path")
        .attr("class", "link")
        .attr("d", diagonal)
        .attr("fill", "none")
        .attr("stroke", "#aaa")
        .attr("stroke-width", "2.45px")
        .on("mouseover", function () {
            ribbonEnterTime = new Date().getTime();
            d3.select(this)
                .transition()
                .delay(100)
                .duration(50)
                .attr("stroke", "#E1E100")
                .attr("stroke-width", "4px")
        })
        .on("mouseout", function () {
            ribbonOutTime = new Date().getTime();
            if (ribbonOutTime - ribbonEnterTime <= 1000) {
                d3.select(this)
                    .transition()
                    .duration(50)
                    .attr("stroke", "#aaa")
                    .attr("stroke-width", "2.45px")
            }
        })
        .on('click', function (d) {
            if (popUpMenu.style('visibility') == 'visible') {
                popUpMenu.style('visibility', 'hidden');
            } else {
                popUpMenu.html("<p>Add a <font color='#00DB00'>WGD</font> event within this clade" +
                    "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<button id='close-btn' onclick='closePopUp()'>&times;</button></p>" +
                    "<p><font color='#A6A600'>Set a time: </font>" +
                    "<input type='text' id='time-input'>" +
                    "<font color='#A6A600'> Mya</font>" +
                    "<p></p>" +
                    "<p>Set a Greek letter:" +
                    "<div id='symbol-selector'>" +
                    "<button class='symbol-btn'><font color='#66c2a5'><b>&alpha;</b></font></button>" +
                    "<button class='symbol-btn'><font color='#fc8d62'><b>&beta;</b></font></button>" +
                    "<button class='symbol-btn'><font color='#8da0cb'><b>&gamma;</b></font></button>" +
                    "<button class='symbol-btn'><font color='#e78ac3'><b>&delta;</b></font></button>" +
                    "<button class='symbol-btn'><font color='#a6d854'><b>&epsilon;</b></font></button>" +
                    "</div>" +
                    "</p>"
                );

                d3.select('#close-btn').on('click', closePopUp);
                function closePopUp() {
                    popUpMenu.style('visibility', 'hidden');
                };

                var clickedPath = this;
                var pathData = clickedPath.getAttribute('d');
                var pathArray = pathData.split(' ');
                var xValue = pathArray[1].split(',')[0];
                var yValue = pathArray[2].split(',')[1];
                var middleXpos = (Number(pathArray[2].split(',')[0]) + Number(pathArray[1].split(',')[0])) / 2;
                var timeInput = document.getElementById('time-input');

                d3.selectAll('.symbol-btn').on('click', function () {
                    var maxLength = getMaxNodeLength(nodes);
                    if (ori === 'right') {
                        var yScaleNew = d3.scale.linear()
                            .domain([0, maxLength])
                            .range([0, w]);
                    } else {
                        var yScaleNew = d3.scale.linear()
                            .domain([0, maxLength])
                            .range([w, w * ratio]);
                    }

                    var xPos = yScaleNew(maxLength - timeInput.value / 100);
                    if (xPos < xValue) {
                        popUpMenu.style('visibility', 'hidden');
                        Swal.fire({
                            icon: 'error',
                            title: 'Oops...',
                            html: 'Input time excesses the length of this branch. Please add this WGD event to the ancestral branch!',
                        });
                    } else {
                        var symbolText = this.innerHTML;
                        var symbolText = this.innerHTML.match(/<b.*?>(.*?)<\/b>/)[1];
                        var buttonColor = this.innerHTML.match(/<font color=\"(.*?)\">/)[1];
                        var textElement = d3.select(clickedPath.parentNode).append('text')
                            .text(symbolText)
                            .attr('x', xPos)
                            .attr('y', Number(yValue) - 12)
                            .style('font-size', '18px')
                            .attr("text-anchor", "middle")
                            .style('fill', buttonColor)
                            .style('opacity', 0.9)

                        var line = d3.select(clickedPath.parentNode).append('line')
                            .attr('x1', textElement.attr('x'))
                            .attr('x2', textElement.attr('x'))
                            .attr('y1', Number(yValue) - 1)
                            .attr('y2', Number(yValue) - 6)
                            .style('stroke', buttonColor)
                            .style('stroke-width', '2px');

                        popUpMenu.style('visibility', 'hidden');
                    }
                });

                popUpMenu.style('left', (middleXpos + 100) + 'px')
                    .style('top', (Number(yValue) + 40) + 'px')
                    .style('visibility', 'visible');
            }
        });

    // Move the created paths to the bottom of the SVG
    vis.selectAll("path.link").each(function () {
        var firstChild = this.parentNode.firstChild;
        if (firstChild) {
            this.parentNode.insertBefore(this, firstChild);
        }
    });

    // add a condition when hpd is missing
    var filteredData = nodes.filter(function (d) {
        return d.hasOwnProperty("branchHPD") && d.branchHPD !== "";
    });
    var maxLength = getMaxNodeLength(nodes);
    if (typeof wgdTableInfo === 'undefined') {
        if (filteredData.length === 0) {
            console.log("No 95% CI HPD data to visualize.");
        } else {
            vis.selectAll('g.root.node')
                .attr('class', 'hpd_rect')
                .append('rect')
                .attr('x', function (d) {
                    var x1 = parseFloat(d.branchHPD.match(/\{([\d\.]+),/)[1]);
                    var x2 = parseFloat(d.branchHPD.match(/, ([\d\.]+)\}/)[1]);
                    var transformAttr = d3.select(this.parentNode).attr('transform');
                    var translate = transformAttr.match(/translate\(([\d\.]+),([\d\.]+)\)/);
                    var x = translate[1];
                    if (ori === "right") {
                        return yscale(x2) - x - 5;
                    } else {
                        return yscale(x1) - x;
                    }
                })
                .attr("y", -5)
                .attr('width', function (d) {
                    var x1 = parseFloat(d.branchHPD.match(/\{([\d\.]+),/)[1]);
                    var x2 = parseFloat(d.branchHPD.match(/, ([\d\.]+)\}/)[1]);
                    if (ori === "right") {
                        return yscale(x1) - yscale(x2);
                    } else {
                        return yscale(x2) - yscale(x1);
                    }
                })
                .attr('height', 10)
                .attr('fill', '#707038')
                .attr('fill-opacity', 0.3)
                .attr("data-tippy-content", (d) => {
                    var x1 = parseFloat(d.branchHPD.match(/\{([\d\.]+),/)[1]);
                    var x2 = parseFloat(d.branchHPD.match(/, ([\d\.]+)\}/)[1]);
                    return "Divergence Time: <font color='red'>" + numFormatter(maxLength * 100) + "</font><br>" +
                        "95%CI = [<font color='#00DB00'>" + numFormatter(x1 * 100) +
                        ",</font> <font color='orange'>" + numFormatter(x2 * 100) + "</font>]";
                });

            vis.selectAll('g.inner.node')
                .attr('class', 'hpd_rect')
                .append('rect')
                .attr('x', function (d) {
                    var x1 = parseFloat(d.branchHPD.match(/\{([\d\.]+),/)[1]);
                    var x2 = parseFloat(d.branchHPD.match(/, ([\d\.]+)\}/)[1]);
                    var transformAttr = d3.select(this.parentNode).attr('transform');
                    var translate = transformAttr.match(/translate\(([\d\.]+),([\d\.]+)\)/);
                    var x = translate[1];
                    var x = translate[1];
                    if (ori === "right") {
                        return yscale(x2) - x;
                    } else {
                        return yscale(x1) - x;
                    };
                })
                .attr("y", -6)
                .attr('width', function (d) {
                    var x1 = parseFloat(d.branchHPD.match(/\{([\d\.]+),/)[1]);
                    var x2 = parseFloat(d.branchHPD.match(/, ([\d\.]+)\}/)[1]);
                    if (ori === "right") {
                        return yscale(x1) - yscale(x2);
                    } else {
                        return yscale(x2) - yscale(x1);
                    }
                })
                .attr('height', 12)
                .attr('fill', '#707038')
                .attr('fill-opacity', 0.3)
                .attr("data-tippy-content", function (d) {
                    var x1 = parseFloat(d.branchHPD.match(/\{([\d\.]+),/)[1]);
                    var x2 = parseFloat(d.branchHPD.match(/, ([\d\.]+)\}/)[1]);
                    return "Divergence Time: <font color='red'>" + numFormatter((maxLength - d.rootDist) * 100) + " Mya</font>" +
                        "<br></font>95%CI = [<font color='#00DB00'>" + numFormatter(x1 * 100) +
                        ",</font> <font color='orange'>" + numFormatter(x2 * 100) + "</font>]";
                })

            tippy(".hpd_rect rect", { trigger: "mouseenter", followCursor: "initial", allowHTML: true, delay: [200, null] });
        }
    }

    // Add the WGD events to the tree
    if (typeof wgdTableInfo !== "undefined") {
        wgdTableInfo.forEach(function (item) {
            var speciesName = item.species.replace(/\s+/g, '_');
            var speciesColor = item.color;
            var branch = nodes.find(function (node) {
                return node.name === speciesName;
            });

            var wgdInfo = item.wgds;
            if (wgdInfo.toString().includes(",")) {
                var wgdsRange = item.wgds.split(',');

                wgdsRange.forEach(function (range, index) {
                    if (range.includes('-')) {
                        var [min, max] = range.split('-').map(Number);
                        if (ori === "right") {
                            var rectX = yscale(max);
                            var rectWidth = yscale(min) - yscale(max);
                        } else {
                            var rectX = yscale(min);
                            var rectWidth = yscale(max) - yscale(min);
                        }

                        var cumulativeLength = branch.length;
                        var currentBranch = branch;
                        var parentCount = 0;

                        // Calculate the cumulative length of multiple parent nodes
                        while (currentBranch.parent && (min > cumulativeLength)) {
                            cumulativeLength += currentBranch.parent.length;
                            currentBranch = currentBranch.parent;
                            parentCount++;
                        }

                        var rectY = branch.x;
                        var tempBranch = branch;
                        for (var i = 0; i < parentCount; i++) {
                            tempBranch = tempBranch.parent;
                            rectY = tempBranch.x;
                        }

                        // Create a rectangle element
                        vis.append('rect')
                            .attr("class", "wgd_rect")
                            .attr('x', rectX)
                            .attr('y', rectY - 6)
                            .attr('width', rectWidth)
                            .attr('height', 12)
                            .attr('fill', speciesColor)
                            // .attr('fill-opacity', 0.7)
                            .attr("data-tippy-content", () => {
                                // var x1 = parseFloat(d.branchHPD.match(/\{([\d\.]+),/)[1]);
                                // var x2 = parseFloat(d.branchHPD.match(/, ([\d\.]+)\}/)[1]);
                                return "WGD-" + Number(index + 1) + " in <font color='red'><i><b>" + item.species + "</b></i></font>" +
                                    ": <br><font color='#73BF00'>" + numFormatter(min * 100) +
                                    "</font> - <font color='orange'>" + numFormatter(max * 100) + "</font> MYA";
                            });

                        tippy(".wgd_rect", { trigger: "mouseenter", followCursor: "initial", allowHTML: true, delay: [200, null] });
                    } else {
                        var posX = yscale(range);
                        var cumulativeLength = branch.length;
                        var currentBranch = branch;
                        var parentCount = 0;

                        // Calculate the cumulative length of multiple parent nodes
                        while (currentBranch.parent && (range > cumulativeLength)) {
                            cumulativeLength += currentBranch.parent.length;
                            currentBranch = currentBranch.parent;
                            parentCount++;
                        }

                        var rectY = branch.x;
                        var tempBranch = branch;
                        for (var i = 0; i < parentCount; i++) {
                            tempBranch = tempBranch.parent;
                            rectY = tempBranch.x;
                        }
                        // Create a line element
                        vis.append('line')
                            .attr("class", "wgd_line")
                            .attr('x1', posX)
                            .attr('x2', posX)
                            .attr('y1', rectY - 6)
                            .attr('y2', rectY + 6)
                            .attr("stroke-width", 2)
                            .attr('stroke', speciesColor)
                            // .attr('fill-opacity', 0.7)
                            .attr("data-tippy-content", () => {

                                return "WGD-" + Number(index + 1) + " in <font color='red'><i><b>" + item.species + "</b></i></font>" +
                                    ": <br><font color='#73BF00'>" + numFormatter(range * 100) + "</font> MYA";
                            });

                        tippy(".wgd_line", { trigger: "mouseenter", followCursor: "initial", allowHTML: true, delay: [200, null] });
                    }
                });
            } else {
                var range = item.wgds;
                if (range.toString().includes('-')) {
                    var [min, max] = range.split('-').map(Number);
                    if (ori === "right") {
                        var rectX = yscale(max);
                        var rectWidth = yscale(min) - yscale(max);
                    } else {
                        var rectX = yscale(min);
                        var rectWidth = yscale(max) - yscale(min);
                    }

                    var cumulativeLength = branch.length;
                    var currentBranch = branch;
                    var parentCount = 0;

                    while (currentBranch.parent && (min > cumulativeLength)) {
                        cumulativeLength += currentBranch.parent.length;
                        currentBranch = currentBranch.parent;
                        parentCount++;
                    }

                    var rectY = branch.x;
                    var tempBranch = branch;
                    for (var i = 0; i < parentCount; i++) {
                        tempBranch = tempBranch.parent;
                        rectY = tempBranch.x;
                    }

                    vis.append('rect')
                        .attr("class", "wgd_rect")
                        .attr('x', rectX)
                        .attr('y', rectY - 6)
                        .attr('width', rectWidth)
                        .attr('height', 12)
                        .attr('fill', speciesColor)
                        // .attr('fill-opacity', 0.7)
                        .attr("data-tippy-content", () => {
                            return "WGD in <font color='red'><i><b>" + item.species + "</b></i></font>" +
                                ": <br><font color='#73BF00'>" + numFormatter(min * 100) +
                                "</font> - <font color='orange'>" + numFormatter(max * 100) + "</font> MYA";
                        });
                    tippy(".wgd_rect", { trigger: "mouseenter", followCursor: "initial", allowHTML: true, delay: [200, null] });
                } else {
                    var posX = yscale(range);
                    var cumulativeLength = branch.length;
                    var currentBranch = branch;
                    var parentCount = 0;

                    while (currentBranch.parent && (parseFloat(range) > cumulativeLength)) {
                        cumulativeLength += currentBranch.parent.length;
                        currentBranch = currentBranch.parent;
                        parentCount++;
                    }

                    var rectY = branch.x;
                    var tempBranch = branch;
                    for (var i = 0; i < parentCount; i++) {
                        tempBranch = tempBranch.parent;
                        rectY = tempBranch.x;
                    }
                    vis.append('line')
                        .attr("class", "wgd_line")
                        .attr('x1', posX)
                        .attr('x2', posX)
                        .attr('y1', rectY - 6)
                        .attr('y2', rectY + 6)
                        .attr("stroke-width", 2)
                        .attr('stroke', speciesColor)
                        // .attr('fill-opacity', 0.7)
                        .attr("data-tippy-content", () => {
                            return "WGD in <font color='red'><i><b>" + item.species + "</b></i></font>" +
                                ": <br><font color='#73BF00'>" + numFormatter(range * 100) + "</font> MYA";
                        });
                    tippy(".wgd_line", { trigger: "mouseenter", followCursor: "initial", allowHTML: true, delay: [200, null] });
                }
            }
        });
    }

    // draw geologic time scale
    drawGeologicTimeBar(maxLength, vis, yscale, h, ori);
}

function buildUltrametricTree(selector, vis, ultrametricTreeJson, longestXLabelLength, w, h, ori, ratio) {
    if (ori === "right") {
        var tree = d3.layout.cluster()
            .size([h, w])
            .separation(function (a, b) {
                return 1;
            })
            .sort(function (node) {
                return node.children ? node.children.length : -1;
            })
            .children(function (node) {
                return node.branchset
            });

        var diagonal = rightAngleDiagonal();
        var nodes = tree(ultrametricTreeJson);
    } else {
        var tree = d3.layout.cluster()
            .size([h, w * ratio * 0.8])
            .separation(function (a, b) {
                return 1;
            })
            .sort(function (node) {
                return node.children ? node.children.length : -1;
            })
            .children(function (node) {
                return node.branchset
            });

        var diagonal = ultrametriAngleDiagonal(w);
        var nodes = tree(ultrametricTreeJson);
    }

    var node = vis.selectAll("g.node")
        .data(nodes)
        .enter().append("svg:g")
        .attr("class", function (n) {
            if (n.children) {
                if (n.depth == 0) {
                    return "root node"
                } else {
                    return "inner node"
                }
            } else {
                return "leaf node"
            }
        })
        .attr("transform", function (d) { return "translate(" + d.y + "," + d.x + ")"; })

    /*     vis.selectAll('g.root.node')
            .append('line')
            .attr('stroke', '#aaa')
            .attr('stroke-width', 2.45)
            .attr('x1', 0)
            .attr('y1', 0)
            .attr('x2', function () {
                if (ori === "right") {
                    return -10;
                } else {
                    return 10;
                }
            })
            .attr('y2', 0) */

    d3.select('.leaf-pop-up-menu').remove();
    var leafPopUpMenu = d3.select(selector).append('div')
        .classed('leaf-pop-up-menu', true)
        .style('position', 'absolute')
        .style('top', 0)
        .style('left', 0)
        .style('visibility', 'hidden')
        .style('background-color', 'white')
        .style('border', '1px solid black')
        .style('padding', '5px');

    vis.selectAll('g.leaf.node')
        .append("svg:text")
        .attr("class", "my-text")
        .attr("dx", function () {
            if (ori === "right") {
                return 8;
            } else {
                return w * ratio * 0.25 - longestXLabelLength * 5;
            }
        })
        .attr("dy", 3)
        .attr("text-anchor", function () {
            if (ori === "right") {
                return "start";
            } else {
                return "middle";
            }
        })
        .attr("font-size", "12px")
        .attr('fill', 'black')
        .text(function (d) {
            var name = d.name.replace(/_/g, ' ').replace(/(\w)\w+_(\w+)/, "$1. $2");;
            return name;
        })
        .attr('font-style', 'italic')
        .on("mouseover", function () {
            ribbonEnterTime = new Date().getTime();
            d3.select(this)
                .transition()
                .delay(100)
                .duration(50)
                .attr("fill", "#E1E100")
        })
        .on("mouseout", function () {
            ribbonOutTime = new Date().getTime();
            if (ribbonOutTime - ribbonEnterTime <= 1000) {
                d3.select(this)
                    .transition()
                    .duration(50)
                    .attr("fill", "black")
            }
        })
        .on('click', function (d) {
            if (leafPopUpMenu.style('visibility') == 'visible') {
                leafPopUpMenu.style('visibility', 'hidden');
            } else {
                var name = d.name.replace(/_/g, ' ');

                leafPopUpMenu.html("<p><font color='#00DB00'><i>" + name + "</i></font>" +
                    "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" +
                    "<button id='close-btn-leaf' onclick='closeLeafPopUp()'>&times;</button></p>" +
                    "<p>Choose a color:</p>" +
                    "<div id='color-options'></div>"); // +
                /* "<p></p>" +
                "<p>Choose a symbol:" +
                "<div id='symbol-options'></div>"); */

                d3.select('#close-btn-leaf').on('click', closeLeafPopUp);
                function closeLeafPopUp() {
                    leafPopUpMenu.style('visibility', 'hidden');
                };

                var colors = ['#FF0000', '#00FF00', '#0000FF', '#FFA500', '#800080', '#FFC0CB', 'black'];
                var textElement = d3.select(this.parentNode).select('.my-text').node();
                // console.log("textElement", textElement)
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
                    .on('click', function (d) {
                        d3.select(textElement).style('fill', d);
                        leafPopUpMenu.style('visibility', 'hidden');
                    });

                /* var symbols = [
                    { name: 'Circle', type: 'circle' },
                    { name: 'Cross', type: 'cross' },
                    { name: 'Diamond', type: 'diamond' },
                    { name: 'Square', type: 'square' },
                    { name: 'Triangle Up', type: 'triangle-up' }
                ];

                var clickedLeafNode = this;
                var symbolOptions = d3.select('#symbol-options')
                    .selectAll('div')
                    .data(symbols)
                    .enter()
                    .append('div')
                    .style('cursor', 'pointer')
                    .style('width', '30px')
                    .style('height', '30px')
                    .style('margin-right', '3px')
                    .style('float', 'left')
                    .append('svg')
                    .attr('width', '60')
                    .attr('height', '60')
                    .append('path')
                    .attr('transform', 'translate(15, 15)')
                    .attr('d', function (d) {
                        if (d.type === 'circle') {
                            return d3.svg.symbol().type('circle')();
                        } else if (d.type === 'cross') {
                            return d3.svg.symbol().type('cross')();
                        } else if (d.type === 'diamond') {
                            return d3.svg.symbol().type('diamond')();
                        } else if (d.type === 'square') {
                            return d3.svg.symbol().type('square')();
                        } else if (d.type === 'triangle-up') {
                            return d3.svg.symbol().type('triangle-up')();
                        }
                    })
                    .attr('stroke', '#707038')
                    .attr('fill', '#707038')
                    .on('click', function (d) {
                        var leafNode = clickedLeafNode.parentNode;
                        var symbol = d3.svg.symbol().type(d.type)
                        var styleAttr = d3.select(clickedLeafNode).attr('style');
                        var match = styleAttr.match(/fill:\s*(.*?);/);
                        var textColor = match[1];
                        d3.select(leafNode)
                            .append('path')
                            .attr('d', symbol)
                            .attr('stroke', textColor)
                            .attr('fill', textColor)
                            .attr('stroke-width', '1px');
                    }); */

                const transformAttributeValue = d3.select(this.parentNode).attr("transform");
                const match = transformAttributeValue.match(/translate\(([\d.-]+),([\d.-]+)\)/);
                const xx = parseFloat(match[1]);
                const yy = parseFloat(match[2]);
                leafPopUpMenu.style('left', (xx + 200) + 'px')
                    .style('top', (yy - 5) + 'px')
                    .style('visibility', 'visible');
            }
        });
    tippy(".my-text rect", { trigger: "mouseenter", followCursor: "initial", allowHTML: true, delay: [200, null] });

    d3.select('.path-pop-up-menu').remove();
    var popUpMenu = d3.select(selector).append('div')
        .classed('path-pop-up-menu', true)
        .style('position', 'absolute')
        .style('top', 0)
        .style('left', 0)
        .style('visibility', 'hidden')
        .style('background-color', 'white')
        .style('border', '1px solid black')
        .style('padding', '5px');

    var link = vis.selectAll("path.link")
        .data(tree.links(nodes))
        .enter().append("path")
        .attr("class", "link")
        .attr("d", diagonal)
        .attr("fill", "none")
        .attr("stroke", "#aaa")
        .attr("stroke-width", "2.45px")
        .on("mouseover", function () {
            ribbonEnterTime = new Date().getTime();
            d3.select(this)
                .transition()
                .delay(100)
                .duration(50)
                .attr("stroke", "#E1E100")
                .attr("stroke-width", "4px")
        })
        .on("mouseout", function () {
            ribbonOutTime = new Date().getTime();
            if (ribbonOutTime - ribbonEnterTime <= 1000) {
                d3.select(this)
                    .transition()
                    .duration(50)
                    .attr("stroke", "#aaa")
                    .attr("stroke-width", "2.45px")
            }
        })
        .on('click', function (d) {
            if (popUpMenu.style('visibility') == 'visible') {
                popUpMenu.style('visibility', 'hidden');
            } else {
                popUpMenu.html("<p>Add <font color='#00DB00'>WGD Events</font> within this clade" +
                    "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<button id='close-btn' onclick='closePopUp()'>&times;</button></p>" +
                    "<p><font color='#A6A600'>Set how many WGD events to place: </font></p>" +
                    "<input type='text' id='time-input'>" +
                    "<p>Choose a color:</p>" +
                    "<div id='color-wgd-options'></div>" +
                    "<p></p>"
                );

                d3.select('#close-btn').on('click', closePopUp());
                function closePopUp() {
                    popUpMenu.style('visibility', 'hidden');
                };

                var clickedPath = this;
                var pathData = clickedPath.getAttribute('d');
                var pathArray = pathData.split(' ');
                var yValue = pathArray[2].split(',')[1];
                var middleXpos = (Number(pathArray[2].split(',')[0]) + Number(pathArray[1].split(',')[0])) / 2;

                var colors = ['#FF0000', '#00FF00', '#0000FF', '#FFA500', '#800080', '#FFC0CB', 'black'];
                var colorOptions = d3.select('#color-wgd-options')
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
                        var timeInput = document.getElementById('time-input').value;
                        var color = d3.select(this).style('background-color');

                        if (!timeInput || isNaN(timeInput)) {
                            Swal.fire({
                                icon: 'error',
                                title: 'Oops...',
                                html: 'Please enter a valid number in <span style="color: #A6A600;">Set how many WGD events to place</span> field first.',
                            });
                            return;
                        }

                        for (var i = 1; i <= timeInput; i++) {
                            var rectangleWidth = 10;
                            var rectangleHeight = 20;
                            var spacing = 15;

                            d3.select(clickedPath.parentNode)
                                .append('rect')
                                .attr('x', middleXpos - (timeInput * spacing / 2) + (i - 1) * spacing)
                                .attr('y', yValue - rectangleHeight / 2)
                                .attr('width', rectangleWidth)
                                .attr('height', rectangleHeight)
                                .attr('fill', color);
                        }
                        popUpMenu.style('visibility', 'hidden');
                    });


                /*                 d3.select(clickedPath.parentNode).append('line')
                                    .attr('x1', textElement.attr('x'))
                                    .attr('x2', textElement.attr('x'))
                                    .attr('y1', Number(yValue) - 1)
                                    .attr('y2', Number(yValue) - 6)
                                    .style('stroke', buttonColor)
                                    .style('stroke-width', '2px'); */

                /* d3.selectAll('.symbol-btn').on('click', function () {
                    var symbolText = this.innerHTML;
                    var symbolText = this.innerHTML.match(/<b style=\"-webkit-user-select: auto;\">(.*?)<\/b>/)[1];
                    var buttonColor = this.innerHTML.match(/<font color=\"(.*?)\" style=\"-webkit-user-select: auto;\">/)[1];
                    var textElement = d3.select(clickedPath.parentNode).append('text')
                        .text(symbolText)
                        .attr('x', function () {
                            var maxLength = getMaxNodeLength(nodes);
                            if (ori === 'right') {
                                var yScaleNew = d3.scale.linear()
                                    .domain([0, maxLength])
                                    .range([0, w]);
                            } else {
                                var yScaleNew = d3.scale.linear()
                                    .domain([0, maxLength])
                                    .range([w, w * ratio]);
                            }
                            return yScaleNew(maxLength - timeInput.value / 100);
                        })
                        .attr('y', Number(yValue) - 12)
                        .style('font-size', '18px')
                        .attr("text-anchor", "middle")
                        .style('fill', buttonColor)
                        .style('opacity', 0.9)

                    var line = d3.select(clickedPath.parentNode).append('line')
                        .attr('x1', textElement.attr('x'))
                        .attr('x2', textElement.attr('x'))
                        .attr('y1', Number(yValue) - 1)
                        .attr('y2', Number(yValue) - 6)
                        .style('stroke', buttonColor)
                        .style('stroke-width', '2px');

                    closePopUp();
                }); */

                popUpMenu.style('left', (middleXpos + 100) + 'px')
                    .style('top', (Number(yValue) + 40) + 'px')
                    .style('visibility', 'visible');
            }
        });

    // Move the created paths to the bottom of the SVG
    vis.selectAll("path.link").each(function () {
        var firstChild = this.parentNode.firstChild;
        if (firstChild) {
            this.parentNode.insertBefore(this, firstChild);
        }
    });

}

function buildSpeciesTree(selector, vis, speciesTreeJson, wgdNodesInfo, w, h, ori, ratio) {
    if (ori === "right") {
        var tree = d3.layout.cluster()
            .size([h, w])
            .separation(function (a, b) {
                return 1;
            })
            .sort(function (node) {
                return node.children ? node.children.length : -1;
            })
            .children(function (node) {
                return node.branchset
            });

        var diagonal = rightAngleDiagonal();
        var nodes = tree(speciesTreeJson);
    } else {
        var tree = d3.layout.cluster()
            .size([h, w * ratio * 0.8])
            .separation(function (a, b) {
                return 1;
            })
            .sort(function (node) {
                return node.children ? node.children.length : -1;
            })
            .children(function (node) {
                return node.branchset
            });

        var diagonal = ultrametriAngleDiagonal(w);
        var nodes = tree(speciesTreeJson);
    }

    var node = vis.selectAll("g.node")
        .data(nodes)
        .enter().append("svg:g")
        .attr("class", function (n) {
            if (n.children) {
                if (n.depth == 0) {
                    return "root node"
                } else {
                    return "inner node"
                }
            } else {
                return "leaf node"
            }
        })
        .attr("transform", function (d) { return "translate(" + d.y + "," + d.x + ")"; })

    vis.selectAll('g.leaf.node')
        .append("svg:text")
        .attr("class", "my-text")
        .attr("dx", function () {
            if (ori === "right") {
                return 8;
            } else {
                return w * ratio * 0.25 - longestXLabelLength * 5;
            }
        })
        .attr("dy", 3)
        .attr("text-anchor", function () {
            if (ori === "right") {
                return "start";
            } else {
                return "middle";
            }
        })
        .attr("font-size", "14px")
        .attr('fill', 'black')
        .text(function (d) {
            var name = d.name.replace(/_/g, ' ').replace(/(\w)\w+_(\w+)/, "$1. $2");;
            return name;
        })
        .attr('font-style', 'italic')
        .on("mouseover", function () {
            ribbonEnterTime = new Date().getTime();
            d3.select(this)
                .transition()
                .delay(100)
                .duration(50)
                .attr("fill", "#E1E100")
        })
        .on("mouseout", function () {
            ribbonOutTime = new Date().getTime();
            if (ribbonOutTime - ribbonEnterTime <= 1000) {
                d3.select(this)
                    .transition()
                    .duration(50)
                    .attr("fill", "black")
            }
        });
    tippy(".my-text rect", { trigger: "mouseenter", followCursor: "initial", allowHTML: true, delay: [200, null] });

    d3.select('.path-pop-up-menu').remove();
    var popUpMenu = d3.select(selector).append('div')
        .classed('path-pop-up-menu', true)
        .style('position', 'absolute')
        .style('top', 0)
        .style('left', 0)
        .style('visibility', 'hidden')
        .style('background-color', 'white')
        .style('border', '1px solid black')
        .style('padding', '5px');

    var wgdInput = new Set();
    var link = vis.selectAll("path.link")
        .data(tree.links(nodes))
        .enter().append("svg:path")
        .attr("class", "link")
        .attr("d", diagonal)
        .attr("fill", "none")
        .attr("stroke", "#aaa")
        .attr("stroke-width", "2.45px")
        .on("mouseover", function () {
            ribbonEnterTime = new Date().getTime();
            d3.select(this)
                .transition()
                .delay(100)
                .duration(50)
                .attr("stroke", "#E1E100")
                .attr("stroke-width", "4px")
        })
        .on("mouseout", function () {
            ribbonOutTime = new Date().getTime();
            if (ribbonOutTime - ribbonEnterTime <= 1000) {
                d3.select(this)
                    .transition()
                    .duration(50)
                    .attr("stroke", "#aaa")
                    .attr("stroke-width", "2.45px")
            }
        })
        .on('click', function (d) {
            if (popUpMenu.style('visibility') == 'visible') {
                popUpMenu.style('visibility', 'hidden');
            } else {
                function flattenArray(arr) {
                    var flattened = [];
                    arr.forEach(function (item) {
                        if (Array.isArray(item)) {
                            flattened = flattened.concat(flattenArray(item));
                        } else {
                            flattened.push(item);
                        }
                    });
                    return flattened;
                }

                function traverseChildren(target) {
                    var names = [];
                    if (target.children && target.children.length > 0) {
                        for (var i = 0; i < target.children.length; i++) {
                            var child = target.children[i];
                            var name = traverseChildren(child);
                            if (name) {
                                names.push(name);
                            }
                        }
                    } else {
                        names.push(target.name)
                    }
                    return names;
                }

                var names = traverseChildren(d.target);
                if (names.length > 1) {
                    var names = flattenArray(names);
                    var species1 = names[0];
                    var species2 = names[names.length - 1];
                } else {
                    var species1 = names[0];
                    var species2 = names[0];
                }

                popUpMenu.html("<p>Add a <font color='#00DB00'>Hypothetical WGD</font> event to this clade" +
                    "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<button id='close-btn-two' onclick='closePopUpTwo()'>&times;</button></p>" +
                    "<p><font color='#A6A600'>Set a Name: </font>" +
                    "<input type='text' id='name-input'>" +
                    "&nbsp;&nbsp;&nbsp;&nbsp;<button class='symbol-btn'><font color='#66c2a5'><b><b>&#43;</b></b></font></button>" +
                    "<p>Note: Input should start with 'wgd' followed by a number </p>" +
                    "<p>e.g., 'wgd1', 'wgd2'."
                );

                var closeButton = document.getElementById('close-btn-two');
                closeButton.addEventListener('click', closePopUpTwo);
                function closePopUpTwo() {
                    popUpMenu.style('visibility', 'hidden');
                }

                var clickedPath = this;
                var pathData = clickedPath.getAttribute('d');
                var pathArray = pathData.split(' ');

                // Extract the x-coordinates from the pathArray
                var xCoords = pathArray.map(function (coord) {
                    return parseFloat(coord.split(',')[0]);
                });
                // Calculate the middle x-coordinate
                var xValue = (xCoords[1] + xCoords[2]) / 2;
                var yValue = pathArray[2].split(',')[1];

                var nameInput = document.getElementById('name-input');

                // Add an event listener to the input field
                nameInput.addEventListener('blur', function () {
                    var inputValue = nameInput.value;

                    var rule = /^wgd\d+$/;

                    if (!rule.test(inputValue)) {
                        popUpMenu.style('visibility', 'hidden');
                        nameInput.value = '';
                        // var warningMessage = "Input should start with 'wgd' followed by a number (e.g., 'wgd1', 'wgd2').";
                        Swal.fire({
                            icon: 'error',
                            title: 'Oops...',
                            html: 'Input should start with \'<span style="color: #A6A600;"><b>wgd</b></span>\' followed by a number (e.g., \'<span style="color: #A6A600;"><b>wgd1</b></span>\', \'<span style="color: #A6A600;"><b>wgd2</b></span>\').',
                        });
                        // alert(warningMessage);
                    } else {
                        d3.selectAll('.symbol-btn').on('click', function () {
                            var rectWidth = 18;
                            var rectHeight = 18;
                            var rectElement = d3.select(clickedPath.parentNode)
                                .append("rect")
                                .attr('class', 'testWgd')
                                .attr('x', xValue - 9)
                                .attr('y', yValue - 9)
                                .attr('width', rectWidth)
                                .attr('height', rectHeight)
                                .style('fill', 'white')
                                .style('stroke', '#F75000')
                                .style('stroke-width', 2.5)
                                .attr("data-tippy-content", (d) => {
                                    return nameInput.value;
                                });

                            var nameElment = d3.select(clickedPath.parentNode)
                                .append("text")
                                .attr('class', 'testWgd')
                                .attr("x", xValue)
                                .attr("y", yValue - 20)
                                .text(function () {
                                    var enteredText = nameInput.value;
                                    return enteredText;
                                })
                                .attr("text-anchor", "middle")
                                .attr("font-size", "13px")
                                .attr("data-tippy-content", (d) => {
                                    return "text:" + nameInput.value;
                                });

                            closePopUpTwo();

                            var wgdName = nameInput.value;
                            if (wgdInput.size > 0) {
                                wgdInput.add("\n" + wgdName + ": " + species1 + " - " + species2);
                            } else {
                                wgdInput.add(wgdName + ": " + species1 + " - " + species2);
                            }
                            Shiny.onInputChange("wgdInput", Array.from(wgdInput));
                        });
                    }
                });

                d3.select('#close-btn-two').on('click', closePopUpTwo);
                function closePopUpTwo() {
                    popUpMenu.style('visibility', 'hidden');
                };

                popUpMenu.style('left', (xValue + 100) + 'px')
                    .style('top', (Number(yValue) + 40) + 'px')
                    .style('visibility', 'visible');

                /* popUpMenu.style('left', (d3.event.pageX + 10) + 'px')
                    .style('top', (d3.event.pageY - 10) + 'px')
                    .style('visibility', 'visible'); */
            }
        });

    // Move the created paths to the bottom of the SVG
    vis.selectAll("path.link").each(function () {
        var firstChild = this.parentNode.firstChild;
        if (firstChild) {
            this.parentNode.insertBefore(this, firstChild);
        }
    });

    // draw geologic time scale
    /*     if (maxLength > 20) {
            console.log("maxLength / 100", maxLength / 100)
            drawGeologicTimeBar(maxLength / 100, vis, yscale, h, ori);
        } else {
            
        } */
    downloadSVG("speciesTreePlotDownload", "speciesTree_plot", "whale_hypothesis.speciesTree.svg");

    // drawGeologicTimeBar(maxLength, vis, yscale, h, ori);
}

function extractNames(obj) {
    var names = [];

    if (obj.name) {
        names.push(obj.name);
    }

    if (obj.children && Array.isArray(obj.children)) {
        obj.children.forEach(function (child) {
            names = names.concat(extractNames(child));
        });
    }

    if (obj.branchset && Array.isArray(obj.branchset)) {
        obj.branchset.forEach(function (branch) {
            names = names.concat(extractNames(branch));
        });
    }

    return names;
}

function scaleBranchLengths(nodes, w) {
    // Visit all nodes and adjust y pos width distance metric
    var visitPreOrder = function (root, callback) {
        callback(root)
        if (root.children) {
            for (var i = root.children.length - 1; i >= 0; i--) {
                visitPreOrder(root.children[i], callback)
            };
        }
    }
    visitPreOrder(nodes[0], function (node) {
        node.rootDist = (node.parent ? node.parent.rootDist : 0) + (node.length || 0)
    })
    var rootDists = nodes.map(function (n) {
        return n.rootDist;
    });

    var yscale = d3.scale.linear()
        .domain([0, d3.max(rootDists)])
        .range([0, w]);

    visitPreOrder(nodes[0], function (node) {
        node.y = parseInt(yscale(node.rootDist));
    })
    return yscale
}

function scaleLeftBranchLengths(nodes, w, ratio) {
    // Visit all nodes and adjust y pos width distance metric
    var visitPreOrder = function (root, callback) {
        callback(root)
        if (root.children) {
            for (var i = root.children.length - 1; i >= 0; i--) {
                visitPreOrder(root.children[i], callback)
            };
        }
    }
    visitPreOrder(nodes[0], function (node) {
        node.rootDist = (node.parent ? node.parent.rootDist : 0) + (node.length || 0)
    })
    var rootDists = nodes.map(function (n) {
        return n.rootDist;
    });

    var yscale = d3.scale.linear()
        .domain([0, d3.max(rootDists)])
        .range([w, w * ratio]);

    visitPreOrder(nodes[0], function (node) {
        node.y = parseInt(yscale(node.rootDist));
    })
    return yscale
}

function scaleUltrameticLeftBranchLengths(nodes, w, ratio) {
    // Find the maximum depth in the tree
    var maxDepth = 0;
    nodes.forEach(function (node) {
        if (node.depth > maxDepth) {
            maxDepth = node.depth;
        }
    });

    // Visit all nodes and adjust y pos with distance metric
    var visitPreOrder = function (root, callback) {
        callback(root);
        if (root.children) {
            for (var i = root.children.length - 1; i >= 0; i--) {
                visitPreOrder(root.children[i], callback);
            }
        }
    };

    // Calculate rootDist based on proportional depth for leaf nodes and constant length for internal nodes
    visitPreOrder(nodes[0], function (node) {
        // node.rootDist = (node.parent ? node.parent.rootDist : 0) + 100;
        if (!node.children || !node.children.length) {
            if (node.depth !== maxDepth) {
                // revise the distance to root of its parent node
                node.parent.rootDist = maxDepth - 1;
                if (node.parent.parent) {
                    node.parent.parent.rootDist = maxDepth - node.depth;

                    let currentParent = node.parent.parent;
                    while (currentParent && currentParent.parent) {
                        if (currentParent.parent.rootDist) {
                            currentParent.parent.rootDist = currentParent.rootDist - 1;
                        }
                        currentParent = currentParent.parent;
                    }
                } else {
                    node.parent.rootDist = 0;
                }
            }
            node.rootDist = maxDepth;
        }
        /*         if (!node.rootDist) {
                    node.rootDist = (node.parent ? node.parent.rootDist : 0) + 1;
                } */
        // else {
        //  node.rootDist = (node.parent ? node.parent.rootDist : 0) + 1;
        // }
    });


    var rootDists = nodes.map(function (n) {
        return n.rootDist;
    });

    var yscale = d3.scale.linear()
        .domain([0, d3.max(rootDists)])
        .range([w, w * ratio]);
    // .range([w * ratio, w]);

    visitPreOrder(nodes[0], function (node) {
        node.y = parseInt(yscale(node.rootDist));
    });

    return yscale;
}

function rightAngleDiagonal() {
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

function leftAngleDiagonal() {
    var projection = function (d) {
        return [d.y, d.x];
    };

    var path = function (pathData) {
        return "M" + pathData[0] + " " + pathData[1] + " " + pathData[2];
    };

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

function ultrametriAngleDiagonal(w) {
    var projection = function (d) {
        return [w - d.y, d.x];
    }
    var path = function (pathData) {
        return "M" + pathData[0] + ' ' + pathData[1] + " " + pathData[2];
    }
    function diagonal(diagonalPath, i) {
        var source = diagonalPath.source;
        var target = diagonalPath.target;
        var pathData = [source, { x: target.x, y: source.y }, target];
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


function styleTreeNodes(vis) {
    vis.selectAll('g.leaf.node')
        .append("svg:diamond")
        .attr("r", 4.5)
        .attr('stroke', 'yellowGreen')
        .attr('fill', 'greenYellow')
        .attr('stroke-width', '2px');

    vis.selectAll('g.root.node')
        .append('svg:circle')
        .attr("r", 4.5)
        .attr('fill', 'steelblue')
        .attr('stroke', '#369')
        .attr('stroke-width', '2px');
}

function drawGeologicTimeBar(maxLength, vis, yscale, h, ori) {
    const geologicData = [
        { name: 'Quaternary', start: 0, end: 2.6 },
        { name: 'Neogene', start: 2.6, end: 23 },
        { name: 'Paleogene', start: 23, end: 66 },
        { name: 'Cretaceous', start: 66, end: 145 },
        { name: 'Jurassic', start: 145, end: 201.4 },
        { name: 'Triassic', start: 201.4, end: 251.9 },
        { name: 'Permian', start: 251.9, end: 298.9 },
        { name: 'Carboniferous', start: 298.9, end: 358.9 },
        { name: 'Devonian', start: 358.9, end: 419.2 },
        { name: 'Silurian', start: 419.2, end: 443.8 },
        { name: 'Ordovician', start: 443.8, end: 485.4 },
        { name: 'Cambrian', start: 485.4, end: 538.8 },
        { name: 'Ediacaran', start: 538.8, end: 635 },
        { name: 'Cryogenian', start: 635, end: 720 },
        { name: 'Tonian', start: 720, end: 1000 }
    ];

    var drawTimeData = geologicData
        .filter(function (d) {
            if (ori === "right") {
                return d.end < Math.ceil((maxLength * 100) / 10) * 10;
            } else {
                return d.start < Math.ceil((maxLength * 100) / 10) * 10;
            }
        });

    var lastElement = Object.assign({}, geologicData[drawTimeData.length]);
    lastElement.end = Math.ceil((maxLength * 100) / 10) * 10;

    drawTimeData = drawTimeData.concat(lastElement);

    var color = d3.scale.ordinal()
        .domain(["Quaternary", "Neogene", "Paleogene", "Cretaceous", "Jurassic",
            "Triassic", "Permian", "Carboniferous", "Devonian", "Silurian", "Ordovician",
            "Cambrian", "Ediacaran", "Cryogenian", "Tonian"])
        .range(["#a6cee3", "#1f78b4", "#b2df8a", "#33a02c", "#fb9a99",
            "#e31a1c", "#fdbf6f", "#ff7f00", "#cab2d6", "#6a3d9a", "#ffff99",
            "#AE8F00", "#737300", "#9D9D9D", "#5B5B5B"]);

    var popUpMenu = d3.select('body').append('div')
        .style('position', 'absolute')
        .style('top', 0)
        .style('left', 0)
        .style('visibility', 'hidden')
        .style('background-color', 'white')
        .style('border', '1px solid black')
        .style('padding', '5px');

    // Add the bars
    vis.selectAll('.time_rect')
        .data(drawTimeData)
        .enter().append("svg:g")
        .attr('class', 'time_rect')
        .append('rect')
        .attr('x', function (d) {
            if (ori === "right") {
                return yscale(d.end / 100);
            } else {
                return yscale(d.start / 100);
            }
        })
        .attr('y', h + 18)
        .attr('width', function (d) {
            if (ori === "right") {
                return yscale(d.start / 100) - yscale(d.end / 100);
            } else {
                return yscale(d.end / 100) - yscale(d.start / 100);
            }
        })
        .attr('height', 18)
        .style("fill", function (d) { return color(d.name); })
        .attr("data-tippy-content", (d) => {
            var trueDate = geologicData.filter(function (item) {
                return item.name === d.name
            });
            if (ori === "right") {
                return "<font color='#4DFFFF'>" + d.name + "</font>: <font color='orange'>" + trueDate[0].end
                    + "</font> <b>&#8656</b> <font color='#00DB00'>"
                    + trueDate[0].start + "</font>";
            } else {
                return "<font color='#4DFFFF'>" + d.name + "</font>: <font color='#00DB00'>" + trueDate[0].start
                    + "</font> <b>&#8658</b> <font color='orange'>"
                    + trueDate[0].end + "</font>";
            }
        })
        .on('click', function (d) {
            if (popUpMenu.style('visibility') == 'visible') {
                popUpMenu.style('visibility', 'hidden');
            } else {
                popUpMenu.html("<p>Add a <font color='#4DFFFF'>shape</font> to highlight a geologic time period" +
                    "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<button id='close-btn-t' onclick='closePopUp()'>&times;</button></p>" +
                    "<p><font color='#00DB00'>Set the start time: </font>" +
                    "<input type='text' id='time-input-start'>" +
                    "<font color='#00DB00'> Mya</font>" +
                    "<p></p>" +
                    "<p><font color='orange'>Set the end time: </font>" +
                    "<input type='text' id='time-input-end'>" +
                    "<font color='orange'> Mya</font>" +
                    "<p><button class='add-btn'><font color='#66c2a5'>Add Shape</b></font></button>"
                );

                d3.select('#close-btn-t').on('click', closePopUp);
                function closePopUp() {
                    popUpMenu.style('visibility', 'hidden');
                };

                var clickedPath = d3.select(this);
                var timePeriodRect = d3.selectAll('.add-btn').on('click', function () {
                    var timeInputStart = document.getElementById('time-input-start').value;
                    var timeInputEnd = document.getElementById('time-input-end').value;
                    var x1 = yscale(timeInputStart / 100);
                    var x2 = yscale(timeInputEnd / 100);
                    if (ori === "right") {
                        var rectWidth = (x1 - x2);
                    } else {
                        var rectWidth = (x2 - x1);
                    }
                    var rectStyle = clickedPath.attr('style');
                    var fillColorRegex = /fill:\s*(.*?);/;
                    var colormatch = fillColorRegex.exec(rectStyle)[1];

                    vis.append('rect')
                        .attr('class', 'time_rect')
                        .attr('x', function () {
                            if (ori === "right") {
                                return x2;
                            } else {
                                return x1;
                            }
                        })
                        .attr('y', 0)
                        .attr('width', rectWidth)
                        .attr('height', h)
                        .style('fill', colormatch)
                        .style('opacity', 0.3)
                        .attr("data-tippy-content", function (d) {
                            if (ori === "right") {
                                return "<font color='#4DFFFF'>Time period</font>: <font color='orange'>" + timeInputEnd
                                    + "</font> <b>&#8656</b> <font color='#00DB00'>"
                                    + timeInputStart + "</font>";
                            } else {
                                return "<font color='#4DFFFF'>Time period</font>: <font color='orange'>" + timeInputStart
                                    + "</font> <b>&#8658</b> <font color='#00DB00'>"
                                    + timeInputEnd + "</font>";
                            }
                        })
                        .style('-webkit-user-select', 'initial')
                        .on('mouseover', function (event) {
                            tippy(event.target, {
                                allowHTML: true,
                                arrow: true,
                                content: event.target.getAttribute('data-tippy-content'),
                                placement: 'bottom',
                            }).show();
                        })
                        .on('mouseout', function (event) {
                            var tooltip = tippy(event.target).get(0);
                            if (tooltip) {
                                tooltip.hide();
                            }
                        });

                    popUpMenu.style('visibility', 'hidden');
                });
                //tippy(".time_shape_rect", { trigger: "mouseenter", followCursor: "initial", allowHTML: true, delay: [200, null] });

                d3.select('#close-btn-t').on('click', closePopUp);
                function closePopUp() {
                    popUpMenu.style('visibility', 'hidden');
                };

                popUpMenu.style('left', (d3.event.pageX + 10) + 'px')
                    .style('top', (d3.event.pageY - 10) + 'px')
                    .style('visibility', 'visible');
            }
        });
    tippy(".time_rect rect", { trigger: "mouseenter", followCursor: "initial", allowHTML: true, delay: [200, null] });

    // Add the labels for each bar
    vis.selectAll('.bar-label')
        .data(drawTimeData)
        .enter().append('text')
        .attr('class', 'bar_label')
        .attr('x', function (d) {
            var barWidth = yscale(d.end / 100) - yscale(d.start / 100);
            var translateX = yscale(d.start / 100) + barWidth / 2;
            if (d.start == 0) {
                if (ori === 'right') {
                    translateX += 30;
                } else {
                    translateX = yscale(d.start) - 25;
                }
            }
            return translateX;
        })
        .attr('y', h + 31)
        .text(function (d) { return d.name; })
        .attr("text-anchor", "middle")
        .attr("font-size", "9px")
        .attr("font-weight", "bold")
        .attr('fill', function (d) {
            if (d.start == 0) {
                return '#a6cee3';
            } else {
                return '#3C3C3C';
            }
        });

    // Add the x axis
    /* */// Use the d3 v3 function for the x axis

    /*     // Add the y axis
        svg.append('g')
            .attr('class', 'y axis')
            .call(yAxis);  */
}

function getMaxNodeLength(nodes) {
    let maxLength = 0;
    for (let i = 0; i < nodes.length; i++) {
        const nodeLength = nodes[i].rootDist;
        if (nodeLength > maxLength) {
            maxLength = nodeLength;
        }
    }
    return maxLength;
}

function downloadSVG(downloadButtonID, svgDivID, svgOutFile) {
    // Add event listener to the button
    // since some button are generated dynamically
    // need to be called each time the button was generated
    // give a condition to check the svg available

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

function phylogramBuild(selector, treeJson, wgdTableInfo, height, width) {

    // load the d3 v3
    var script = document.createElement('script');
    script.src = 'https://d3js.org/d3.v3.min.js';
    document.head.appendChild(script);
    script.onload = function () {
        var w = width;
        var h = height;

        var tree = d3.layout.cluster()
            .size([h, w])
            .separation(function (a, b) {
                return 1;
            })
            .sort(function (node) {
                return node.children ? node.children.length : -1;
            })
            .children(function (node) {
                return node.branchset
            });

        var diagonal = rightAngleDiagonal();
        d3.select(selector).select("svg").remove();
        var vis = d3.select(selector).append("svg:svg")
            .attr("width", w + 400)
            .attr("height", h + 100)
            .append("svg:g")
            .attr("transform", "translate(120, 20)");

        var nodes = tree(treeJson);

        var yscale = scaleBranchLengths(nodes, w).range([w, 0]);

        vis.selectAll('line')
            .data(yscale.ticks(11))
            .enter().append('svg:line')
            .attr('y1', 0)
            .attr('y2', h)
            .attr('x1', yscale)
            .attr('x2', yscale)
            .attr("stroke-dasharray", "4 1")
            .attr("stroke-width", 0.66)
            .attr("stroke-opacity", 0.2)
            .attr("stroke", "blue");

        vis.selectAll("text.rule")
            .data(yscale.ticks(11))
            .enter().append("svg:text")
            .attr("class", "rule")
            .attr("x", yscale)
            .attr("y", h + 15)
            .attr("dy", -3)
            .attr("text-anchor", "middle")
            .attr("font-size", "10px")
            .attr('fill', 'blue')
            .attr('opacity', 0.3)
            .text(function (d) { return (Math.round(d * 100) / 100 * 100).toFixed(0); });

        var legend = vis.append('g')
            .attr('class', 'legend')
            .append('text')
            .attr('x', w + 8)
            .attr('y', h + 12)
            .attr('text-anchor', 'start')
            .attr('font-size', '10px')
            .attr('fill', 'blue')
            .attr('opacity', 0.3)
            .text('million years ago');

        var node = vis.selectAll("g.node")
            .data(nodes)
            .enter().append("svg:g")
            .attr("class", function (n) {
                if (n.children) {
                    if (n.depth == 0) {
                        return "root node"
                    } else {
                        return "inner node"
                    }
                } else {
                    return "leaf node"
                }
            })
            .attr("transform", function (d) { return "translate(" + d.y + "," + d.x + ")"; })

        vis.selectAll('g.root.node')
            .append('svg:circle')
            .attr("r", 4.5)
            .attr('fill', 'steelblue')
            .attr('stroke', '#369')
            .attr('stroke-width', '2px');

        vis.selectAll('g.root.node')
            .append('text')
            .attr('fill', '#FF00FF')
            .attr("dx", -8)
            .attr("dy", 4.5)
            .attr("text-anchor", "end")
            .attr("font-size", "14px")
            .text("MRCA");

        // add a condition when hpd is missing
        // console.log("nodes", nodes);
        var filteredData = nodes.filter(function (d) {
            return d.hasOwnProperty("branchHPD") && d.branchHPD !== "";
        });
        var maxLength = getMaxNodeLength(nodes);
        if (filteredData.length === 0) {
            console.log("No 95% CI HPD data to visualize.");
        } else {
            vis.selectAll('g.root.node')
                .attr('class', 'hpd_rect')
                .append('rect')
                .attr('x', function (d) {
                    var x2 = parseFloat(d.branchHPD.match(/, ([\d\.]+)\}/)[1]);
                    var transformAttr = d3.select(this.parentNode).attr('transform');
                    var translate = transformAttr.match(/translate\(([\d\.]+),([\d\.]+)\)/);
                    var x = translate[1];
                    return yscale(x2) - x - 5;
                })
                .attr("y", -5)
                .attr('width', function (d) {
                    var x1 = parseFloat(d.branchHPD.match(/\{([\d\.]+),/)[1]);
                    var x2 = parseFloat(d.branchHPD.match(/, ([\d\.]+)\}/)[1]);
                    return yscale(x1) - yscale(x2);
                })
                .attr('height', 10)
                .attr('fill', '#707038')
                .attr('fill-opacity', 0.3)
                .attr("data-tippy-content", (d) => {
                    var x1 = parseFloat(d.branchHPD.match(/\{([\d\.]+),/)[1]);
                    var x2 = parseFloat(d.branchHPD.match(/, ([\d\.]+)\}/)[1]);
                    return "Divergence Time: <font color='red'>" + numFormatter(maxLength * 100) + "</font><br>" +
                        "95%CI = [<font color='#00DB00'>" + numFormatter(x1 * 100) +
                        ",</font> <font color='orange'>" + numFormatter(x2 * 100) + "</font>]";
                });

            vis.selectAll('g.inner.node')
                .attr('class', 'hpd_rect')
                .append('rect')
                .attr('x', function (d) {
                    // var x1 = parseFloat(d.branchHPD.match(/\{([\d\.]+),/)[1]);
                    var x2 = parseFloat(d.branchHPD.match(/, ([\d\.]+)\}/)[1]);
                    var transformAttr = d3.select(this.parentNode).attr('transform');
                    var translate = transformAttr.match(/translate\(([\d\.]+),([\d\.]+)\)/);
                    var x = translate[1];
                    return yscale(x2) - x;
                })
                .attr("y", -6)
                .attr('width', function (d) {
                    var x1 = parseFloat(d.branchHPD.match(/\{([\d\.]+),/)[1]);
                    var x2 = parseFloat(d.branchHPD.match(/, ([\d\.]+)\}/)[1]);
                    return yscale(x1) - yscale(x2);
                })
                .attr('height', 12)
                .attr('fill', '#707038')
                .attr('fill-opacity', 0.3)
                .attr("data-tippy-content", function (d) {
                    var x1 = parseFloat(d.branchHPD.match(/\{([\d\.]+),/)[1]);
                    var x2 = parseFloat(d.branchHPD.match(/, ([\d\.]+)\}/)[1]);
                    return "Divergence Time: <font color='red'>" + numFormatter((maxLength - d.rootDist) * 100) + " Mya</font>" +
                        "<br></font>95%CI = [<font color='#00DB00'>" + numFormatter(x1 * 100) +
                        ",</font> <font color='orange'>" + numFormatter(x2 * 100) + "</font>]";
                })

            tippy(".hpd_rect rect", { trigger: "mouseenter", followCursor: "initial", allowHTML: true, delay: [200, null] });
        }

        d3.select('.leaf-pop-up-menu').remove();
        var leafPopUpMenu = d3.select(selector).append('div')
            .classed('leaf-pop-up-menu', true)
            .style('position', 'absolute')
            .style('top', 0)
            .style('left', 0)
            .style('visibility', 'hidden')
            .style('background-color', 'white')
            .style('border', '1px solid black')
            .style('padding', '5px');

        vis.selectAll('g.leaf.node')
            .append("svg:text")
            .attr("class", "my-text")
            .attr("dx", 8)
            .attr("dy", 3)
            .attr("text-anchor", "start")
            .attr("font-size", "14px")
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
            })
            .attr("data-tippy-content", (d) => {
                return "<font color='#00DB00'>" + d.name +
                    "</font>: <font color='orange'>" + numFormatter(d.length * 100) + " Mya</font>";
            })
            .on("mouseover", function () {
                ribbonEnterTime = new Date().getTime();
                d3.select(this)
                    .transition()
                    .delay(100)
                    .duration(50)
                    .attr("fill", "#E1E100")
            })
            .on("mouseout", function () {
                ribbonOutTime = new Date().getTime();
                if (ribbonOutTime - ribbonEnterTime <= 1000) {
                    d3.select(this)
                        .transition()
                        .duration(50)
                        .attr("fill", "black")
                }
            })
            .on('click', function (d) {
                if (leafPopUpMenu.style('visibility') == 'visible') {
                    leafPopUpMenu.style('visibility', 'hidden');
                } else {
                    var name = d.name.replace(/_/g, ' ');
                    if (d.name.match(/\_/)) {
                        leafPopUpMenu.html("<p><font color='#00DB00'><i>" + name + "</i></font>: <font color='orange'>" +
                            numFormatter(d.length * 100) + " Mya</font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" +
                            "<button id='close-btn' onclick='closePopUp()'>&times;</button></p>" +
                            "<p>Choose a color:</p>" +
                            "<div id='color-options'></div>" +
                            "<p></p>" +
                            "<p>Choose a symbol:" +
                            "<div id='symbol-options'></div>");
                        // "<button id='add-symbol' onclick='addSymbol(textElement)'>Add Symbol</button>");
                    } else {
                        leafPopUpMenu.html("<p><font color='#00DB00'>" + name + "</font>: <font color='orange'>" +
                            numFormatter(d.length * 100) + " Mya</font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" +
                            "<button id='close-btn' onclick='closePopUp()'>&times;</button></p>" +
                            "<p>Choose a color:" +
                            "<div id='color-options'></div>" +
                            "<p></p>" +
                            "<p>Choose a symbol:" +
                            "<div id='symbol-options'></div>");
                        // "<button id='add-symbol' onclick='addSymbol(textElement)'>Add Symbol</button>");
                    }
                    d3.select('#close-btn').on('click', closePopUp);
                    function closePopUp() {
                        leafPopUpMenu.style('visibility', 'hidden');
                    };

                    var colors = ['#FF0000', '#00FF00', '#0000FF', '#FFA500', '#800080', '#FFC0CB', 'black'];
                    var textElement = d3.select(this.parentNode).select('.my-text').node();
                    // console.log("textElement", textElement)
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
                        .on('click', function (d) {
                            d3.select(textElement).style('fill', d);
                            // closePopUp();
                        });

                    function changeColorSecondPopUpMenu(textElement) {
                        var colors = ['#FF0000', '#00FF00', '#0000FF', '#FFA500', '#800080', '#FFC0CB', '#008080'];
                        var colorMenu = d3.select('body')
                            .append('div')
                            .attr('id', 'color-menu')
                            .style('position', 'absolute')
                            .style('top', (d3.event.pageY + 10) + 'px')
                            .style('left', (d3.event.pageX + 10) + 'px')
                            .style('padding', '10px')
                            .style('background-color', '#FFF')
                            .style('border', '1px solid #999');
                        colorMenu.append('p').text('Select a color:');
                        var colorOptions = colorMenu.selectAll('div')
                            .data(colors)
                            .enter()
                            .append('div')
                            .style('cursor', 'pointer')
                            .style('background-color', function (d) { return d; })
                            .style('width', '30px')
                            .style('height', '30px')
                            .style('margin-right', '5px')
                            .style('float', 'left')
                            .on('click', function (d) {
                                d3.select(textElement).style('fill', d);
                                // colorMenu.remove();
                            });
                    }

                    var symbols = [
                        { name: 'Circle', type: 'circle' },
                        { name: 'Cross', type: 'cross' },
                        { name: 'Diamond', type: 'diamond' },
                        { name: 'Square', type: 'square' },
                        { name: 'Triangle Up', type: 'triangle-up' }
                    ];

                    var clickedLeafNode = this;
                    var symbolOptions = d3.select('#symbol-options')
                        .selectAll('div')
                        .data(symbols)
                        .enter()
                        .append('div')
                        .style('cursor', 'pointer')
                        .style('width', '30px')
                        .style('height', '30px')
                        .style('margin-right', '3px')
                        .style('float', 'left')
                        .append('svg')
                        .attr('width', '60')
                        .attr('height', '60')
                        .append('path')
                        .attr('transform', 'translate(15, 15)')
                        .attr('d', function (d) {
                            if (d.type === 'circle') {
                                return d3.svg.symbol().type('circle')();
                            } else if (d.type === 'cross') {
                                return d3.svg.symbol().type('cross')();
                            } else if (d.type === 'diamond') {
                                return d3.svg.symbol().type('diamond')();
                            } else if (d.type === 'square') {
                                return d3.svg.symbol().type('square')();
                            } else if (d.type === 'triangle-up') {
                                return d3.svg.symbol().type('triangle-up')();
                            }
                        })
                        .attr('stroke', '#707038')
                        .attr('fill', '#707038')
                        .on('click', function (d) {
                            var leafNode = clickedLeafNode.parentNode;
                            var symbol = d3.svg.symbol().type(d.type)
                            var styleAttr = d3.select(clickedLeafNode).attr('style');
                            var match = styleAttr.match(/fill:\s*(.*?);/);
                            var textColor = match[1];
                            /* var textColor = d3.select(clickedLeafNode).select('my-text').style('fill');
                            console.log(textColor); */
                            d3.select(leafNode)
                                .append('path')
                                .attr('d', symbol)
                                .attr('stroke', textColor)
                                .attr('fill', textColor)
                                .attr('stroke-width', '1px');
                        });

                    if (d3.event && d3.event.pageX !== null) {
                        // Use d3.event.pageX here
                        var mouseX = d3.event.pageX;
                        var mouseY = d3.event.pageY;
                        leafPopUpMenu.style('left', (mouseX + 10) + 'px')
                            .style('top', (mouseY - 10) + 'px')
                            .style('visibility', 'visible');
                    } else {
                        console.log("Unable to retrieve pageX value");
                    }
                }
            });
        tippy(".my-text rect", { trigger: "mouseenter", followCursor: "initial", allowHTML: true, delay: [200, null] });

        d3.select('.path-pop-up-menu').remove();
        var popUpMenu = d3.select(selector).append('div')
            .classed('path-pop-up-menu', true)
            .style('position', 'absolute')
            .style('top', 0)
            .style('left', 0)
            .style('visibility', 'hidden')
            .style('background-color', 'white')
            .style('border', '1px solid black')
            .style('padding', '5px');

        var link = vis.selectAll("path.link")
            .data(tree.links(nodes))
            .enter().append("svg:path")
            .attr("class", "link")
            .attr("d", diagonal)
            .attr("fill", "none")
            .attr("stroke", "#aaa")
            .attr("stroke-width", "3px")
            .on("mouseover", function () {
                ribbonEnterTime = new Date().getTime();
                d3.select(this)
                    .transition()
                    .delay(100)
                    .duration(50)
                    .attr("stroke", "#E1E100")
                    .attr("stroke-width", "4px")
            })
            .on("mouseout", function () {
                ribbonOutTime = new Date().getTime();
                if (ribbonOutTime - ribbonEnterTime <= 1000) {
                    d3.select(this)
                        .transition()
                        .duration(50)
                        .attr("stroke", "#aaa")
                        .attr("stroke-width", "3px")
                }
            })
            .on('click', function (d) {
                if (popUpMenu.style('visibility') == 'visible') {
                    popUpMenu.style('visibility', 'hidden');
                } else {
                    popUpMenu.html("<p>Add a <font color='#00DB00'>WGD</font> event within this clade" +
                        "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<button id='close-btn' onclick='closePopUp()'>&times;</button></p>" +
                        "<p><font color='#A6A600'>Set a time: </font>" +
                        "<input type='text' id='time-input'>" +
                        "<font color='#A6A600'> Mya</font>" +
                        "<p></p>" +
                        "<p>Set a Greek letter:" +
                        "<div id='symbol-selector'>" +
                        "<button class='symbol-btn'><font color='#66c2a5'><b>&alpha;</b></font></button>" +
                        "<button class='symbol-btn'><font color='#fc8d62'><b>&beta;</b></font></button>" +
                        "<button class='symbol-btn'><font color='#8da0cb'><b>&gamma;</b></font></button>" +
                        "<button class='symbol-btn'><font color='#e78ac3'><b>&delta;</b></font></button>" +
                        "<button class='symbol-btn'><font color='#a6d854'><b>&epsilon;</b></font></button>" +
                        "</div>" +
                        "</p>"
                    );

                    d3.select('#close-btn').on('click', closePopUp);
                    function closePopUp() {
                        popUpMenu.style('visibility', 'hidden');
                    };

                    var clickedPath = this;
                    var pathData = clickedPath.getAttribute('d');
                    var pathArray = pathData.split(' ');
                    var yValue = pathArray[2].split(',')[1];
                    var timeInput = document.getElementById('time-input');
                    d3.selectAll('.symbol-btn').on('click', function () {
                        var symbolText = this.innerHTML;
                        var symbolText = this.innerHTML.match(/<b style=\"-webkit-user-select: auto;\">(.*?)<\/b>/)[1];
                        var buttonColor = this.innerHTML.match(/<font color=\"(.*?)\" style=\"-webkit-user-select: auto;\">/)[1];
                        var textElement = d3.select(clickedPath.parentNode).append('text')
                            .text(symbolText)
                            .attr('x', function () {
                                var maxLength = getMaxNodeLength(nodes);
                                var yScaleNew = d3.scale.linear()
                                    .domain([0, maxLength])
                                    .range([0, w]);
                                return yScaleNew(maxLength - timeInput.value / 100);
                            })
                            .attr('y', Number(yValue) - 12)
                            .style('font-size', '18px')
                            .attr("text-anchor", "middle")
                            .style('fill', buttonColor);
                        var line = d3.select(clickedPath.parentNode).append('line')
                            .attr('x1', textElement.attr('x'))
                            .attr('x2', textElement.attr('x'))
                            .attr('y1', Number(yValue) - 1)
                            .attr('y2', Number(yValue) - 6)
                            .style('stroke', buttonColor)
                            .style('stroke-width', '2px');

                        var bbox = textElement.node().getBBox();
                        var padding = 5;
                        var rectElement = d3.select(clickedPath.parentNode).insert('rect', 'text')
                            .attr('x', bbox.x - padding)
                            .attr('y', bbox.y - padding)
                            .attr('width', bbox.width + (padding * 2))
                            .attr('height', bbox.height + (padding * 2))
                            .style('fill', 'white')
                            .style('stroke', 'none');

                        closePopUp();
                    });

                    //colorOptions.node().removeAttribute('style');

                    d3.select('#close-btn').on('click', closePopUp);
                    function closePopUp() {
                        popUpMenu.style('visibility', 'hidden');
                    };

                    popUpMenu.style('left', (d3.event.pageX + 10) + 'px')
                        .style('top', (d3.event.pageY - 10) + 'px')
                        .style('visibility', 'visible');
                }
            });
        // Move the created paths to the bottom of the SVG
        vis.selectAll("path.link").each(function () {
            var firstChild = this.parentNode.firstChild;
            if (firstChild) {
                this.parentNode.insertBefore(this, firstChild);
            }
        });

        // Add the WGD events to the tree
        if (typeof wgdTableInfo !== "undefined") {
            wgdTableInfo.forEach(function (item) {
                var speciesName = item.species.replace(/\s+/g, '_');
                var branch = nodes.find(function (node) {
                    return node.name === speciesName;
                });
                var wgdsRange = item.wgds.split(',');

                wgdsRange.forEach(function (range, index) {
                    var [min, max] = range.split('-').map(Number);
                    var rectX = yscale(max);
                    var rectWidth = yscale(min) - yscale(max);

                    var cumulativeLength = branch.length;
                    var currentBranch = branch;
                    var parentCount = 0;

                    // Calculate the cumulative length of multiple parent nodes
                    while (currentBranch.parent && (min > cumulativeLength)) {
                        cumulativeLength += currentBranch.parent.length;
                        currentBranch = currentBranch.parent;
                        parentCount++;
                    }

                    var rectY = branch.x;
                    var tempBranch = branch;
                    for (var i = 0; i < parentCount; i++) {
                        tempBranch = tempBranch.parent;
                        rectY = tempBranch.x;
                    }

                    // Create a rectangle element
                    vis.append('rect')
                        .attr("class", "wgd_rect")
                        .attr('x', rectX)
                        .attr('y', rectY - 6)
                        .attr('width', rectWidth)
                        .attr('height', 12)
                        .attr('fill', 'steelblue')
                        .attr('fill-opacity', 0.7)
                        .attr("data-tippy-content", () => {
                            // var x1 = parseFloat(d.branchHPD.match(/\{([\d\.]+),/)[1]);
                            // var x2 = parseFloat(d.branchHPD.match(/, ([\d\.]+)\}/)[1]);
                            return "WGD Time in <font color='red'><i><b>" + item.species + "</b></i></font>" +
                                ": <br><font color='#73BF00'>" + numFormatter(min * 100) +
                                "</font> - <font color='orange'>" + numFormatter(max * 100) + "</font> MYA";
                        });

                    tippy(".wgd_rect", { trigger: "mouseenter", followCursor: "initial", allowHTML: true, delay: [200, null] });

                    /* if (min > branch.length) {
                        console.log("over", range);
                        if (min > branch.length + branch.parent.length) {
                            // var rectY = branch.parent.parent.x;
                            vis.append('rect')
                                .attr("class", "wgd_rect")
                                .attr('x', rectX)
                                .attr('y', rectY - 6)
                                .attr('width', rectWidth)
                                .attr('height', 12)
                                .attr('fill', 'orange')
                                .attr('fill-opacity', 0.6);
                        } else {
                            // var rectY = branch.parent.x;
                            vis.append('rect')
                                .attr("class", "wgd_rect")
                                .attr('x', rectX)
                                .attr('y', rectY - 6)
                                .attr('width', rectWidth)
                                .attr('height', 12)
                                .attr('fill', 'red')
                                .attr('fill-opacity', 0.6);
                        }
                    } else { */
                    // var rectY = branch.x;
                    //}
                });
            });

            tippy(".hpd_rect rect", { trigger: "mouseenter", followCursor: "initial", allowHTML: true, delay: [200, null] });
        }

        // draw geologic time scale
        drawGeologicTimeBar(maxLength, vis, yscale, h, "right");

        return { tree: tree, vis: vis }
    }
}
