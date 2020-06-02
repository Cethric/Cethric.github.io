---
layout: post
excerpt_separator: <!-- content -->
time: '2020-05-26 15:36 +1000'
author: Blake Rogan
toc: true
published: true
title: Yarn 2 the new Project Manager
tags:
  - Yarn 2
  - PNP
  - NodeJS
  - Tutorial
  - Project Structure
categories:
  - Blogging
  - Tutorial
---
So the new version of Yarn broke your project. It was broken anyway. Yarn just made you fix it.

<!-- content -->

--

Yarn 2 is the *new and improved* version of the popular package manager Yarn which is an alternative to the default **N**ode **P**ackage **M**anager that comes with NodeJS. In this article, I will talk about some of the things that it breaks and ways to work around the issues until package maintainers update their projects to support the [plug and play runtime][pnp_runtime]. 


# The Plug'n'Play Runtime
Around September 2018 the new Plug'n'Play (PnP) installation strategy was unveiled for NodeJS that transformed the way packages are installed while still being backwards compatible. Currently, when installing a package to be consumed by the [Node Resolution Algorithm][node_resolution_algorithm], it is added to the project's `node_modules` folder which is shared with all other dependencies of the project regardless of if they explicitly declare them as a dependency. It also requires that each time the `install` operation is run the entire `node_modules` folder will be either regenerated or each file will be checked for differences. This regeneration and checking of the `nodue_modules` folder is a very IO heavy operation leaving little room for optimisation as the system can only be so fast.

What the PnP runtime does as part of the default installation process in Yarn 2 is to make it the responsibility of the package manager to perform all of the module resolutions and save it for later use. Unlike the current installation method that just places it in the `node_modules` folder and leaves resolution up to NodeJS each invokation.

This new installation process is considerably more stable and reliable due to the reduced IO operations and allows for much better dependency tree optimisations. This process also means that NodeJS start up times are noticably faster due to it only reading the `.pnp.js` to find packages and their dependencies, compared to needing to walk the `node_modules` folder for each dependency.

## The Problem
However all these great thinks come with a problem, it's not an issue that Yarn 2 created but rather one that it brought to light. Some packages rely on their dependencies to already be in `node_modules` without defining them in their own `package.json` file.
For example, package `A` depends on package `B` and uses parts of package `C` and package `B` depends on package `C`. In the previouse `node_modules` module resolution process this would work fine as package `C` is already in `node_modules` so even though package `A` does not depend on package `C` it is still able to use it. However in the new PnP runtime this would throw an issue `A package is trying to access another package without the second one being listed as a dependency of the first one.`

[pnp_runtime]: https://yarnpkg.com/features/pnp
[node_resolution_algorithm]: https://nodejs.org/api/modules.html#modules_all_together