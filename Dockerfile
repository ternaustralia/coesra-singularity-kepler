FROM centos:7

COPY configuration.xml /tmp 
COPY core_configuration.xml /tmp
COPY common_configuration.xml /tmp

COPY modules.txt /tmp
COPY current-suite.txt /tmp

COPY kepler.sh /tmp
COPY install_animal_conservation_packages.sh /tmp

RUN yum update -y
RUN yum install -y java-1.8.0-openjdk wget git ant

RUN groupadd kepler
RUN useradd -g kepler kepler

RUN mkdir /opt/kepler
RUN chown kepler:kepler /opt/kepler

WORKDIR /opt/kepler

RUN wget https://code.kepler-project.org/code/kepler/releases/installers/2.4/kepler-2.4-linux.tar.gz

RUN tar -C /opt/kepler -xvf /opt/kepler/kepler-2.4-linux.tar.gz

RUN cp /tmp/configuration.xml /opt/kepler/kepler-2.4/module-manager-2.4.0/resources/configurations/configuration.xml

RUN cp /tmp/core_configuration.xml /opt/kepler/kepler-2.4/core-2.4.0/resources/configurations/configuration.xml

RUN cp /tmp/common_configuration.xml /opt/kepler/kepler-2.4/common-2.4.0/resources/configurations/configuration.xml

RUN chown -R kepler:kepler /opt/kepler/kepler-2.4/

RUN ln -s /opt/kepler/kepler-2.4/kepler.sh /usr/bin/kepler

RUN rm /opt/kepler/*.gz

RUN rm -f /home/kepler/.kepler

RUN mkdir -p /root/.ssh/ 
RUN touch /root/.ssh/config
RUN chmod 0644 /root/.ssh/config

RUN git clone https://bitbucket.org/coesra/kepler_archives.git /mnt/kepler_archives

WORKDIR /mnt/kepler_archives/files

RUN tar -xvf kepler_coesra_builder.tar.gz

RUN chown -R kepler:kepler ./*

WORKDIR kepler_coesra_builder
RUN ant

RUN chown -R kepler:kepler /mnt/kepler_archives/files/

RUN cp /mnt/kepler_archives/files/kepler_coesra_utility.tar.gz /opt/kepler/kepler-2.4

# Some missing modules i.e. coesra-tern-2.4.0, nimrodk-2.4.0, etc
# TODO: Relocate it to https://bitbucket.org/coesra/kepler_archives.git?
COPY  modules.tar.gz /opt/kepler/kepler-2.4

RUN chown -R kepler:kepler /opt/kepler/kepler-2.4

WORKDIR /opt/kepler/kepler-2.4/
RUN tar -xvf kepler_coesra_utility.tar.gz
RUN tar -xvf modules.tar.gz

RUN chown -R kepler:kepler /opt/kepler/kepler-2.4/

RUN cp /tmp/modules.txt /opt/kepler/kepler-2.4/build-area/
RUN chown kepler:kepler /opt/kepler/kepler-2.4/build-area/modules.txt

RUN cp /tmp/current-suite.txt /opt/kepler/kepler-2.4/build-area/current-suite.txt
RUN chown kepler:kepler /opt/kepler/kepler-2.4/build-area/current-suite.txt

RUN ssh-keygen -f /root/.ssh/id_rsa
RUN touch /root/.ssh/known_hosts
RUN ssh-keyscan bitbucket.org >> /root/.ssh/known_hosts

RUN git clone https://bitbucket.org/coesra/kepler-data.git /mnt/kepler-data
WORKDIR /mnt/kepler-data
RUN tar -xvf KeplerData.tar.gz

RUN mv /mnt/kepler-data/KeplerData/kepler.modules/reporting-2.4.0 /opt/kepler/kepler-2.4/
RUN mv /mnt/kepler-data/KeplerData/kepler.modules/provenance-2.4.1 /opt/kepler/kepler-2.4/
RUN mv /mnt/kepler-data/KeplerData/kepler.modules/tagging-2.4.0 /opt/kepler/kepler-2.4/
RUN mv /mnt/kepler-data/KeplerData/kepler.modules/workflow-run-manager-2.4.0 /opt/kepler/kepler-2.4/
RUN mv /mnt/kepler-data/KeplerData/kepler.modules/workflow-scheduler-gui-1.1.0 /opt/kepler/kepler-2.4/

RUN chown -R kepler:kepler /opt/kepler/kepler-2.4/

RUN mv /tmp/kepler.sh /opt/kepler/kepler-2.4/
RUN chown kepler:kepler /opt/kepler/kepler-2.4/kepler.sh
RUN chmod +x /opt/kepler/kepler-2.4/kepler.sh

#######Animal conservation package###
RUN yum install -y libpng-devel \
    libxml2-devel \
    libcurl-devel \
    gdal	\
    gdal-devel \
    proj-devel \
    proj-nad \
    proj-epsg \
    geo	\
    geos-devel \
    mesa-libGL \
    mesa-libGL-devel \
    mesa-libGLU-devel

RUN yum install -y R R-devel openssl openssl-devel

RUN mkdir /mnt/animal_conservation
WORKDIR /mnt/animal_conservation
RUN wget http://cran.r-project.org/src/contrib/Archive/multicore/multicore_0.2.tar.gz

RUN git clone https://git@bitbucket.org/coesra/rpackages.git

RUN yum install -y epel-release 
RUN yum install -y xpdf

WORKDIR /mnt
RUN wget http://vault.centos.org/6.7/os/Source/SPackages/gthumb-2.10.11-8.el6.src.rpm

RUN rpm -ivh /mnt/gthumb-2.10.11-8.el6.src.rpm

RUN mv /tmp/install_animal_conservation_packages.sh /mnt/
RUN chmod 0755 /mnt/install_animal_conservation_packages.sh
# RUN sh /mnt/install_animal_conservation_packages.sh > /tmp/routput.log

ENTRYPOINT /opt/kepler/kepler-2.4/kepler.sh