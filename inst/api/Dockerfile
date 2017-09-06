FROM trestletech/plumber
MAINTAINER Ryan Hafen <rhafen@gmail.com>

RUN apt-get update
RUN apt-get -y install libxml2-dev
RUN R -e "devtools::install_github('hbgdki/rallyengine', dependencies = TRUE)"

# re-install rallyengine every time we restart the image (to get package updates)
ENTRYPOINT ["R", "-e", "devtools::install_github('hbgdki/rallyengine'); pr <- plumber::plumb(commandArgs()[4]); pr$run(host='0.0.0.0', port=8000)"]
CMD ["/usr/local/lib/R/site-library/rallyengine/api/api.R"]
