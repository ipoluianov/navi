package mainform

import (
	"github.com/ipoluianov/goforms/ui"
	"golang.org/x/image/colornames"
)

type PlainViewer struct {
	ui.Control
}

func NewPlainViewer(parent ui.Widget) *PlainViewer {
	var c PlainViewer
	c.InitControl(parent, &c)
	return &c
}

func (c *PlainViewer) Draw(ctx ui.DrawContext) {
	ctx.SetColor(colornames.White)
	ctx.DrawRect(1, 1, c.Width()-2, c.Height()-2)
	ctx.DrawText(5, 0, c.Width()-1, c.Height()-1, c.ControlType())
}

func (c *PlainViewer) XExpandable() bool {
	return true
}

func (c *PlainViewer) YExpandable() bool {
	return true
}
