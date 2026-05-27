---
layout: page
title: OSPO activities
permalink: /ospo/
---

REG Open Source Service Area also contribute to institute-level housekeeping similar to the work of an [Open Source Programme Office (OSPO)](https://github.com/todogroup/ospodefinition.org).

## Archiving

Turing's GitHub organisation accumulates repositories over time — many are maintained, but some are stale such as projects which are no longer funded, stale forks or finished work/research that no longer needs to be actively maintained. REG OSSA identifies these stale repos and encourages archival for repos that are no longer active.

In 2025 we ran our first major archiving pass across the alan-turing-institue org: we gathered repo activity data via GrimoireLab, identified inactive repos, contacted the top contributor(s) for each one and archived the repo if they agreed. In total, we archived 177 repos in this first pass.

We are now planning a second pass to catch any newly inactive repos and to manage stale forks (of which there are over 100 in the Turing org). 

## Licensing

Open source software needs a licence to be open source. REG OSSA tries to ensure Turing repositories have licences and develop policies and guidance on which licences to choose.

In 2025 we ran our first audit of Turing's GitHub repositories to identify any that were missing licences: we found that 84 public repos were missing licences using our github-analyzer tool, we divided these into repos that contained minimal content (34) versus those that contained licenseable content (50), contacted top contributor(s) and encouraged them to add a licence. So far, 19 repos have added licences as a result of this inital outreach.

Since then we have also built a [missing-licence GitHub Action](https://github.com/alan-turing-institute/missing-license) to help us automatically identify Turing repos that are missing licences. This runs once monthly across the alan-turing-institute org and creates issues on repos that are missing licences. We hope this will help authors of newly public repos to remember to add a licence in particular.

We are also hoping to do a second pass encouraging any remaining unlicensed repos to add licences and do some cleanup of repos that we deemed to contain minimal content and therefore not worth licensing.

We are also working to ensure that datasets and models published on Turing's HuggingFace account are licensed appropriately, and to develop guidance for researchers on how to choose licences for these types of research outputs.

## Policy & guidance

REG OSSA are improving the written guidance available to Turing researchers and engineers working on open source software. This includes developing an [Open Source Policy for the Research Engineering Group (REG)](https://alan-turing-institute.github.io/REG-handbook/docs/how_we_work/open_source_policy/) and improving the guidance available in the REG handbook. 

We are working towards improving/expanding the Turing-wide Open Source Policy and developing a set of guidelines for open sourcing private projects.
