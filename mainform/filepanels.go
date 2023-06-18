package mainform

import "github.com/ipoluianov/goforms/ui"

func NewFilePanels(parent ui.Widget) ui.Widget {
	c := ui.NewPanel(parent)
	c.SetPanelPadding(0)
	panel := c.AddHPanel()
	panel.SetPanelPadding(0)
	panel.AddWidget(NewFilePanel(panel))
	panel.AddWidget(NewFilePanel(panel))
	return c
}
