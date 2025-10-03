# Apollo Runtime Container

A container that has all the required utilities to run the Apollo Runtime, including our new MCP Server.

## Container Tags

> ⚠ Note we do not support every potential combination of the tags below so please check the container you want
> exists before attempting to use it.

The container has a tagging scheme that consists of three parts, the container version, the Apollo Router version, 
and the MCP Server version, each separated by underscores.

This leads to different tags that will pin different versions of the runtime components as well as the container itself.

For example:
* `ghcr.io/apollographql/apollo-runtime:latest` - This will give the latest of all components and the runtime container
* `ghcr.io/apollographql/apollo-runtime:v0.1.0_router2.1.2` - This will pin the runtime container version and the router version, but always get the latest `mcp-server` version
* `ghcr.io/apollographql/apollo-runtime:latest_router2.1.2_mcp-server0.2.1` - This will pin Router and MCP Server versions but not the runtime container version

> If `ghcr.io` is inaccessible to you, we also publish all images to DockerHub as of `0.0.13_router2.5.0_mcp-server0.7.0` onwards.
> 
> Simply run `docker pull apollograph/apollo-runtime` to access the images

## Running The Container

The container can be run in multiple configurations depending on your specific needs, and several environment variables
and file paths can be overridden to give different behaviour.

To get started though, you can use a command like the following, substituting the `APOLLO_GRAPH_REF` and `APOLLO_KEY` for the correct values: 
```shell
docker run \
--env APOLLO_GRAPH_REF="your graph here" \
--env APOLLO_KEY="your key here" \
--env MCP_ENABLE=1 \
--rm \
-p 4000:4000 \
-p 8000:8000 \
ghcr.io/apollographql/apollo-runtime:latest
```
We open two ports in the above command:
- 4000 is where the router is listening. Make your GraphQL queries here.
- 8000 is where the MCP server is mounted, specifically at the `/mcp` path. Connect your assistants to this port.

### Running the MCP Server

Set the environment variable `MCP_ENABLE` when running the container.

```shell
...
--env MCP_ENABLE=1 \
...
```

See the example [config file](config/mcp_config.yaml) for information on configuring the MCP Server.

## Configuring Using Local Files

Many of the features the container provides can be configured by using and editing local files. To do this create a copy
of the [`config` folder](config), name it `my_config`. Then add the following new flag to the command from above:

```shell
...
-v <<ABSOLUTE_PATH_TO_THE_MY_CONFIG_DIRECTORY>>:/config
...
```

The configuration options below will make it clear when files need to be added to or changed in the `my_config` directory.

> 💡 If you want to override individual files, rather than the whole directory simply change the command above
> so it refers to an individual file. For example:
> 
> ```shell
> ...
>  -v <<ABSOLUTE_PATH_TO_SCHEMA_FILE>:/config/schema.graphql 
> ...
> ```

### In Dockerfile
If you're working with a `Dockerfile` instead of a CLI, you can also add the following to use local files:
```dockerfile
FROM ghcr.io/apollographql/apollo-runtime:latest

EXPOSE 4000

COPY data/router.yaml /config/router_config.yaml
COPY data/schema.graphql /config/schema.graphql

ENV APOLLO_ROUTER_CONFIG_PATH=/config/router_config.yaml
ENV APOLLO_ROUTER_SUPERGRAPH_PATH=/config/schema.graphql
```

### Schemas

Two kinds of schema can be provided to the container for use by the Router and the MCP Server. These are the 
Supergraph Schema and the Supergraph API Schema respectively.

#### Supergraph Schema

Providing a Supergraph Schema to the container can be done in two ways.

##### GraphOS Based
You can provide a schema directly from GraphOS by setting two environment variables 
* `APOLLO_KEY` - This should be set to the value of a Graph API Key, generated in GraphOS Studio
* `APOLLO_GRAPH_REF` - This should be set to the value of the GraphRef from GraphOS Studio

This is already demonstrated in the example above

##### File Based 
Alternatively you can provide the schema to the container can be done by using a local file. Add your schema
file to the `my_config` directory, ensuring it is named `schema.graphql` to use this feature

#### API Schema
To provide an API schema to the MCP Server you can add a file called `api_schema.graphql` to the `my_config`
directory.

### Persisted Queries Manifests
To provide a Persisted Queries Manifest to the MCP Server you can add a file called `persisted_queries_manifest.json` to
the `my_config` directory.

### Custom Scalars Config
To provide a Custom Scalars Config to the MCP Server you can add a file called `custom_scalars.graphql` to the 
`my_config` directory.

### Operations
To provide the MCP Server with a set of operations in a file you either:

* Add the operations to a new folder called `operations` in the `my_config` folder or
* Mount an existing folder of operations to `/config/operations` in the container. That can be achieved with an
additional flag to the command thus:

```shell
> ```shell
> ...
>  -v <<ABSOLUTE_PATH_TO_EXISTING_OPERATIONS_FOLDER>:/config/operations
> ...
```

### Router Config
To override the default router config provided you can change the values in the `router_config.yaml` file in
the `my_config` directory.

### Dev Mode

> ⚠️ This setting should not be used in a production context

To enable Dev Mode for the Router, set the environment variable `DEV_MODE` to the value 1 when running the container.
This can be very useful when testing out the container as it enables 
[Apollo Sandbox](https://www.apollographql.com/docs/graphos/platform/sandbox) and will hot reload the router if
config changes.

This can be done by adding a new flag to the command above as follows:
```shell
...
--env DEV_MODE=1
...
```

## Configuring Using Environment Variables

There are several environment variables you can pass to Router and MCP Server to further configure their behaviour,
these are as follows:

| Environment Variable             | Notes                                                                                                                                                                  |
|----------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `APOLLO_KEY`                     | A valid API Key for Apollo Studio                                                                                                                                      |
| `APOLLO_GRAPH_REF`               | The Graph Ref in Apollo Studio referenced by the Router and MCP Server                                                                                                 |
| `MCP_ENABLE`                     | Enable the MCP Server                                                                                                                                                  |
