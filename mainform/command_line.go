package mainform

import "github.com/ipoluianov/goforms/ui"

func NewCommandLine(parent ui.Widget) ui.Widget {
	c := ui.NewHPanel(parent)
	c.AddTextBlock("command line:")
	c.AddTextBox()
	return c
}
