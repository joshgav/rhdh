## RH Developer Hub

### Resources

- Docs: <https://docs.redhat.com/en/documentation/red_hat_developer_hub>
- Issues: <https://issues.redhat.com/projects/RHIDP>
- Repo: <https://github.com/janus-idp/backstage-showcase>
- Docs repo: <https://github.com/redhat-developer/red-hat-developers-documentation-rhdh>
- Operator repo: <https://github.com/redhat-developer/rhdh-operator>
- Other repos: <https://github.com/redhat-developer?q=rhdh>, <https://github.com/janus-idp>
- Examples:
    - <https://github.com/varkrish/rh-devhub-quickstart>
    - <https://github.com/joshgav/rhdh>
    - <https://github.com/pittar-demos/rhdh-build-an-idp>
    - <https://github.com/maarten-vandeperre/developer-hub-documentation>
- Info on "orchestrator": https://www.parodos.dev/docs/

- To port a static plugin to a dynamic plugin, follow instructions at <https://github.com/gashcrumb/dynamic-plugins-getting-started>, see <https://github.com/gashcrumb/dynamic-plugins-getting-started?tab=readme-ov-file#phase-3---dynamic-plugin-enablement>

### Azure Entra

- App Registration: <https://portal.azure.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Overview/appId/6a9c36f7-fbb8-4c06-82b9-4dffdd43b8d3/isMSAApp~/false>

- https://github.com/backstage/backstage/blob/master/plugins/catalog-backend-module-msgraph/README.md
- https://issues.redhat.com/browse/RHIDP-2529
- https://backstage.io/docs/integrations/azure/org/
- https://backstage.io/docs/integrations/azure/org/#app-registration
    - be sure to use Application permissions, not delegated
    - but for auth need to use delegated
- https://docs.redhat.com/en/documentation/red_hat_developer_hub/1.3/html/authentication/assembly-authenticating-with-microsoft-azure
- be sure to enable the MsGraphOrg dynamic plugin

## For AWS
- https://github.com/gashcrumb/dynamic-plugins-getting-started
- https://github.com/awslabs/backstage-plugins-for-aws/tree/main/plugins/core/scaffolder-actions