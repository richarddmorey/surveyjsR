const summerWidgetJSON = {
  name: "summeredit",
  widgetIsLoaded: function () {
   return typeof $('body').summernote == "function";
  },
  isFit: function (question) {
     return question.getType() == "summeredit";
  },
  init: function() {
    Survey.Serializer.addClass("summeredit", [], null, "empty");
    Survey.Serializer.addProperty("summeredit", {
      name: "summerOpts",
      type: "object",
      category: "general",
      default: {
        placeholder: "Type your text here..."
      }
    });
  },
  htmlTemplate: "<div style='white-space: normal;'><div class='summereditor-container' /></div>",
  willUnmount: function(question, element){
    var el = $(element).children(".summereditor-container")[0];
    $(el).summernote('destroy');
  },
  afterRender: function(question, element) {
    var el = $(element).children(".summereditor-container")[0];
    $(el).summernote(question.summerOpts);
    var changingValue = false;
    var updateQuestionValue = function () {
      if (changingValue) return;
      changingValue = true;
      question.value = $(el).summernote('code');
      changingValue = false;
    };
    $(el).on('summernote.change', updateQuestionValue);
    question.valueChangedCallback = function () {
      if (changingValue) return;
      changingValue = true;
      $(el).summernote('code', question.value || '');
      changingValue = false;
    };
    var updateReadOnly = function () {
      if(question.isReadOnly){
        $(el).summernote('disable');
      }else{
        $(el).summernote('enable');
      }
    };
    updateReadOnly();
    question.readOnlyChangedCallback = function () {
      updateReadOnly();
    };
  }
};

Survey.CustomWidgetCollection.Instance.addCustomWidget(summerWidgetJSON, "customtype");
