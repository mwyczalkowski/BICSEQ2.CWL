# See Dockerfile.201901 for details of this build
FROM mwyczalkowski/bicseq2:201901

RUN apt-get -y install locales
# Set the locale so perl doesn't complain
RUN locale-gen en_US.UTF-8  
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8  

CMD ["/bin/bash"]
