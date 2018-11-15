
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

### Latest changes in dynguidelines 0.3.0 (15-11-2018)

**New features**

  - Add category headers, just like figure 2/3
  - Columns are now sorted within each category, categories are sorted
    according to figure 2/3
  - New columns: overall scores within each category, wrapper type,
    prior information
  - New lens: Summary (Fig. 2)
  - Show lenses by default

**Fixes**

  - Several small cosmetic changes
  - Code and doi links are opened in a new tab
  - Not knowing the explicit topology will now filter on multifurcations
    as well

### Latest changes in dynguidelines 0.2.1 (14-11-2018)

  - Add warning column for when a method errors too often
  - Several fixes for more readable columns (such as usability)
  - Update deployment instructions
  - Rename scaling to scalability
