var indeterminateCheckbox = new Shiny.InputBinding();


function setIndeterminateCheckboxValue(input, value) {
  if (value == "indeterminate") {
    input.prop("indeterminate", true);
    input.prop("readOnly", true);
    input.prop('checked',false);
  } else if (value == "true") {
    input.prop('readOnly',true);
    input.prop('indeterminate',false);
    input.prop('checked',true);
  } else {
    input.prop('readOnly',true);
    input.prop('indeterminate',false);
    input.prop('checked',false);
  }
}


$.extend(indeterminateCheckbox, {
  find: function(scope) {
    return $(scope).find(".indeterminate-checkbox");
  },
  getValue: function(el) {
    var input = $(el).find("input");

    /* if already setup in subscribe, give value, otherwise give initial */
    if (input.data("setup")) {
      if (input.prop("indeterminate")) {
        return "indeterminate";
      } else if (input.prop("checked")) {
        return "true";
      } else {
        return "false";
      }
    } else {
      input.data("initial")
    }


  },
  setValue: function(el, value) { var input = $(el).find("input"); setIndeterminateCheckboxValue(input, value) },
  subscribe: function(el, callback) {
    var input = $(el).find("input");
    input.on("click", function(e) {
      var input = $(this);
      if (input.prop("readOnly")) {
        input.prop("checked", false)
        input.prop("readOnly", false)
      } else if (!input.prop("checked")) {
        input.prop("indeterminate", true)
        input.prop("readOnly", true)
      }

      callback();
    })

    /* set initial value */
    setIndeterminateCheckboxValue(input, input.data("initial"));
    input.data("setup", true)
  },
  unsubscribe: function(el) {

  },
  getRatePolicy: function() {
    return {
      policy: "throttle",
      delay: 1000
    };
  }
});

Shiny.inputBindings.register(indeterminateCheckbox);