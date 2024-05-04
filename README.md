                                           
# WORK IN PROGRESS - DOES NOT BUILD YET

## UDS Core RKE2 Example Bundle

This is a sample application using a Defense Unicorns UDS Bundle to package up 
the UDS Core Zarf Package into a bundle capable of running on RKE2.

This assumes that you have a RKE2 cluster up and running and that you have
configured your `kubectl` to point to that cluster. Additionally, a default
storage class should be available. RKE2 does not provide one by default, so
you may need to install one. Rancher's Local Path Provisioner is suitable for
testing on single-node clusters, and can be installed on your RKE2 cluster with:

```shell
# Install the Local Path Provisioner
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml

# Set LPP as the default storage class:
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

## Installation

### Terminate RKE2 Metrics Server

UDS Core provides it's own metrics server, and the Helm installation of the
UDS Core metrics server conflicts with the namespace of the RKE2 deployment.
Terminate the RKE2 metrics server _and_ **remove the helmchart object** or, 
if you're starting a new cluster, use this snippet in /etc/rancher/rke2/config.yaml:

```yaml
# /etc/rancher/rke2/config.yaml
disable:
  - rke2-metrics-server
```

### Modify Bundle Configuration

You'll probably want to set your own domain name for the cluster. This can be
done by modifying the `bundles/uds-config.yaml` file. You will likely want to
override the MetalLB address range as well. These are the addresses that MetalLB
will use to expose services on your local network.

### TLS Keypair Generation

If you have your own TLS keypair to use for the cluster, copy the keypair to the
top-level folder of this repo and name the files `tls.cert` and `tls.key`.
Otherwise, you can create a self-signed set yourself with:

```shell
uds run certs
```

Note that they will be set up to use the domain name `uds-core.lan` by default.

### Authenticate with ghcr.io

Recommended:

`gh auth token | docker login ghcr.io --username <username> --password-stdin`

Or create a personal access token and use that:

`docker login ghcr.io --username <username> --password <token>`

### Bundle Creation

`uds run create-bundle`

### Bundle Deployment

Deploy Zarf:

`uds zarf init`

Deploy this UDS Bundle:

`uds deploy bundles/uds-bundle-uds-core-rke2-bundle-amd64-0.21.1.tar.zst`

## Organization of the UDS Core RKE2 Bundle

```ascii                                                   
     ┌────────────────────────────────────────────────────────────────────────────┐
     │                        UDS Bundle: "UDS Core RKE2"                         │
     │                                                                            │
     │                     [uds-core-rke2-bundle - bundles/]                      │
     │                                                                            │
     │  ╔══════════════════════════════════════════════════════════════════════╗  │
     │  ║                        Zarf Package: MetalLB                         ║  │
     │  ║                                                                      ║  │
     │  ║                [metallb-package - packages/metallb/]                 ║  │
     │  ║                                                                      ║  │
     │  ║          ┌──────────────────────────────────────────────┐            ║  │
     │  ║          │      Zarf Component: MetalLB Namespace       │            ║  │
     │  ║          │                                              │            ║  │
     │  ║          │        [metallb-namespace-component]         │            ║  │
     │  ║          └──────────────────────────────────────────────┘            ║  │
     │  ║          ┌──────────────────────────────────────────────┐            ║  │
     │  ║          │Zarf Component: MetalLB (upstream Helm chart) │            ║  │
     │  ║          │                                              │            ║  │
     │  ║          │             [metallb-component]              │            ║  │
     │  ║          └──────────────────────────────────────────────┘            ║  │
     │  ║          ┌──────────────────────────────────────────────┐            ║  │
     │  ║          │    Zarf Component: MetalLB Configuration     │            ║  │
     │  ║          │                                              │            ║  │
     │  ║          │          [metallb-config-component]          │            ║  │
     │  ║          └──────────────────────────────────────────────┘            ║  │
     │  ╚══════════════════════════════════════════════════════════════════════╝  │
     │  ╔══════════════════════════════════════════════════════════════════════╗  │
     │  ║                 Zarf package: Pepr policy exemptions                 ║  │
     │  ║                                                                      ║  │
     │  ║              [exemptions-package - packages/exemptions]              ║  │
     │  ║                                                                      ║  │
     │  ║          ┌──────────────────────────────────────────────┐            ║  │
     │  ║          │          Zarf Component: Exemptions          │            ║  │
     │  ║          └──────────────────────────────────────────────┘            ║  │
     │  ╚══════════════════════════════════════════════════════════════════════╝  │
     │  ╔══════════════════════════════════════════════════════════════════════╗  │
     │  ║                        Zarf Package: UDS Core                        ║  │
     │  ║                                                                      ║  │
     │  ║ [uds-core-package - oci://ghcr.io/defenseunicorns/packages/uds/core] ║  │
     │  ║                                                                      ║  │
     │  ║                      ╔══════════════════════╗                        ║  │
     │  ║                      ║Zarf Sub-packages:    ║                        ║  │
     │  ║                      ║                      ║                        ║  │
     │  ║                      ║ - Authservice        ║                        ║  │
     │  ║                      ║ - Grafana            ║                        ║  │
     │  ║                      ║ - Istio              ║                        ║  │
     │  ║                      ║ - Keycloak           ║                        ║  │
     │  ║                      ║ - Kiali              ║                        ║  │
     │  ║                      ║ - Loki               ║                        ║  │
     │  ║                      ║ - Metrics-server     ║                        ║  │
     │  ║                      ║ - Neuvector          ║                        ║  │
     │  ║                      ║ - Pepr               ║                        ║  │
     │  ║                      ║ - Prometheus-stack   ║                        ║  │
     │  ║                      ║ - Promtail           ║                        ║  │
     │  ║                      ║ - Tempo              ║                        ║  │
     │  ║                      ║ - Test               ║                        ║  │
     │  ║                      ║ - Velero             ║                        ║  │
     │  ║                      ╚══════════════════════╝                        ║  │
     │  ╚══════════════════════════════════════════════════════════════════════╝  │
     └────────────────────────────────────────────────────────────────────────────┘
```

## Naming conventions

UDS Bundles contain Zarf Packages which contain Zarf Components. Zarf components
in turn can contain images, Helm charts, and manifests. This repo tries to be
explicit with the naming of each of these resources. So for example, the Zarf
package for Pepr Exemptions is called `exemptions-package`, and it contains
a Zarf component called `exemptions-component`. This is to make it easy to
understand the organization of each of these resources.

## Issues

Depending on the version of Kubernetes being used, the UDS Core bundle may
deploy Istio proxy inside some of the Job pods. Because it's a sidecar, it
never exits and the Job will not complete. You may have to manually enter the
pod in debug mode and tell the istio-proxy container to exit.

```shell
$ kubectl debug -it -n <namespace> <pod-name> --image=busybox
```

Then inside the pod:

```shell
$ wget -q --post-data='' -S -O /dev/null http://127.0.0.1:15020/quitquitquit
$ exit
```