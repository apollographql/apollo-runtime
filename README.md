# Apollo Runtime All-In-One

A container that contains all the required utilities to run the Apollo Runtime, including our new MCP Server.

## Container Tags

> ⚠ Note we do not support every potential combination of the tags below so please check the container you want
> exists before attempting to use it.

The container has a tagging scheme that consists of three parts, the container version, the Apollo Router version, 
and the MCP Server version, each separated by underscores.

This leads to different tags that will pin different versions of the runtime components as well as the container itself.

For example:
* `ghcr.io/apollographql/runtime-all-in-one:latest` - This will give the latest of all components and the runtime container
* `ghcr.io/apollographql/runtime-all-in-one:v0.1.0_router2.1.2` - This will pin the runtime container version and the router version, but always get the latest `mcp-server` version
* `ghcr.io/apollographql/runtime-all-in-one:latest_router2.1.2_mcp-server0.2.1` - This will pin Router and MCP Server versions but not the runtime container version

## Running The Container

The container can be run in multiple configurations depending on your specific needs, and several environment variables
and file paths can be overridden to give different behaviour.

To get started though, you can use a command like the following, substituting the `APOLLO_GRAPH_REF` and `APOLLO_API_KEY` for the correct values: 
```shell
docker run \
--env APOLLO_GRAPH_REF="your graph here" \
--env APOLLO_KEY="your key here" \
--rm \
-p 4000:4000 \
-p 5001:5001 \
ghcr.io/apollographql/runtime-all-in-one:latest
```

### Schemas

Two kinds of schema can be provided to the container for use by the Router and the MCP Server. These are the 
Supergraph Schema and the Supergraph API Schema respectively.

#### Supergraph Schema

Providing a Supergraph Schema to the container can be done in two ways, either from GraphOS (as in the example above)

##### GraphOS Based
You can provide a schema directly from GraphOS by setting two environment variables 
* `APOLLO_API_KEY` - This should be set to the value of a Graph API Key, generated in GraphOS Studio
* `APOLLO_GRAPH_REF` - This should be set to the value of the GraphRef from GraphOS Studio

This is already demonstrated in the example above

##### File Based 
Alternatively you can provide the schema to the container can be done by using a volume mount and mounting a file to the path `/dist/schema.graphql`. 
To do this add a new flag to the command above as follows:

```shell
...
-v <<ABSOLUTE_PATH_TO_SCHEMA>>:/dist/schema.graphql
...
```

#### API Schema
To provide an API schema to the MCP Server you can volume mount a file to `/dist/api_schema.graphql`.
To do this add a new flag to the command above as follows:

```shell
...
-v <<ABSOLUTE_PATH_TO_API_SCHEMA>>:/dist/api_schema.graphql
...
```

### Operations
To provide the MCP Server with a set of operations in a file you can volume mount a folder to `/dist/operations`.
To do this add a new flag to the command above as follows:

```shell
...
-v <<ABSOLUTE_PATH_TO_OPERATIONS>>:/dist/operations
...
```

### Router Config
To override the default router config provided you can mount your own to `/dist/config.yaml`.
To do this add a new flag to the command above as follows:

```shell
...
-v <<ABSOLUTE_PATH_TO_ROUTER_CONFIG>>:/dist/config.yaml
...
```

### Dev Mode
To enable Dev Mode for the Router, set the environment variable `DEV_MODE` to the value 1 when running the container.
This can be done by adding a new flag to the command above as follows:
```shell
...
--env DEV_MODE=1
```