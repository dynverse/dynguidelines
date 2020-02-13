// Listener functions for the lock buttons
var lockListener = function(e) {
  $(this).toggleClass("locked")

  var id = $(this).attr("id");

  // find the input with the same id
  var slider = $(this).parent().parent().find("input#" + id).data("ionRangeSlider");
  slider.update({block:!slider.options.block});
}




var balancingSliders = new Shiny.InputBinding();
$.extend(balancingSliders, {
  find: function(scope) {
    return $(scope).find(".balancing-sliders");
  },
  getValue: function(el) {
    var inputs = $(el).find(".js-range-slider");
    var vals = inputs.map(function() {return Number($(this).val())}).get();
    var ids = inputs.map(function() {return $(this).attr("id")}).get();

    return _.zipObject(ids, vals);
  },
  setValue: function(el, value) {
    $(el).text(value);
  },
  subscribe: function(el, callback) {
    // activate lock listener
    $(el).find("button").on("click", lockListener)

    // activate drag listener
    $(el).find("input").on("change.balancing-sliders", function(e) {
      // get the changed input and the non-changed inputs (otherInputs)
      var changedInput = $(e.currentTarget);

      if (changedInput.attr("data-dependent") != "true") {
        // fixed inputs = changedInput + all locked inputs
        var otherInputs = $(el).find(".js-range-slider:not(#" + changedInput.attr("id") + ")");

        // these inputs can be changed
        var changeableInputs = otherInputs.filter(function() {
          return !$(this).data("ionRangeSlider").options.block;
        });

        // these inputs cannot be changed
        var fixedInputs = otherInputs.filter(function() {
          return $(this).data("ionRangeSlider").options.block;
        });
        fixedInputs = fixedInputs.add(changedInput)

        // make the other inputs "dependent", so that their change event won't induce a recursion
        changeableInputs.attr("data-dependent", "true");

        // calculate the scaling of all other values, based on what is left over of the values of fixedInputs
        var fixedVals = fixedInputs.map(function() {return Number($(this).val())});
        var fixedSum = _.sum(fixedVals)

        var changeableVals = changeableInputs.map(function() {return Number($(this).val())});
        var changeableSum = _.sum(changeableVals);

        var scale = (1-fixedSum) / changeableSum;

        // special case where a slider goes out of possible bounds (eg. everything is locked)
        // this is also triggered when there are no other available sliders
        // this will reset the value of the changed slider back to its original position
        if ((fixedSum > 1 && changeableSum === 0) || (changeableInputs.length === 0)) {
          changedInput.attr("data-dependent", "true");
          changeableInputs.attr("data-dependent", "false");
          var changedVal = Number(changedInput.val());

          changedInput.data("ionRangeSlider").update({"from": changedVal + (1-fixedSum)});

        // special case where all otherVals are 0, but the fixedVal has just become lower than 1
        // in that case, the otherVals should become (1-changeVal)/nOthers
        } else if (fixedSum < 1 && changeableSum === 0) {
          changeableInputs.each(function() {
            var changeableVal = (1 - fixedSum) / changeableVals.length;
            $(this).data("ionRangeSlider").update({"from":changeableVal});
          });

        // regular case
        } else {
          changeableInputs.each(function() {
            var changeableVal = $(this).val() * scale;
            $(this).data("ionRangeSlider").update({"from":changeableVal});
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