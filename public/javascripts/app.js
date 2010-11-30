/*jslint white: true, onevar: true, undef: true, nomen: true, eqeqeq: true, bitwise: true, regexp: true, newcap: true, immed: true */
/*global jQuery $ Leonardo */
var Fuelyo = {};
Fuelyo = (function () {
    var labels = [],
        series = { 'Avg. MPG': [] };

    function extractData() {
        var data = $('#mpg-graph').text().split(',');
        $.each(data, function (index, value) {
            // Data is in the form label,value,label,value...
            if (index % 2 === 0) {
                labels.push(value);
            } else {
                series['Avg. MPG'].push(parseFloat(value));
            }
        });
    }

    return {
        onReady: function () {
            extractData();
            Leonardo.lineChart('line-chart', series, labels);
        }
    }
}());
