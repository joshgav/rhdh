global:
  # -- Shorthand for users who do not want to specify a custom HOSTNAME. Used ONLY with the DEFAULT upstream.backstage.appConfig value and with OCP Route enabled.
  # clusterRouterBase: apps.example.com
  # -- Custom hostname shorthand, overrides `global.clusterRouterBase`, `upstream.ingress.host`, `route.host`, and url values in `upstream.backstage.appConfig`
  host: backstage-${bs_app_name}.${openshift_ingress_domain}
  auth:
    backend:
      enabled: true
  dynamic:
    includes:
      - dynamic-plugins.default.yaml
    plugins:
    - package: ./dynamic-plugins/dist/backstage-plugin-github-actions
      disabled: false
    - package: ./dynamic-plugins/dist/backstage-plugin-github-issues
      disabled: false
    - package: ./dynamic-plugins/dist/roadiehq-backstage-plugin-github-insights
      disabled: false
    - package: ./dynamic-plugins/dist/roadiehq-backstage-plugin-github-pull-requests
      disabled: false
    - package: ./dynamic-plugins/dist/backstage-plugin-catalog-backend-module-github-dynamic
      disabled: false
    - package: ./dynamic-plugins/dist/backstage-plugin-catalog-backend-module-github-org-dynamic
      disabled: false
    - package: ./dynamic-plugins/dist/backstage-plugin-techdocs
      disabled: false
    - package: ./dynamic-plugins/dist/backstage-plugin-techdocs-backend-dynamic
      disabled: false
    - package: ./dynamic-plugins/dist/roadiehq-backstage-plugin-argo-cd-backend-dynamic
      disabled: false
    - package: ./dynamic-plugins/dist/roadiehq-scaffolder-backend-argocd-dynamic
      disabled: false
    - package: ./dynamic-plugins/dist/roadiehq-backstage-plugin-argo-cd
      disabled: false
    - package: ./dynamic-plugins/dist/backstage-plugin-kubernetes-backend-dynamic
      disabled: false
    - package: ./dynamic-plugins/dist/backstage-plugin-kubernetes
      disabled: false
    - package: ./dynamic-plugins/dist/janus-idp-backstage-plugin-quay
      disabled: false
    - package: ./dynamic-plugins/dist/janus-idp-backstage-plugin-tekton
      disabled: false
    - package: ./dynamic-plugins/dist/janus-idp-backstage-plugin-topology
      disabled: false
route:
  enabled: true
  host: '{{ .Values.global.host }}'
  path: /
  tls:
    enabled: true
    insecureEdgeTerminationPolicy: Redirect
    termination: edge
  wildcardPolicy: None
