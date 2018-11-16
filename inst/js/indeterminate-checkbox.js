var indeterminateCheckbox = new Shiny.InputBinding();


function setIndeterminateCheckboxValue(input, value) {
  if (value == "indeterminate") {
    input.prop("indeterminate", true);
    input.prop("readOnly", true);
    input.prop('checked',true);
  } else if (value == "true") {
    input.prop('readOnly',false);
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
      return input.data("initial");
    }
  },
  setValue: function(el, value) {
    var input = $(el).find("input");
    setIndeterminateCheckboxValue(input, value);
  },
  subscribe: function(el, callback) {
    var input = $(el).find("input");
    input.on("change", function(e) {
      var input = $(this);

      console.log("checked: ", input.prop("checked"));
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
  },
  receiveMessage: function(el, data) {
    var input = $(el).find("input");

    if (data.hasOwnProperty("value")) {
      setIndeterminateCheckboxValue(input, data["value"])
    }

    input.trigger('change');
  }
});

Shiny.inputBindings.register(indeterminateCheckbox, 'shiny.indeterminateCheckbox');