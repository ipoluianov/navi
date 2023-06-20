package mainform

import (
	"github.com/ipoluianov/goforms/ui"
	"github.com/ipoluianov/goforms/utils/canvas"
)

func NewCommandLine(parent ui.Widget) ui.Widget {
	c := ui.NewHPanel(parent)
	currentPathText := ui.NewTextBlock(c, "C:\\>")
	currentPathText.SetMinWidth(300)
	currentPathText.SetMaxWidth(300)
	currentPathText.TextHAlign = canvas.HAlignRight
	c.AddWidget(currentPathText)
	c.AddTextBox()
	return c
}
