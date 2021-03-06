---
layout: post
excerpt_separator: <!-- content -->
time: '2020-06-05 15:00 +1000'
author: Blake Rogan
toc: true
published: true
title: Yarn 2 the new Package Manager
tags:
  - Yarn 2
  - PNP
  - NodeJS
  - tutorial
  - Project Structure
categories:
  - Blogging
  - Tutorial
---
So the new version of Yarn broke your project. It was broken anyway. Yarn just made you fix it.

<!-- content -->

------

Yarn 2 is the *new and improved* version of the popular package manager Yarn which is an alternative to the default **N**ode **P**ackage **M**anager that comes with NodeJS. In this article, I will talk about some of the things that it breaks and ways to work around the issues until package maintainers update their projects to support the [plug and play runtime][pnp_runtime]. 


# The Plug'n'Play Runtime
Around September 2018 the new Plug'n'Play (PnP) installation strategy was unveiled for NodeJS that transformed the way packages are installed while still being backwards compatible. Currently, when installing a package to be consumed by the [Node Resolution Algorithm][node_resolution_algorithm], it is added to the project's `node_modules` folder which is shared with all other dependencies of the project regardless of if they explicitly declare them as a dependency. It also requires that each time the `install` operation is run the entire `node_modules` folder will be either regenerated or each file will be checked for differences. This regeneration and checking of the `nodue_modules` folder is a very IO heavy operation leaving little room for optimisation as the system can only be so fast.

What the PnP runtime does as part of the default installation process in Yarn 2 is to make it the responsibility of the package manager to perform all of the module resolutions and save it for later use. Unlike the current installation method that places it in the `node_modules` folder and leaves resolution up to NodeJS each invocation.

This new installation process is considerably more stable and reliable due to the reduced IO operations and allows for much better dependency tree optimisations. This process also means that NodeJS start-up times are noticeably faster due to only reading the `.pnp.js` to find packages and their dependencies, compared to needing to walk the `node_modules` folder for each dependency.

## The Problem
However, all these great things come with a problem, and it's not an issue that Yarn 2 created but rather one that was brought to light because of the new PnP runtime. Some packages rely on their dependencies to already be in `node_modules` without defining them in their own `package.json` file.
For example, package `A` depends on package `B` and uses parts of package `C` and package `B` depends on package `C`. In the previous `node_modules` module resolution process this would work fine as package `C` is already in `node_modules` so even though package `A` does not depend on package `C` it is still able to use it. However, in the new PnP runtime, this would throw an issue `A package is trying to access another package without the second one being listed as a dependency of the first one.`

## The Solution
As per the Yarn 2 [migration guide][migration_guide], the long term recommended solution is to provide a PR to the upstream package to add the missing dependencies to the package listings. However this can take time to be processed and filter into npm modules, so a short term solution is available that involves modifying the `.yarnrc.yml` file to make yarn aware of the missing dependencies. This can be achieved by adding entries to the [`packageExtensions`][package-extensions] key in the `.yarnrc.yml` file.

```yaml
packageExtensions:
  webpack@*:
    dependencies:
      lodash: "^4.15.0"
    peerDependencies:
      webpack-cli: "*"
```

In some situations, adding dependencies to the `packageExtensions` key may not be enough, or there might be too many to be practically possible to manage. As a result, the node linker mode can also be changed to revert back to the older `node_modules` format. This can be achieved by modifying the `nodeLinker` key in the `.yarnrc.yml` file
```yaml
# This can either be "pnp" or "node-modules"
nodeLinker: "node-modules"
```

# So should I use it in my next project?
The short answer not yet, unfortuanatly not enough projects have been updated to support the new PnP runtime which means that most of your time will be spent trying to resolve missing dependancies in the `packageExtensions` before you can start developing. However that does not mean that yarn 2 should not be used at all. Other features that may be discussed in future posts can still be used with the PnP runtime disabled, improved project management with workspaces, and reduced install times and project sizes compared to npm. Yarn2 is also being regularly updated and package maintainers' are updating their projects to [support the PnP runtime][compat_table].

[pnp_runtime]: https://yarnpkg.com/features/pnp
[node_resolution_algorithm]: https://nodejs.org/api/modules.html#modules_all_together
[migration_guide]: https://yarnpkg.com/advanced/migration
[package-extensions]: https://yarnpkg.com/configuration/yarnrc#packageExtensions
[compat_table]: https://yarnpkg.com/features/pnp#compatibility-table
