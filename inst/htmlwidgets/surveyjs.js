HTMLWidgets.widget({

  name: 'surveyjs',

  type: 'output',

  factory: function(el, width, height) {

    var survey;

    return {

      getData: function(){
        if(typeof survey !== 'undefined'){
          return survey.data;
        }
      },

      renderValue: function(x) {

          if(typeof survey === 'undefined'){
            survey = new Survey.Model(x.model);
            jQuery(el).Survey({ model: survey });
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
