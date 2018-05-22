sudo bash -c 'CMS_HOME="/usr/local/cloudmonitor" CMS_VERSION="1.2.24" CMS_ARCH="linux64" CMS_PROXY="hzcmsproxy.aliyun.com:3128"; \
if [ -f $CMS_HOME/wrapper/bin/cloudmonitor.sh ] ; then $CMS_HOME/wrapper/bin/cloudmonitor.sh remove; rm -rf $CMS_HOME; fi ; \
mkdir -p $CMS_HOME && \
wget -e "http_proxy=$CMS_PROXY" -O "$CMS_HOME/cloudmonitor.tar.gz" "http://cms-download.aliyun.com/release/$CMS_VERSION/$CMS_ARCH/agent-$CMS_ARCH-$CMS_VERSION-package.tar.gz" && \
tar -xf $CMS_HOME/cloudmonitor.tar.gz -C $CMS_HOME && \
rm -f $CMS_HOME/cloudmonitor.tar.gz && \
chown -R root:root $CMS_HOME && \
$CMS_HOME/wrapper/bin/cloudmonitor.sh install && \
$CMS_HOME/wrapper/bin/cloudmonitor.sh start'
