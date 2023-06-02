# surveyjsR

This R package allows creation of [surveyjs](https://surveyjs.io/) survey models, and uses these survey models in widgets to print the survey to HTML (e.g. in Rmarkdown).

## Installation

```
install.packages('devtools')
devtools::install.github('richarddmorey/surveyjsR', dependencies = TRUE)
```


## Example of use
```

s = surveyjsR::survey$new(
  settings = list(title = 'Hi there!')
)

s$add(name = 'q1', type = 'text', title = 'What is your name?')
s$add(name = 'q2', type = 'dropdown', title = 'Pizza toppings?',
      choices = list(
        "Olives",
        "Mozzarella",
        "Mushrooms",
        "Red pepper",
        "Pepperoni",
        "Shrimps"),
      correctAnswer = "Mozzarella"
)
s$add(name = 'q3', type = 'summeredit', title = "Describe in detail your opinion of pizza")

surveyjsR::surveyjs(s)
```

The above code will create a survey in an `htmlwidgets` object. You can, for instance, put it into an Rmarkdown file and the survey will be embeded in the compiled HTML document. It should look something like this:

<img width="791" alt="image" src="https://github.com/richarddmorey/surveyjsR/assets/1284826/66f296b5-41de-4c53-96ce-7f26cc048419">

Currently, the package mostly just creates the JSON code for the survey model and passes it to the widget. For now, the package does not know anything about various question types, etc; you have to know them from the [surveyjs documentation](https://surveyjs.io/form-library/documentation/overview). I recommend looking at the [examples](https://surveyjs.io/form-library/examples/nps-question/reactjs) (in particular the [survey model](https://surveyjs.io/form-library/documentation/design-survey/create-a-simple-survey) JSON files, typically called `json.js`) to get a sense of how to form proper surveys.

Currently, you can create a `$new()` survey object, `$add()` a question, `$remove()` questions, change the sorting using `$sortkeys()`, join questions using `$gather_to_panel()` and `$gather_to_page()`. You can also `$validate()` the object, output the survey data frame with `$survey()`, or output the whole survey structure (including the surveyjs survey model) with `$model()`. 

The widget is printed from the survey object with `surveyjsR::surveyjs()`.

## Extra surveyjs widgets

The package includes the `quilledit` and `summeredit` question types, which create [quilljs](https://quilljs.com/) and [summernote](https://summernote.org/) open response editors, respectively.



