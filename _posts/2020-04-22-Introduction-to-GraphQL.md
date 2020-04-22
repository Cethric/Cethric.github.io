---
layout: post
excerpt_separator: <!-- content -->
time: '2020-04-22 16:30 +1000'
author: Blake Rogan
toc: true
published: true
title: Introduction to GraphQL
category:
  - Blogging
  - Tutorial
tags:
  - graphql
  - hasura
  - apollo
  - tutorial
  - web-api
---
What is GraphQL and how do I use it?

An incomplete introduction to GraphQL.

<!-- content -->

In this blog post, I will cover some basic techniques to create a GraphQL server using the Apollo Server Library and the Hasura GraphQL engine. I will then go on to provide an example of how to connect a client application to the GraphQL server.
I should also note that this tutorial does not cover all of the features of GraphQL but only a few of them

# GraphQL Server

##  Apollo GraphQL Server

When designing an Apollo GraphQL server 3 key areas need to be considered;

- [The Schema](#the-schema) &mdash; provides structure to the API and defines what the types, queries, mutations, and subscriptions look like and how they can be used
- [The Resolvers](#the-resolvers) &mdash; are a way to descript what each query, mutation, and subscription will do.
- [The Server](#the-server) &mdash; is the final part that wraps the schema and resolvers together into a functional API that can be consumed by a [GraphQL client](#graphql-client)

An example of how this all links together can be [found here][apollo-example]


### The Schema
In GraphQL a schema defines fields that can be queried, mutated, or subscribed to and what the type of those fields are. GraphQL provides a Domain Specific Language (DSL) known as the GraphQL Schema Definition Language (SDL) which is used to create these schemas.

#### What makes a schema
When defining a GraphQL schema there are a few key parts that must be present. These include the `Root` type (some GraphQL server libraries may automatically define this) which is used to group the [`Query`, `Mutation`, and `Subscription`][the-query-and-mutation-types] types. A `Query` type should be defined if there are any queries that can be made in the API, A `Mutation` type should be defined if there are any mutations that can be made and a `Subscription` type should be defined if a user can subscribe to server events (This feature uses WebSockets so that the server can notify the client of an event)

As well as the predefined `Query`, `Mutation` and `Subscription` types GraphQL allows you to define custom types. This is achieved using the [`type`][object-types-and-fields] keyword for custom objects and the [`scalar`][scalar-types] keyword for custom scalars (such as Apollo file uploading facility or the `_uuid` in Hasura).

For example, it is possible to create a `Book` type that contains a custom `BookId` scalar

Something to note however is that types are only output to be able to bundle arguments together the [`input`][input-types] type needs to be used.

Unlike some typesafe languages which assume a value is not `null` by default, GraphQL does the opposite and will assume a value is `nullable` unless declared otherwise with the exclamation mark (`!`) operator

#### Example
An example schema is defined below for a simple book database where a user can query for all books or a specific book by title. They are also able to insert a new book into the database.
```graphql
type Book {
    title: String
    author: String
}

type Query {
    books: [Book]!

    book(title: String!): Book
}

type Mutation {
    insert_book(title:String! author:String!): Boolean!
}

```

For more information about how to create GraphQL schemas [visit the GraphQL website here](https://graphql.org/learn/schema)

### The Resolvers
Resolvers are used to connect the GraphQL schema to an action in the server. 

In the example of an Apollo GraphQL server resolvers link a schema type to its respective response, each response is a function that can take up to four arguments.

|---|---|
| `parent`/`source` | The result of the parent resolver (the previous resolver in the chain) |
| `args` | an object of input arguments from the GraphQL schema |
| `context` | a shared object between all resolvers for a particular operation. This can be used to share state |
| `info` | Information about the current operation's execution state |

Each of these functions will return a result that matches the format defined in the return type of the GraphQL schema.

```typescript
const resolvers: Resolvers = {
    Query: {
        books: (source, args, context) => {
            return context.data.books();
        },
        book: (source, {title}, context) => {
            return context.data.book(title);
        },
    },
    Mutation: {
        insert_book: (source, {title, author}, context) => {
            return context.data.insertBook(title, author);
        }
    },
}

```


### The Server
Finally, a GraphQL server is declared where the schema (`typeDefs`) `resolvers` and `context` are brought together in a single object and the server is then launched. In this example, the server will expose the [GraphiQL][graphiql-link] IDE to [`http://localhost:3000`](http://localhost:3000) which is also the same endpoint address for the GraphQL API

```typescript
const server = new ApolloServer({
    typeDefs,
    resolvers,
    context: (async (context) => ({
        data: new MockDatabase(),
        ...context,
    })) as DatabaseResolverContextFunction
});

server.listen({
    port: 4000,
}).then(({url}) => {
    console.log(`🚀  Server ready at ${url}`);
}).catch((reason) => {
    console.error('Failed to launch server');
    console.error(reason);
});

```

## Hasura GraphQL Engine
The [Hasura GraphQL Engine][hasura-home-page] is an alternative batteries included approach to creating a GraphQL server compared to the Apollo GraphQL Server. It makes use of a PostgreSQL database for storage and a web interface/rest API to manage and interact with the server. Hasura allows for other GraphQL servers, microservices and other serverless code to be merged into a single GraphQL endpoint making it easier to manage and access from the clients' machine.

### Running the server
Hasura can be launched using the following docker-compose script
```yaml
version: "3.7"

services:
  postgres:
    image: postgres:12
    ports:
      - "5432:5432"
    restart: always
    environment:
      POSTGRES_PASSWORD: ChangeThisDatabasePassword
    volumes:
      - type: volume
        source: database
        target: /var/lib/postgresql/data
        volume:
          nocopy: true

  hasura:
    image: hasura/graphql-engine:v1.2.0-beta.4
    restart: always
    depends_on:
      - postgres
    ports:
      - "8090:8080"
    environment:
      HASURA_GRAPHQL_DATABASE_URL: postgres://postgres:ChangeThisDatabasePassword@postgres:5432/postgres
      HASURA_GRAPHQL_ENABLE_CONSOLE: "false"
      HASURA_GRAPHQL_ENABLED_LOG_TYPES: startup, http-log, webhook-log, websocket-log, query-log
      HASURA_GRAPHQL_ADMIN_SECRET: "ChangeThisSecretKey"
      HASURA_GRAPHQL_UNAUTHORIZED_ROLE: "public"

volumes:
  database:
    name: "GraphQLIntroPostgreSQL"
```

The two volumes that are bound to the Hasura container (ln 32 &amp; ln 37) are for the Hasura metadata and migrations API which can be used to automate the process of creating the container and the PostgreSQL database

An example of this can be [found here](https://github.com/Cethric/GraphQLIntro/tree/master/hasura)


### Connecting to the server
When accessing Hasura for the first time in a web browser (which in this example is available at [`http://localhost:8090`](http://localhost:8090)) you will need to enter the secret key (`ChangeThisSecretKey`) to be granted admin priveledges where you can start defining the structure of the `PostgreSQL` tables, the permissions on each row and column of a table and any custom actions, triggers or remote schemas that should be joined.

# GraphQL Client
When connecting to GraphQL using the GraphQL client there is a [common part](#apollo-graphql-client) and then there may be a plugin for the front end framework being used to display content to the user. In this example it is [VueJS](#vuejs-web-application)

An example of this can be [found here](https://github.com/Cethric/GraphQLIntro/tree/master/apollo-client)

## Apollo GraphQL Client

```typescript
const httpLink = createHttpLink({
    // You should use an absolute URL here
    uri: 'http://localhost:8090/v1/graphql',
});

// Cache implementation
const cache = new InMemoryCache();

// Create the apollo client
const apolloClient = new ApolloClient({
    link: httpLink,
    cache,
});
```

## VueJS Web Application


```typescript
const apolloProvider = new VueApollo({
    defaultClient: apolloClient,
});

export {
    apolloClient,
    apolloProvider,
};
```

To then use the GraphQL provider the following can be done.

For a mutation:
```typescript
const result = await this.$apollo.mutate<MutationResult, MutationVariables>({
  mutation: gql`mutation($author:String! $title: String!) {
    insert_book(object: {author: $author title: $title}) {
      author
      title
    }
  }`,
  variables: {
    title: this.title,
    author: this.author,
  }
});
```

For a query
```typescript
@Component({
  apollo: {
    book: {
      query: gql`query($title:String!) {book(title:$title){title author}}`,
      variables() {
        return {
          title: this.$route.params.title,
        }
      }
    },
  }
})
export default class Details extends Vue {
}
```

# Links
[GraphQL](https://graphql.org/)

[Apollo GraphQL][hasura-home-page]

[Hasura GraphQL Engine](https://hasura.io/)

[Example Project](https://github.com/Cethric/GraphQLIntro)

[hasura-home-page]: https://www.apollographql.com/
[apollo-example]: https://github.com/Cethric/GraphQLIntro/tree/master/apollo
[the-query-and-mutation-types]: https://graphql.org/learn/schema/#the-query-and-mutation-types
[object-types-and-fields]: https://graphql.org/learn/schema/#object-types-and-fields
[scalar-types]: https://graphql.org/learn/schema/#scalar-types
[input-types]: https://graphql.org/learn/schema/#input-types
[graphiql-link]: https://github.com/graphql/graphiql
