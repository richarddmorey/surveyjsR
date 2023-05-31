const quillWidgetJSON = {
  name: "quilledit",
  widgetIsLoaded: function () {
   return typeof Quill == "function";
  },
  isFit: function (question) {
     return question.getType() == "quilledit";
  },
  init: function() {
    Survey.Serializer.addClass("quilledit", [], null, "empty");
    Survey.Serializer.addProperty("quilledit", {
      name: "quillOpts",
      type: "object",
      category: "general",
      default: {
        placeholder: "Type your text here...",
        theme: 'snow',
        modules: {
          toolbar: [
            [{"header":[1,2,false]}],
            ["bold","italic","underline"],
            ["image","code-block"]
          ]
        }
      }
    });
  },
  htmlTemplate: "<div><div class='quilleditor-container' /></div>",
  afterRender: function(question, element) {
    var editor = element.getElementsByClassName("quilleditor-container");
    var quill = new Quill(editor[0], question.quillOpts);
    var changingValue = false;
    var updateQuestionValue = function () {
      if (changingValue) return;
      changingValue = true;
      question.value = JSON.stringify(quill.getContents());
      changingValue = false;
    };
    quill.on('text-change', updateQuestionValue);
    question.valueChangedCallback = function () {
      if (changingValue) return;
      changingValue = true;
      const v = question.value ? JSON.parse(question.value) : {ops:[]};
      quill.setContents(v);
      changingValue = false;
    };
    var updateReadOnly = function () {
      quill.enable(!question.isReadOnly);
    };
    updateReadOnly();
    question.readOnlyChangedCallback = function () {
      updateReadOnly();
    };
  }
};

 Survey.CustomWidgetCollection.Instance.addCustomWidget(quillWidgetJSON, "customtype");
