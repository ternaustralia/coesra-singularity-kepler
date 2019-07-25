#!/bin/bash
#
# COER-247
#
# Installs Animal conservation related packages.
#
# Pre-requisite: R has been installed, requires root
#
WORK_DIR=/mnt/animal_conservation
#rm -rf $WORK_DIR
mkdir -p $WORK_DIR
cd $WORK_DIR

echo "Installing animal conservation packages..."
echo "Installing yum packages..."
yum install -y libcurl-devel-7.19.7 gdal-1.7.3-15 gdal-devel-1.7.3 proj-devel-4.7.0 proj-nad-4.7.0 proj-epsg-4.7.0 geos-3.3.2 geos-devel-3.3.2 mesa-libGL mesa-libGL-devel mesa-libGLU-devel
yum install -y libcurl-devel gdal gdal-devel proj-devel-4.7.0 proj-nad-4.7.0 proj-epsg-4.7.0 geos-3.3.2 geos-devel-3.3.2 mesa-libGL mesa-libGL-devel mesa-libGLU-devel

echo "Upgrading GCC/G++..."
wget "http://people.centos.org/tru/devtools-1.1/devtools-1.1.repo" -P /etc/yum.repos.d
echo "enabled=1" >> /etc/yum.repos.d/devtools-1.1.repo
yum install -y devtoolset-1.1

echo "Downloading custom tarballs..."
#echo "Downloading VTrack multicore: http://cran.r-project.org/src/contrib/Archive/multicore/multicore_0.2.tar.gz"
#wget "http://cran.r-project.org/src/contrib/Archive/multicore/multicore_0.2.tar.gz"
#echo "Downloading VTrack:  http://www.uq.edu.au/eco-lab/Vtrack/VTrack%20v102/VTrack_1.02.tar.gz"
#wget "http://www.uq.edu.au/eco-lab/Vtrack/VTrack%20v102/VTrack_1.02.tar.gz"
##because VTrack_1.10 is not available for download, assume the tar ball is here in the current directory along with MTrack_0.1
#echo "Downloading RStudio..."
#wget "http://download1.rstudio.org/rstudio-0.98.1103-x86_64.rpm"
#yum install -y rstudio-0.98.1103-x86_64.rpm
## clone RPackages
git clone https://bitbucket.org/coesra/rpackages.git
# Install PDF Viewer COER-240 + gthumb
#yum install -y xpdf-3.04 gthumb
echo "Running RScript to install the packages..."
cat << EOF > animal_conservation.r 
#!/usr/bin/Rscript
install.packages(c('devtools'),repos='http://cran.csiro.au')
#install required R packages
install.packages(c('ape','bitops','brew','caTools','chron','colorspace','crayon','data.table','devtools','dichromat','digest','dismo','doMC','doParallel','doSNOW','evaluate'), repos='http://cran.rstudio.com/')
install.packages(c('fastcluster','foreach','formatR','gdalUtils','gdistance','highr','htmltools','httr','igraph','iterators','jsonlite','knitr','labeling','lazyeval','lintr'), repos='http://cran.rstudio.com/')
install.packages(c('magrittr','maptools','markdown','memoise','mime','munsell','PBSmapping','permute','plyr','png','R.methodsS3','R.oo','R.utils','R6','raster'), repos='http://cran.rstudio.com/')
install.packages(c('RColorBrewer','Rcpp','RCurl','reshape2','rex','rgdal','rgeos','RgoogleMaps','RJSONIO','rmarkdown','roxygen2','rstudioapi','scales','shape','snow','sp'), repos='http://cran.rstudio.com/')
install.packages(c('stringdist','stringr','testthat','translations','utils','vegan','whisker','yaml','sqldf','labdsv','plotKML'), repos='http://cran.rstudio.com/')
install.packages(c('mvtnorm','reshape', 'oz', 'maps', 'mapplots', 'shapefiles'), repos='http://cran.csiro.au')

#install Marxan
devtools:::install_github('paleo13/marxan')

# install VTrack
install.packages("multicore_0.2.tar.gz", repos = NULL, type="source")
install.packages("VTrack", repos = "http://cran.csiro.au")
#install.packages("rpackages/VTrack_1.10.tar.gz", repos = NULL, type="source")
install.packages("rpackages/MTrack_0.12.tar.gz", repos = NULL, type="source")

# installl Shiny COER-254
install.packages('shiny', repos='http://cran.csiro.au')

# install IUCN dependencies
install.packages("rpackages/IUCNcriteriaAmountainashforests_1.1_R_x86_64-pc-linux-gnu.tar.gz", repos = NULL, type = "source")
install.packages("rpackages/IUCNcriteriaBmountainashforests_1.1_R_x86_64-pc-linux-gnu.tar.gz", repos = NULL, type = "source")
install.packages("rpackages/IUCNcriteriaCmountainashforests_1.1_R_x86_64-pc-linux-gnu.tar.gz", repos = NULL, type = "source")
install.packages("rpackages/IUCNcriteriaDmountainashforests_1.1_R_x86_64-pc-linux-gnu.tar.gz", repos = NULL, type = "source")
install.packages("rpackages/IUCNcriteriaEmountainashforests_1.1_R_x86_64-pc-linux-gnu.tar.gz", repos = NULL, type = "source")
install.packages("rpackages/IUCNEcosystemRiskAssessment_1.1_R_x86_64-pc-linux-gnu.tar.gz", repos = NULL, type = "source")

EOF

chmod +x animal_conservation.r
#need to enable new version of gcc/g++
#scl enable devtoolset-3 ./animal_conservation.r
./animal_conservation.r

