# Examples

This directory contains some example code that can be used to run this container in 
some different scenarios

## Docker Compose With Grafana

To run the container with the [Grafana LGTM](https://grafana.com/blog/2024/03/13/an-opentelemetry-backend-in-a-docker-image-introducing-grafana/otel-lgtm/)
image you can use the [`compose.yaml`](./compose.yaml) file in this directory.

This will run a local instance of the OTEL Collector, Grafana, Loki, Tempo and Prometheus
which means you can explore the different metrics the Router and the MCP Server output.

To do this run the following command

```shell
APOLLO_KEY="your Apollo API Key" \
APOLLO_GRAPH_REF="your graph ref" \
docker compose up 
```

Execute some GraphQL queries against the running router, then navigate to `http://localhost:3000`, which will be a 
running Grafana instance. If you navigate to `Drilldown` in the left hand menu you can see the different metrics the
router has emitted, start to build dashboards etc.

> ⚠️ The dashboards you create will not persist between runs of the container so make sure to export the JSON before 
> the container shuts down!

## Configuring The OTEL Collector For Use With Your Own APM

By default, the container ships with a bundled OTEL Collector, however the functionality is turned off by default. If 
however, you supply a valid OTEL Collector config at the path `/config/otel-config.yaml`, the collector will turn on
and start collecting Router metrics. These can then be sent to your own APM system by tweaking the config to suit your 
needs.

An [example config](datadog/otel-collector/otel-datadog.yaml) is provided in the `datadog` directory for interfacing with 
[DataDog](https://docs.datadoghq.com/opentelemetry/setup/collector_exporter/), other APM providers will provide similar
documentation and the example can be further tweaked to suit these requirements.