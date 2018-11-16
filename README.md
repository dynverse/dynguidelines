
<!-- README.md is generated from README.Rmd. Please edit that file -->

[![Build
Status](https://img.shields.io/travis/dynverse/dynguidelines.svg?logo=travis)](https://travis-ci.org/dynverse/dynguidelines)
[![AppVeyor Build
Status](https://ci.appveyor.com/api/projects/status/github/dynverse/dynguidelines?branch=master&svg=true)](https://ci.appveyor.com/project/dynverse/dynguidelines)
[![codecov](https://codecov.io/gh/dynverse/dynguidelines/branch/master/graph/badge.svg)](https://codecov.io/gh/dynverse/dynguidelines)
<img src="man/figures/logo.png" align="right" width="150px" />

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

Check out `news(package = "dynguidelines")` or [NEWS.md](inst/NEWS.md)
for a full list of
changes.

<!-- This section gets automatically generated from inst/NEWS.md, and also generates inst/NEWS -->

### Latest changes in dynguidelines 0.3.2 (unreleased)

### Latest changes in dynguidelines 0.3.1 (16-11-2018)

**New features**

  - Time and memory are now formatted relative to the limits in the
    questions (fixes \#46)
  - If time and memory exceed the limit, they are clipped

**Fixes**

  - Remove debug javascript messages
  - Fix javascript error for lenses which activated wrong columns
  - Fix bug when no n\_cells or n\_features is entered
  - Clean stability column names
  - Clean scalability column names
  - Add tooltips to priors
  - Small fixes for default columns
  - Cleanup of exported function and documentation
