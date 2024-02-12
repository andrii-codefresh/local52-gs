apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: versions-appset
spec:
  generators:
    - list:
        elements:
          {{- range $i := until (int .Values.appCount) }}
          - "{{ $i }}"
          {{- end }}

  syncPolicy:
    preserveResourcesOnDeletion: false
  template:
    metadata:
      name: versions-appset-app-{{`{{appCount}}`}}
      annotations:
        "codefresh.io/product": {{ .Values.metadata.product }}
      labels:
        {{- range $key, $val := .Values.metadata.labels }}
          {{ $key }}: {{ $val | quote }}
        {{- end}}
      finalizers:
        - resources-finalizer.argocd.argoproj.io/foreground
    spec:
      project: default
      source:
        path: helm-guestbook
        repoURL: https://github.com/denis-codefresh/argocd-example-apps.git
        targetRevision: HEAD
      destination:
        name: scale-prod
        namespace: version-load-test-{{ .Values.metadata.product }}
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
          allowEmpty: true
        syncOptions:
          - PrunePropagationPolicy=foreground
          - Replace=false
          - PruneLast=false
          - Validate=true
          - CreateNamespace=true
          - ApplyOutOfSyncOnly=false
          - ServerSideApply=false
          - RespectIgnoreDifferences=false
