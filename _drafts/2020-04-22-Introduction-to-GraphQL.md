---
layout: post
excerpt_separator: <!-- content -->
time: '2020-04-22 09:05 +1000'
author: Blake Rogan
toc: true
published: false
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

In this blog post I will cover some basic techniques to create a GraphQL server using the Apollo Server Library and the Hasura GraphQL engine. I will then go on to provide an example of to connect a client application to the GraphQL server.

# GraphQL Server

##  Apollo GraphQL Server

When designing a Apollo GraphQL server 3 key areas need to be considered;

- [The Schema](#the-schema) &mdash; provides structure to the API and defines what the types, queries, mutations and subscriptions look like and how they can be used
- [The Resolvers](#the-resolvers) &mdash; are a way to descript what each query, mutation and subscription will do.
- [The Server](#the-server) &mdash; is the final part that wraps the schema and resolvers together in to a functional API that can be consumed by a [GraphQL client](#graphql-client)

An example for how this all links together can be [found here](https://github.com/Cethric/GraphQLIntro/tree/master/apollo)


### The Schema
The schema can be defined using the following format:

```graphql
type Book {
	title: String
	author: String
}

type Query {
	books: [Book]!

	book(title:String!): Book
}

type Mutation {
	insert_book(title:String! author:String!): Boolean!
}
```

### The Resolvers
Resolvers can be declared in the following way


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
The server can be declared in the following way

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

Hasura can be launched using the following docker compose script
```yaml
version: "3.7"

services:
  postgres:
    image: postgres:12
    ports:
      - "5432:5432"
    restart: always
    environment:
      POSTGRES_PASSWORD: databasePassword
    volumes:
      - type: volume
        source: database
        target: /var/lib/postgresql/data
        volume:
          nocopy: true

  hasura:
    image: hasura/graphql-engine:v1.2.0-beta.3.cli-migrations-v2
    restart: always
    depends_on:
      - postgres
    ports:
      - "8090:8080"
    environment:
      HASURA_GRAPHQL_DATABASE_URL: postgres://postgres:databasePassword@postgres:5432/postgres
      HASURA_GRAPHQL_ENABLE_CONSOLE: "false"
      HASURA_GRAPHQL_ENABLED_LOG_TYPES: startup, http-log, webhook-log, websocket-log, query-log
      HASURA_GRAPHQL_ADMIN_SECRET: "hasuraSecret"
      HASURA_GRAPHQL_UNAUTHORIZED_ROLE: "public"
    volumes:
      - type: bind
        source: ./metadata
        target: /hasura-metadata
        read_only: true

      - type: bind
        source: ./migrations
        target: /hasura-migrations
        read_only: true

volumes:
  database:
    name: "GraphQLIntroPostgreSQL"
```

The two volumes that are bound to the hasura container (ln 32 &amp; ln 37) are for the hasura metadata and migrations API which can be used to automate the process of creating the container and the PostgreSQL database

An example for this can be [found here](https://github.com/Cethric/GraphQLIntro/tree/master/hasura)

# GraphQL Client
When connecting to GraphQL using the GraphQL client there is a [common part](#apollo-graphql-client) and there may be a plugin for the front end framework being used to display content to the user. In this example it is [VueJS](#vuejs-web-application)

An example for this can be [found here](https://github.com/Cethric/GraphQLIntro/tree/master/apollo-client)

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

[Apollo GraphQL](https://www.apollographql.com/)

[Hasura GraphQL Engine](https://hasura.io/)

[Example Project](https://github.com/Cethric/GraphQLIntro)
