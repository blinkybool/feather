--[[
	From Roact: https://github.com/Roblox/roact/blob/master/src/Symbol.lua

	Symbols have the type 'userdata', but when printed to the console or coerced
	to a string, the name of the symbol is shown.
]]
local function namedSymbol(name)
	assert(type(name) == "string", "Symbols must be created using a string name!")

	local self = newproxy(true)

	local wrappedName = ("Symbol(%s)"):format(name)

	getmetatable(self).__tostring = function()
		return wrappedName
	end

	return self
end

--- @class Feather

local Feather = {
	
	Children = namedSymbol("Children"),
	DeltaChildren = namedSymbol("DeltaChildren"),
	SubtractChild = namedSymbol("SubtractChild"),
	HostInitProps = namedSymbol("InitProps"),
	BulkMoveCFrame = namedSymbol("BulkMoveCFrame")
}

--- @prop Children Symbol
--- @within Feather

--- @prop DeltaChildren Symbol
--- @within Feather

--- @prop SubtractChild Symbol
--- @within Feather

--- @prop HostInitProps Symbol
--- @within Feather

--- @prop BulkMoveCFrame Symbol
--- @within Feather

--[=[
	@type FeatherComponent string | (props: table, oldProps: table) -> FeatherElement
	@within Feather

	A string FeatherComponent is the ClassName of an Instance (e.g. "Part")

	A function FeatherComponent turns props into a FeatherElement.
	Optionally this function can also depend on the second argument passed `oldProps`
	if the component makes use of [Feather.DeltaChildren].
]=]
export type FeatherComponent = string | (props: {}, oldProps: {}) -> FeatherElement


-- --[=[
-- 	@ignore
-- 	@type FeatherElement { component: FeatherComponent, props: table, }
-- 	@within Feather
-- ]=]
export type FeatherElement = {
	component: FeatherComponent,
	props: {},
}

-- This is intended to mean
--   [1]: Instance -- hostInstance
--   [2]: table? -- deltaChildren
--   [3]: table? -- children
export type FeatherHostVirtualNode = {Instance | {}? | {}?}

export type FeatherFunctionVirtualNode = {
	result: FeatherVirtualNode?,
	component: (props: {}, oldProps: {}) -> FeatherElement,
	props: {},
}

export type FeatherVirtualNode = FeatherHostVirtualNode | FeatherFunctionVirtualNode

-- --[=[
-- 	@ignore
-- 	@type FeatherTree {root: FeatherVirtualNode, rootParent: Instance, rootKey: string}
-- 	@within Feather
-- ]=]
export type FeatherTree = {

	root: FeatherVirtualNode?,
	rootParent: Instance,
	rootKey: string,
}

--[=[
	@param component FeatherComponent
	@param props table
	@return FeatherElement
]=]

function Feather.createElement(component: FeatherComponent, props: {}): FeatherElement

	return {

		component = component,
		props = props,
	}
end

local function destroyVirtualNode(virtualNode: any): ()
	if virtualNode == nil then
		return
	end

	if virtualNode[1] then
		virtualNode[1]:Destroy() -- This means its unsafe to destroy something and then lazyParent
		table.clear(virtualNode)
		return
	end

	if virtualNode.result then
		destroyVirtualNode(virtualNode.result)
		table.clear(virtualNode)
		return
	end
end

type FeatherTreeInUpdate = FeatherTree & {
	__bulkMoveCFrames: {CFrame},
	__bulkMoveParts: {BasePart},
	_lazyPairs: {{Instance}}, -- lazy child-parent pairs
}

