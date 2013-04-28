var colourScale;	// used to colour edges and nodes
var tooltip;		// mouse over tooltip showing info about the node
var TFname;			// workaround for RegPrecise JSON data

/**
* Draw a wagon wheel using JSON data object. The JSON format is from RegPrecise.
*
* Code is adapted from "http://bl.ocks.org/4063550" and
* "http://bl.ocks.org/2952964".
*
* For a normal simple tree layout example,
* please go to "http://bl.ocks.org/1312406"
*
* @param wheelData This is a wheel data object.
* @param {bool} fullSize This is a bool value. Draw in full size if it is true.
* @param {string} locationId This is the id of where the wagon wheel will be appended to.
*/
function drawAWagonWheelFromWheelData(wheelData, fullSize, locationId) {
    var diameter;
    var size;
    var padding = 0;
    var location;
    TFname = wheelData.TFname;

    // size differs
    if (fullSize) {
        diameter = 700;
        size = [360, diameter / 2 - 160];
    } else {
        diameter = 500;
        size = [360, diameter / 2 - 60];
    }

    // default location
    if (locationId == null) {
        location = "#allWheels";
    } else {
        location = locationId;
    }

    // create the tooltip.
    if (tooltip == null) {
        tooltip = d3.select("body").append("div")
                    .attr("class", "tooltip")
                    .style("opacity", 0);
    }

    // used to color the nodes.
    if (colourScale == null) {
        colourScale = d3.scale.category20();
    }

    // the d3 tree layout
    var tree = d3.layout.tree()
        .size(size)
        .separation(function (a, b) { return (a.parent == b.parent ? 1 : 2) / a.depth; });

    // radial is used, therefore x means angle and y means diameter.
    var diagonal = d3.svg.diagonal.radial()
        .projection(function (d) {
            // ignore the control points to keep links straight.
            if (isTG(d) && hasEdge(d)) {
                return [d.y, d.x / 180 * Math.PI];
            } else {
                return [0, 0];
            }
        });

    // create parent element of the svg
    var div = d3.select(location).append("div")
        .attr("class", "wheel")
        .attr("id", wheelData.Genome);

    // draw the svg
    var svg = div.append("svg")
        .attr("width", diameter + padding)
        .attr("height", diameter + padding)
        .append("g")
        .attr("transform", "translate(" + (diameter + padding) / 2 + "," + (diameter + padding) / 2 + ")");
        //XYC .on("mousedown", repaint);

    // let d3js tree layout calculate the coordinates of all nodes and links.
    var nodes = tree.nodes(wheelData);
    var links = tree.links(nodes);

    // about the spoke like a clock face starting with the first TG
    // (spoke = 1) passing 12 o'clock TF spoke = 0

    // draw links
    svg.selectAll(".link")
         .data(links)
       .enter().append("path")
         .attr("class", "link")
         .attr("spoke", function (d, i) { return i + 1; }) // used for highlighting
         .attr("d", diagonal)
         .style("stroke", function (d) {
        	 return getColour(d.target);
    	 })
         .attr("opacity", 0.5);

    // draw nodes
    var node = svg.selectAll(".node")
          .data(nodes)
        .enter().append("g")
          .attr("class", "node")
          .attr("spoke", function (d, i) { return i; }) // used for highlighting
          .attr("transform", function (d) {
              // make the label of TF easier to read.
              if (isTF(d)) {
                  return "rotate(-90) translate(0)";
              } else {
                  return "rotate(" + (d.x - 90) + ") translate(" + d.y + ")";
              }
          })
          .on("mousedown", function () {
              var spoke = d3.select(this).attr("spoke");
              var indexOfSpoke = selected.indexOf(spoke);

              // push the spoke if not already in selected, vice versa.
              if (indexOfSpoke == -1) {
                  selected.push(spoke);
              } else {
                  selected.splice(indexOfSpoke, 1);
              }
          })
          .on("mouseover", showTooltip)
          .on("mousemove", function (d) { moveTooltip(d); })
          .on("mouseout", hideTooltip);

    // append circles
    node.append("circle")
          .attr("r", function (d) { return getRadius(d); })
          .style("fill", function (d) { return getColour(d); });

    // append label to each node.
    if (fullSize) {
        node.append("text")
          .attr("dy", ".31em")
          .attr("text-anchor", function (d) {

              // make the label of TF easier to read
              if (isTF(d)) {
                  return "start";
              } else {
                  return d.x < 180 ? "start" : "end";
              }
          })
          .attr("transform", function (d) {

              // make the label of TF easier to read
              if (isTF(d)) {
                  return "rotate(90) translate(10)";
              } else {
                  return d.x < 180 ? "translate(8)" : "rotate(180)translate(-8)";
              }
          })
          .text(function (d) { return d.name; });
    }

    // append label of the genome
    svg.append("text")
            .attr("class", "genomeLabel")
            .attr("x", 0)
            .attr("y", diameter / 2 - 20)
            .text(wheelData.Genome)
            .attr("text-anchor", "middle");
}

/**
* Get the tooltip info of the gene.
* @param gene This is a gene object.
* @return {bool} This returns a bool value.
*/
function getTooltipInfo(gene) {
	var items = [];
	$.each(gene, function(key, val) {
      if (key != "depth" && key != "parent" && key != "x" && key != "y") {
	    items.push('<b>' + key + ': </b>' + val);
      }
	});
	return items.join('<br/>');
}


/**
 * Work-around for RegPrecise JSON data.
 *
 * @param gene
 * @returns {Boolean}
 */
function isTF(gene) {
	if (TFname == undefined) {
	  return false; //assume false
	} else if (gene.name == undefined) {
      // A TF can be self-regulated, will have to do a round-loop
      // Will show as straight line for now
      var isTF = false;
      if (gene.name !== void 0) {
        isTF = gene.name.toLowerCase() == TFname.toLowerCase();
      }
      if (isTF) {
        return false;
      }
      return isTF;
	} else {
	  if (gene.TFname != undefined) {
		return gene.TFname.toLowerCase() == TFname.toLowerCase();
	  } else if (gene.locusTag != undefined) {
		//FIXME: assume is a target gene
		return false;
	  }
	}
}


/**
 * Work-around for RegPrecise JSON data. Data passed in is a list of target
 * genes and should have key 'name'.
 * @param gene
 * @returns {Boolean}
 */
function isTG(gene) {
	return (gene.name != undefined);
}


/**
* Checks if the gene has an edge.
* Needs to check against another RegPrecise webservices call (see getSites).
* TODO: Will always return true for now
*
* @param gene This is a gene object.
* @return {bool} This returns a bool value.
*/
function hasEdge(gene) {
    var edge = Math.random() >= 0.5;
    return edge;
}
