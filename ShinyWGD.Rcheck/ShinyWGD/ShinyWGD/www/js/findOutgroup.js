Shiny.addCustomMessageHandler("findOutgroup", findOutgroup);
function findOutgroup(InputData) {
    var newick_tree = InputData;
    var treeJson = parseTree(newick_tree);

    var speciesOrder = findCommonAncestorFromJSON(treeJson);
    // console.log("speciesOrder", speciesOrder);
    // var outgroup = new Set();
    // outgroup.add(speciesOrder);
    // Shiny.onInputChange("treeOrderList", speciesOrder);
    var jsonData = JSON.stringify(speciesOrder);

    Shiny.onInputChange("treeOrderList", speciesOrder)
}

function parseTree(ksTree) {
    var ancestors = [];
    var tree = {};
    var tokens = ksTree.split(/\s*(;|\(|\)|,|:)\s*/).map(token => token.trim()).filter(Boolean);
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

function findCommonAncestorFromJSON(json_tree) {
    var species_name = []; // Create an empty list to store the names
    traverseBranchset(json_tree, species_name); // Start traversing the branchset
    return species_name;
}

function traverseBranchsetold(node, species_name) {
    if (node.hasOwnProperty('branchset') && node.branchset.length > 0) {
        for (var i = 0; i < node.branchset.length; i++) {
            var childNode = node.branchset[i];
            if (childNode.hasOwnProperty('name')) {
                species_name.push(childNode.name); 
            }
            traverseBranchset(childNode, species_name); 
        }
    }
}

function traverseBranchset(node, species_name) {
    if (node.hasOwnProperty('branchset') && node.branchset.length > 0) {
        for (var i = 0; i < node.branchset.length; i++) {
            var childNode = node.branchset[i];
            if (childNode.hasOwnProperty('name')) {
                species_name.push([childNode.name, childNode.id, node.id]); 
            }
            traverseBranchset(childNode, species_name); 
        }
    }
}
