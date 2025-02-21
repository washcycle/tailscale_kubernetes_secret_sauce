# Project Demonstrates Tailscale Operator

This project deploys the Tailscale Operator to a Kubernetes cluster and sets up features like Tailscale proxy and cluster API access. 

Details: https://tailscale.com/kb/1236/kubernetes-operator

## Prerequisites

1. Create an OAuth client in the OAuth clients page of the admin console. Create the client with Devices Core and Auth Keys write scopes, and the tag `tag:k8s-operator`.

Add this to the tailscale ACLs. Also give your user 
```yaml
"tagOwners": {
   "tag:k8s-operator": [],
   "tag:k8s": ["tag:k8s-operator"],
}
```

Kubernetes API Access

This project demostrates access via the Tailscale operator, which the host name for the operator becomes the tailnet hostname for the Kuberentes API.

```yaml
"acls": [{
    "action": "accept",
    "src": ["tag:k8s-readers"],
    "dst": ["tag:k8s-operator:443"]
}]
```

In the ACL rules you have to map groups and tags to k8s roles.

```yaml
{
  "grants": [
    {
      "src": ["group:prod"],
      "dst": ["tag:k8s-operator"],
      "app": {
        "tailscale.com/cap/kubernetes": [{
          "impersonate": {
            "groups": ["system:masters"],
          },
        }],
      },
    },
    {
      "src": ["group:k8s-readers"],
      "dst": ["tag:k8s-operator"],
      "app": {
        "tailscale.com/cap/kubernetes": [{
          "impersonate": {
            "groups": ["tailnet-readers"],
          },
        }],
      },
    }
  ],
}
```

2. Ensure you have `kubectl` and `helm` installed and configured to access your Kubernetes cluster.
3. Install Terraform (version 1.10.5 or later).

## Deployment

To deploy the Tailscale Operator to your Kubernetes cluster, follow these steps:

1. Clone the repository:
    ```sh
    git clone <repository-url>
    cd <repository-directory>
    ```

2. Initialize and apply the Terraform configuration:
    ```sh
    terraform init
    terraform apply
    ```

## Testing Locally

To test the deployment locally, you can use the following steps:

1. Verify the Tailscale Operator is deployed:
    ```sh
    kubectl get pods -n tailscale
    ```

2. Check the Tailscale proxy configuration:
    ```sh
    kubectl get proxygroup ts-proxies -n tailscale -o yaml
    ```

3. Ensure the Helm release is installed:
    ```sh
    helm list -n tailscale
    ```

## Cleanup

To remove the deployed resources, run:
```sh
terraform destroy
```