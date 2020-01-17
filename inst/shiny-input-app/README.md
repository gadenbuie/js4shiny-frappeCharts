
# Building a Shiny Input

In this project, we’re going to create a typing speed app using a custom
Shiny input. The app will give users typing prompts, monitor their
typing speed, and use a Frappe Chart line chart to show their speed over
time as they type.

## Setup a folder for our app inside the frappeCharts package

  - [changelog: 113340](https://github.com/gadenbuie/js4shiny-frappeCharts/commit/113340074c3af9c2cdf46cd7787829d4ec56bfcf)

Create the directory `inst/shiny-input-app` and add `app.R` and
`typing.js`.

``` r
usethis::use_directory("inst/shiny-input-app")
file.create("inst/shiny-input-app/app.R")
file.create("inst/shiny-input-app/typing.js")
```

## Create a basic Shiny app with a typing area

  - [changelog:
    ff3a96](https://github.com/gadenbuie/js4shiny-frappeCharts/commit/ff3a962f7e6d16a75ebdb620aac0fdfc9949086e)
  - Checkpoint: `js4shiny::repl_example("shiny-typing-01")`

We’ll start with typical Shiny inputs.

``` r
library(shiny)

ui <- fluidPage(
  textAreaInput("typing", "Type here..."),
  verbatimTextOutput("debug")
)

server <- function(input, output, session) {
  output$debug <- renderPrint(input$typing)
}

shinyApp(ui, server)
```

Run this app and type in the box.

## Create our own typingSpeedInput()

  - [changelog:
    b71080](https://github.com/gadenbuie/js4shiny-frappeCharts/commit/b7108029b58635652ce87f3e1ea9a2c5a6232020)

Use Shiny’s `textAreaInput()` to get the template for our own
`typingSpeedInput()`

``` r
shiny_text_input <- shiny::textAreaInput(
  "INPUT", "LABEL", placeholder = "PLACEHOLDER"
)
cat(format(shiny_text_input))
```

    ## <div class="form-group shiny-input-container">
    ##   <label class="control-label" for="INPUT">LABEL</label>
    ##   <textarea id="INPUT" class="form-control" placeholder="PLACEHOLDER"></textarea>
    ## </div>

``` r
typingSpeedInput <- function(inputId, label, placeholder = NULL) {
  .label <- label
  htmltools::withTags(
    div(
      class = "form-group typing-speed",
      label(class = "control-label", `for` = inputId, .label),
      textarea(id = inputId, class = "form-control", placeholder = placeholder)
    )
  )
}
```

Two points:

1.  Notice that I used `htmltools::withTags()`, which makes it easier to
    write multiple tags at once. But it has the downside of masking the
    `label` argument of `typingSpeedInput()`. Hence, the first line
    `.label <- label`.

2.  I added `.typing-speed` to our parent container so that we can find
    or style our custom input.

Replace the `textAreaInput()` with our new `typingSpeedInput()` and run
the app. It works the same\! Wait, why?

``` r
ui <- fluidPage(
  # textAreaInput("typing", "Type here..."),
  typingSpeedInput("typing", "Type here..."),
  verbatimTextOutput("debug")
)
```

## Start creating an input binding for `typingSpeedInput()`

  - [changelog: 02adb8](https://github.com/gadenbuie/js4shiny-frappeCharts/commit/02adb896c50a97ebe7f9a7fef2a6f00488f9418d)
  - Checkpoint: `js4shiny::repl_example("shiny-typing-02")`

Now we can open `typing.js` and create a Shiny input binding.

If you used `js4shiny::snippets_install()`, you have a
`ShinyInputBinding` snippet that provides a template for you. Or you can
copy the chunk below.

<details>

<summary>Shiny Input Binding Template</summary>

``` js
// Ref: https://shiny.rstudio.com/articles/building-inputs.html
// Ref: https://github.com/rstudio/shiny/blob/master/srcjs/input_binding.js

const bindingName = new Shiny.InputBinding();

$.extend(bindingName, {
  find: function(scope) {
    // Specify the selector that identifies your input. `scope` is a general
    // parent of your input elements. This function should return the nodes of
    // ALL of the inputs that are inside `scope`. These elements should all
    // have IDs that are used as the inputId on the server side.
    return scope.querySelectorAll("inputBindingSelector");
  },
  getValue: function(el) {
    // For a particular input, this function is given the element containing
    // your input. In this function, find or construct the value that will be
    // returned to Shiny. The ID of `el` is used for the inputId.

    // e.g: return el.value
    return 'FIXME';
  },
  setValue: function(el, value) {
    // This method is used for restoring the bookmarked state of your input
    // and allows you to set the input's state without triggering reactivity.
    // Basically, reverses .getValue()

    // e.g.; el.value = value
    console.error('bindingName.setValue() is not yet defined');
  },
  receiveMessage: function(el, data) {
    // Given the input's container and data, update the input
    // and its elements to reflect the given data.
    // The messages are sent from R/Shiny via
    // R> session$sendInputMessage(inputId, data)
    console.error('bindingName.receiveMessage() is not yet defined');

    // If you want the update to trigger reactivity, trigger a subscribed event
    $(el).trigger("change")
  },
  subscribe: function(el, callback) {
    // Listen to events on your input element. The following block listens to
    // the change event, but you might want to listen to another event.
    // Repeat the block for each event type you want to subscribe to.

    $(el).on("change.bindingName", function(e) {
      // Use callback() or callback(true).
      // If using callback(true) the rate policy applies,
      // for example if you need to throttle or debounce
      // the values being sent back to the server.
      callback();
    });
  },
  getRatePolicy: function() {
    return {
      policy: 'debounce', // 'debounce', 'throttle' or 'direct' (default)
      delay: 100 // milliseconds for debounce or throttle
    };
  },
  unsubscribe: function(el) {
    $(el).off(".bindingName");
  }
});

Shiny.inputBindings.register(bindingName, 'pkgName.bindingName');
```

</details>

  - [changelog: 6fffc2](https://github.com/gadenbuie/js4shiny-frappeCharts/commit/6fffc2337ad475af2ab09ee571014afdbb680fb6)

If you use the snippet, it automatically walks you through the first
pass of parts that need to be changed. If you copied the template, you
need to find and replace all:

  - `bindingName`: the name of the JavaScript object with the specifics
    of your Shiny input. This name isn’t user facing, but helps Shiny
    keep track of which the inputs in an app.
    
    We’ll call ours `typingSpeed`

  - `inputBindingSelector`: this is the CSS selector that can be used to
    find the HTML element of your input. The element you find here is
    the element in your input’s HTML that has the `id` with the input’s
    `inputId`.
    
    In our case, we want the `textarea` element that’s a descendent of
    `.typing-speed`, so we use
    
    ``` css
    .typing-speed textarea
    ```

  - `change`: This is the event that will be listened to by Shiny to
    know when the input has updated. For our typing speed input, we’re
    going to listen to the `keyup` event.

  - `pkgName`: if you’re writing this input as part of a package, use
    your package name. It’s not critical; this just provides some
    namespacing in case there’s another package that impelements an in
    put with the same `bindingName`.
    
    Here we use `js4shiny`.

## Add a dependency to the typing input

  - [changelog: 0be8ef](https://github.com/gadenbuie/js4shiny-frappeCharts/commit/0be8efb83bef664f707b8716eab1d5478de933c7)

To have `typing.js` included with our input, we use
`htmltools::htmlDependency()` inside our input function. This guarantees
that `typing.js` is loaded once per page and is included whenever a
`typingSpeedInput()` is created.

``` r
# I used the htmldeps snippet for this
htmltools::htmlDependency(
  name = "typingSpeed",
  version = "0.0.1",
  src = ".",
  script = "typing.js",
  all_files = FALSE
)
```

Now when you run the app, you’ll see `"FIXME"` as the output of
`input$typing`. That’s our next step.

## Explore the input binding

Read through the comments of the input binding template. They explain
the role of each function.

In a nutshell, as a Shiny input author, your job is to tell Shiny a few
key things:

1.  **`.find()`** — How to find your input elements on the page

2.  **`.subscribe()`** — What browser events will trigger an update from
    your input.
    
    The template show how to listen `'change'` events, but you may want
    to listen for a different event (or multiple events\!), like a
    button `'click'` or a `'keydown'` or `'keyup'` event.

3.  **`.getRatePolicy()`** — How often to send updates back to the
    server.
    
    There are three options here: `'debounce'`, `'throttle'`, and
    `'direct'`. See the [shiny debounce
    documentation](https://shiny.rstudio.com/reference/shiny/latest/debounce.html)
    and my slides for more info.

4.  **`.getValue()`** — What is the value of your input?
    
    This method is called whenever a subscribed event happens, and if
    the value of the input has changed it is reported back to Shiny.
    It’s up to you, though, in this function, to read the HTML to
    determine the current value of the input and to construct the data
    that’s sent back to the server.

5.  **`.receiveMessage()`** - Let the input receive messages from the
    server.
    
    This works just like custom message handles, except that you call
    `shiny::sendInputMessage(inputId, data)` on the server side. This
    method receives the data and can be used to update the state of the
    input from values sent by the server.
    
    Ideally you would write an `update<InputName>()` function that wraps
    `shiny::sendInputMessage()`. This is how
    [`updateTextInput()`](https://github.com/rstudio/shiny/blob/a2a4e40821b9811a40e461f67e3622196d8aa726/srcjs/input_binding_text.js#L31-L41)
    and others works.
    
    If you want the updated values to flow through the reactive graph
    (you probably do), then you need to trigger a subscribed event after
    you make the changes. This calls `.getValue()` which sets the input
    values and reports back to the server.

6.  **`.setValue()`** — This method takes a value sent from your input
    and updates your HTML to match.
    
    This method is required to be able to restore the input from a
    bookmarked state. It also allows you to set the input’s value
    without triggering reactivity.

### Read the input binding for `checkboxInput()`

The input binding JavaScript for `checkboxInput()` is available in the
[Shiny GitHub
repository](https://github.com/rstudio/shiny/blob/a2a4e40821b9811a40e461f67e3622196d8aa726/srcjs/input_binding_checkbox.js).
Read through it and discuss what each method does.

## Setup our input binding

Now it’s time to setup our input binding. Replace `FIXME` with
`el.value`.
([changelog: 85205f](https://github.com/gadenbuie/js4shiny-frappeCharts/commit/85205fbcbb93ccb506558e62f73a8f0d6a88c83c))

### Your Turn

The `.value` of a `textarea` element is a string containing the text
inside the element.

Update `.getValue()` to

1.  Return the number of characters the user has typed ([changelog:
    b3958d](https://github.com/gadenbuie/js4shiny-frappeCharts/commit/b3958d5e3f60fbac3a0100673696bd413a276fb4))

2.  Return the number of words the user has entered ([changelog:
    e3fa48](https://github.com/gadenbuie/js4shiny-frappeCharts/commit/e3fa485bb60853e391302289213d3cd5f0846b3e))

3.  Create variables for both number of characters and words and return
    both in an object ([changelog:
    edfb93](https://github.com/gadenbuie/js4shiny-frappeCharts/commit/edfb9399eae5207cc4a3ef9b48e62c9c92230477))

### Tracking the timing

You can add your own properties and methods to the input binding. As a
convention, the property or method names start with `_`. Let’s add a
`_timing` property that with initialize with `null`.
([changelog: 9568fd](https://github.com/gadenbuie/js4shiny-frappeCharts/commit/9568fdcd06fa1fe1815dc48bf6efb03f9af68b29))

``` js
$.extend(typingSpeed, {
  _timing: null,
  // ...
}
```

Inside our input binding methods, we can now access `this._timing` to
get the timing property for the input. (And a new input binding is
created for each input, so if there are multiple typingSpeed inputs,
we’ll automatically get the right `_timing` value.)

For methods called on objects, `this` refers the the parent object.

Try the `repl_example("this-simple")` example to see how this works.

<details>

<summary>`repl_example("this-simple")`</summary>

``` js
const person = {
  name: "Christelle",
  sayHello: function() {
    console.log(`Hello, ${this.name}!`)
  }
}

person.sayHello()

person.name = 'Mateo'
person.sayHello()
```

</details>

#### Your Turn: Start `_timing`

We’re going to use this property to start timing the user’s typing. On
the one hand, when they delete all the text in the text area, we want to
reset the timers. On the other hand, when they start typing, we want to
know when they started.

Update the `.getValue()` method so that whenever

  - there are no characters in the textarea

`this._timing` is set to `null` and a `null` value is returned to Shiny.

Similarly, when

  - `this._timing` is `null`
  - and there are any characters in the text area

`this._timing` is updated to the current time (`Date.now()`) and a
`null` value is returned.

Include the timing value in the data returned to Shiny so that you can
verify it’s working.

([changelog: 073186](https://github.com/gadenbuie/js4shiny-frappeCharts/commit/073186bcc9741cb2494b4b9a17042ea5716a7dd5))

### Your Turn: How Fast?

Now you’re ready to calculate typing statistics.

Here’s the idea: each time the user presses a key, we calculate the
`elapsed` time in seconds since they started typing.

Then, from that value calculate:

  - words per minute (`wpm`)
  - characters per second (`cps`)

Return an object/list with

  - `wpm`,
  - `cps`,
  - the current timestamp as `time` and
  - the `text` in the input

([changelog:
fa02cb](https://github.com/gadenbuie/js4shiny-frappeCharts/commit/fa02cb2314fa58ea714002072be0f78da2c6aa82))

### Your Turn: Hold your horses

How does the app report the initial typing speed rates?

Add another `if` statement to continue to return `null` until there are
at least 3 words in the text box.

  - [changelog: 9f9153](https://github.com/gadenbuie/js4shiny-frappeCharts/commit/9f915337a2ab55c7e94eaa5cfa454c21bc8d72ba)

### Your Turn: Find a rate policy balance

At this point, we are streaming values straight from the browser to the
server. This is probably a bit much.

Change `callback()` to `callback(true)` in `subscribe()`.

Try various settings of

  - `policy`: `debounce`, `throttle` or `direct`.

Find a good delay rate.

  - [changelog: 8519d7](https://github.com/gadenbuie/js4shiny-frappeCharts/commit/8519d729bca13c730528a287c3601c4df2828e4f)

### Almost done: Implement `receiveMessage()`

There’s not much we’d want to do from the server side in terms of
updating the typing area. But maybe we’d like to be able to add a
“Reset” button.

Write a method that, when it recieves a `true` value from the server,
clears the text input area.

Add a reset button to your app that uses `shiny$sendInputMessage()` to
send `typing` a `TRUE` whenever the button is clicked.

  - [changelog: 269e4e](https://github.com/gadenbuie/js4shiny-frappeCharts/commit/269e4ebdc48a66ecf7466192076c4fa259582cc6)

Once you get that working, refactor it into a `resetTypingSpeed()`
function.

This function should take an `inputId` and a `session` object. Use
`shiny::getDefaultReactiveDomain()` for the default `session` value.

  - [changelog: 644a8b](https://github.com/gadenbuie/js4shiny-frappeCharts/commit/644a8b6c2e8f3719bda89cbd7801a90401c9eadb)

### Final Step: Extra inputs on the side

In our final app, we’re going to want to know on the Shiny server side
when the user has reset the typing input. We can watch for the typing
speed input to be `NULL`, but ultimately it’s a bit of a hassle to turn
`is.null()`/`!is.null()` into an event.

It will be easier for us if we can simply send an `{inputId}_reset`
event to the server when the input has changed.

Try adding a `Shiny.setInputValue()` that sends the current time to the
input ID `{inputId}_reset` when the `this._timing` property is reset.
Also, update the `debug` output to monitor `input$typing_reset` as well.

  - [changelog:
    ccc35d](https://github.com/gadenbuie/js4shiny-frappeCharts/commit/ccc35d6978dabf4a709a795f89719cc353ac72bd)

## Use our frappeChart widget to show speed over time

  - Checkpoint (completed JS):
    `js4shiny::repl_example("shiny-typing-03")`
  - Checkpoint (with frappeChart):
    `js4shiny::repl_example("shiny-typing-04")`

### First pass

  - [changelog:
    fe55bf](https://github.com/gadenbuie/js4shiny-frappeCharts/commit/fe55bf588400f8586472b1050c0da1b931bad1c3)

We’re going to drop-in our `frappeChart` package to add a dynamic plot
showing typing speed over time.

If you didn’t complete the `frappeChart` project earlier in the
workshop, you can run the code below to install the package in the state
I hope it’s in by the time we finish that section.

``` r
devtools::install_github("gadenbuie/js4shiny-frappeCharts@pkg")
```

Our first pass is going to add a chart, but it’s not going to look super
great.

To get setup, we’re going to cache the `time` and `wpm` sent from the
browser in a `reactiveValues` object that we can coerce into a
`data.frame`.

``` r
# server
wpm <- reactiveValues(time = c(), wpm = c())

observeEvent(input$typing_reset, {
  wpm$time <- c()
  wpm$wpm <- c()
})

observeEvent(input$typing, {
  req(input$typing)
  wpm$time <- c(wpm$time, input$typing$time)
  wpm$wpm <- c(wpm$wpm, input$typing$wpm)
})
```

We add the `frappeCharts` output to our UI

``` r
# ui
frappeCharts::frappeChartOutput("chart_typing_speed")
```

and use the following settings to render the `wpm` in “real time”

``` r
# server
output$chart_typing_speed <- frappeCharts::renderFrappeChart({
  frappeCharts::frappeChart(
    data.frame(time = wpm$time, wpm = wpm$wpm),
    type = "line",
    title = "Your Typing Speed",
    is_navigable = FALSE,
    axisOptions = list(xIsSeries = TRUE),
    lineOptions = list(regionFill = TRUE)
  )
})
```

### Don’t redraw: Use the update method we made for frappeCharts

  - [changelog: 8d519b](https://github.com/gadenbuie/js4shiny-frappeCharts/commit/8d519b645abb990df17843f36cc418591e238aca)

Replace the initial `frappeChart()` with a simple placeholder.

``` r
# server
output$chart_typing_speed <- frappeCharts::renderFrappeChart({
  frappeCharts::frappeChart(
    data.frame(time = 0, wpm = 0),
    type = "line",
    title = "Your Typing Speed",
    is_navigable = FALSE,
    axisOptions = list(xIsSeries = TRUE),
    lineOptions = list(regionFill = TRUE)
  )
})
```

and use the `updateFrappeChart()` function to update the chart in place.

``` r
observeEvent(wpm$time, {
  frappeCharts::updateFrappeChart(
    inputId = "chart_typing_speed",
    data = data.frame(time = wpm$time, wpm =  wpm$wpm)
  )
})
```

## Final Step: Make it fun

  - [changelog:
    d6fa10](https://github.com/gadenbuie/js4shiny-frappeCharts/commit/d6fa10cb805ce8aa044987814cc22cadacb37ab3)
  - Checkpoint (final app): `js4shiny::repl_example("shiny-typing-05")`

Download the [Shiny module I
created](https://gist.github.com/gadenbuie/08546fd96b96fbf810f84ccdc7b69bcc)
for this project into the directory with your `app.R` file.

``` r
download.file(
  "http://bit.ly/js4shiny-typing-stats-module",
  "module_typingStats.R"
)
```

Then source this module at the start of your app.

``` r
source("module_typingStats.R")
```

Add the module’s UI to your UI above the typing area.

``` r
# ui
typingStatsUI('typing_stats')
```

While you’re in the UI area, fix something I missed earlier. With
bootstrap, you can [set the number of
rows](https://getbootstrap.com/docs/3.3/css/#textarea) in the
`textarea`. Add this argument to `typingSpeedInput` and set the default
value to `4`.

Use the `typingStats()` module to calculate `wpm`. Replace the `wpm`
reactive values list and the two observers we had before with the new
`typingStats()` module.

``` r
# server
wpm <- typingStats(
  "typing_stats", 
  typing = reactive(input$typing), 
  typing_reset = reactive(input$typing_reset)
)
```

And finally, use the new `wpm()` reactive from the module as the data
for the `frappeChart` update.

``` r
observeEvent(wpm()$time, {
  frappeCharts::updateFrappeChart('chart_typing_speed', wpm())
})
```

If you don’t have the
[stringdist](https://github.com/markvanderloo/stringdist) package
installed, install it now to get some extra stats.

``` r
install.packages("stringdist")
```

Push the app to <https://shinyapps.io>\!

Or check out the one I deployed:
[type-racer](https://gadenbuie.shinyapps.io/type-racer/).
