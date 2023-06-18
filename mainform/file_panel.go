package mainform

import "github.com/ipoluianov/goforms/ui"

func NewFilePanel(parent ui.Widget) ui.Widget {
	c := ui.NewPanel(parent)
	c.SetPanelPadding(0)
	lv := c.AddListView()
	lv.AddColumn("Name", 300)
	lv.AddColumn("Type", 100)
	lv.AddColumn("Attr", 50)
	lv.AddColumn("DT", 50)
	return c
}
