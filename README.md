# RH Developer Hub

To deploy, set env vars in `.env` or `secrets.env`, then run
`./deploy/deploy.sh` for operator-based deployment, or `./deploy-helm/deploy.sh`
for chart-based deployment.

Note that the operator and chart deployments may diverge :D

## Resources

- Docs: <https://docs.redhat.com/en/documentation/red_hat_developer_hub>
- Issues: <https://issues.redhat.com/projects/RHIDP>
- Repo: <https://github.com/janus-idp/backstage-showcase>
    - Future: <https://github.com/redhat-developer/red-hat-developer-hub>
- Docs repo: <https://github.com/redhat-developer/red-hat-developers-documentation-rhdh>
- Operator repo: <https://github.com/redhat-developer/rhdh-operator>
- Other repos: <https://github.com/redhat-developer?q=rhdh>, <https://github.com/janus-idp>
- Examples:
    - <https://github.com/varkrish/rh-devhub-quickstart>
    - <https://github.com/joshgav/rhdh>
    - <https://github.com/pittar-demos/rhdh-build-an-idp>
    - <https://github.com/maarten-vandeperre/developer-hub-documentation>
- RHDH orchestrator: <https://www.rhdhorchestrator.io/>

## Dynamic Plugins
- To port a static plugin to a dynamic plugin, follow instructions at <https://github.com/gashcrumb/dynamic-plugins-getting-started>, see <https://github.com/gashcrumb/dynamic-plugins-getting-started?tab=readme-ov-file#phase-3---dynamic-plugin-enablement>

### Azure Entra

- App Registrations: <https://portal.azure.com/#view/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/~/RegisteredApps>

- https://docs.redhat.com/en/documentation/red_hat_developer_hub/1.3/html/authentication/assembly-authenticating-with-microsoft-azure
- https://github.com/backstage/backstage/blob/master/plugins/catalog-backend-module-msgraph/README.md
- https://backstage.io/docs/integrations/azure/org/
    - be sure to use Application permissions, not Delegated (i.e., by user) permissions
    - note that for `auth` plugin need to use Delegated (i.e., by user) permissions, e.g., `oidc`
    - be sure to enable the MsGraphOrg dynamic plugin in RHDH

## For AWS
- https://github.com/awslabs/backstage-plugins-for-aws/tree/main/plugins/core/scaffolder-actions
- follow for conversion to dynamic: https://github.com/gashcrumb/dynamic-plugins-getting-started

## Generate a Kubernetes SA Token

```bash
namespace=kube-system
sa="default"

oc project ${namespace}
oc adm policy add-cluster-role-to-user \
    --namespace ${namespace} \
    cluster-admin \
    --serviceaccount ${sa}

## `create token` not yet available in oc
kubectl create token --namespace ${namespace} ${sa} \
    --duration 999999h
```
