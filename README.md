
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

Check out `news(package = "dynguidelines")` or [NEWS.md](NEWS.md) for a
full list of changes.

<!-- This section gets automatically generated from NEWS.md -->

### Recent changes in dynguidelines 1.0 (29-03-2019)

#### Minor changes

  - Remove dyneval dependency
  - Minor changes due to changes in dynwrap v1.0

### Recent changes in dynguidelines 0.3.2 (17-12-2018)

#### New features

  - Enable automatic deployment via travis-ci

#### Fixes

  - Justify lens buttons
  - Use master branch of dynwrap instead of devel