local function updateVirtualNode(tree: FeatherTreeInUpdate, virtualNode: FeatherVirtualNode?, element: FeatherElement?, hostParent: Instance, hostKey: string, lazy: boolean): FeatherVirtualNode?

	if not element then
		
		destroyVirtualNode(virtualNode)
		return nil
	end
	
	if typeof(element.component) == "string" then

		--[[
			virutalNode should be a numeric array where
			hostInstance, deltaChildren, children = unpack(virtualNode)

			This uses less memory for trees with many instances.
		--]]

		-- NOTE: VirtualNode[1] is the hostInstance

		-- Destroy the virtual node if it's not a hostNode

		if not virtualNode or not (virtualNode :: any)[1] then

			if virtualNode then
				
				destroyVirtualNode(virtualNode)
			end
			virtualNode = {}
		end

		local hostVirtualNode: FeatherHostVirtualNode = (virtualNode :: any)

		-- For parenting after props are assigned (unless)
		local needToParent = false
		
		-- WARNING: It is assumed that the instance class does not change
		-- for a fixed key. This avoids reading Instance.ClassName, which (I think)
		-- is costly for many instances, and the alternative solution of
		-- storing the class name in memory.
		-- If it seems necessary to change the class of an instance, consider
		-- using a different key, or restructuring your tree so that the
		-- other-class version of some host lives on a different branch.
		
		-- Create the instance if it doesn't exist
		
		if not hostVirtualNode[1] then
			
			local instance = Instance.new(element.component)
			instance.Name = hostKey

			if element.props[Feather.HostInitProps] then
				
				for key, value in element.props[Feather.HostInitProps] do
					
					instance[key] = value
				end
			end

			hostVirtualNode[1] = instance
			-- Assign parenting strategy
			if lazy then
				table.insert(tree._lazyPairs, {instance, hostParent})
			else
				needToParent = true
			end
		end

		local hostInstance: Instance = hostVirtualNode[1] :: any

		-- Update all the props
		for key, value in element.props do
			if typeof(key) == "string" then
				hostInstance[key] = value
			elseif key == Feather.BulkMoveCFrame then
				table.insert(tree.__bulkMoveParts, hostInstance :: Part)
				table.insert(tree.__bulkMoveCFrames, value)
			end
		end

		-- Update delta children that have changed (Up to user to ensure correctness)
		
		if element.props[Feather.DeltaChildren] then
			
			if not hostVirtualNode[2] then
				hostVirtualNode[2] = {}
			end
			local deltaChildren: {[any]: FeatherVirtualNode?} = hostVirtualNode[2] :: any

			for key, childElementOrRemoveChild in element.props[Feather.DeltaChildren] do
				
				if childElementOrRemoveChild == Feather.SubtractChild then
					
					destroyVirtualNode(deltaChildren[key])
					deltaChildren[key] = nil
				else
					
					deltaChildren[key] =
						updateVirtualNode(
							tree,
							deltaChildren[key],
							childElementOrRemoveChild,
							hostInstance,
							key,
							lazy
						)
				end
			end
		end

		-- If there are no children left, delete the table for memory space

		if hostVirtualNode[2] and not next(hostVirtualNode[2] :: any) then
			
			hostVirtualNode[2] = nil
		end
		
		-- NOTE: virtualNode[3] is children (child virtual nodes)

		-- Remove children that no longer exist in the element

		if hostVirtualNode[3] then

			local children: {[any]: FeatherVirtualNode?} = hostVirtualNode[3] :: any
			local removals = {}
			
			for key, childVirtualNode in children do
				if not element.props[Feather.Children] or not element.props[Feather.Children][key] then
					destroyVirtualNode(childVirtualNode)
					table.insert(removals, key)
				end
			end

			for _, key in ipairs(removals) do
				children[key] = nil
			end
		end

		-- Create or Update any new children

		if element.props[Feather.Children] then
			if not hostVirtualNode[3] then
				hostVirtualNode[3] = {}
			end
			local children: {[any]: FeatherVirtualNode?} = hostVirtualNode[3] :: any

			for key, childElement in element.props[Feather.Children] do
				children[key] = updateVirtualNode(tree, children[key], childElement, hostInstance, key, lazy)
			end
		end

		-- If there were no children added, delete the table for memory space
		-- TODO does this break if the table is numeric and the first index is nil?

		if hostVirtualNode[3] and not next(hostVirtualNode[3] :: any) then
			hostVirtualNode[3] = nil
		end
		
		-- Update the parent if necessary (done last for performance)
		-- If lazy = true, then needToParent is false and this will be done later
		if needToParent then 
			hostInstance.Parent = hostParent
		end

		return virtualNode

	elseif typeof(element.component) == "function" then

		--[[
			virtualNode should have the shape
			{
				component: (Props) -> Element
				props: Props
				result: VirtualNode
			}
		--]]

		-- If the existing component is not a function, destroy the virtual node

		if not virtualNode or typeof((virtualNode :: any).component) ~= "function" then
			
			if virtualNode then
				
				destroyVirtualNode(virtualNode)
			end
			virtualNode = {}
		end

		local functionVirtualNode: FeatherFunctionVirtualNode = virtualNode :: any

		-- If the component function changed, replace node data and update with the new result

		if functionVirtualNode.component ~= element.component then
			
			functionVirtualNode.result =
				updateVirtualNode(
					tree,
					functionVirtualNode.result,
					element.component(element.props, functionVirtualNode.props or {}),
					hostParent,
					hostKey,
					lazy)

			functionVirtualNode.component = element.component
			functionVirtualNode.props = element.props
			return virtualNode
		end

		-- If the component and props are unchanged, shortcut the update

		if functionVirtualNode.props == element.props then
			return virtualNode
		end

		-- If any existing props have been changed/removed, replace props and update with the new result

		for key, prop in functionVirtualNode.props do
			
			if element.props[key] ~= prop then
				functionVirtualNode.result =
					updateVirtualNode(
						tree,
						functionVirtualNode.result,
						element.component(element.props, functionVirtualNode.props or {}),
						hostParent,
						hostKey,
						lazy)
				
				functionVirtualNode.props = element.props
				return virtualNode
			end
		end

		-- If any new element props have been changed/added, replace props and update with the new result

		for key, prop in element.props do
			
			if functionVirtualNode.props[key] ~= prop then
				
				functionVirtualNode.result =
					updateVirtualNode(
						tree,
						functionVirtualNode.result,
						element.component(element.props, functionVirtualNode.props or {}),
						hostParent,
						hostKey,
						lazy)
				
				functionVirtualNode.props = element.props
				return virtualNode
			end
		end

		-- Component and props are unchanged, shortcut the update

		return virtualNode
	else

		error("Component not recognised")
	end
