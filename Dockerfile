FROM crystallang/crystal

ENV TMPDIR /tmp
RUN mkdir -p /opt/resource_cr/ /opt/resource/
COPY *.cr /opt/resource_cr/
RUN cd /opt/resource_cr \
  && crystal build check.cr && mv check /opt/resource/ \
  && crystal build in.cr && mv in /opt/resource/
