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
Around september 2018 the new plug'n'play (PnP) installation strategy was unveiled for NodeJS that changes how packages are installed while still being backwards compatable. Currently when installing a package to be consumed by the [Node Resolution Algorithm][node_resolution_algorithm] it is added to the projects `node_modules` folder which is shared with all other dependencies of the project regardless of if they explicitly declare them as a dependency. It also requires that each time `npm install` or `yarn install` is run the entire `node_modules` folder needs to be regenerated, or at the very least each file needs to be checked, which makes this a very IO heavy operation leaving little room for optimisation as the system can only be so fast.


[pnp_runtime]: https://yarnpkg.com/features/pnp
[node_resolution_algorithm]: https://nodejs.org/api/modules.html#modules_all_together