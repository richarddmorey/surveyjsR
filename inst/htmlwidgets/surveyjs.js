HTMLWidgets.widget({

  name: 'surveyjs',

  type: 'output',

  factory: function(el, width, height) {

    var survey;

    return {

      getObject: function(){
        if(typeof survey !== 'undefined'){
          return {
            el: el,
            survey: survey
          }
        }
      },

      renderValue: function(x) {

          if(typeof survey === 'undefined'){
            survey = new Survey.Model(x.model);
            jQuery(el).Survey({ model: survey });
            const ev = new CustomEvent("surveyDefined", {
              detail: {
                el: el,
                survey: survey
              }
            });
            document.querySelector("body").dispatchEvent(ev);

          }else{
            survey.data = x.data
          }
      },

      resize: function(width, height) {

        // TODO: code to re-render the widget with a new size

      }

    };
  }
});
