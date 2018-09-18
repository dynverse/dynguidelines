# Selecting the most optimal TI methods <img src="man/figures/logo.png" align="right" width="150px" />

[![Build Status](https://travis-ci.org/dynverse/dynguidelines.svg)](https://travis-ci.org/dynverse/dynguidelines)
[![codecov](https://codecov.io/gh/dynverse/dynguidelines/branch/master/graph/badge.svg)](https://codecov.io/gh/dynverse/dynguidelines)
![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)

This package summarises the results from the [dynbenchmark](https://www.github.com/dynverse/dynbenchmark) evaluation of trajectory inference methods. Both programmatically and through a (shiny) app, users can select the most optimal set of methods given a set of user and dataset specific parameters.

Installing the app:
```
# install.packages("devtools")
devtools::install_github("dynverse/dynguidelines")
```

Running the app:
```
dynguidelines::guidelines_shiny()
```

See [dyno](https://www.github.com/dynverse/dyno) for more information on how to use this package to infer and interpret trajectories.

![demo](man/figures/demo.gif)