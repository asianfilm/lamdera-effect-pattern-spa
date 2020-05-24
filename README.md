This codebase was created to demonstrate a simple Single Page Application written in **Lamdera** using the **Effect pattern**. It is adapted from [dmy/elm-realworld-example-app](https://github.com/dmy/elm-realworld-example-app).

# How it works
The Effect pattern used in this application consists in definining an `Effect` custom type that can represent all the effects that `init` and `update` functions want to produce.

These effects can represent:
* a `Cmd` value
* a request to change the state at an upper level (for example an URL change from a subpage without an anchor)

There are several benefits to this approach that makes it a valuable pattern for complex applications:
* All frontend effects are defined in a single `Effect` module, which acts as an internal API for the whole application that is guaranteed to list every possible effect.

* Effects can be inspected and tested, not like `Cmd` values. This allows to test all the application effects, including HTTP requests.

* Effects can represent a modification of top level model data, like the `Session`, or the current page when an URL change is wanted by a subpage `update` function.

* All the `update` functions keep a clean and concise signature returning a tuple, for example:  
`FrontendMsg -> FrontendModel -> ( FrontendModel, Effect FrontendMsg )`

* Because effects carry the minimum information required, some parameters like the `Browser.Navigation.key` are needed only in the effects [`perform`](https://github.com/dmy/elm-realworld-example-app/blob/master/src/Effect.elm#L209) function, which frees the developer from passing them to functions all over the application.

* A single `NoOp` or `Ignored String` can be used for the whole application.

