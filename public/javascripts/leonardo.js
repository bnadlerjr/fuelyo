/*jslint white: true, onevar: true, undef: true, nomen: true, eqeqeq: true, bitwise: true, regexp: true, newcap: true, immed: true */
/*global Raphael */

/**
 * Raphael helper functions. Namespaced to prevent trampling the main Raphael
 * namespace.
 */
Raphael.fn.leonardo = {
    /**
     * Draws a horizontal line.
     *
     * Arguments
     * x:
     *     Value of the x-coordinate
     *
     * y:
     *     Value of the y-coordinate
     *
     * width:
     *     Length of the line
     */
    hLine: function (x, y, width) {
        return this.path(["M", x, y, "h", width]);
    },

    /**
     * Draws a vertical line.
     *
     * Arguments
     * x:
     *     Value of the x-coordinate
     *
     * y:
     *     Value of the y-coordinate
     *
     * height:
     *     Length of the line
     */
    vLine: function (x, y, height) {
        return this.path(["M", x, y, "v", height]);
    },

    /**
     * Draws drawing a line between two points.
     *
     * Arguments
     * x1, y1:
     *     Coords for 'from' point
     *
     * x2, y2:
     *     Coords for 'to' point
     */
    line: function (x1, y1, x2, y2) {
        return this.path(["M", x1, y1, "L", x2, y2]);
    },

    /**
     * Draws a line from the current point to the specified coordinates. The first
     * time this function is called, x and y are cached. On subsequent calls, they
     * are again cached after drawing the line.
     *
     * NOTE: There is currently no way to reset the cache for the last coordinates.
     * Not sure if we're going to need that yet.
     *
     * Arguments
     * x, y:
     *     Coords to draw the line to.
     */
    lineTo: function (x, y) {
        if (this.cache) {
            this.path(["M", this.cache.lastX, this.cache.lastY, "L", x, y]);
        }
        this.cache = { lastX: x, lastY: y };
    }
};

var Leonardo = {};

/**
 * Namespace for the Leonardo graphing library.
 */
