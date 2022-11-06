---
sidebar_position: 2
---

# Key Differences to Roact

## Features

There is no support for events, state, hooks, lifecycle methods, context etc. Feather is supposed to be simple and lightweight so it can handle many instances, and is not intended to be a replacement for Roact. However you could certainly make use of Feather *within* a Roact component, by calling `Feather.mount`, `Feather.update` and `Feather.unmount` in `Component:didMount`, `Component:didUpdate` and `Component:willUnmount` respectively.

## Host Elements

It is assumed that the instance class does not change for a fixed key. This avoids reading `Instance.ClassName`, which (I think) is costly for many instances, and also avoids the alternative solution of storing the class name in memory. If it seems necessary to change the class of an instance, consider using a different key, or restructuring your tree so that the other-class version of some host lives on a different branch.

## Host Children

In Roact you can pass the children table to the `[Roact.Children]` key of the prop table, or as the third argument of `Roact.createElement`. `Feather.createElement` does not support an optional children argument - you must use the [Feather.Children](/api/Feather#Children) or [Feather.DeltaChildren](/api/Feather#DeltaChildren) key. This makes it more explicit which kind is in use.

## Host Props

Feather does not store host props, so it cannot revert a host property to the default value if it is missing from the props table. For example, the following update would not set the part color back to the default color (like it would in Roact).

```lua
Feather.update(tree, e(sphere, {

	Diameter = 2,
	Position = Vector3.new(0,5,0),
}))
```

However, this can be exploited for performance by performing only the necessary updates to props (see [Optimising](/docs/Optimising))
This makes Feather **not** *truly declarative*, and the props table for hosts should be considered as an update-table, not a complete description of the host properties.

## Function components are pure

Function components are treated as *pure* by default, meaning if there are no differences in the keys and values of the old and new props, the update process will shortcut.


