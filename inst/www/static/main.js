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
    checkbox: enter_btn_toggle
};
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
    }
};
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
        .attr("class", "tab-pane fade")
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
var update_methods = function () {
    methodsTable.transition(250).style("opacity", "0.1");
    // d3.select("#methods-loader").style("visibility", "visible")
    ocpu.call("get_results", { "survey_results": survey_results }, function (session) {
        console.log("Your session id is :" + session.getKey());
        session.getObject(function (methods_data) {
            // d3.select("#methods-loader").style("visibility", "hidden")
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
            var rows = methodsBody.selectAll('tr')
                .data(methods_data.methods);
            rows
                .exit()
                .remove();
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
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIi4uLy4uLy4uLy4uLy4uLy4uLy4uLy4uLy4uL3Vzci9sb2NhbC9saWIvbm9kZV9tb2R1bGVzL3dhdGNoaWZ5L25vZGVfbW9kdWxlcy9icm93c2VyLXBhY2svX3ByZWx1ZGUuanMiLCJpbmRleC5qcyJdLCJuYW1lcyI6W10sIm1hcHBpbmdzIjoiQUFBQTtBQ0FBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQSIsImZpbGUiOiJnZW5lcmF0ZWQuanMiLCJzb3VyY2VSb290IjoiIiwic291cmNlc0NvbnRlbnQiOlsiKGZ1bmN0aW9uKCl7ZnVuY3Rpb24gcihlLG4sdCl7ZnVuY3Rpb24gbyhpLGYpe2lmKCFuW2ldKXtpZighZVtpXSl7dmFyIGM9XCJmdW5jdGlvblwiPT10eXBlb2YgcmVxdWlyZSYmcmVxdWlyZTtpZighZiYmYylyZXR1cm4gYyhpLCEwKTtpZih1KXJldHVybiB1KGksITApO3ZhciBhPW5ldyBFcnJvcihcIkNhbm5vdCBmaW5kIG1vZHVsZSAnXCIraStcIidcIik7dGhyb3cgYS5jb2RlPVwiTU9EVUxFX05PVF9GT1VORFwiLGF9dmFyIHA9bltpXT17ZXhwb3J0czp7fX07ZVtpXVswXS5jYWxsKHAuZXhwb3J0cyxmdW5jdGlvbihyKXt2YXIgbj1lW2ldWzFdW3JdO3JldHVybiBvKG58fHIpfSxwLHAuZXhwb3J0cyxyLGUsbix0KX1yZXR1cm4gbltpXS5leHBvcnRzfWZvcih2YXIgdT1cImZ1bmN0aW9uXCI9PXR5cGVvZiByZXF1aXJlJiZyZXF1aXJlLGk9MDtpPHQubGVuZ3RoO2krKylvKHRbaV0pO3JldHVybiBvfXJldHVybiByfSkoKSIsInZhciBleHRyYWN0X2RhdGE7XG52YXIgc3VydmV5X3Jlc3VsdHM7XG52YXIgcXVlc3Rpb25zO1xudmFyIGV4dHJhY3RfZGF0YSA9IGZ1bmN0aW9uICgpIHtcbiAgICBzdXJ2ZXlfcmVzdWx0cyA9IHF1ZXN0aW9uc1xuICAgICAgICAuY2FsbChmdW5jdGlvbiAoZCkge1xuICAgICAgICBleHRyYWN0X3N1cnZleV9mdW5jdGlvbltkLnR5cGVdKGQsIGQzLnNlbGVjdCh0aGlzKSwgZDMuc2VsZWN0KGQzLmV2ZW50LnRhcmdldCkpO1xuICAgIH0pO1xufTtcbnZhciBtZXRob2RzVGFibGU7XG52YXIgbWV0aG9kc0hlYWQ7XG52YXIgbWV0aG9kc0JvZHk7XG52YXIgZW50ZXJfYnRuX3RvZ2dsZSA9IGZ1bmN0aW9uIChwLCBxdWVzdGlvbikge1xuICAgIGNob2ljZXNfY29udGFpbmVyID0gcXVlc3Rpb25cbiAgICAgICAgLmFwcGVuZChcImRpdlwiKTtcbiAgICB2YXIgY2hvaWNlcyA9IGNob2ljZXNfY29udGFpbmVyXG4gICAgICAgIC5hcHBlbmQoXCJkaXZcIilcbiAgICAgICAgLmF0dHIoXCJjbGFzc1wiLCBcImJ0bi1ncm91cC10b2dnbGVcIilcbiAgICAgICAgLnNlbGVjdEFsbChcImxhYmVsXCIpXG4gICAgICAgIC5kYXRhKGZ1bmN0aW9uIChkKSB7IHJldHVybiBwLmNob2ljZXM7IH0pXG4gICAgICAgIC5lbnRlcigpXG4gICAgICAgIC5hcHBlbmQoXCJsYWJlbFwiKVxuICAgICAgICAuYXR0cihcImNsYXNzXCIsIFwiYnRuIGJ0bi1wcmltYXJ5XCIpXG4gICAgICAgIC50ZXh0KGZ1bmN0aW9uIChkKSB7IHJldHVybiBkOyB9KVxuICAgICAgICAub24oXCJjbGlja1wiLCBmdW5jdGlvbiAoKSB7XG4gICAgICAgIGlmIChwLnR5cGUgPT0gXCJyYWRpb1wiKSB7XG4gICAgICAgICAgICBkMy5zZWxlY3QodGhpcy5wYXJlbnROb2RlKVxuICAgICAgICAgICAgICAgIC5zZWxlY3RBbGwoXCJsYWJlbFwiKVxuICAgICAgICAgICAgICAgIC5jbGFzc2VkKFwiYWN0aXZlXCIsIGZhbHNlKTtcbiAgICAgICAgfVxuICAgICAgICBkM1xuICAgICAgICAgICAgLnNlbGVjdCh0aGlzKVxuICAgICAgICAgICAgLmNsYXNzZWQoXCJhY3RpdmVcIiwgIWQzLnNlbGVjdCh0aGlzKS5jbGFzc2VkKFwiYWN0aXZlXCIpKTtcbiAgICAgICAgZDMuZXZlbnQucHJldmVudERlZmF1bHQoKTtcbiAgICAgICAgdXBkYXRlX2RhdGFfZnVuY3Rpb25zW3AudHlwZV0ocCwgcXVlc3Rpb24pO1xuICAgICAgICB1cGRhdGVfcmVzdWx0cygpO1xuICAgIH0pO1xuICAgIGNob2ljZXNcbiAgICAgICAgLmFwcGVuZChcImlucHV0XCIpXG4gICAgICAgIC5hdHRyKFwidHlwZVwiLCBwLnR5cGUpXG4gICAgICAgIC5hdHRyKFwiaWRcIiwgZnVuY3Rpb24gKGQpIHsgcmV0dXJuIGQ7IH0pXG4gICAgICAgIC5hdHRyKFwiYXV0b2NvbXBsZXRlXCIsIFwib2ZmXCIpO1xuICAgIGlmIChwLnNwZWNpYWxfY2hvaWNlcykge1xuICAgICAgICBjaG9pY2VzX2NvbnRhaW5lclxuICAgICAgICAgICAgLmFwcGVuZChcImRpdlwiKVxuICAgICAgICAgICAgLmF0dHIoXCJjbGFzc1wiLCBcImJ0bi1ncm91cFwiKVxuICAgICAgICAgICAgLnNlbGVjdEFsbChcImxhYmVsXCIpXG4gICAgICAgICAgICAuZGF0YShmdW5jdGlvbiAoZCkgeyByZXR1cm4gcC5zcGVjaWFsX2Nob2ljZXM7IH0pXG4gICAgICAgICAgICAuZW50ZXIoKVxuICAgICAgICAgICAgLmFwcGVuZChcImxhYmVsXCIpXG4gICAgICAgICAgICAuYXR0cihcImNsYXNzXCIsIFwiYnRuIGJ0bi1zZWNvbmRhcnlcIilcbiAgICAgICAgICAgIC50ZXh0KGZ1bmN0aW9uIChkKSB7IHJldHVybiBkWzBdOyB9KVxuICAgICAgICAgICAgLm9uKFwiY2xpY2tcIiwgZnVuY3Rpb24gKCkge1xuICAgICAgICAgICAgdmFyIGNob2ljZV9pZHMgPSBldmFsKGQzLnNlbGVjdCh0aGlzKS5kYXRhKClbMF1bMV0pO1xuICAgICAgICAgICAgY2hvaWNlc1xuICAgICAgICAgICAgICAgIC5jbGFzc2VkKFwiYWN0aXZlXCIsIGZhbHNlKVxuICAgICAgICAgICAgICAgIC5maWx0ZXIoZnVuY3Rpb24gKGQpIHsgcmV0dXJuIGNob2ljZV9pZHMuaW5kZXhPZihkKSA+IC0xOyB9KVxuICAgICAgICAgICAgICAgIC5jbGFzc2VkKFwiYWN0aXZlXCIsIHRydWUpO1xuICAgICAgICAgICAgdXBkYXRlX2RhdGFfZnVuY3Rpb25zW3AudHlwZV0ocCwgcXVlc3Rpb24pO1xuICAgICAgICAgICAgdXBkYXRlX3Jlc3VsdHMoKTtcbiAgICAgICAgfSk7XG4gICAgfVxuICAgIGlmIChwLmRlZmF1bHQpIHtcbiAgICAgICAgdmFyIGNob2ljZV9pZHMgPSBwLmRlZmF1bHQ7XG4gICAgICAgIGNob2ljZXNcbiAgICAgICAgICAgIC5jbGFzc2VkKFwiYWN0aXZlXCIsIGZhbHNlKVxuICAgICAgICAgICAgLmZpbHRlcihmdW5jdGlvbiAoZCkgeyByZXR1cm4gY2hvaWNlX2lkcy5pbmRleE9mKGQpID4gLTE7IH0pXG4gICAgICAgICAgICAuY2xhc3NlZChcImFjdGl2ZVwiLCB0cnVlKTtcbiAgICB9XG59O1xudmFyIGVudGVyX3N1cnZleV9mdW5jdGlvbnMgPSB7XG4gICAgcmFkaW86IGVudGVyX2J0bl90b2dnbGUsXG4gICAgY2hlY2tib3g6IGVudGVyX2J0bl90b2dnbGVcbn07XG52YXIgdXBkYXRlX2RhdGFfZnVuY3Rpb25zID0ge1xuICAgIHJhZGlvOiBmdW5jdGlvbiAocCwgcXVlc3Rpb24pIHtcbiAgICAgICAgdmFyIGFjdGl2ZU9wdGlvbiA9IHF1ZXN0aW9uXG4gICAgICAgICAgICAuc2VsZWN0QWxsKFwibGFiZWwuYnRuLmFjdGl2ZVwiKTtcbiAgICAgICAgY2hvaWNlID0gbnVsbDtcbiAgICAgICAgaWYgKGFjdGl2ZU9wdGlvbi5zaXplKCkgPT0gMSkge1xuICAgICAgICAgICAgY2hvaWNlID0gYWN0aXZlT3B0aW9uLmRhdGEoKS5tYXAoZnVuY3Rpb24gKGQpIHsgcmV0dXJuIGQ7IH0pWzBdO1xuICAgICAgICB9XG4gICAgICAgIHAudmFsdWUgPSBjaG9pY2U7XG4gICAgICAgIHF1ZXN0aW9uLmRhdHVtKHApO1xuICAgICAgICAvLyB1cGRhdGVfcmVzdWx0cygpXG4gICAgfSxcbiAgICBjaGVja2JveDogZnVuY3Rpb24gKHAsIHF1ZXN0aW9uKSB7XG4gICAgICAgIHZhciBhY3RpdmVPcHRpb24gPSBxdWVzdGlvblxuICAgICAgICAgICAgLnNlbGVjdEFsbChcImxhYmVsLmJ0bi5hY3RpdmVcIik7XG4gICAgICAgIGNob2ljZXMgPSBbXTtcbiAgICAgICAgaWYgKGFjdGl2ZU9wdGlvbi5zaXplKCkgPiAwKSB7XG4gICAgICAgICAgICBjaG9pY2VzID0gYWN0aXZlT3B0aW9uLmRhdGEoKS5tYXAoZnVuY3Rpb24gKGQpIHsgcmV0dXJuIGQ7IH0pO1xuICAgICAgICB9XG4gICAgICAgIHAudmFsdWUgPSBjaG9pY2VzO1xuICAgICAgICBxdWVzdGlvbi5kYXR1bShwKTtcbiAgICAgICAgLy8gdXBkYXRlX3Jlc3VsdHMoKVxuICAgIH1cbn07XG52YXIgdXBkYXRlX3Jlc3VsdHMgPSBmdW5jdGlvbiAoKSB7XG4gICAgLyogZ2V0IHJlc3VsdHMsIG9ubHkgZm9yIGFjdGl2ZSBxdWVzdGlvbnMgKi9cbiAgICAvKiB0aGVuIGNoZWNrIGRlcGVuZGVuY2llcyAqL1xuICAgIC8qIHVudGlsIGNvbnZlcmdlbmNlICovXG4gICAgLyogZG8gdGhpcyB2ZXJ5IHN0dXBpZGx5IGZvciBub3cgKi9cbiAgICBmb3IgKGkgPSAwOyBpIDwgMTA7IGkrKykge1xuICAgICAgICBzdXJ2ZXlfcmVzdWx0cyA9IF8uZnJvbVBhaXJzKHF1ZXN0aW9uc1xuICAgICAgICAgICAgLmZpbHRlcihmdW5jdGlvbiAoZCkgeyByZXR1cm4gIWQzLnNlbGVjdCh0aGlzKS5jbGFzc2VkKFwiaW5hY3RpdmUtcXVlc3Rpb25cIik7IH0pXG4gICAgICAgICAgICAuZGF0YSgpXG4gICAgICAgICAgICAubWFwKGZ1bmN0aW9uICh4KSB7IHJldHVybiBbeC5xdWVzdGlvbl9pZCwgeC52YWx1ZV07IH0pKTtcbiAgICAgICAgY2hlY2tfZGVwZW5kZW5jaWVzKCk7XG4gICAgfVxuICAgIHVwZGF0ZV9tZXRob2RzKCk7XG59O1xudmFyIGNoZWNrX2RlcGVuZGVuY2llcyA9IGZ1bmN0aW9uICgpIHtcbiAgICBxdWVzdGlvbnNcbiAgICAgICAgLmNsYXNzZWQoXCJpbmFjdGl2ZS1xdWVzdGlvblwiLCBmdW5jdGlvbiAoZCkgeyByZXR1cm4gIWV2YWwoZC5hY3RpdmVJZlswXSk7IH0pO1xufTtcbi8qIExvYWQgZGF0YSBhbmQgcHJvY2VzcyBxdWVzdGlvbnMgKi9cbiQuZ2V0SlNPTihcIi4uL1IvcXVlc3Rpb25zL2pzb25cIiwgZnVuY3Rpb24gKGRhdGEpIHtcbiAgICAvLyBjb25zb2xlLmxvZyhkYXRhKVxuICAgIHF1ZXN0aW9uc19kYXRhID0gZGF0YS5xdWVzdGlvbnM7XG4gICAgdmFyIGNhdGVnb3J5X2RhdGEgPSBkMy5uZXN0KClcbiAgICAgICAgLmtleShmdW5jdGlvbiAoZCkgeyByZXR1cm4gZC5jYXRlZ29yeTsgfSlcbiAgICAgICAgLmVudHJpZXMocXVlc3Rpb25zX2RhdGEpO1xuICAgIHN1cnZleSA9IGQzLnNlbGVjdChcIiNzdXJ2ZXlcIik7XG4gICAgLy8gY2F0ZWdvcmllc1xuICAgIHZhciBjYXRlZ29yeV9waWxscyA9IHN1cnZleVxuICAgICAgICAuYXBwZW5kKFwidWxcIilcbiAgICAgICAgLmF0dHIoXCJjbGFzc1wiLCBcIm5hdiBuYXYtdGFicyBuYXYtanVzdGlmaWVkXCIpXG4gICAgICAgIC5zZWxlY3RBbGwoXCJsaVwiKVxuICAgICAgICAuZGF0YShjYXRlZ29yeV9kYXRhKVxuICAgICAgICAuZW50ZXIoKVxuICAgICAgICAuYXBwZW5kKFwibGlcIilcbiAgICAgICAgLmNsYXNzZWQoXCJuYXYtaXRlbVwiLCB0cnVlKVxuICAgICAgICAuYXBwZW5kKFwiYVwiKVxuICAgICAgICAuYXR0cihcImNsYXNzXCIsIFwibmF2LWxpbmtcIilcbiAgICAgICAgLmNsYXNzZWQoXCJhY3RpdmVcIiwgZnVuY3Rpb24gKGQsIGkpIHsgcmV0dXJuIGkgPT0gMDsgfSlcbiAgICAgICAgLmF0dHIoXCJpZFwiLCBmdW5jdGlvbiAoZCkgeyByZXR1cm4gZC5rZXkgKyBcIi10YWJcIjsgfSlcbiAgICAgICAgLmF0dHIoXCJkYXRhLXRvZ2dsZVwiLCBcInBpbGxcIilcbiAgICAgICAgLmF0dHIoXCJocmVmXCIsIGZ1bmN0aW9uIChkKSB7IHJldHVybiBcIiNcIiArIGQua2V5OyB9KVxuICAgICAgICAudGV4dChmdW5jdGlvbiAoZCkgeyByZXR1cm4gZC5rZXk7IH0pO1xuICAgIHZhciBjYXRlZ29yaWVzID0gc3VydmV5XG4gICAgICAgIC5hcHBlbmQoXCJkaXZcIilcbiAgICAgICAgLmF0dHIoXCJjbGFzc1wiLCBcInRhYi1jb250ZW50XCIpXG4gICAgICAgIC5zZWxlY3RBbGwoXCJkaXZcIilcbiAgICAgICAgLmRhdGEoY2F0ZWdvcnlfZGF0YSlcbiAgICAgICAgLmVudGVyKClcbiAgICAgICAgLmFwcGVuZChcImRpdlwiKVxuICAgICAgICAuYXR0cihcImNsYXNzXCIsIFwidGFiLXBhbmUgZmFkZVwiKVxuICAgICAgICAuY2xhc3NlZChcInNob3dcIiwgZnVuY3Rpb24gKGQsIGkpIHsgcmV0dXJuIGkgPT0gMDsgfSlcbiAgICAgICAgLmNsYXNzZWQoXCJhY3RpdmVcIiwgZnVuY3Rpb24gKGQsIGkpIHsgcmV0dXJuIGkgPT0gMDsgfSlcbiAgICAgICAgLmF0dHIoXCJpZFwiLCBmdW5jdGlvbiAoZCkgeyByZXR1cm4gZC5rZXk7IH0pO1xuICAgIC8vIHF1ZXN0aW9uc1xuICAgIHF1ZXN0aW9ucyA9IGNhdGVnb3JpZXNcbiAgICAgICAgLnNlbGVjdEFsbChcImRpdlwiKVxuICAgICAgICAuZGF0YShmdW5jdGlvbiAoZCkgeyByZXR1cm4gZC52YWx1ZXM7IH0pXG4gICAgICAgIC5lbnRlcigpXG4gICAgICAgIC5hcHBlbmQoXCJkaXZcIilcbiAgICAgICAgLmNsYXNzZWQoXCJmb3JtLWdyb3VwXCIsIHRydWUpO1xuICAgIHF1ZXN0aW9uc1xuICAgICAgICAuYXBwZW5kKFwibGFiZWxcIilcbiAgICAgICAgLnRleHQoZnVuY3Rpb24gKGQpIHsgcmV0dXJuIGQudGl0bGU7IH0pO1xuICAgIHF1ZXN0aW9uc1xuICAgICAgICAuZWFjaChmdW5jdGlvbiAoZCkge1xuICAgICAgICBlbnRlcl9zdXJ2ZXlfZnVuY3Rpb25zW2QudHlwZV0oZCwgZDMuc2VsZWN0KHRoaXMpKTtcbiAgICB9KVxuICAgICAgICAuZWFjaChmdW5jdGlvbiAoZCkgeyB1cGRhdGVfZGF0YV9mdW5jdGlvbnNbZC50eXBlXShkLCBkMy5zZWxlY3QodGhpcykpOyB9IC8vIEluaXRpYWwgdXBkYXRlXG4gICAgLy8gdGFibGVcbiAgICAsIC8vIEluaXRpYWwgdXBkYXRlXG4gICAgLy8gdGFibGVcbiAgICBtZXRob2RzVGFibGUgPSBkMy5zZWxlY3QoJyNtZXRob2RzJyksIG1ldGhvZHNIZWFkID0gbWV0aG9kc1RhYmxlLmFwcGVuZCgndGhlYWQnKSwgbWV0aG9kc0JvZHkgPSBtZXRob2RzVGFibGUuYXBwZW5kKCd0Ym9keScpKTtcbiAgICB1cGRhdGVfcmVzdWx0cygpO1xuICAgIGNoZWNrX2RlcGVuZGVuY2llcygpO1xufSk7XG4vKiBUYWJsZSAqL1xudG9wb2xvZ3lfaW5mZXJlbmNlX3R5cGVfY29sb3JzID0geyBcImZyZWVcIjogXCJncmVlblwiLCBcImZpeGVkXCI6IFwicmVkXCIsIFwicGFyYW1ldGVyXCI6IFwib3JhbmdlXCIgfTtcbnZhciBjb2x1bW5fcmVuZGVyZXJzID0ge1xuICAgIFwidGV4dFwiOiBmdW5jdGlvbiAodGQpIHsgcmV0dXJuIHRkLnRleHQoZnVuY3Rpb24gKGQpIHsgcmV0dXJuIGQudmFsdWU7IH0pOyB9LFxuICAgIFwidG9wb2xvZ3lfaW5mZXJlbmNlX3R5cGVcIjogZnVuY3Rpb24gKHRkKSB7IHJldHVybiB0ZC50ZXh0KGZ1bmN0aW9uIChkKSB7IHJldHVybiBkLnZhbHVlOyB9KS5zdHlsZShcImNvbG9yXCIsIGZ1bmN0aW9uIChkKSB7IHJldHVybiB0b3BvbG9neV9pbmZlcmVuY2VfdHlwZV9jb2xvcnNbZC52YWx1ZV07IH0pOyB9LFxuICAgIFwiYmVuY2htYXJrX3Njb3JlXCI6IGZ1bmN0aW9uICh0ZCkge1xuICAgICAgICB2YXIgY29sb3Jfc2NhbGUgPSBkM1xuICAgICAgICAgICAgLnNjYWxlU2VxdWVudGlhbChkMy5pbnRlcnBvbGF0ZUluZmVybm8pXG4gICAgICAgICAgICAuZG9tYWluKFswLCAxXSk7XG4gICAgICAgIHZhciByYWRpdXMgPSAxNTtcbiAgICAgICAgdmFyIHJhZGl1c19zY2FsZSA9IGQzXG4gICAgICAgICAgICAuc2NhbGVTcXJ0KClcbiAgICAgICAgICAgIC5kb21haW4oWzAsIDFdKVxuICAgICAgICAgICAgLnJhbmdlKFsxLCByYWRpdXNdKTtcbiAgICAgICAgdmFyIHRleHRfc2NhbGUgPSBkM1xuICAgICAgICAgICAgLnNjYWxlU3FydCgpXG4gICAgICAgICAgICAuZG9tYWluKFswLCAxXSlcbiAgICAgICAgICAgIC5yYW5nZShbMiwgMjBdKTtcbiAgICAgICAgdmFyIHRleHRfZm9ybWF0ID0gZDMuZm9ybWF0KFwiLjBmXCIpO1xuICAgICAgICBzdmcgPSB0ZFxuICAgICAgICAgICAgLnRleHQoXCJcIilcbiAgICAgICAgICAgIC5hcHBlbmQoXCJzdmdcIilcbiAgICAgICAgICAgIC5hdHRyKFwid2lkdGhcIiwgcmFkaXVzICogMilcbiAgICAgICAgICAgIC5hdHRyKFwiaGVpZ2h0XCIsIHJhZGl1cyAqIDIpO1xuICAgICAgICBzdmcuYXBwZW5kKFwiY2lyY2xlXCIpXG4gICAgICAgICAgICAuYXR0cihcInJcIiwgZnVuY3Rpb24gKGQpIHsgcmV0dXJuIHJhZGl1c19zY2FsZShkLnZhbHVlKTsgfSlcbiAgICAgICAgICAgIC5hdHRyKFwidHJhbnNmb3JtXCIsIFwidHJhbnNsYXRlKFwiICsgcmFkaXVzICsgXCIsXCIgKyByYWRpdXMgKyBcIilcIilcbiAgICAgICAgICAgIC5zdHlsZShcImZpbGxcIiwgZnVuY3Rpb24gKGQpIHsgcmV0dXJuIGNvbG9yX3NjYWxlKGQudmFsdWUpOyB9KTtcbiAgICAgICAgc3ZnLmFwcGVuZChcInRleHRcIilcbiAgICAgICAgICAgIC50ZXh0KGZ1bmN0aW9uIChkKSB7IHJldHVybiB0ZXh0X2Zvcm1hdChkLnZhbHVlICogMTAwKTsgfSlcbiAgICAgICAgICAgIC5hdHRyKFwieFwiLCByYWRpdXMpXG4gICAgICAgICAgICAuYXR0cihcInlcIiwgcmFkaXVzKVxuICAgICAgICAgICAgLmF0dHIoXCJmaWxsXCIsIFwid2hpdGVcIilcbiAgICAgICAgICAgIC5zdHlsZShcImFsaWdubWVudC1iYXNlbGluZVwiLCBcIm1pZGRsZVwiKVxuICAgICAgICAgICAgLnN0eWxlKFwiZm9udC1zaXplXCIsIGZ1bmN0aW9uIChkKSB7IHJldHVybiB0ZXh0X3NjYWxlKGQudmFsdWUpOyB9KVxuICAgICAgICAgICAgLnN0eWxlKFwidGV4dC1hbmNob3JcIiwgXCJtaWRkbGVcIik7XG4gICAgfSxcbiAgICBcImJvb2xcIjogZnVuY3Rpb24gKHRkKSB7IHJldHVybiB0ZC50ZXh0KGZ1bmN0aW9uIChkKSB7IGlmIChkKSB7XG4gICAgICAgIHJldHVybiBcIuKclO+4j1wiO1xuICAgIH1cbiAgICBlbHNlIHtcbiAgICAgICAgcmV0dXJuIFwi4p2MXCI7XG4gICAgfSB9KTsgfVxufTtcbnZhciB1cGRhdGVfbWV0aG9kcyA9IGZ1bmN0aW9uICgpIHtcbiAgICBtZXRob2RzVGFibGUudHJhbnNpdGlvbigyNTApLnN0eWxlKFwib3BhY2l0eVwiLCBcIjAuMVwiKTtcbiAgICAvLyBkMy5zZWxlY3QoXCIjbWV0aG9kcy1sb2FkZXJcIikuc3R5bGUoXCJ2aXNpYmlsaXR5XCIsIFwidmlzaWJsZVwiKVxuICAgIG9jcHUuY2FsbChcImdldF9yZXN1bHRzXCIsIHsgXCJzdXJ2ZXlfcmVzdWx0c1wiOiBzdXJ2ZXlfcmVzdWx0cyB9LCBmdW5jdGlvbiAoc2Vzc2lvbikge1xuICAgICAgICBjb25zb2xlLmxvZyhcIllvdXIgc2Vzc2lvbiBpZCBpcyA6XCIgKyBzZXNzaW9uLmdldEtleSgpKTtcbiAgICAgICAgc2Vzc2lvbi5nZXRPYmplY3QoZnVuY3Rpb24gKG1ldGhvZHNfZGF0YSkge1xuICAgICAgICAgICAgLy8gZDMuc2VsZWN0KFwiI21ldGhvZHMtbG9hZGVyXCIpLnN0eWxlKFwidmlzaWJpbGl0eVwiLCBcImhpZGRlblwiKVxuICAgICAgICAgICAgbWV0aG9kc1RhYmxlLnRyYW5zaXRpb24oMSkuc3R5bGUoXCJvcGFjaXR5XCIsIFwiMVwiKTtcbiAgICAgICAgICAgIHZhciBjb2x1bW5zID0gbWV0aG9kc0hlYWQuc2VsZWN0QWxsKCd0aCcpXG4gICAgICAgICAgICAgICAgLmRhdGEobWV0aG9kc19kYXRhLm1ldGhvZF9jb2x1bW5zKTtcbiAgICAgICAgICAgIGNvbHVtbnMuZW50ZXIoKVxuICAgICAgICAgICAgICAgIC5hcHBlbmQoJ3RoJyk7XG4gICAgICAgICAgICBjb2x1bW5zLmV4aXQoKVxuICAgICAgICAgICAgICAgIC5yZW1vdmUoKTtcbiAgICAgICAgICAgIG1ldGhvZHNIZWFkXG4gICAgICAgICAgICAgICAgLnNlbGVjdEFsbCgndGgnKVxuICAgICAgICAgICAgICAgIC50ZXh0KGZ1bmN0aW9uIChjb2x1bW4pIHsgcmV0dXJuIGNvbHVtbi5sYWJlbDsgfSk7XG4gICAgICAgICAgICB2YXIgcm93cyA9IG1ldGhvZHNCb2R5LnNlbGVjdEFsbCgndHInKVxuICAgICAgICAgICAgICAgIC5kYXRhKG1ldGhvZHNfZGF0YS5tZXRob2RzKTtcbiAgICAgICAgICAgIHJvd3NcbiAgICAgICAgICAgICAgICAuZXhpdCgpXG4gICAgICAgICAgICAgICAgLnJlbW92ZSgpO1xuICAgICAgICAgICAgdmFyIGNlbGxzID0gcm93c1xuICAgICAgICAgICAgICAgIC5lbnRlcigpXG4gICAgICAgICAgICAgICAgLmFwcGVuZCgndHInKVxuICAgICAgICAgICAgICAgIC5tZXJnZShyb3dzKVxuICAgICAgICAgICAgICAgIC5zZWxlY3RBbGwoJ3RkJylcbiAgICAgICAgICAgICAgICAuZGF0YShmdW5jdGlvbiAocm93KSB7XG4gICAgICAgICAgICAgICAgcmV0dXJuIG1ldGhvZHNfZGF0YS5tZXRob2RfY29sdW1ucy5tYXAoZnVuY3Rpb24gKGNvbHVtbikge1xuICAgICAgICAgICAgICAgICAgICByZXR1cm4geyB2YWx1ZTogcm93W2NvbHVtbi5jb2x1bW5faWRdLCBjb2x1bW46IGNvbHVtbiB9O1xuICAgICAgICAgICAgICAgIH0pO1xuICAgICAgICAgICAgfSk7XG4gICAgICAgICAgICBjZWxscyA9IGNlbGxzLmVudGVyKClcbiAgICAgICAgICAgICAgICAuYXBwZW5kKFwidGRcIilcbiAgICAgICAgICAgICAgICAubWVyZ2UoY2VsbHMpO1xuICAgICAgICAgICAgdmFyIF9sb29wXzEgPSBmdW5jdGlvbiAoY29sdW1uKSB7XG4gICAgICAgICAgICAgICAgY29sdW1uX3JlbmRlcmVyc1tjb2x1bW4ucmVuZGVyZXJdKGNlbGxzXG4gICAgICAgICAgICAgICAgICAgIC5maWx0ZXIoZnVuY3Rpb24gKGQpIHsgcmV0dXJuIGQuY29sdW1uLmNvbHVtbl9pZCA9PSBjb2x1bW4uY29sdW1uX2lkOyB9KSk7XG4gICAgICAgICAgICB9O1xuICAgICAgICAgICAgZm9yICh2YXIgX2kgPSAwLCBfYSA9IG1ldGhvZHNfZGF0YS5tZXRob2RfY29sdW1uczsgX2kgPCBfYS5sZW5ndGg7IF9pKyspIHtcbiAgICAgICAgICAgICAgICB2YXIgY29sdW1uID0gX2FbX2ldO1xuICAgICAgICAgICAgICAgIF9sb29wXzEoY29sdW1uKTtcbiAgICAgICAgICAgIH1cbiAgICAgICAgfSk7XG4gICAgfSk7XG59O1xuIl19
