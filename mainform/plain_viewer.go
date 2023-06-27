package mainform

import (
	"os"

	"github.com/ipoluianov/goforms/ui"
	"golang.org/x/image/colornames"
)

type HexViewer struct {
	ui.Control
	data []byte
}

func NewHexViewer(parent ui.Widget) *HexViewer {
	var c HexViewer
	c.InitControl(parent, &c)
	c.readFile()
	return &c
}

func (c *HexViewer) Draw(ctx ui.DrawContext) {
	ctx.SetColor(colornames.White)
	ctx.DrawRect(1, 1, c.Width()-2, c.Height()-2)
	ctx.DrawText(5, 0, c.Width()-1, c.Height()-1, c.ControlType())
}

func (c *HexViewer) updateInnerSize() {
	c.InnerHeightOverloaded = 2000
	c.InnerWidthOverloaded = 2000
	c.InnerSizeOverloaded = true
}

func (c *HexViewer) XExpandable() bool {
	return true
}

func (c *HexViewer) YExpandable() bool {
	return true
}

func (c *HexViewer) readFile() {
	var err error
	c.data, err = os.ReadFile("d:\\data.png")
	if err != nil {
		return
	}
	c.updateInnerSize()
}
