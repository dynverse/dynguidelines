
<!-- README.md is generated from README.Rmd. Please edit that file -->

<!-- badges: start -->

[![R build
status](https://github.com/dynverse/dynguidelines/workflows/R-CMD-check/badge.svg)](https://github.com/dynverse/dynguidelines/actions)
[![codecov](https://codecov.io/gh/dynverse/dynguidelines/branch/master/graph/badge.svg)](https://codecov.io/gh/dynverse/dynguidelines)
<img src="man/figures/logo.png" align="right" width="150px" />
<!-- badges: end -->

# Selecting the most optimal TI methods

This package summarises the results from the
[dynbenchmark](https://www.github.com/dynverse/dynbenchmark) evaluation
of trajectory inference methods. Both programmatically and through a
(shiny) app, users can select the most optimal set of methods given a
set of user and dataset specific parameters.

Installing the app:

``` r
# install.packages("devtools")
devtools::install_github("dynverse/dynguidelines")
```

Running the app:

``` r
dynguidelines::guidelines_shiny()
```

See [dyno](https://www.github.com/dynverse/dyno) for more information on
how to use this package to infer and interpret trajectories.

<!-- This gif was recorded using peek (https://github.com/phw/peek) --->

![demo](man/figures/demo.gif)

## Latest changes

Check out `news(package = "dynguidelines")` or [NEWS.md](NEWS.md) for a
full list of changes.

<!-- This section gets automatically generated from NEWS.md -->

### Recent changes in dynguidelines 1.0.1 (29-06-2020)

#### Fixes

  - Fix `get_questions()`: Remove accidental reliance on list name
    autocompletion, which has been removed from R.

#### Minor changes

  - Migrate from Travis CI to Github Actions for CMD check and codecov,
    not yet for automated deployment.

### Recent changes in dynguidelines 1.0 (29-03-2019)

#### Minor changes

  - Remove dyneval dependency
  - Minor changes due to changes in dynwrap v1.0