Leonardo = (function () {
    var paper,
        plotArea = {},
        scaleValues = [],
        maxValue,
        // TODO: Document the default options.
        opts = {
            'width'              : 300,
            'height'             : 200,
            'padding'            : 10,
            'barWidth'           : 6,
            'tickSize'           : 5,
            'drawBorder'         : true,
            'plotAreaPercentage' : 0.9,
            'scaleSize'          : 5
        };

    /**
     * Extends target object with properties of obj. Performs a deep copy.
     * Similiar to jQuery.extend(). Taken from the book "Javascript Patterns".
     */
    function extend(target, obj) {
        var i,
            toStr = Object.prototype.toString,
            aStr  = "[object Array]";

        target = target || {};

        for (i in obj) {
            if (obj.hasOwnProperty(i)) {
                if (typeof obj[i] === "object") {
                    target[i] = (toStr.call(obj[i]) === aStr) ? [] : {};
                    extend(obj[i], target[i]);
                } else {
                    target[i] = obj[i];
                }
            }
        }

        return target;
    }

    /**
     * Retrieves the maximum value from a data series. Assumes series is a hash
     * and not an Array.
     */
    function getMaxValue(series) {
        var data = [],
            item;

        for (item in series) {
            if (series.hasOwnProperty(item)) {
                data = data.concat(series[item]);
            }
        }

        return Math.max.apply(Math, data);
    }

    /**
     * Initializes graph by calculating the plot area and scale values.
     */
    function init(domID, max, num_labels, options) {
        opts = extend(opts, options || {});
        maxValue = max;

        var paddedWidth        = opts.width  - (opts.padding * 2),
            paddedHeight       = opts.height - (opts.padding * 2),
            axisAreaPercentage = 1 - opts.plotAreaPercentage,
            ratio              = maxValue / opts.scaleSize,
            i                  = opts.scaleSize;

        // Calculate size of plot area
        plotArea.x       = axisAreaPercentage * paddedWidth + opts.padding;
        plotArea.y       = opts.padding;
        plotArea.width   = opts.plotAreaPercentage * paddedWidth;
        plotArea.height  = paddedHeight - (axisAreaPercentage / 2 * opts.height);
        plotArea.xOffset = (plotArea.width / num_labels / 2) - opts.padding;

        // Calculate scale values
        // TODO: Round the scale values
        scaleValues[0] = 0;
        while (i--) {
            scaleValues.push(((i + 1) * ratio).toFixed(0));
        }

        // Create drawing surface
        paper = new Raphael(domID, opts.width, opts.height);
    }

    /**
     * Plots an array of items on the graph. Provides drawingCallback with the
     * x and y coords, as well as the current value.
     */
    function plot(values, drawingCallback) {
        var xStep = plotArea.width / (values.length),
            paddedHeight = plotArea.height + opts.padding,
            adjustedHeight = paddedHeight > opts.height ? plotArea.height + 1 : paddedHeight, // Can't be larger than total height
            xOffset = plotArea.x,
            yOffset;

        values.forEach(function (value, index) {
            xOffset += (0 === index) ? 3 : xStep;
            yOffset = adjustedHeight - (value / maxValue * plotArea.height);
            drawingCallback(xOffset, yOffset, value);
        });
    }

    /**
     * Draw a rectangular border around the chart.
     */
    function drawBorder(width, height) {
        paper.rect(0, 0, width, height);
    }

    /**
     * Draw the x-axis for the chart.
     */
    function drawXAxis(labels) {
        paper.leonardo.hLine(plotArea.x, plotArea.y + plotArea.height, plotArea.width);

        // TODO: Get rid of magic number. Base labelText on font size.
        var labelY = plotArea.y + plotArea.height,
            labelTextY = labelY + (2 * opts.tickSize);

        plot(labels, function (x, y, label) {
            x += plotArea.xOffset;
            paper.leonardo.vLine(x, labelY, opts.tickSize);
            paper.text(x, labelTextY, label);
        });
    }

    /**
     * Draw the y-axis for the chart.
     */
    function drawYAxis() {
        paper.leonardo.vLine(plotArea.x, plotArea.y, plotArea.height);

        // TODO: Get rid of magic number. Base text on font size instead.
        var valueX = plotArea.x - opts.tickSize,
            valueTextX = plotArea.x - (3 * opts.tickSize);

        plot(scaleValues, function (x, y, value) {
            paper.leonardo.hLine(valueX, y, opts.tickSize);
            paper.text(valueTextX, y, value);
        });
    }

    /**
     * Returns the length of a data series. Series is an object that looks like
     * an associative array. This method returns the number of "keys".
     */
    function getSeriesLength(series) {
        var size = 0,
            key;

        for (key in series) {
            if (series.hasOwnProperty(key)) {
                size += 1;
            }
        }

        return size;
    }

    /**
     * Public API
     */
    return {
        /**
         * Draws a column based chart.
         *
         * Arguments
         * domID:
         *     ID for a DOM element. This element will contain the graph.
         *
         * series:
         *     Key-value pair where the key is the name of the data series and the
         *     value is an array of values for the series.
         *
         * labels:
         *     Array of strings to use as labels.
         *
         * options:
         *     Key-value pairs representing various chart options. See default
         *     options above for a list.
         */
        columnChart: function (domID, series, labels, options) {
            init(domID, getMaxValue(series), labels.length, options || {});

            if (opts.drawBorder) {
                drawBorder(opts.width, opts.height);
            }

            drawXAxis(labels);
            drawYAxis();

            // Draw series bars
            // TODO: barWidth should actually be calculated according to
            // seriesWidth.
            var adjustedHeight = plotArea.height + opts.padding,
                seriesOffset = 0,
                seriesLength = getSeriesLength(series),
                halfBarWidth = opts.barWidth / 2,
                item,
                color;

            Raphael.getColor.reset();
            color = Raphael.getColor();
            for (item in series) {
                if (series.hasOwnProperty(item)) {
                    plot(series[item], function (x, y, value) {
                        var localColor = color;
                        x += seriesOffset - halfBarWidth;

                        // Only one data series so center the bar over the tick
                        // mark.
                        if (seriesLength === 1) {
                            x += plotArea.xOffset;
                        }

                        paper.rect(x, y, opts.barWidth, adjustedHeight - y).hover(
                            function (event) {
                                    this.attr({fill: "gray"});
                                }, function (event) {
                                this.attr({fill: localColor});
                            }).attr({title: item + ": " + value, fill: localColor});
                    });

                    seriesOffset += opts.barWidth;
                    if (!(opts.singleSeriesColor)) {
                        color = Raphael.getColor();
                    }
                }
            }
        },

        /**
         * Draws a line chart.
         *
         * Arguments
         *
         * domID:
         *     ID for a DOM element. This element will contain the graph.
         *
         * series:
         *     Key-value pair where the key is the name of the data series and the
         *     value is an array of values for the series.
         *
         * labels:
         *     Array of strings to use as labels.
         *
         * options:
         *     Key-value pairs representing various chart options. See default
         *     options above for a list.
         */
        lineChart: function (domID, series, labels, options) {
            init(domID, getMaxValue(series), labels.length, options || {});

            if (opts.drawBorder) {
                drawBorder(opts.width, opts.height);
            }

            drawXAxis(labels);
            drawYAxis();

            // Draw series lines
            for (var item in series) {
                if (series.hasOwnProperty(item)) {
                    plot(series[item], function (x, y, value) {
                        paper.leonardo.lineTo(x + plotArea.xOffset, y);
                    });
                }
            }
        },

        /**
         * Draws a sparkline chart. Only accepts one data series.
         *
         * Arguments
         * domID:
         *     ID for a DOM element. This element will contain the graph.
         *
         * data:
         *     Array of data values.
         *
         * options:
         *     Key-value pairs representing various chart options. See default
         *     options above for a list.
         */
        sparkline: function (domID, data, options) {
            opts = extend(opts, options || {});

            plotArea.x      = opts.padding;
            plotArea.width  = opts.width  - (opts.padding * 2);
            plotArea.height = opts.height;

            maxValue = Math.max.apply(Math, data);
            paper = new Raphael(domID, opts.width, opts.height);

            plot(data, function (x, y, value) {
                if (value === 0) {
                    y = plotArea.height;
                }
                paper.leonardo.lineTo(x, y);
            });
        },

        /**
         * Draws a single horizontal bar.
         *
         * Arguments
         * domID:
         *     ID for a DOM element. This element will contain the graph.
         *
         * percentageAsDecimal:
         *     Percentage value for the bar, given in decimal format.
         *
         * options:
         *     Key-value pairs representing various chart options.  See default
         *     options above for a list.
         */
        oneBar: function (domID, percentageAsDecimal, options) {
            opts = extend(opts, options || {});

            var paddedHeight = opts.height - 2;

            Raphael.getColor.reset();

            paper = new Raphael(domID, opts.width, opts.height);
            paper.rect(0, 1, percentageAsDecimal * opts.width, paddedHeight).attr({fill: Raphael.getColor()});

            if (opts.showPercentage) {
                paper.text(2,
                    paddedHeight / 2, (percentageAsDecimal * 100).toFixed(0) + "%").attr({'text-anchor': 'start'});
            }
        }
    };
}());
