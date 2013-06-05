
/**
* get the radius of the gene.
* @param gene This is a gene object.
* @return {number} This returns a the radius in number.
*/
function getRadius(gene) {
    if (isTF(gene)) {
        return 7;
    } else if (isTG(gene)) {
        return 5;
    } else {
        return 2;
    }
}


/**
* Show the tooltip.
*/
function showTooltip() {
    tooltip.transition()
                .duration(300)
                .style("opacity", 1);
}

/**
* Move the tooltip and get the info.
*/
function moveTooltip(d) {
    tooltip.html(getTooltipInfo(d))
                .style("left", (d3.event.pageX + 20) + "px")
                .style("top", (d3.event.pageY) + "px");
}

/**
* Hide the tooltip.
*/
function hideTooltip() {
    tooltip.transition()
                .duration(300)
                .style("opacity", 0);
}


/**
* get the colour of the gene.
* @param gene This is a gene object.
* @return {string} This returns a colour code.
*/
function getColour(gene) {
    // when the gene is a TF, colour rule order for TF
    if (isTF(gene)) {
        // keep reference TF gray
        if (gene.Genome == "reference") {// || (getLengthOfcolourArray() > 0)) {
            return "#e7e7eb";
        } else {
            return "#e2041b";
        }
    }

    // when the gene is a TG, colour rule order for TG
    // operation result > findMe > ref > none of all above
    if (isTG(gene)) {
        // this part is used to colour nodes in operations (AND, OR and XOR)
        if (gene.owner != null) {
            if (gene.owner == 0) {
                return "#895b8a";
            } else if (gene.owner == -1) {
                return "#E6B422";
            } else if (gene.owner == 1) {
                return "#007b43";
            } else {
                return "#e7e7eb";
            }
        }

        // function can be very long, base colour on the first three words
        var bioFunction = gene['function'].split(/[\s,-]+/, 3).join(" ");
        return colourScale(bioFunction);
    }
}
