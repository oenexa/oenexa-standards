$baseDir = "C:\workspace\oenexarepo"
$repos = (Get-ChildItem -Directory $baseDir).Name

$stagingTemplate = @'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: oenexa-staging

resources:
  - ../../base

namePrefix: staging-

patches:
  - target:
      kind: Deployment
      name: __REPO_NAME__
    patch: |-
      - op: replace
        path: /spec/replicas
        value: 1
      - op: add
        path: /spec/template/spec/containers/0/env
        value:
          - name: NODE_ENV
            value: staging
          - name: LOG_LEVEL
            value: debug
'@

$productionTemplate = @'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: oenexa-production

resources:
  - ../../base

namePrefix: prod-

patches:
  - target:
      kind: Deployment
      name: __REPO_NAME__
    patch: |-
      - op: replace
        path: /spec/replicas
        value: 3
      - op: add
        path: /spec/template/spec/containers/0/env
        value:
          - name: NODE_ENV
            value: production
          - name: LOG_LEVEL
            value: info
'@

foreach ($r in $repos) {
    $stagingDir = Join-Path $baseDir "$r\deploy\overlays\staging"
    $prodDir = Join-Path $baseDir "$r\deploy\overlays\production"
    
    if (-not (Test-Path $stagingDir)) { New-Item -ItemType Directory -Path $stagingDir -Force | Out-Null }
    if (-not (Test-Path $prodDir)) { New-Item -ItemType Directory -Path $prodDir -Force | Out-Null }
    
    $stagingFile = Join-Path $stagingDir "kustomization.yaml"
    $prodFile = Join-Path $prodDir "kustomization.yaml"
    
    [System.IO.File]::WriteAllText($stagingFile, $stagingTemplate.Replace("__REPO_NAME__", $r).TrimStart(), [System.Text.Encoding]::UTF8)
    [System.IO.File]::WriteAllText($prodFile, $productionTemplate.Replace("__REPO_NAME__", $r).TrimStart(), [System.Text.Encoding]::UTF8)
    Write-Host "Configured Kustomize overlays for $r"
}
