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

An [example config](datadog/otel-collector/otel-config.yaml) is provided in the `datadog/otel-collector` directory for interfacing with 
[DataDog](https://docs.datadoghq.com/opentelemetry/setup/collector_exporter/), other APM providers will provide similar
documentation and the example can be further tweaked to suit these requirements.

## Deployment to AWS ECS

Before you start:

1. [Set up a GraphQL API in GraphOS](https://www.apollographql.com/docs/graphos/get-started/guides/graphql#step-1-set-up-your-graphql-api).
    * Save your `APOLLO_KEY` and `APOLLO_GRAPH_REF`. You'll need them when deploying the container.
2. Set up you [AWS environment](https://aws.amazon.com/getting-started/guides/setup-environment/)
    * Install the AWS CLI.
3. Choose a version of the container to deploy. See [the tagging section](README.md) of the README for more information.

## Create and deploy ECS task

With your image pushed to your ECR repository, in ECS you can define a task and deploy it as a service.

### Create cluster

You need an ECS cluster to deploy the router.

If you don't have a cluster, you can create one with default settings:

1. In the AWS Console, go to the Amazon ECS Console, then click **Create cluster**.
2. Enter a name for your cluster.
3. Click **Create**.

### Create task definition

Create an ECS task definition for your router:

1. In the AWS ECS Console, go to **Task definitions** from the left navigation panel, then click **Create new task definition**.
2. Fill in the details for **Container - 1**:
    * **Name**: Enter a container name
    * **Image URI**: Select the URI of your Apollo Runtime Container image (i.e. `ghcr.io/apollographql/apollo-runtime:0.0.4_router2.3.0_mcp-server0.3.0`)
    * **Port mappings**:
      * **Router**
        * **Container port**: Enter `4000` (must match) and
        * **Port name**: router
        * **App protocol**: HTTP
      * **MCP Server** (if using)
        * **Container port**: Enter `5000`(must match) and
        * **Port name**: mcp-server
        * **App protocol**: HTTP
    * **Environment variables**: 
      * `APOLLO_KEY` - Set to the value acquired in the prerequiste steps (_You could also use a secret reference here, if required_)
      * `APOLLO_GRAPH_REF` - Set to the value acquire in prerequiste steps
      * `DEV_MODE` - Set to the value '1'
      * For further environment variables to configure the container see [the environment variables section](README.md) of the README
3. Click **Create**.

### Deploy to ECS

Deploy the Apollo Runtime container in your ECS cluster:

1. In AWS ECS Console under **Task definitions**, select your defined task, then click **Deploy** and select **Create service**.
2. Fill in the fields for the service:
    * **Existing cluster**: Select your cluster
    * **Service name**: Enter a name for your service
3. Click **Create** to create the service. ECS will start deploying the service for the router.
4. Once the service is created go to **Configuration and Networking**, then under **Network Configuration** click on the name of the Security Group
5. Click **Edit Inbound Rules**
    * Add a rule:
      * **Type**: Custom TCP
      * **Port Range**: 4000
      * **CIDR Blocks**: 0.0.0.0/0
    * If using the MCP Server add a second rule:
      * **Type**: Custom TCP
      * **Port Range**: 5000
      * **CIDR Blocks**: 0.0.0.0/0
6. Go to the service URL and validate the router's development Sandbox is running successfully.

Congratulations you've successfully deployed the Apollo Runtime Container

> Note: The above security group settings are for *testing only* and should not be used in production unless you wish
> to expose those ports to all incoming traffic. Security group settings should be chosen carefully in line with your 
> specific needs.
