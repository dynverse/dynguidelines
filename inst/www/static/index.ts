var extract_data
var survey_results
var questions

var extract_data = function() {
    survey_results = questions
        .call(function(d) {
            extract_survey_function[d.type](d, d3.select(this), d3.select(d3.event.target))
        })
}

var methodsTable
var methodsHead
var methodsBody



/* Create survey questions */
var enter_btn_toggle = function(p, question) {
    choices_container =  question
        .append("div")

    var choices = choices_container
        .append("div")
        .attr("class", "btn-group-toggle")
        .selectAll("label")
        .data(d => p.choices)
        .enter()
        .append("label")
        .attr("class", "btn btn-primary")
        .text(d => d)
        .on("click", function() {
            if (p.type == "radio") {
                d3.select(this.parentNode)
                    .selectAll("label")
                    .classed("active", false)
            }

            d3
                .select(this)
                .classed("active", !d3.select(this).classed("active"))

            d3.event.preventDefault()

            update_data_functions[p.type](p, question)

            update_results()
        })

    choices
        .append("input")
        .attr("type", p.type)
        .attr("id", d => d)
        .attr("autocomplete", "off")

    if (p.special_choices) {
        choices_container
            .append("div")
            .attr("class", "btn-group")
            .selectAll("label")
            .data(d => p.special_choices)
            .enter()
            .append("label")
            .attr("class", "btn btn-secondary")
            .text(d => d[0])
            .on("click", function() {
                var choice_ids = eval(d3.select(this).data()[0][1])
                choices
                    .classed("active", false)
                    .filter(d => choice_ids.indexOf(d) > -1)
                    .classed("active", true)

                update_data_functions[p.type](p, question)

                update_results()
            })
    }

    if(p.default) {
        var choice_ids = p.default
        choices
            .classed("active", false)
            .filter(d => choice_ids.indexOf(d) > -1)
            .classed("active", true)
    }
}
var enter_survey_functions = {
    radio: enter_btn_toggle,
    checkbox: enter_btn_toggle,
    slider: function(p, question) {
        question
            .append("div")
            .append("input")
            .attr("type", "range")
            .attr("defaultValue", p.default)
            .attr("min", p.min)
            .attr("max", p.max)
            .attr("step", p.step)
            .on("change", d => {
                update_data_functions[p.type](p, question)
                update_results()
            })

        question.append("span")
            .classed("slider-label", true)

        eval('p.label = ' + p.label) // process label function

        question.datum(p)
    }
}

/* Update data from survey */
var update_data_functions = {
    radio: function(p, question) {
        var activeOption = question
            .selectAll("label.btn.active")

        choice = null
        if (activeOption.size() == 1) {
            choice = activeOption.data().map(d=>d)[0]
        }

        p.value = choice

        question.datum(p)

        // update_results()
    },
    checkbox: function(p, question) {
        var activeOption = question
            .selectAll("label.btn.active")

        choices = []
        if (activeOption.size() > 0) {
            choices = activeOption.data().map(d=>d)
        }

        p.value = choices

        question.datum(p)

        // update_results()
    },
    slider: function(p, question) {
        p.value = question.select("input").property("value")

        question.select("label.slider-label")
            .text(p.label(p.value))

        question.datum(p)
    }
}

/* Update results of survey */
var update_results = function() {
    /* get results, only for active questions */
    /* then check dependencies */
    /* until convergence */
    /* do this very stupidly for now */
    for (i=0; i<10; i++) {
        survey_results = _.fromPairs(
            questions
                .filter(function(d) {return !d3.select(this).classed("inactive-question")})
                .data()
                .map(x => [x.question_id, x.value])
        )

        check_dependencies()
    }

    update_methods()
}

/* Check dependencies between questions */
var check_dependencies = function() {
    questions
        .classed("inactive-question", d => !eval(d.activeIf[0]))
}



