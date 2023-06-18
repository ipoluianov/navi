package mainform

import "github.com/ipoluianov/goforms/ui"

func NewToolbar(parent ui.Widget) ui.Widget {
	c := ui.NewPanel(parent)
	c.AddTextBlock("TOOLBAR")
	return c
}
