var lockListener = function(e) {
  console.log("hi")
  $(e.currentTarget).toggleClass("locked")

  e.stopPropagation();
}




var balancingSliders = new Shiny.InputBinding();
$.extend(balancingSliders, {
  find: function(scope) {
    return $(scope).find(".balancing-sliders");
  },
  getValue: function(el) {
    var inputs = $(el).find(".js-range-slider");
    var vals = inputs.map(function() {return Number($(this).val())}).get();

    return vals;
  },
  setValue: function(el, value) {
    $(el).text(value);
  },
  subscribe: function(el, callback) {

    $(el).find("input").find("finish.balancing-sliders", function(e) {
      console.log("jhsldkjfhqlsdkjf")
    })

    $(el).find("input").on("change.balancing-sliders", function(e) {
      // get the changed input and the non-changed inputs (otherInputs)
      var changedInput = $(e.currentTarget);
      $(el).find("span.irs-slider.single").on("click", lockListener)

      if (changedInput.attr("data-dependent") != "true") {
        var otherInputs = $(el).find(".js-range-slider:not(#" + changedInput.attr("id") + ")");

        // make the other inputs "dependent", so that their change event won't induce a recursion
        otherInputs.attr("data-dependent", "true");

        window.ch = changedInput;

        // calculate the scaling of all other values, based on what is left over if the values of the current slider chages
        var changedVal = Number(ch.val());
        var otherVals = otherInputs.map(function() {return Number($(this).val())});

        var otherSum = _.sum(otherVals);
        var otherScale = (1-changedVal) / otherSum;

        // special case where all otherVals are 0, but the changedVal is lower than 1
        // in that case, the otherVals should become (1-changeVal)/nOthers
        if (changedVal < 1 && otherSum == 0) {
          otherInputs.each(function() {
            var otherVal = (1 - changedVal) / otherVals.length;
            $(this).data("ionRangeSlider").update({"from":otherVal});
          });
        } else {
          otherInputs.each(function() {
            var otherVal = $(this).val() * otherScale;
            $(this).data("ionRangeSlider").update({"from":otherVal});
          });
        }

        callback(true);
      } else {
        changedInput.attr("data-dependent", "false");
      }

      //
    });
  },
  unsubscribe: function(el) {
    $(el).off(".balancing-sliders");
  },
  getRatePolicy: function() {
    return {
      policy: "throttle",
      delay: 1000
    };
  }
});

Shiny.inputBindings.register(balancingSliders);