/* Load data and process questions */
$.getJSON("../R/questions/json", function(data) {
    // console.log(data)

    questions_data = data.questions;

    var category_data = d3.nest()
        .key(d => d.category)
        .entries(questions_data)

    survey = d3.select("#survey")

    // categories
    var category_pills = survey
        .append("ul")
        .attr("class","nav nav-tabs nav-justified")
        .selectAll("li")
        .data(category_data)
        .enter()
        .append("li")
        .classed("nav-item", true)
        .append("a")
        .attr("class", "nav-link")
        .classed("active", (d,i) => i == 0)
        .attr("id", d => d.key + "-tab")
        .attr("data-toggle","pill")
        .attr("href", d => "#" + d.key)
        .text(d => d.key)

    var categories = survey
        .append("div")
        .attr("class", "tab-content")
        .selectAll("div")
        .data(category_data)
        .enter()
        .append("div")
        .attr("class", "tab-pane")
        .classed("show", (d,i) => i == 0)
        .classed("active", (d,i) => i == 0)
        .attr("id", d => d.key)

    // questions
    questions = categories
        .selectAll("div")
        .data(d => d.values)
        .enter()
        .append("div")
        .classed("form-group", true)

    questions
        .append("label")
        .text(d => d.title)

    questions
        .each(function(d) {
            enter_survey_functions[d.type](d, d3.select(this))
        })
        .each(function(d) {update_data_functions[d.type](d, d3.select(this))} // Initial update

    // table
    methodsTable = d3.select('#methods')
    methodsHead = methodsTable.append('thead')
    methodsBody = methodsTable.append('tbody');

    update_results()
    check_dependencies()
})



/* Table */
/* Render table columns */
topology_inference_type_colors = {"free":"green", "fixed":"red", "parameter":"orange"}
var column_renderers = {
    "text": (td) => td.text(d => d.value),
    "topology_inference_type": (td) => td.text(d => d.value).style("color", d => topology_inference_type_colors[d.value]),
    "benchmark_score": (td) => {
        var color_scale = d3
            .scaleSequential(d3.interpolateInferno)
            .domain([0, 1])

        var radius = 15

        var radius_scale = d3
            .scaleSqrt()
            .domain([0, 1])
            .range([1, radius])

        var text_scale = d3
            .scaleSqrt()
            .domain([0, 1])
            .range([2, 20])

        var text_format = d3.format(".0f")

        svg = td
            .text("")
            .append("svg")
            .attr("width", radius*2)
            .attr("height", radius*2)

        svg.append("circle")
            .attr("r", d => radius_scale(d.value))
            .attr("transform", `translate(${radius},${radius})`)
            .style("fill", d => color_scale(d.value))

        svg.append("text")
            .text(d => text_format(d.value * 100))
            .attr("x", radius)
            .attr("y", radius)
            .attr("fill", "white")
            .style("alignment-baseline", "middle")
            .style("font-size", d=>text_scale(d.value))
            .style("text-anchor", "middle")
    },
    "bool": (td) => td.text(d => if(d) {return "✔️"} else {return "❌"})
}

/* Update table */
var update_methods = function() {
    methodsTable.transition(250).style("opacity", "0.1")

    ocpu.call("get_results", {"survey_results":survey_results}, function(session) {

        console.log("Your session id is :" + session.getKey())

        session.getObject(function(methods_data) {

            methodsTable.transition(1).style("opacity", "1")

            var columns = methodsHead.selectAll('th')
    		  .data(methods_data.method_columns)

            columns.enter()
              .append('th')

            columns.exit()
              .remove()

            methodsHead
                .selectAll('th')
    		    .text(function (column) { return column.label });

            // remove old tds
            methodsBody
                .selectAll('tr')
                .html("")

            // add data to each row
            var rows = methodsBody
                .selectAll('tr')
                .data(methods_data.methods)

            rows
                .exit()
                .remove()

            // render columns
            var cells = rows
                .enter()
                .append('tr')
                .merge(rows)
                .selectAll('td')
                .data(function (row) {
                    return methods_data.method_columns.map(function (column) {
                        return {value:row[column.column_id] column: column};
                    });
                })

            cells = cells.enter()
                .append("td")
                .merge(cells)


            for (let column of methods_data.method_columns) {
                column_renderers[column.renderer](
                    cells
                        .filter(d => d.column.column_id == column.column_id)
                )


            }
        })
    })
}
