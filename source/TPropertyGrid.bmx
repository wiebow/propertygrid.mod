

rem
bbdoc: the propertygrid type is the container type for property groups
endrem
Type TPropertyGrid Extends TPropertyBase

	'LAYOUT CONSTANTS.
	Global GRID_WIDTH:Int = 321
	Global INTERACT_WIDTH:Int = 150
	Global SLIDER_WIDTH:Int = 21

	Global ITEM_INDENT_SIZE:Int = 12
	Global ITEM_SIZE:Int = 24
	Global ITEM_SPACING:Int = 1


	Global instance:TPropertyGrid

	'scrollable panel
	Field scrollPanel:TScrollPanel

	'groups in this container
	Field groupList:TList



	rem
	bbdoc: Default constructor
	endrem
	Method New()
		If instance Throw "Cannot create multiple instances of TPropertyGrid."
		instance = Self
		groupList = New TList
		AddHook(EmitEventHook, EventHandler, Self, -1)
	End Method



	rem
	bbdoc: Creates or returns property grid instance
	endrem
	Function GetInstance:TPropertyGrid()
		If Not instance Then Return New TPropertyGrid
		Return instance
	End Function



	rem
	bbdoc: Sets up the property grid.
	about: location 0 will result in a container on the left of the parent window
	endrem
	Method Initialize(parentwindow:TGadget, location:Int = 1)
		Local xpos:Int = ClientWidth(parentwindow) - TPropertyGrid.GRID_WIDTH
		If location = 0 Then xpos = 0

		scrollPanel = CreateScrollPanel(xpos, 0, TPropertyGrid.GRID_WIDTH, ClientHeight(parentwindow), parentwindow, SCROLLPANEL_HNEVER | SCROLLPANEL_VALWAYS)
		If location = 0 Then SetGadgetLayout(scrollPanel, EDGE_ALIGNED, EDGE_CENTERED, EDGE_ALIGNED, EDGE_ALIGNED)
		If location = 1 Then SetGadgetLayout(scrollPanel, EDGE_CENTERED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED)

		'set grid container panel to the client panel in the scrollpanel
		'so groups can be added there and it can be easily resized
		SetContainerPanel(ScrollPanelClient(scrollPanel))

		SetGadgetColor(ScrollPanelClient(scrollPanel), 255, 255, 255)
	End Method



	rem
	bbdoc: Frees the property grid
	endrem
	Method CleanUp()
		groupList.Clear()
		groupList = Null
		instance = Null
		RemoveHook(EmitEventHook, EventHandler, Self)
	End Method



	rem
	bbdoc: refresh the layout of the container and its groups
	endrem
	Method RefreshLayout()
		Local ypos:Int = 0
		For Local g:TPropertyGroup = EachIn groupList

			'make sure the group is sized properly
			'before getting its height
			g.RefreshLayout()

			'position it on current ypos
			g.SetVerticalPosition(ypos)


			ypos:+g.GetVerticalSize()
		Next

		'set scrolling panel vertical size to total of groups
		FitScrollPanelClient(scrollPanel, SCROLLPANEL_SIZETOKIDS)
	End Method



	Rem
	bbdoc: Returns group list
	endrem
	Method GetGroupList:TList()
		Return groupList
	End Method



	rem
	bbdoc: Adds a new group
	endrem
	Method AddGroup:TPropertyGroup(label:String, groupID:Int)
		Local g:TPropertyGroup = TPropertyGroup.Create(label, groupID, Self)
		groupList.AddLast(g)
		Return g
	End Method



	rem
	bbdoc: Retrieves a group by label
	endrem
	Method GetGroup:TPropertyGroup(label:String)
		For Local g:TPropertyGroup = EachIn groupList
			If g.GetLabel() = label Then Return g
		Next
	End Method



	rem
	bbdoc: Removes a group by label
	returns: the removed group
	endrem
	Method RemoveGroup:TPropertyGroup(label:String)
		For Local g:TPropertyGroup = EachIn groupList
			If g.GetLabel() = label
				groupList.Remove(g)
				Return g
			EndIf
		Next
		Return Null
	End Method



	rem
	bbdoc: Cleans a group by label.
	returns: The cleaned group.
	endrem
	Method CleanGroup:TPropertyGroup(label:String)
		For Local g:TPropertyGroup = EachIn groupList
			If g.GetLabel() = label
				g.GetItemList().Clear()
				Return g
			EndIf
		Next
		Return Null
	End Method



	Function eventHandler:Object(id:Int, data:Object, context:Object)
		Local tmpPropertyGrid:TPropertyGrid = TPropertyGrid(context)
		If tmpPropertyGrid Then data = tmpPropertyGrid.eventHook(id, data, context)
		Return data
	End Function



	'handle events generated by groups
	Method eventHook:Object(id:Int, data:Object, context:Object)
		Local tmpEvent:TEvent = TEvent(data)
		If Not tmpEvent Then Return data

		Select tmpEvent.id
			Case EVENT_PG_GROUPTOGGLED
				RefreshLayout()

			Default
				'no event for this property grid
				Return data
		End Select

		'handled, so get rid of event
		data = Null

		Return data
	End Method

End Type
