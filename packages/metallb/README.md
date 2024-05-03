
## MetalLB Zarf Package

This package installs the MetalLB Load Balancer for Kubernetes.

There are three components in the Zarf package:

1. The MetalLB _namespace manifest_ containing the namespace that Helm will install MetalLB into. This is required because we need to explicitly disable istio injection in this namespace.

2. The MetalLB _Helm chart itself_ that will install the MetalLB controller and speaker components.

3. The MetalLB _configuration Helm charts_ that will set up the IPAddressPool and L2Advertisement custom resources.