end

local function update(tree: FeatherTree, element: FeatherElement, lazy: boolean): FeatherTree
	if Feather.numLazyInstances(tree) > 0 then
		error("[Feather] Cannot update tree while lazy Instances exist")
	end
	
	-- This is just a type coercion. treeInUpdate is the same table as tree
	local treeInUpdate: FeatherTreeInUpdate = tree :: any
	treeInUpdate.__bulkMoveCFrames = {}
	treeInUpdate.__bulkMoveParts = {}
	if lazy then
		treeInUpdate._lazyPairs = {}
		(treeInUpdate :: any)._lazyIndex = nil
		(treeInUpdate :: any)._lazySize = nil
	end

	treeInUpdate.root = updateVirtualNode(treeInUpdate, treeInUpdate.root, element, treeInUpdate.rootParent, treeInUpdate.rootKey, lazy)

	if #treeInUpdate.__bulkMoveCFrames > 0 then
		workspace:BulkMoveTo(treeInUpdate.__bulkMoveParts, treeInUpdate.__bulkMoveCFrames, Enum.BulkMoveMode.FireCFrameChanged)
	end

	treeInUpdate.__bulkMoveCFrames = nil :: any
	treeInUpdate.__bulkMoveParts = nil :: any

	return tree
end

--[=[
	@param tree FeatherTree
	@param element FeatherElement

	@return FeatherTree

	Updates the tree using the new element.
]=]
function Feather.update(tree: FeatherTree, element: FeatherElement): FeatherTree
	update(tree, element, false)
	return tree
end

--[=[
	@param tree FeatherTree
	@param element FeatherElement

	@return FeatherTree

	Lazily updates the tree using the new element. See Feather.lazyParent for
	usage.
]=]
function Feather.lazyUpdate(tree: FeatherTree, element: FeatherElement): FeatherTree
	update(tree, element, true)
	return tree
end

type LazyTree = FeatherTree & {
	_lazyPairs: {{Instance}},
	_lazyIndex: number,
	_lazySize: number,
}

