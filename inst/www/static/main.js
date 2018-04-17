(function(){function r(e,n,t){function o(i,f){if(!n[i]){if(!e[i]){var c="function"==typeof require&&require;if(!f&&c)return c(i,!0);if(u)return u(i,!0);var a=new Error("Cannot find module '"+i+"'");throw a.code="MODULE_NOT_FOUND",a}var p=n[i]={exports:{}};e[i][0].call(p.exports,function(r){var n=e[i][1][r];return o(n||r)},p,p.exports,r,e,n,t)}return n[i].exports}for(var u="function"==typeof require&&require,i=0;i<t.length;i++)o(t[i]);return o}return r})()({1:[function(require,module,exports){
var extract_data;
var survey_results;
var questions;
var extract_data = function () {
    survey_results = questions
        .call(function (d) {
        extract_survey_function[d.type](d, d3.select(this), d3.select(d3.event.target));
    });
};
var methodsTable;
var methodsHead;
var methodsBody;
/* Create survey questions */
var enter_btn_toggle = function (p, question) {
    choices_container = question
        .append("div");
    var choices = choices_container
        .append("div")
        .attr("class", "btn-group-toggle")
        .selectAll("label")
        .data(function (d) { return p.choices; })
        .enter()
        .append("label")
        .attr("class", "btn btn-primary")
        .text(function (d) { return d; })
        .on("click", function () {
        if (p.type == "radio") {
            d3.select(this.parentNode)
                .selectAll("label")
                .classed("active", false);
        }
        d3
            .select(this)
            .classed("active", !d3.select(this).classed("active"));
        d3.event.preventDefault();
        update_data_functions[p.type](p, question);
        update_results();
    });
    choices
        .append("input")
        .attr("type", p.type)
        .attr("id", function (d) { return d; })
        .attr("autocomplete", "off");
    if (p.special_choices) {
        choices_container
            .append("div")
            .attr("class", "btn-group")
            .selectAll("label")
            .data(function (d) { return p.special_choices; })
            .enter()
            .append("label")
            .attr("class", "btn btn-secondary")
            .text(function (d) { return d[0]; })
            .on("click", function () {
            var choice_ids = eval(d3.select(this).data()[0][1]);
            choices
                .classed("active", false)
                .filter(function (d) { return choice_ids.indexOf(d) > -1; })
                .classed("active", true);
            update_data_functions[p.type](p, question);
            update_results();
        });
    }
    if (p.default) {
        var choice_ids = p.default;
        choices
            .classed("active", false)
            .filter(function (d) { return choice_ids.indexOf(d) > -1; })
            .classed("active", true);
    }
};
var enter_survey_functions = {
    radio: enter_btn_toggle,
    checkbox: enter_btn_toggle,
    slider: function (p, question) {
        question
            .append("div")
            .append("input")
            .attr("type", "range")
            .attr("defaultValue", p.default)
            .attr("min", p.min)
            .attr("max", p.max)
            .attr("step", p.step)
            .on("change", function (d) {
            update_data_functions[p.type](p, question);
            update_results();
        });
        question.append("span")
            .classed("slider-label", true);
        eval('p.label = ' + p.label); // process label function
        question.datum(p);
    }
};
/* Update data from survey */
var update_data_functions = {
    radio: function (p, question) {
        var activeOption = question
            .selectAll("label.btn.active");
        choice = null;
        if (activeOption.size() == 1) {
            choice = activeOption.data().map(function (d) { return d; })[0];
        }
        p.value = choice;
        question.datum(p);
        // update_results()
    },
    checkbox: function (p, question) {
        var activeOption = question
            .selectAll("label.btn.active");
        choices = [];
        if (activeOption.size() > 0) {
            choices = activeOption.data().map(function (d) { return d; });
        }
        p.value = choices;
        question.datum(p);
        // update_results()
    },
    slider: function (p, question) {
        p.value = question.select("input").property("value");
        question.select("label.slider-label")
            .text(p.label(p.value));
        question.datum(p);
    }
};
/* Update results of survey */
var update_results = function () {
    /* get results, only for active questions */
    /* then check dependencies */
    /* until convergence */
    /* do this very stupidly for now */
    for (i = 0; i < 10; i++) {
        survey_results = _.fromPairs(questions
            .filter(function (d) { return !d3.select(this).classed("inactive-question"); })
            .data()
            .map(function (x) { return [x.question_id, x.value]; }));
        check_dependencies();
    }
    update_methods();
};
/* Check dependencies between questions */
var check_dependencies = function () {
    questions
        .classed("inactive-question", function (d) { return !eval(d.activeIf[0]); });
};
/* Load data and process questions */
$.getJSON("../R/questions/json", function (data) {
    // console.log(data)
    questions_data = data.questions;
    var category_data = d3.nest()
        .key(function (d) { return d.category; })
        .entries(questions_data);
    survey = d3.select("#survey");
    // categories
    var category_pills = survey
        .append("ul")
        .attr("class", "nav nav-tabs nav-justified")
        .selectAll("li")
        .data(category_data)
        .enter()
        .append("li")
        .classed("nav-item", true)
        .append("a")
        .attr("class", "nav-link")
        .classed("active", function (d, i) { return i == 0; })
        .attr("id", function (d) { return d.key + "-tab"; })
        .attr("data-toggle", "pill")
        .attr("href", function (d) { return "#" + d.key; })
        .text(function (d) { return d.key; });
    var categories = survey
        .append("div")
        .attr("class", "tab-content")
        .selectAll("div")
        .data(category_data)
        .enter()
        .append("div")
        .attr("class", "tab-pane")
        .classed("show", function (d, i) { return i == 0; })
        .classed("active", function (d, i) { return i == 0; })
        .attr("id", function (d) { return d.key; });
    // questions
    questions = categories
        .selectAll("div")
        .data(function (d) { return d.values; })
        .enter()
        .append("div")
        .classed("form-group", true);
    questions
        .append("label")
        .text(function (d) { return d.title; });
    questions
        .each(function (d) {
        enter_survey_functions[d.type](d, d3.select(this));
    })
        .each(function (d) { update_data_functions[d.type](d, d3.select(this)); } // Initial update
    // table
    , // Initial update
    // table
    methodsTable = d3.select('#methods'), methodsHead = methodsTable.append('thead'), methodsBody = methodsTable.append('tbody'));
    update_results();
    check_dependencies();
});
/* Table */
/* Render table columns */
topology_inference_type_colors = { "free": "green", "fixed": "red", "parameter": "orange" };
var column_renderers = {
    "text": function (td) { return td.text(function (d) { return d.value; }); },
    "topology_inference_type": function (td) { return td.text(function (d) { return d.value; }).style("color", function (d) { return topology_inference_type_colors[d.value]; }); },
    "benchmark_score": function (td) {
        var color_scale = d3
            .scaleSequential(d3.interpolateInferno)
            .domain([0, 1]);
        var radius = 15;
        var radius_scale = d3
            .scaleSqrt()
            .domain([0, 1])
            .range([1, radius]);
        var text_scale = d3
            .scaleSqrt()
            .domain([0, 1])
            .range([2, 20]);
        var text_format = d3.format(".0f");
        svg = td
            .text("")
            .append("svg")
            .attr("width", radius * 2)
            .attr("height", radius * 2);
        svg.append("circle")
            .attr("r", function (d) { return radius_scale(d.value); })
            .attr("transform", "translate(" + radius + "," + radius + ")")
            .style("fill", function (d) { return color_scale(d.value); });
        svg.append("text")
            .text(function (d) { return text_format(d.value * 100); })
            .attr("x", radius)
            .attr("y", radius)
            .attr("fill", "white")
            .style("alignment-baseline", "middle")
            .style("font-size", function (d) { return text_scale(d.value); })
            .style("text-anchor", "middle");
    },
    "bool": function (td) { return td.text(function (d) { if (d) {
        return "✔️";
    }
    else {
        return "❌";
    } }); }
};
/* Update table */
var update_methods = function () {
    methodsTable.transition(250).style("opacity", "0.1");
    ocpu.call("get_results", { "survey_results": survey_results }, function (session) {
        console.log("Your session id is :" + session.getKey());
        session.getObject(function (methods_data) {
            methodsTable.transition(1).style("opacity", "1");
            var columns = methodsHead.selectAll('th')
                .data(methods_data.method_columns);
            columns.enter()
                .append('th');
            columns.exit()
                .remove();
            methodsHead
                .selectAll('th')
                .text(function (column) { return column.label; });
            // remove old tds
            methodsBody
                .selectAll('tr')
                .html("");
            // add data to each row
            var rows = methodsBody
                .selectAll('tr')
                .data(methods_data.methods);
            rows
                .exit()
                .remove();
            // render columns
            var cells = rows
                .enter()
                .append('tr')
                .merge(rows)
                .selectAll('td')
                .data(function (row) {
                return methods_data.method_columns.map(function (column) {
                    return { value: row[column.column_id], column: column };
                });
            });
            cells = cells.enter()
                .append("td")
                .merge(cells);
            var _loop_1 = function (column) {
                column_renderers[column.renderer](cells
                    .filter(function (d) { return d.column.column_id == column.column_id; }));
            };
            for (var _i = 0, _a = methods_data.method_columns; _i < _a.length; _i++) {
                var column = _a[_i];
                _loop_1(column);
            }
        });
    });
};

},{}]},{},[1])
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIi4uLy4uLy4uLy4uLy4uLy4uLy4uLy4uLy4uL3Vzci9sb2NhbC9saWIvbm9kZV9tb2R1bGVzL3dhdGNoaWZ5L25vZGVfbW9kdWxlcy9icm93c2VyLXBhY2svX3ByZWx1ZGUuanMiLCJpbmRleC5qcyJdLCJuYW1lcyI6W10sIm1hcHBpbmdzIjoiQUFBQTtBQ0FBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0EiLCJmaWxlIjoiZ2VuZXJhdGVkLmpzIiwic291cmNlUm9vdCI6IiIsInNvdXJjZXNDb250ZW50IjpbIihmdW5jdGlvbigpe2Z1bmN0aW9uIHIoZSxuLHQpe2Z1bmN0aW9uIG8oaSxmKXtpZighbltpXSl7aWYoIWVbaV0pe3ZhciBjPVwiZnVuY3Rpb25cIj09dHlwZW9mIHJlcXVpcmUmJnJlcXVpcmU7aWYoIWYmJmMpcmV0dXJuIGMoaSwhMCk7aWYodSlyZXR1cm4gdShpLCEwKTt2YXIgYT1uZXcgRXJyb3IoXCJDYW5ub3QgZmluZCBtb2R1bGUgJ1wiK2krXCInXCIpO3Rocm93IGEuY29kZT1cIk1PRFVMRV9OT1RfRk9VTkRcIixhfXZhciBwPW5baV09e2V4cG9ydHM6e319O2VbaV1bMF0uY2FsbChwLmV4cG9ydHMsZnVuY3Rpb24ocil7dmFyIG49ZVtpXVsxXVtyXTtyZXR1cm4gbyhufHxyKX0scCxwLmV4cG9ydHMscixlLG4sdCl9cmV0dXJuIG5baV0uZXhwb3J0c31mb3IodmFyIHU9XCJmdW5jdGlvblwiPT10eXBlb2YgcmVxdWlyZSYmcmVxdWlyZSxpPTA7aTx0Lmxlbmd0aDtpKyspbyh0W2ldKTtyZXR1cm4gb31yZXR1cm4gcn0pKCkiLCJ2YXIgZXh0cmFjdF9kYXRhO1xudmFyIHN1cnZleV9yZXN1bHRzO1xudmFyIHF1ZXN0aW9ucztcbnZhciBleHRyYWN0X2RhdGEgPSBmdW5jdGlvbiAoKSB7XG4gICAgc3VydmV5X3Jlc3VsdHMgPSBxdWVzdGlvbnNcbiAgICAgICAgLmNhbGwoZnVuY3Rpb24gKGQpIHtcbiAgICAgICAgZXh0cmFjdF9zdXJ2ZXlfZnVuY3Rpb25bZC50eXBlXShkLCBkMy5zZWxlY3QodGhpcyksIGQzLnNlbGVjdChkMy5ldmVudC50YXJnZXQpKTtcbiAgICB9KTtcbn07XG52YXIgbWV0aG9kc1RhYmxlO1xudmFyIG1ldGhvZHNIZWFkO1xudmFyIG1ldGhvZHNCb2R5O1xuLyogQ3JlYXRlIHN1cnZleSBxdWVzdGlvbnMgKi9cbnZhciBlbnRlcl9idG5fdG9nZ2xlID0gZnVuY3Rpb24gKHAsIHF1ZXN0aW9uKSB7XG4gICAgY2hvaWNlc19jb250YWluZXIgPSBxdWVzdGlvblxuICAgICAgICAuYXBwZW5kKFwiZGl2XCIpO1xuICAgIHZhciBjaG9pY2VzID0gY2hvaWNlc19jb250YWluZXJcbiAgICAgICAgLmFwcGVuZChcImRpdlwiKVxuICAgICAgICAuYXR0cihcImNsYXNzXCIsIFwiYnRuLWdyb3VwLXRvZ2dsZVwiKVxuICAgICAgICAuc2VsZWN0QWxsKFwibGFiZWxcIilcbiAgICAgICAgLmRhdGEoZnVuY3Rpb24gKGQpIHsgcmV0dXJuIHAuY2hvaWNlczsgfSlcbiAgICAgICAgLmVudGVyKClcbiAgICAgICAgLmFwcGVuZChcImxhYmVsXCIpXG4gICAgICAgIC5hdHRyKFwiY2xhc3NcIiwgXCJidG4gYnRuLXByaW1hcnlcIilcbiAgICAgICAgLnRleHQoZnVuY3Rpb24gKGQpIHsgcmV0dXJuIGQ7IH0pXG4gICAgICAgIC5vbihcImNsaWNrXCIsIGZ1bmN0aW9uICgpIHtcbiAgICAgICAgaWYgKHAudHlwZSA9PSBcInJhZGlvXCIpIHtcbiAgICAgICAgICAgIGQzLnNlbGVjdCh0aGlzLnBhcmVudE5vZGUpXG4gICAgICAgICAgICAgICAgLnNlbGVjdEFsbChcImxhYmVsXCIpXG4gICAgICAgICAgICAgICAgLmNsYXNzZWQoXCJhY3RpdmVcIiwgZmFsc2UpO1xuICAgICAgICB9XG4gICAgICAgIGQzXG4gICAgICAgICAgICAuc2VsZWN0KHRoaXMpXG4gICAgICAgICAgICAuY2xhc3NlZChcImFjdGl2ZVwiLCAhZDMuc2VsZWN0KHRoaXMpLmNsYXNzZWQoXCJhY3RpdmVcIikpO1xuICAgICAgICBkMy5ldmVudC5wcmV2ZW50RGVmYXVsdCgpO1xuICAgICAgICB1cGRhdGVfZGF0YV9mdW5jdGlvbnNbcC50eXBlXShwLCBxdWVzdGlvbik7XG4gICAgICAgIHVwZGF0ZV9yZXN1bHRzKCk7XG4gICAgfSk7XG4gICAgY2hvaWNlc1xuICAgICAgICAuYXBwZW5kKFwiaW5wdXRcIilcbiAgICAgICAgLmF0dHIoXCJ0eXBlXCIsIHAudHlwZSlcbiAgICAgICAgLmF0dHIoXCJpZFwiLCBmdW5jdGlvbiAoZCkgeyByZXR1cm4gZDsgfSlcbiAgICAgICAgLmF0dHIoXCJhdXRvY29tcGxldGVcIiwgXCJvZmZcIik7XG4gICAgaWYgKHAuc3BlY2lhbF9jaG9pY2VzKSB7XG4gICAgICAgIGNob2ljZXNfY29udGFpbmVyXG4gICAgICAgICAgICAuYXBwZW5kKFwiZGl2XCIpXG4gICAgICAgICAgICAuYXR0cihcImNsYXNzXCIsIFwiYnRuLWdyb3VwXCIpXG4gICAgICAgICAgICAuc2VsZWN0QWxsKFwibGFiZWxcIilcbiAgICAgICAgICAgIC5kYXRhKGZ1bmN0aW9uIChkKSB7IHJldHVybiBwLnNwZWNpYWxfY2hvaWNlczsgfSlcbiAgICAgICAgICAgIC5lbnRlcigpXG4gICAgICAgICAgICAuYXBwZW5kKFwibGFiZWxcIilcbiAgICAgICAgICAgIC5hdHRyKFwiY2xhc3NcIiwgXCJidG4gYnRuLXNlY29uZGFyeVwiKVxuICAgICAgICAgICAgLnRleHQoZnVuY3Rpb24gKGQpIHsgcmV0dXJuIGRbMF07IH0pXG4gICAgICAgICAgICAub24oXCJjbGlja1wiLCBmdW5jdGlvbiAoKSB7XG4gICAgICAgICAgICB2YXIgY2hvaWNlX2lkcyA9IGV2YWwoZDMuc2VsZWN0KHRoaXMpLmRhdGEoKVswXVsxXSk7XG4gICAgICAgICAgICBjaG9pY2VzXG4gICAgICAgICAgICAgICAgLmNsYXNzZWQoXCJhY3RpdmVcIiwgZmFsc2UpXG4gICAgICAgICAgICAgICAgLmZpbHRlcihmdW5jdGlvbiAoZCkgeyByZXR1cm4gY2hvaWNlX2lkcy5pbmRleE9mKGQpID4gLTE7IH0pXG4gICAgICAgICAgICAgICAgLmNsYXNzZWQoXCJhY3RpdmVcIiwgdHJ1ZSk7XG4gICAgICAgICAgICB1cGRhdGVfZGF0YV9mdW5jdGlvbnNbcC50eXBlXShwLCBxdWVzdGlvbik7XG4gICAgICAgICAgICB1cGRhdGVfcmVzdWx0cygpO1xuICAgICAgICB9KTtcbiAgICB9XG4gICAgaWYgKHAuZGVmYXVsdCkge1xuICAgICAgICB2YXIgY2hvaWNlX2lkcyA9IHAuZGVmYXVsdDtcbiAgICAgICAgY2hvaWNlc1xuICAgICAgICAgICAgLmNsYXNzZWQoXCJhY3RpdmVcIiwgZmFsc2UpXG4gICAgICAgICAgICAuZmlsdGVyKGZ1bmN0aW9uIChkKSB7IHJldHVybiBjaG9pY2VfaWRzLmluZGV4T2YoZCkgPiAtMTsgfSlcbiAgICAgICAgICAgIC5jbGFzc2VkKFwiYWN0aXZlXCIsIHRydWUpO1xuICAgIH1cbn07XG52YXIgZW50ZXJfc3VydmV5X2Z1bmN0aW9ucyA9IHtcbiAgICByYWRpbzogZW50ZXJfYnRuX3RvZ2dsZSxcbiAgICBjaGVja2JveDogZW50ZXJfYnRuX3RvZ2dsZSxcbiAgICBzbGlkZXI6IGZ1bmN0aW9uIChwLCBxdWVzdGlvbikge1xuICAgICAgICBxdWVzdGlvblxuICAgICAgICAgICAgLmFwcGVuZChcImRpdlwiKVxuICAgICAgICAgICAgLmFwcGVuZChcImlucHV0XCIpXG4gICAgICAgICAgICAuYXR0cihcInR5cGVcIiwgXCJyYW5nZVwiKVxuICAgICAgICAgICAgLmF0dHIoXCJkZWZhdWx0VmFsdWVcIiwgcC5kZWZhdWx0KVxuICAgICAgICAgICAgLmF0dHIoXCJtaW5cIiwgcC5taW4pXG4gICAgICAgICAgICAuYXR0cihcIm1heFwiLCBwLm1heClcbiAgICAgICAgICAgIC5hdHRyKFwic3RlcFwiLCBwLnN0ZXApXG4gICAgICAgICAgICAub24oXCJjaGFuZ2VcIiwgZnVuY3Rpb24gKGQpIHtcbiAgICAgICAgICAgIHVwZGF0ZV9kYXRhX2Z1bmN0aW9uc1twLnR5cGVdKHAsIHF1ZXN0aW9uKTtcbiAgICAgICAgICAgIHVwZGF0ZV9yZXN1bHRzKCk7XG4gICAgICAgIH0pO1xuICAgICAgICBxdWVzdGlvbi5hcHBlbmQoXCJzcGFuXCIpXG4gICAgICAgICAgICAuY2xhc3NlZChcInNsaWRlci1sYWJlbFwiLCB0cnVlKTtcbiAgICAgICAgZXZhbCgncC5sYWJlbCA9ICcgKyBwLmxhYmVsKTsgLy8gcHJvY2VzcyBsYWJlbCBmdW5jdGlvblxuICAgICAgICBxdWVzdGlvbi5kYXR1bShwKTtcbiAgICB9XG59O1xuLyogVXBkYXRlIGRhdGEgZnJvbSBzdXJ2ZXkgKi9cbnZhciB1cGRhdGVfZGF0YV9mdW5jdGlvbnMgPSB7XG4gICAgcmFkaW86IGZ1bmN0aW9uIChwLCBxdWVzdGlvbikge1xuICAgICAgICB2YXIgYWN0aXZlT3B0aW9uID0gcXVlc3Rpb25cbiAgICAgICAgICAgIC5zZWxlY3RBbGwoXCJsYWJlbC5idG4uYWN0aXZlXCIpO1xuICAgICAgICBjaG9pY2UgPSBudWxsO1xuICAgICAgICBpZiAoYWN0aXZlT3B0aW9uLnNpemUoKSA9PSAxKSB7XG4gICAgICAgICAgICBjaG9pY2UgPSBhY3RpdmVPcHRpb24uZGF0YSgpLm1hcChmdW5jdGlvbiAoZCkgeyByZXR1cm4gZDsgfSlbMF07XG4gICAgICAgIH1cbiAgICAgICAgcC52YWx1ZSA9IGNob2ljZTtcbiAgICAgICAgcXVlc3Rpb24uZGF0dW0ocCk7XG4gICAgICAgIC8vIHVwZGF0ZV9yZXN1bHRzKClcbiAgICB9LFxuICAgIGNoZWNrYm94OiBmdW5jdGlvbiAocCwgcXVlc3Rpb24pIHtcbiAgICAgICAgdmFyIGFjdGl2ZU9wdGlvbiA9IHF1ZXN0aW9uXG4gICAgICAgICAgICAuc2VsZWN0QWxsKFwibGFiZWwuYnRuLmFjdGl2ZVwiKTtcbiAgICAgICAgY2hvaWNlcyA9IFtdO1xuICAgICAgICBpZiAoYWN0aXZlT3B0aW9uLnNpemUoKSA+IDApIHtcbiAgICAgICAgICAgIGNob2ljZXMgPSBhY3RpdmVPcHRpb24uZGF0YSgpLm1hcChmdW5jdGlvbiAoZCkgeyByZXR1cm4gZDsgfSk7XG4gICAgICAgIH1cbiAgICAgICAgcC52YWx1ZSA9IGNob2ljZXM7XG4gICAgICAgIHF1ZXN0aW9uLmRhdHVtKHApO1xuICAgICAgICAvLyB1cGRhdGVfcmVzdWx0cygpXG4gICAgfSxcbiAgICBzbGlkZXI6IGZ1bmN0aW9uIChwLCBxdWVzdGlvbikge1xuICAgICAgICBwLnZhbHVlID0gcXVlc3Rpb24uc2VsZWN0KFwiaW5wdXRcIikucHJvcGVydHkoXCJ2YWx1ZVwiKTtcbiAgICAgICAgcXVlc3Rpb24uc2VsZWN0KFwibGFiZWwuc2xpZGVyLWxhYmVsXCIpXG4gICAgICAgICAgICAudGV4dChwLmxhYmVsKHAudmFsdWUpKTtcbiAgICAgICAgcXVlc3Rpb24uZGF0dW0ocCk7XG4gICAgfVxufTtcbi8qIFVwZGF0ZSByZXN1bHRzIG9mIHN1cnZleSAqL1xudmFyIHVwZGF0ZV9yZXN1bHRzID0gZnVuY3Rpb24gKCkge1xuICAgIC8qIGdldCByZXN1bHRzLCBvbmx5IGZvciBhY3RpdmUgcXVlc3Rpb25zICovXG4gICAgLyogdGhlbiBjaGVjayBkZXBlbmRlbmNpZXMgKi9cbiAgICAvKiB1bnRpbCBjb252ZXJnZW5jZSAqL1xuICAgIC8qIGRvIHRoaXMgdmVyeSBzdHVwaWRseSBmb3Igbm93ICovXG4gICAgZm9yIChpID0gMDsgaSA8IDEwOyBpKyspIHtcbiAgICAgICAgc3VydmV5X3Jlc3VsdHMgPSBfLmZyb21QYWlycyhxdWVzdGlvbnNcbiAgICAgICAgICAgIC5maWx0ZXIoZnVuY3Rpb24gKGQpIHsgcmV0dXJuICFkMy5zZWxlY3QodGhpcykuY2xhc3NlZChcImluYWN0aXZlLXF1ZXN0aW9uXCIpOyB9KVxuICAgICAgICAgICAgLmRhdGEoKVxuICAgICAgICAgICAgLm1hcChmdW5jdGlvbiAoeCkgeyByZXR1cm4gW3gucXVlc3Rpb25faWQsIHgudmFsdWVdOyB9KSk7XG4gICAgICAgIGNoZWNrX2RlcGVuZGVuY2llcygpO1xuICAgIH1cbiAgICB1cGRhdGVfbWV0aG9kcygpO1xufTtcbi8qIENoZWNrIGRlcGVuZGVuY2llcyBiZXR3ZWVuIHF1ZXN0aW9ucyAqL1xudmFyIGNoZWNrX2RlcGVuZGVuY2llcyA9IGZ1bmN0aW9uICgpIHtcbiAgICBxdWVzdGlvbnNcbiAgICAgICAgLmNsYXNzZWQoXCJpbmFjdGl2ZS1xdWVzdGlvblwiLCBmdW5jdGlvbiAoZCkgeyByZXR1cm4gIWV2YWwoZC5hY3RpdmVJZlswXSk7IH0pO1xufTtcbi8qIExvYWQgZGF0YSBhbmQgcHJvY2VzcyBxdWVzdGlvbnMgKi9cbiQuZ2V0SlNPTihcIi4uL1IvcXVlc3Rpb25zL2pzb25cIiwgZnVuY3Rpb24gKGRhdGEpIHtcbiAgICAvLyBjb25zb2xlLmxvZyhkYXRhKVxuICAgIHF1ZXN0aW9uc19kYXRhID0gZGF0YS5xdWVzdGlvbnM7XG4gICAgdmFyIGNhdGVnb3J5X2RhdGEgPSBkMy5uZXN0KClcbiAgICAgICAgLmtleShmdW5jdGlvbiAoZCkgeyByZXR1cm4gZC5jYXRlZ29yeTsgfSlcbiAgICAgICAgLmVudHJpZXMocXVlc3Rpb25zX2RhdGEpO1xuICAgIHN1cnZleSA9IGQzLnNlbGVjdChcIiNzdXJ2ZXlcIik7XG4gICAgLy8gY2F0ZWdvcmllc1xuICAgIHZhciBjYXRlZ29yeV9waWxscyA9IHN1cnZleVxuICAgICAgICAuYXBwZW5kKFwidWxcIilcbiAgICAgICAgLmF0dHIoXCJjbGFzc1wiLCBcIm5hdiBuYXYtdGFicyBuYXYtanVzdGlmaWVkXCIpXG4gICAgICAgIC5zZWxlY3RBbGwoXCJsaVwiKVxuICAgICAgICAuZGF0YShjYXRlZ29yeV9kYXRhKVxuICAgICAgICAuZW50ZXIoKVxuICAgICAgICAuYXBwZW5kKFwibGlcIilcbiAgICAgICAgLmNsYXNzZWQoXCJuYXYtaXRlbVwiLCB0cnVlKVxuICAgICAgICAuYXBwZW5kKFwiYVwiKVxuICAgICAgICAuYXR0cihcImNsYXNzXCIsIFwibmF2LWxpbmtcIilcbiAgICAgICAgLmNsYXNzZWQoXCJhY3RpdmVcIiwgZnVuY3Rpb24gKGQsIGkpIHsgcmV0dXJuIGkgPT0gMDsgfSlcbiAgICAgICAgLmF0dHIoXCJpZFwiLCBmdW5jdGlvbiAoZCkgeyByZXR1cm4gZC5rZXkgKyBcIi10YWJcIjsgfSlcbiAgICAgICAgLmF0dHIoXCJkYXRhLXRvZ2dsZVwiLCBcInBpbGxcIilcbiAgICAgICAgLmF0dHIoXCJocmVmXCIsIGZ1bmN0aW9uIChkKSB7IHJldHVybiBcIiNcIiArIGQua2V5OyB9KVxuICAgICAgICAudGV4dChmdW5jdGlvbiAoZCkgeyByZXR1cm4gZC5rZXk7IH0pO1xuICAgIHZhciBjYXRlZ29yaWVzID0gc3VydmV5XG4gICAgICAgIC5hcHBlbmQoXCJkaXZcIilcbiAgICAgICAgLmF0dHIoXCJjbGFzc1wiLCBcInRhYi1jb250ZW50XCIpXG4gICAgICAgIC5zZWxlY3RBbGwoXCJkaXZcIilcbiAgICAgICAgLmRhdGEoY2F0ZWdvcnlfZGF0YSlcbiAgICAgICAgLmVudGVyKClcbiAgICAgICAgLmFwcGVuZChcImRpdlwiKVxuICAgICAgICAuYXR0cihcImNsYXNzXCIsIFwidGFiLXBhbmVcIilcbiAgICAgICAgLmNsYXNzZWQoXCJzaG93XCIsIGZ1bmN0aW9uIChkLCBpKSB7IHJldHVybiBpID09IDA7IH0pXG4gICAgICAgIC5jbGFzc2VkKFwiYWN0aXZlXCIsIGZ1bmN0aW9uIChkLCBpKSB7IHJldHVybiBpID09IDA7IH0pXG4gICAgICAgIC5hdHRyKFwiaWRcIiwgZnVuY3Rpb24gKGQpIHsgcmV0dXJuIGQua2V5OyB9KTtcbiAgICAvLyBxdWVzdGlvbnNcbiAgICBxdWVzdGlvbnMgPSBjYXRlZ29yaWVzXG4gICAgICAgIC5zZWxlY3RBbGwoXCJkaXZcIilcbiAgICAgICAgLmRhdGEoZnVuY3Rpb24gKGQpIHsgcmV0dXJuIGQudmFsdWVzOyB9KVxuICAgICAgICAuZW50ZXIoKVxuICAgICAgICAuYXBwZW5kKFwiZGl2XCIpXG4gICAgICAgIC5jbGFzc2VkKFwiZm9ybS1ncm91cFwiLCB0cnVlKTtcbiAgICBxdWVzdGlvbnNcbiAgICAgICAgLmFwcGVuZChcImxhYmVsXCIpXG4gICAgICAgIC50ZXh0KGZ1bmN0aW9uIChkKSB7IHJldHVybiBkLnRpdGxlOyB9KTtcbiAgICBxdWVzdGlvbnNcbiAgICAgICAgLmVhY2goZnVuY3Rpb24gKGQpIHtcbiAgICAgICAgZW50ZXJfc3VydmV5X2Z1bmN0aW9uc1tkLnR5cGVdKGQsIGQzLnNlbGVjdCh0aGlzKSk7XG4gICAgfSlcbiAgICAgICAgLmVhY2goZnVuY3Rpb24gKGQpIHsgdXBkYXRlX2RhdGFfZnVuY3Rpb25zW2QudHlwZV0oZCwgZDMuc2VsZWN0KHRoaXMpKTsgfSAvLyBJbml0aWFsIHVwZGF0ZVxuICAgIC8vIHRhYmxlXG4gICAgLCAvLyBJbml0aWFsIHVwZGF0ZVxuICAgIC8vIHRhYmxlXG4gICAgbWV0aG9kc1RhYmxlID0gZDMuc2VsZWN0KCcjbWV0aG9kcycpLCBtZXRob2RzSGVhZCA9IG1ldGhvZHNUYWJsZS5hcHBlbmQoJ3RoZWFkJyksIG1ldGhvZHNCb2R5ID0gbWV0aG9kc1RhYmxlLmFwcGVuZCgndGJvZHknKSk7XG4gICAgdXBkYXRlX3Jlc3VsdHMoKTtcbiAgICBjaGVja19kZXBlbmRlbmNpZXMoKTtcbn0pO1xuLyogVGFibGUgKi9cbi8qIFJlbmRlciB0YWJsZSBjb2x1bW5zICovXG50b3BvbG9neV9pbmZlcmVuY2VfdHlwZV9jb2xvcnMgPSB7IFwiZnJlZVwiOiBcImdyZWVuXCIsIFwiZml4ZWRcIjogXCJyZWRcIiwgXCJwYXJhbWV0ZXJcIjogXCJvcmFuZ2VcIiB9O1xudmFyIGNvbHVtbl9yZW5kZXJlcnMgPSB7XG4gICAgXCJ0ZXh0XCI6IGZ1bmN0aW9uICh0ZCkgeyByZXR1cm4gdGQudGV4dChmdW5jdGlvbiAoZCkgeyByZXR1cm4gZC52YWx1ZTsgfSk7IH0sXG4gICAgXCJ0b3BvbG9neV9pbmZlcmVuY2VfdHlwZVwiOiBmdW5jdGlvbiAodGQpIHsgcmV0dXJuIHRkLnRleHQoZnVuY3Rpb24gKGQpIHsgcmV0dXJuIGQudmFsdWU7IH0pLnN0eWxlKFwiY29sb3JcIiwgZnVuY3Rpb24gKGQpIHsgcmV0dXJuIHRvcG9sb2d5X2luZmVyZW5jZV90eXBlX2NvbG9yc1tkLnZhbHVlXTsgfSk7IH0sXG4gICAgXCJiZW5jaG1hcmtfc2NvcmVcIjogZnVuY3Rpb24gKHRkKSB7XG4gICAgICAgIHZhciBjb2xvcl9zY2FsZSA9IGQzXG4gICAgICAgICAgICAuc2NhbGVTZXF1ZW50aWFsKGQzLmludGVycG9sYXRlSW5mZXJubylcbiAgICAgICAgICAgIC5kb21haW4oWzAsIDFdKTtcbiAgICAgICAgdmFyIHJhZGl1cyA9IDE1O1xuICAgICAgICB2YXIgcmFkaXVzX3NjYWxlID0gZDNcbiAgICAgICAgICAgIC5zY2FsZVNxcnQoKVxuICAgICAgICAgICAgLmRvbWFpbihbMCwgMV0pXG4gICAgICAgICAgICAucmFuZ2UoWzEsIHJhZGl1c10pO1xuICAgICAgICB2YXIgdGV4dF9zY2FsZSA9IGQzXG4gICAgICAgICAgICAuc2NhbGVTcXJ0KClcbiAgICAgICAgICAgIC5kb21haW4oWzAsIDFdKVxuICAgICAgICAgICAgLnJhbmdlKFsyLCAyMF0pO1xuICAgICAgICB2YXIgdGV4dF9mb3JtYXQgPSBkMy5mb3JtYXQoXCIuMGZcIik7XG4gICAgICAgIHN2ZyA9IHRkXG4gICAgICAgICAgICAudGV4dChcIlwiKVxuICAgICAgICAgICAgLmFwcGVuZChcInN2Z1wiKVxuICAgICAgICAgICAgLmF0dHIoXCJ3aWR0aFwiLCByYWRpdXMgKiAyKVxuICAgICAgICAgICAgLmF0dHIoXCJoZWlnaHRcIiwgcmFkaXVzICogMik7XG4gICAgICAgIHN2Zy5hcHBlbmQoXCJjaXJjbGVcIilcbiAgICAgICAgICAgIC5hdHRyKFwiclwiLCBmdW5jdGlvbiAoZCkgeyByZXR1cm4gcmFkaXVzX3NjYWxlKGQudmFsdWUpOyB9KVxuICAgICAgICAgICAgLmF0dHIoXCJ0cmFuc2Zvcm1cIiwgXCJ0cmFuc2xhdGUoXCIgKyByYWRpdXMgKyBcIixcIiArIHJhZGl1cyArIFwiKVwiKVxuICAgICAgICAgICAgLnN0eWxlKFwiZmlsbFwiLCBmdW5jdGlvbiAoZCkgeyByZXR1cm4gY29sb3Jfc2NhbGUoZC52YWx1ZSk7IH0pO1xuICAgICAgICBzdmcuYXBwZW5kKFwidGV4dFwiKVxuICAgICAgICAgICAgLnRleHQoZnVuY3Rpb24gKGQpIHsgcmV0dXJuIHRleHRfZm9ybWF0KGQudmFsdWUgKiAxMDApOyB9KVxuICAgICAgICAgICAgLmF0dHIoXCJ4XCIsIHJhZGl1cylcbiAgICAgICAgICAgIC5hdHRyKFwieVwiLCByYWRpdXMpXG4gICAgICAgICAgICAuYXR0cihcImZpbGxcIiwgXCJ3aGl0ZVwiKVxuICAgICAgICAgICAgLnN0eWxlKFwiYWxpZ25tZW50LWJhc2VsaW5lXCIsIFwibWlkZGxlXCIpXG4gICAgICAgICAgICAuc3R5bGUoXCJmb250LXNpemVcIiwgZnVuY3Rpb24gKGQpIHsgcmV0dXJuIHRleHRfc2NhbGUoZC52YWx1ZSk7IH0pXG4gICAgICAgICAgICAuc3R5bGUoXCJ0ZXh0LWFuY2hvclwiLCBcIm1pZGRsZVwiKTtcbiAgICB9LFxuICAgIFwiYm9vbFwiOiBmdW5jdGlvbiAodGQpIHsgcmV0dXJuIHRkLnRleHQoZnVuY3Rpb24gKGQpIHsgaWYgKGQpIHtcbiAgICAgICAgcmV0dXJuIFwi4pyU77iPXCI7XG4gICAgfVxuICAgIGVsc2Uge1xuICAgICAgICByZXR1cm4gXCLinYxcIjtcbiAgICB9IH0pOyB9XG59O1xuLyogVXBkYXRlIHRhYmxlICovXG52YXIgdXBkYXRlX21ldGhvZHMgPSBmdW5jdGlvbiAoKSB7XG4gICAgbWV0aG9kc1RhYmxlLnRyYW5zaXRpb24oMjUwKS5zdHlsZShcIm9wYWNpdHlcIiwgXCIwLjFcIik7XG4gICAgb2NwdS5jYWxsKFwiZ2V0X3Jlc3VsdHNcIiwgeyBcInN1cnZleV9yZXN1bHRzXCI6IHN1cnZleV9yZXN1bHRzIH0sIGZ1bmN0aW9uIChzZXNzaW9uKSB7XG4gICAgICAgIGNvbnNvbGUubG9nKFwiWW91ciBzZXNzaW9uIGlkIGlzIDpcIiArIHNlc3Npb24uZ2V0S2V5KCkpO1xuICAgICAgICBzZXNzaW9uLmdldE9iamVjdChmdW5jdGlvbiAobWV0aG9kc19kYXRhKSB7XG4gICAgICAgICAgICBtZXRob2RzVGFibGUudHJhbnNpdGlvbigxKS5zdHlsZShcIm9wYWNpdHlcIiwgXCIxXCIpO1xuICAgICAgICAgICAgdmFyIGNvbHVtbnMgPSBtZXRob2RzSGVhZC5zZWxlY3RBbGwoJ3RoJylcbiAgICAgICAgICAgICAgICAuZGF0YShtZXRob2RzX2RhdGEubWV0aG9kX2NvbHVtbnMpO1xuICAgICAgICAgICAgY29sdW1ucy5lbnRlcigpXG4gICAgICAgICAgICAgICAgLmFwcGVuZCgndGgnKTtcbiAgICAgICAgICAgIGNvbHVtbnMuZXhpdCgpXG4gICAgICAgICAgICAgICAgLnJlbW92ZSgpO1xuICAgICAgICAgICAgbWV0aG9kc0hlYWRcbiAgICAgICAgICAgICAgICAuc2VsZWN0QWxsKCd0aCcpXG4gICAgICAgICAgICAgICAgLnRleHQoZnVuY3Rpb24gKGNvbHVtbikgeyByZXR1cm4gY29sdW1uLmxhYmVsOyB9KTtcbiAgICAgICAgICAgIC8vIHJlbW92ZSBvbGQgdGRzXG4gICAgICAgICAgICBtZXRob2RzQm9keVxuICAgICAgICAgICAgICAgIC5zZWxlY3RBbGwoJ3RyJylcbiAgICAgICAgICAgICAgICAuaHRtbChcIlwiKTtcbiAgICAgICAgICAgIC8vIGFkZCBkYXRhIHRvIGVhY2ggcm93XG4gICAgICAgICAgICB2YXIgcm93cyA9IG1ldGhvZHNCb2R5XG4gICAgICAgICAgICAgICAgLnNlbGVjdEFsbCgndHInKVxuICAgICAgICAgICAgICAgIC5kYXRhKG1ldGhvZHNfZGF0YS5tZXRob2RzKTtcbiAgICAgICAgICAgIHJvd3NcbiAgICAgICAgICAgICAgICAuZXhpdCgpXG4gICAgICAgICAgICAgICAgLnJlbW92ZSgpO1xuICAgICAgICAgICAgLy8gcmVuZGVyIGNvbHVtbnNcbiAgICAgICAgICAgIHZhciBjZWxscyA9IHJvd3NcbiAgICAgICAgICAgICAgICAuZW50ZXIoKVxuICAgICAgICAgICAgICAgIC5hcHBlbmQoJ3RyJylcbiAgICAgICAgICAgICAgICAubWVyZ2Uocm93cylcbiAgICAgICAgICAgICAgICAuc2VsZWN0QWxsKCd0ZCcpXG4gICAgICAgICAgICAgICAgLmRhdGEoZnVuY3Rpb24gKHJvdykge1xuICAgICAgICAgICAgICAgIHJldHVybiBtZXRob2RzX2RhdGEubWV0aG9kX2NvbHVtbnMubWFwKGZ1bmN0aW9uIChjb2x1bW4pIHtcbiAgICAgICAgICAgICAgICAgICAgcmV0dXJuIHsgdmFsdWU6IHJvd1tjb2x1bW4uY29sdW1uX2lkXSwgY29sdW1uOiBjb2x1bW4gfTtcbiAgICAgICAgICAgICAgICB9KTtcbiAgICAgICAgICAgIH0pO1xuICAgICAgICAgICAgY2VsbHMgPSBjZWxscy5lbnRlcigpXG4gICAgICAgICAgICAgICAgLmFwcGVuZChcInRkXCIpXG4gICAgICAgICAgICAgICAgLm1lcmdlKGNlbGxzKTtcbiAgICAgICAgICAgIHZhciBfbG9vcF8xID0gZnVuY3Rpb24gKGNvbHVtbikge1xuICAgICAgICAgICAgICAgIGNvbHVtbl9yZW5kZXJlcnNbY29sdW1uLnJlbmRlcmVyXShjZWxsc1xuICAgICAgICAgICAgICAgICAgICAuZmlsdGVyKGZ1bmN0aW9uIChkKSB7IHJldHVybiBkLmNvbHVtbi5jb2x1bW5faWQgPT0gY29sdW1uLmNvbHVtbl9pZDsgfSkpO1xuICAgICAgICAgICAgfTtcbiAgICAgICAgICAgIGZvciAodmFyIF9pID0gMCwgX2EgPSBtZXRob2RzX2RhdGEubWV0aG9kX2NvbHVtbnM7IF9pIDwgX2EubGVuZ3RoOyBfaSsrKSB7XG4gICAgICAgICAgICAgICAgdmFyIGNvbHVtbiA9IF9hW19pXTtcbiAgICAgICAgICAgICAgICBfbG9vcF8xKGNvbHVtbik7XG4gICAgICAgICAgICB9XG4gICAgICAgIH0pO1xuICAgIH0pO1xufTtcbiJdfQ==
