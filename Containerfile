FROM registry.redhat.io/ubi9/go-toolset:9.8-1790174511@sha256:0a4666f7a4eb0644c97a73cba198eb268691b270d97831822689e7a2088f87be AS builder

COPY go.mod go.sum* ./
RUN go mod download

COPY cmd/ cmd/
COPY internal/ internal/
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o ./alerts-adapter ./cmd/alerts-adapter

FROM registry.access.redhat.com/ubi9-micro:9.8-1791765224@sha256:ff30602252a3e92706585c7c34cd3c74028eaac4ab815e6b19f8b27562bdd7e3

LABEL com.redhat.component="lightspeed-agentic-alerts-adapter" \
      name="openshift-lightspeed/lightspeed-agentic-alerts-adapter-rhel9" \
      version="0.1.0" \
      release="1" \
      summary="Lightspeed Agentic Alerts Adapter" \
      description="Polls OpenShift AlertManager for firing alerts and creates AgenticRun CRs to trigger automated remediation via the Lightspeed Agentic operator." \
      io.k8s.description="Polls OpenShift AlertManager for firing alerts and creates AgenticRun CRs to trigger automated remediation via the Lightspeed Agentic operator." \
      url="https://github.com/openshift/lightspeed-agentic-alerts-adapter" \
      vendor="Red Hat, Inc." \
      distribution-scope="public" \
      cpe="cpe:/a:redhat:openshift_lightspeed:2::el9"

COPY LICENSE /licenses/LICENSE
COPY --from=builder /opt/app-root/src/alerts-adapter /usr/local/bin/alerts-adapter

USER 1001

ENTRYPOINT ["alerts-adapter"]
