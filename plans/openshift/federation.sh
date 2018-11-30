KUBEFED_VERSION="v0.0.2"
yum -y install git bind-utils
echo function contextswitch { >> /root/.bashrc
echo oc config use-context \$1 >> /root/.bashrc
echo } >> /root/.bashrc
echo alias contextlist=\"oc config get-contexts\" >> /root/.bashrc
export CLUSTER1=`dig +short federer.default`.xip.io
export CLUSTER2=`dig +short federer.default`.xip.io
oc login --insecure-skip-tls-verify=true -u admin -p admin https://$CLUSTER2:8443
oc config rename-context `oc config current-context` cluster2
oc login --insecure-skip-tls-verify=true -u admin -p admin https://$CLUSTER1:8443
oc config rename-context `oc config current-context` cluster1
curl -LOs https://github.com/kubernetes-sigs/federation-v2/releases/download/$KUBEFED_VERSION/kubefed2.tar.gz
tar xzf kubefed2.tar.gz -C /usr/local/bin
rm -f kubefed2.tar.gz
git clone https://github.com/openshift/federation-dev.git /root/federation-dev
cd /root/federation-dev
oc create clusterrolebinding federation-admin --clusterrole="cluster-admin" --serviceaccount="federation-system:default"
oc create -f cluster-registry.yaml
oc create -f federation.yaml
oc project federation-system
oc create -n federation-system -f federatedtypes/
kubefed2 join cluster1 --host-cluster-context cluster1 --add-to-registry --v=2
kubefed2 join cluster2 --host-cluster-context cluster2 --add-to-registry --v=2
