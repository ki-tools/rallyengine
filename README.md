# rallyengine

This R package acts as an engine for parsing HBGDki rally master templates and generating rally outputs.

This is a package that will not be of use to the general public. It's hosted publicly to make it easy to install and work on.

## Installation

You can install rallyengine from github with:

``` r
# install.packages("devtools")
devtools::install_github("HBGDki/rallyengine")
```

## Notes

This package provides many functions for parsing rally master templates and generating outputs and provides a REST API for accessing these outputs. It also provides a self-contained web front-end that consumes these APIs to provide rally dashboard, overview, and admin pages.

### REST API / Docker

The REST API is pretty straightforward and can be followed by looking here: https://github.com/HBGDki/rallyengine/blob/master/inst/api/

This directory also contains a Dockerfile for setting up the REST API and commands to run it.

### Web Front-End

The web front-end pages are here: https://github.com/HBGDki/rallyengine/tree/master/inst/www

### Environment Variables

Beyond building the Dockerfile, the only other setup necessary to get a working environment is to set the following environment variables:

```
OSF_PAT=__Open Science Framework personal access token__
RALLY_BASE_PATH=__path to where web files and content cache will be stored__
RALLY_API_SERVER=__url of location from which API is served__
```
