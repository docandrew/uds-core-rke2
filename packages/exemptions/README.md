## Exemptions

This Zarf package contains policy exemptions for the UDS Core RKE2 bundle.

### Rationale

UDS Core comes with a policy enforcement tool called Pepr (https://pepr.dev/) and
a set of Pepr capabilities to restrict behavior of applications running alongside
UDS Core, for security reasons. We need to exempt some of our applications from
these policies.

### Manifests

1. `local-path-storage-exemption` - Exempts the Local Path Provisioner from Pepr
    policies. Local Path Provisioner is not included in this bundle, but the
    exemption is here in case it is used as the storage class in the RKE2 cluster.
2. `longhorn-exemption` - Exempts Longhorn from Pepr policies. Note that Longhorn
    is not specifically included in this bundle, but is included here in case
    Longhorn is used as the storage class in the RKE2 cluster being used to
    test this bundle.
3. `metallb-exemption` - Exempts MetalLB from Pepr policies. MetalLB is included
    in this bundle, and requires capabilities that might otherwise be restricted
    by the UDS Core Pepr policies.
