---
layout: page
title: Open source contributions & GitHub analysis
permalink: /contributions/
---

REG Open Source Service Area develop and set up tooling to track open source contributions flowing both in and out of the Turing — to understand the health of our open source footprint and to recognise the contributions REG members make.

## Outbound: Turing contributions to upstream open source repos

REG members contribute to external open source projects throughout their work. We're building better ways to surface and celebrate this.

The most directly tracked is the outcomes of our [hacksessions](./hacksessions).

## Inbound: Open source to Turing repos

We also track contributions coming into Turing-owned repositories from the wider open source community. This gives us a better understanding of where Turing projects are having impact in the wider open source ecosystem and helps us identify projects that are particularly active and may need more support. We also hope to use this data to understand what makes a good open source project and how we can instil those qualities in more of our work.

## Tools

### Pre-existing tools

We've evaluated several open source tools for analysing GitHub contribution data, including:

- **[GrimoireLab](https://chaoss.community/kb/grimoirelab/)** — a free open source toolkit for software development analytics, developed by the CHAOSS project. We've used it to pull GitHub data from all alan-turing-institute repos. It's helped us manage our GitHub org (e.g. archiving stale repo, managing GitHub user accounts) and we're exploring how we can use it to track open source health metrics.
- **GitHub org metrics** — GitHub's built-in org-level contribution data. This is useful for a quick overview of the alan-turing-institute org, particularly as it allows you to download all data as a csv for further analysis. See ours [here](https://alan-turing-institute.github.io/org-metrics-dashboard/).

### Tools we've built

- **github-analyzer** - We built our own Python tool for pulling data from GitHub using the GitHub API. We've used this to get licencing data across all repos in the alan-turing-institute org, analyse top contributors to repos and lots of other custom queries that aren't easily available in the above tools.
- **missing-licence GitHub Action** - We built a GitHub Action that scans an organisation for public repositories without a license and opens issues to notify owners. This has been useful for encouraging new repos created on the alan-turing-institute org to add licences and for identifying repos that need a nudge to add a licence. 