upstream:
  backstage:
    appConfig:
      app:
        baseUrl: 'https://{{- include "janus-idp.hostname" . }}'
      backend:
        auth:
          keys:
            - secret: '${BACKEND_SECRET}'
        baseUrl: 'https://{{- include "janus-idp.hostname" . }}'
        cors:
          origin: 'https://{{- include "janus-idp.hostname" . }}'
        database:
          connection:
            password: '${POSTGRESQL_ADMIN_PASSWORD}'
            user: postgres
    args:
      - '--config'
      - dynamic-plugins-root/app-config.dynamic-plugins.yaml
    containerPorts:
      backend: 7007
    extraAppConfig:
      - configMapRef: app-config-rhdh
        filename: app-config-rhdh.yaml
    extraEnvVars:
      - name: BACKEND_SECRET
        valueFrom:
          secretKeyRef:
            key: backend-secret
            name: '{{ include "janus-idp.backend-secret-name" $ }}'
      - name: POSTGRESQL_ADMIN_PASSWORD
        valueFrom:
          secretKeyRef:
            key: postgres-password
            name: '{{- include "janus-idp.postgresql.secretName" . }}'
    extraEnvVarsSecrets:
      - github-token
      - argocd-token
      - quay-token
    extraVolumeMounts:
      - mountPath: /opt/app-root/src/dynamic-plugins-root
        name: dynamic-plugins-root
      - name: github-app-credentials
        mountPath: /opt/app-root/src/github-app-credentials.yaml
        subPath: github-app-credentials.yaml
    extraVolumes:
      - ephemeral:
          volumeClaimTemplate:
            spec:
              accessModes:
                - ReadWriteOnce
              resources:
                requests:
                  storage: 1Gi
        name: dynamic-plugins-root
      - configMap:
          defaultMode: 420
          name: dynamic-plugins
          optional: true
        name: dynamic-plugins
      - name: dynamic-plugins-npmrc
        secret:
          defaultMode: 420
          optional: true
          secretName: dynamic-plugins-npmrc
      - name: github-app-credentials
        secret:
          secretName: github-app-credentials
          items:
          - key: github-app-credentials.yaml
            path: github-app-credentials.yaml
    image:
      registry: ${registry_hostname}
      repository: ${image_url_path}
      tag: ${image_tag}
    initContainers:
      - command:
          - ./install-dynamic-plugins.sh
          - /dynamic-plugins-root
        env:
          - name: NPM_CONFIG_USERCONFIG
            value: /opt/app-root/src/.npmrc.dynamic-plugins
        image: '{{ include "backstage.image" . }}'
        imagePullPolicy: Always
        name: install-dynamic-plugins
        volumeMounts:
          - mountPath: /dynamic-plugins-root
            name: dynamic-plugins-root
          - mountPath: /opt/app-root/src/dynamic-plugins.yaml
            name: dynamic-plugins
            readOnly: true
            subPath: dynamic-plugins.yaml
          - mountPath: /opt/app-root/src/.npmrc.dynamic-plugins
            name: dynamic-plugins-npmrc
            readOnly: true
            subPath: .npmrc
        workingDir: /opt/app-root/src
    installDir: /opt/app-root/src
    livenessProbe:
      httpGet:
        path: /healthcheck
        port: 7007
        scheme: HTTP
      failureThreshold: 3
      initialDelaySeconds: 60
      periodSeconds: 10
      successThreshold: 1
      timeoutSeconds: 2
    podAnnotations:
      checksum/dynamic-plugins: >-
        {{- include "common.tplvalues.render" ( dict "value"
        .Values.global.dynamic "context" $) | sha256sum }}
    readinessProbe:
      httpGet:
        path: /healthcheck
        port: 7007
        scheme: HTTP
      failureThreshold: 3
      initialDelaySeconds: 30
      periodSeconds: 10
      successThreshold: 2
      timeoutSeconds: 2
    replicas: 1
    revisionHistoryLimit: 10
  clusterDomain: cluster.local
  diagnosticMode:
    args:
      - infinity
    command:
      - sleep
    enabled: false
  ingress:
    enabled: false
    host: '{{ .Values.global.host }}'
    tls:
      enabled: false
  metrics:
    serviceMonitor:
      enabled: false
      path: /metrics
  nameOverride: developer-hub
  networkPolicy:
    egressRules:
      denyConnectionsToExternal: false
    enabled: false
  postgresql:
    auth:
      secretKeys:
        adminPasswordKey: postgres-password
        userPasswordKey: password
    enabled: true
    image:
      registry: registry.redhat.io
      repository: rhel9/postgresql-15
      tag: latest
    postgresqlDataDir: /var/lib/pgsql/data/userdata
    primary:
      containerSecurityContext:
        enabled: false
      extraEnvVars:
        - name: POSTGRESQL_ADMIN_PASSWORD
          valueFrom:
            secretKeyRef:
              key: postgres-password
              name: '{{- include "postgresql.v1.secretName" . }}'
      persistence:
        enabled: true
        mountPath: /var/lib/pgsql/data
        size: 1Gi
      podSecurityContext:
        enabled: false
  service:
    externalTrafficPolicy: Cluster
    ports:
      backend: 7007
      name: http-backend
      targetPort: backend
    sessionAffinity: None
    type: ClusterIP
  serviceAccount:
    automountServiceAccountToken: true
    create: false
