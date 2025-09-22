### Setup Instructions

#### Setting up the OTEL Collector

1. Copy the `otel-config.yaml` to the path `/config/otel-config.yaml` so that the packaged OTEL collector can find it.
2. Copy the `router_config.yaml` to your `/config/router_config.yaml` directory
3. Configure the resource attributes in your copied `router_config.yaml`:
   ```yaml
   resource: ## Resource attributes are used to identify the service in datadog see https://docs.datadoghq.com/opentelemetry/mapping/semantic_mapping/?tab=datadogexporter and https://opentelemetry.io/docs/specs/semconv/resource/ and https://www.apollographql.com/docs/graphos/routing/observability/telemetry/metrics-exporters/overview#resource
     "deployment.environment.name": "local"
     "host.name": "<INSERT_HOSTNAME_HERE>"
     "service.name": "runtime-all-in-one:router"
   ```
4. Set the required environment variables

### Environment Variables

The following environment variables are required for the OTEL collector configuration:

- `DD_SITE` - Your Datadog site (e.g., datadoghq.com, datadoghq.eu)
- `DD_API_KEY` - Your Datadog API key




