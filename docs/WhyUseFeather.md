---
sidebar_position: 4
---

# Why Use Feather?

Feather is a great choice if one or more of the following is true:

- You can compute the configuration of those instances from some underlying state.
- There are 100s, 1000s or 10,000s of instances to manage.
- Memory efficiency is an important constraint.
- Not every instance in the tree needs to be updated every update.†

:::note

† This isn't because feather is too slow when every instance must be updated. Rather, you begin to hit a bottleneck in the Roblox Engine. For example, it just isn't possible to change the cframe of many thousands of parts every single frame without affecting performance, even with [WorldRoot:BulkMoveTo()](https://create.roblox.com/docs/reference/engine/classes/WorldRoot#BulkMoveTo). This will depend on what instances you are using, and what properties you are setting.

:::

Feather was specifically designed for use with [metaboard](https://github.com/metauni/metaboard) (it still uses Roact right now), to draw path-curves with parts. Each board can consist of 10-20,000 parts, and the contents of the board is a function of the curve data + recent edits (like erasing). The board gets updated as it is being written on, and *almost none* of the existing curves are affected by these updates, so this can be detected with a Feather component to only trigger the necessary updates.