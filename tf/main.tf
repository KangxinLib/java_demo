name: security scan
on:
  push:
    branches:
      - main
  pull_request:
    types: [opened, synchronize, reopened]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}
  GIT_TAG: ${{ github.sha }}

jobs:
  sonarcloud-scan:
    name: sonarcloud-scan
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
        with:
          fetch-depth: 0  # Shallow clones should be disabled for a better relevancy of analysis
      - name: Set up JDK 17
        uses: actions/setup-java@v1
        with:
          java-version: 17
      - name: Cache SonarCloud packages
        uses: actions/cache@v1
        with:
          path: ~/.sonar/cache
          key: ${{ runner.os }}-sonar
          restore-keys: ${{ runner.os }}-sonar
      - name: Cache Gradle packages
        uses: actions/cache@v1
        with:
          path: ~/.gradle/caches
          key: ${{ runner.os }}-gradle-${{ hashFiles('**/*.gradle') }}
          restore-keys: ${{ runner.os }}-gradle
      - name: Build and analyze
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}  # Needed to get PR information, if any
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
        run: ./gradlew build sonarqube --info
  snyk-scan:
    name: snyk-scan
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    steps:
      - uses: actions/checkout@v2
      - name: Run Snyk to check for vulnerabilities
        uses: snyk/actions/gradle@master
        continue-on-error: true # To make sure that SARIF upload gets called
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          json: true
      - name: Publish report to defectdojo
        id: import-scan
        uses: ivanamat/defectdojo-import-scan@v1
        with:
          token: ${{ secrets.DEFECTOJO_TOKEN }}
          defectdojo_url: ${{ secrets.DEFECTOJO_URL }}
          engagement: ${{ secrets.ENGAGEMENT }}
          product_name: ${{ secrets.PRODUCT_NAME }}
          file: snyk.json
          scan_type: Snyk Scan
          test_title: Snyk Scan
          tags: snyk
          skip_duplicates: true
          close_old_findings: true
      - name: Show response of defectdojo
        run: |
          set -e
          printf '%s\n' '${{ steps.import-scan.outputs.response }}'
  tfsec-scan:
    name: tfsec-scan
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    steps:
      - uses: actions/checkout@v2
      - name: Run tfsec
        uses: tfsec/tfsec-sarif-action@9a83b5c3524f825c020e356335855741fd02745f
        with:
          sarif_file: tfsec.sarif        
      - name: Publish report to defectdojo
        id: import-scan
        uses: ivanamat/defectdojo-import-scan@v1
        with:
          token: ${{ secrets.DEFECTOJO_TOKEN }}
          defectdojo_url: ${{ secrets.DEFECTOJO_URL }}
          engagement: ${{ secrets.ENGAGEMENT }}
          product_name: ${{ secrets.PRODUCT_NAME }}
          file: tfsec.sarif
          scan_type: SARIF
          test_title: tfsec Scan
          tags: tfsec
          skip_duplicates: true
          close_old_findings: true
      - name: Show response of defectdojo
        run: |
          set -e
          printf '%s\n' '${{ steps.import-scan.outputs.response }}'
  trivy-scan:
    name: trivy-scan
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    steps:
      - uses: actions/checkout@v2
      - name: Set up JDK 17
        uses: actions/setup-java@v2
        with:
          java-version: '17'
          distribution: 'temurin'  
      - name: Build with Gradle
        uses: gradle/gradle-build-action@4137be6a8bf7d7133955359dbd952c0ca73b1021
        with:
          arguments: build
      - name: Build Image
        run: |-
          pwd
          ls -al
          docker build  --tag "java_demo:${{ env.GIT_TAG }}" .
          docker tag "java_demo:${{ env.GIT_TAG }}" java_demo:1.0
        shell: bash
      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@2a2157eb22c08c9a1fac99263430307b8d1bc7a2
        with:
          image-ref: java_demo:1.0
          format: 'json'
          output: 'trivy-results.json'
          severity: 'CRITICAL,HIGH'
      - name: Publish report to defectdojo
        id: import-scan
        uses: ivanamat/defectdojo-import-scan@v1
        with:
          token: ${{ secrets.DEFECTOJO_TOKEN }}
          defectdojo_url: ${{ secrets.DEFECTOJO_URL }}
          engagement: ${{ secrets.ENGAGEMENT }}
          product_name: ${{ secrets.PRODUCT_NAME }}
          file: trivy-results.json
          scan_type: Trivy Scan
          test_title: Trivy Scan
          tags: trivy
          skip_duplicates: true
          close_old_findings: true
      - name: Show response of defectdojo
        run: |
          set -e
          printf '%s\n' '${{ steps.import-scan.outputs.response }}'
  hawkscan:
    name: hawk-scan
    runs-on: ubuntu-latest
    steps:
      - name: Sync ArgoCD Application
        uses: omegion/argocd-actions@v0.2.0
        with:
          address: "argocd.ngrok.buildsecurity.in"
          token: ${{ secrets.ARGOCD_TOKEN }}
          appName: "java-demo-dev"
      - name: Sleep for 30s
        uses: juliangruber/sleep-action@v1
        with:
          time: 30s
      - name: Clone repo
        uses: actions/checkout@v2
      - name: Run HawkScan
        uses: stackhawk/hawkscan-action@v2.0.0
        with:
          apiKey: ${{ secrets.HAWKSCAN_TOKEN }}
