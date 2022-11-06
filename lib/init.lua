local Symbol = require(script.Symbol)

--- @class Feather

local Feather = {
	
	Children = Symbol.named("Children"),
	DeltaChildren = Symbol.named("DeltaChildren"),
	SubtractChild = Symbol.named("SubtractChild"),
	HostInitProps = Symbol.named("InitProps"),
	BulkMoveCFrame = Symbol.named("BulkMoveCFrame")
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
export type FeatherComponent = string | (props: table, oldProps: table) -> FeatherElement


-- --[=[
-- 	@ignore
-- 	@type FeatherElement { component: FeatherComponent, props: table, }
-- 	@within Feather
-- ]=]
export type FeatherElement = {
	component: FeatherComponent,
	props: table,
}

-- This is intended to mean
--   [1]: Instance -- hostInstance
--   [2]: table? -- deltaChildren
--   [3]: table? -- children
export type FeatherHostVirtualNode = {Instance | table? | table?}

export type FeatherFunctionVirtualNode = {
	result: FeatherVirtualNode,
	component: (props: table, oldProps: table) -> FeatherElement,
	props: table,
}

export type FeatherVirtualNode = FeatherHostVirtualNode | FeatherFunctionVirtualNode

-- --[=[
-- 	@ignore
-- 	@type FeatherTree {root: FeatherVirtualNode, rootParent: Instance, rootKey: string}
-- 	@within Feather
-- ]=]
export type FeatherTree = {

	root: FeatherVirtualNode,
	rootParent: Instance,
	rootKey: string,
}

--[=[
	@param component FeatherComponent
	@param props table
	@return FeatherElement
]=]

function Feather.createElement(component: FeatherComponent, props: table): FeatherElement

	return {

		component = component,
		props = props,
	}
end

function Feather.updateVirtualNode(tree: FeatherTree, virtualNode: FeatherVirtualNode?, element: FeatherElement?, hostParent: Instance, hostKey: string): FeatherVirtualNode?

	if not element then
		
		Feather.destroyVirtualNode(virtualNode)
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

		if not virtualNode or not virtualNode[1] then

			if virtualNode then
				
				Feather.destroyVirtualNode(virtualNode)
			end
			virtualNode = {}
		end

		-- For delayed parent-ing
		local needToParent = false
		
		-- WARNING: It is assumed that the instance class does not change
		-- for a fixed key. This avoids reading Instance.ClassName, which (I think)
		-- is costly for many instances, and the alternative solution of
		-- storing the class name in memory.
		-- If it seems necessary to change the class of an instance, consider
		-- using a different key, or restructuring your tree so that the
		-- other-class version of some host lives on a different branch.
		
		-- Create the instance if it doesn't exist
		
		if not virtualNode[1] then
			
			local instance = Instance.new(element.component)
			instance.Name = hostKey

			if element.props[Feather.HostInitProps] then
				
				for key, value in element.props[Feather.HostInitProps] do
					
					instance[key] = value
				end
			end

			virtualNode[1] = instance
			needToParent = true
		end

		-- Update all the props

		for key, value in element.props do

			if typeof(key) == "string" then
				
				-- print("Updating:", virtualNode[1]:GetFullName(), key)
				virtualNode[1][key] = value
				
			elseif key == Feather.BulkMoveCFrame then
				
				table.insert(tree.__bulkMoveParts, virtualNode[1])
				table.insert(tree.__bulkMoveCFrames, value)
			end
		end

		-- NOTE: virtualNode[2] is deltaChildren
		
		-- Update delta children that have changed (Up to user to ensure correctness)
		
		if element.props[Feather.DeltaChildren] then
			
			if not virtualNode[2] then
				
				virtualNode[2] = {}
			end
			
			for key, childElementOrRemoveChild in element.props[Feather.DeltaChildren] do
				
				if childElementOrRemoveChild == Feather.SubtractChild then
					
					Feather.destroyVirtualNode(virtualNode[2][key])
					virtualNode[2][key] = nil
				else
					
					virtualNode[2][key] =
						Feather.updateVirtualNode(
							tree,
							virtualNode[2][key],
							childElementOrRemoveChild,
							virtualNode[1],
							key
						)
				end
			end
		end

		-- If there are no children left, delete the table for memory space

		if virtualNode[2] and not next(virtualNode[2]) then
			
			virtualNode[2] = nil
		end
		
		-- NOTE: virtualNode[3] is children (child virtual nodes)

		-- Remove children that no longer exist in the element

		if virtualNode[3] then

			local removals = {}
			
			for key, childVirtualNode in virtualNode[3] do
				
				if not element.props[Feather.Children] or not element.props[Feather.Children][key] then
					
					Feather.destroyVirtualNode(childVirtualNode)
					table.insert(removals, key)
				end
			end

			for _, key in ipairs(removals) do
				
				virtualNode[3][key] = nil
			end
		end

		-- Create or Update any new children

		if element.props[Feather.Children] then
	
			if not virtualNode[3] then
				
				virtualNode[3] = {}
			end

			for key, childElement in element.props[Feather.Children] do

				virtualNode[3][key] = Feather.updateVirtualNode(tree, virtualNode[3][key], childElement, virtualNode[1], key)
			end
		end

		-- If there were no children added, delete the table for memory space
		-- TODO does this break if the table is numeric and the first index is nil?

		if virtualNode[3] and not next(virtualNode[3]) then
			
			virtualNode[3] = nil
		end
		
		-- Update the parent if necessary (done last for performance)
		
		if needToParent then
			
			virtualNode[1].Parent = hostParent
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

		if not virtualNode or typeof(virtualNode.component) ~= "function" then
			
			if virtualNode then
				
				Feather.destroyVirtualNode(virtualNode)
			end
			virtualNode = {}
		end

		-- If the component function changed, replace node data and update with the new result

		if virtualNode.component ~= element.component then
			
			virtualNode.result =
				Feather.updateVirtualNode(
					tree,
					virtualNode.result,
					element.component(element.props, virtualNode.props or {}),
					hostParent,
					hostKey)

			virtualNode.component = element.component
			virtualNode.props = element.props
			return virtualNode
		end

		-- If the component and props are unchanged, shortcut the update

		if virtualNode.props == element.props then
			
			return virtualNode
		end

		-- If any existing props have been changed/removed, replace props and update with the new result

		for key, prop in virtualNode.props do
			
			if element.props[key] ~= prop then
				
				virtualNode.result =
					Feather.updateVirtualNode(
						tree,
						virtualNode.result,
						element.component(element.props, virtualNode.props or {}),
						hostParent,
						hostKey)
				
				virtualNode.props = element.props
				return virtualNode
			end
		end

		-- If any new element props have been changed/added, replace props and update with the new result

		for key, prop in element.props do
			
			if virtualNode.props[key] ~= prop then
				
				virtualNode.result =
					Feather.updateVirtualNode(
						tree,
						virtualNode.result,
						element.component(element.props, virtualNode.props or {}),
						hostParent,
						hostKey)
				
				virtualNode.props = element.props
				return virtualNode
			end
		end

		-- Component and props are unchanged, shortcut the update

		return virtualNode
	else

		error("Component not recognised")
	end
end

function Feather.destroyVirtualNode(virtualNode: FeatherVirtualNode): ()

	if virtualNode[1] then
		
		virtualNode[1]:Destroy()
		virtualNode[1] = nil
		return
	end

	if virtualNode.result then
		
		Feather.destroyVirtualNode(virtualNode.result)
	end
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
	@param tree FeatherTree
	@param element FeatherElement

	@return FeatherTree

	Updates the tree using the new element.
]=]
function Feather.update(tree: FeatherTree, element: FeatherElement): FeatherTree

	tree.__bulkMoveCFrames = {}
	tree.__bulkMoveParts = {}
	
	tree.root = Feather.updateVirtualNode(tree, tree.root, element, tree.rootParent, tree.rootKey)

	if #tree.__bulkMoveCFrames > 0 then
		
		workspace:BulkMoveTo(tree.__bulkMoveParts, tree.__bulkMoveCFrames, Enum.BulkMoveMode.FireCFrameChanged)
	end

	tree.__bulkMoveCFrames = nil
	tree.__bulkMoveParts = nil

	return tree
end

--[=[
	@param tree FeatherTree

]=]
function Feather.unmount(tree: FeatherTree): ()
	
	Feather.destroyVirtualNode(tree.root)
	table.clear(tree)
end

return Feather