--[=[
	@param tree FeatherTree

	@return number
	Returns the number of lazyInstances that haven't yet been parented to their
	intended parent.
]=]
function Feather.numLazyInstances(tree: FeatherTree): number
	local lazyTree: LazyTree = tree :: any
	if not lazyTree._lazyPairs then
		return 0
	end

	return (lazyTree._lazySize or #lazyTree._lazyPairs) - (lazyTree._lazyIndex or 1) + 1
end


--[=[
	@param tree FeatherTree
	@param maxToParent number

	@return number
	Call this after a lazy mount/update to parent at most `maxToParent` many instances
	to their intended parent. Returns the number parented.

	For example, create a lazy tree with 10,000 instances, then do:
	```lua
	RunService.RenderStepped:Connect(function()
		Feather.lazyParent(tree, 128)
	end)
	```
	to smoothly introduce the tree into the workspace
]=]
function Feather.lazyParent(tree: FeatherTree, maxToParent: number): number
	local lazyTree: LazyTree = tree :: any
	if lazyTree._lazyPairs == nil then
		return 0
	end

	if not lazyTree._lazyIndex then
		lazyTree._lazyIndex = 1
		lazyTree._lazySize = #lazyTree._lazyPairs
	end

	local parented = 0
	while lazyTree._lazyIndex <= lazyTree._lazySize do
		if parented >= maxToParent then
			break
		end
		local instance, parent = table.unpack(lazyTree._lazyPairs[lazyTree._lazyIndex])
		instance.Parent = parent
		parented += 1
		lazyTree._lazyIndex += 1
	end

	if lazyTree._lazyIndex >= lazyTree._lazySize then
		(lazyTree :: any)._lazyPairs = nil
		(lazyTree :: any)._lazySize = nil
		(lazyTree :: any)._lazyIndex = nil
	end

	return parented
end

local function slowDestroy(virtualNode: any, maxToDestroy: number): number
	if virtualNode == nil or maxToDestroy <= 0 then
		return 0
	end

	if virtualNode[1] then
		local destroyed = 0

		-- Destroy children and delta-children first
		for j=2, 3 do
			if virtualNode[j] then
				local key, childNode = next(virtualNode[j])
				while childNode do
					if destroyed >= maxToDestroy then
						return destroyed
					end
					destroyed += slowDestroy(childNode, maxToDestroy-destroyed)
					if not next(childNode) then
						virtualNode[j][key] = nil
					end
					key, childNode = next(virtualNode[j])
				end
				-- Only reach here if all children were destroyed
				virtualNode[j] = nil
			end
		end

		if destroyed < maxToDestroy then
			-- This should only happen if all the children are destroyed and there's
			-- still budget to destroy more
			virtualNode[1]:Destroy()
			destroyed += 1
			table.clear(virtualNode)
		end
		return destroyed
	elseif virtualNode.result then
		local destroyed = slowDestroy(virtualNode.result, maxToDestroy)
		-- Clear this virtualNode iff all of it's descendants are destroyed
		if not next(virtualNode.result) then
			table.clear(virtualNode)
		end
		return destroyed
	end

	return 0
end

--[=[
	@type FeatherTreePartiallyDestroyed {root: FeatherVirtualNode}
	@within Feather
]=]
export type FeatherTreePartiallyDestroyed = {
	root: FeatherVirtualNode,
	rootParent: Instance?
}

--[=[
	@param tree
	@return FeatherTreePartiallyDestroyed

	Returns a version of the tree that can be slow-destroyed, and prevents the
	original tree from being updated further.
]=]
function Feather.surrender(tree: FeatherTree, destroyRootParent: boolean): FeatherTreePartiallyDestroyed
	local root = tree.root
	return {
		root = root,
		rootParent = if destroyRootParent then tree.rootParent else nil
	}
end

--[=[
	@param tree FeatherTreePartiallyDestroyed

	@return boolean
	Returns true if the tree has been fully destroyed.
]=]
function Feather.destructionFinished(tree: FeatherTreePartiallyDestroyed): boolean
	return (tree.root == nil or next(tree.root) == nil) and tree.rootParent == nil
end

--[=[
	@param tree FeatherTreePartiallyDestroyed
	@param maxToDestroy number

	Perform a partial cleanup of the tree by deleting at most maxToDestroy
	instances, starting with the leaf instances

	Returns the number destroyed. Use Feather.isSlowDestroyed to determine
	if cleanup is finished.

	:::warning
	Do not call this on a regular FeatherTree that may be updated somewhere in
	your code. Surrender the tree first with Feather.surrender, and pass the result
	to this function.
	:::
]=]
function Feather.slowDestroy(tree: FeatherTreePartiallyDestroyed, maxToDestroy: number): ()
	local destroyed = slowDestroy(tree.root, maxToDestroy)
	if destroyed < maxToDestroy then
		if tree.rootParent then
			tree.rootParent:Destroy()
			tree.rootParent = nil
		end
	end
	return destroyed
end

--[=[
	@param element FeatherElement
	@param parent Instance
	@param key string

	@return FeatherTree

	Mounts the element to the parent and names it with the key.
	The returned FeatherTree can be passed to [Feather.update] to update the instances.
]=]
function Feather.mount(element: FeatherElement, parent: Instance, key: string): FeatherTree

	local tree = {

		rootParent = parent,
		rootKey = key,
	}

	return Feather.update(tree, element)
end

--[=[
	@param element FeatherElement
	@param parent Instance
	@param key string

	@return FeatherTree

	Lazily Mounts the element to the parent and names it with the key.
	The returned FeatherTree should be called with Feather.lazyParent
	once per frame with a reasonable instance budget until no more
	lazyInstances need to be rendered.
	The returned FeatherTree can be passed to [Feather.update] to update the instances.
]=]
function Feather.lazyMount(element: FeatherElement, parent: Instance, key: string): FeatherTree

	local tree = {

		rootParent = parent,
		rootKey = key,
	}

	return Feather.lazyUpdate(tree, element)
end

--[=[
	@param tree FeatherTree
	Destroys the instances and cleans up the tree
]=]
function Feather.unmount(tree: FeatherTree): ()
	
	destroyVirtualNode(tree.root)
	table.clear(tree)
end

return Feather