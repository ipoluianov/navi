package mainform

import (
	"os"
	"strconv"
	"strings"

	"github.com/ipoluianov/goforms/ui"
	"golang.org/x/image/colornames"
)

type HexViewer struct {
	ui.Control
	data []byte

	charWidth  int
	charHeight int
	lineWidth  int
	interLine  int
}

func NewHexViewer(parent ui.Widget) *HexViewer {
	var c HexViewer
	c.InitControl(parent, &c)
	c.interLine = 0
	c.readFile()
	return &c
}

func (c *HexViewer) Draw(ctx ui.DrawContext) {
	ctx.SetColor(colornames.White)
	ctx.SetFontFamily("robotomono")
	c.charWidth, c.charHeight = ctx.MeasureText("0")
	c.lineWidth, _ = ctx.MeasureText("00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00")
	c.updateInnerSize()
	vRect := c.VisibleInnerRect()
	line := ""
	for i := 0; i < len(c.data); i++ {
		if (i%16) == 0 && len(line) > 0 {
			lineIndex := i / 16
			y := lineIndex * c.charHeight
			if y >= vRect.Y && y <= vRect.Y+vRect.Height {
				ctx.DrawText(0, y, c.contentWidth(), c.charHeight, line)
			}
			line = ""
		}
		ch := strings.ToUpper(strconv.FormatInt(int64(c.data[i]), 16))
		if len(ch) < 2 {
			ch = "0" + ch
		}
		line += ch
		line += " "
	}

	//ctx.DrawRect(1, 1, c.InnerWidth()-2, c.InnerHeight()-2)
	//ctx.DrawText(5, 0, c.InnerWidth()-1, c.InnerHeight()-1, c.ControlType())
}

func (c *HexViewer) updateInnerSize() {
	if c.charWidth == 0 || c.charHeight == 0 {
		c.InnerWidthOverloaded = 1
		c.InnerHeightOverloaded = 1
		c.InnerSizeOverloaded = true
		return
	}
	c.InnerWidthOverloaded = c.contentWidth()
	c.InnerHeightOverloaded = c.contentHeight()
	c.InnerSizeOverloaded = true
	c.SetHorizontalScrollVisible(true)
}

func (c *HexViewer) XExpandable() bool {
	return true
}

func (c *HexViewer) YExpandable() bool {
	return true
}

func (c *HexViewer) contentWidth() int {
	if c.charWidth == 0 {
		return 1
	}
	return c.lineWidth
}

func (c *HexViewer) contentHeight() int {
	if c.charHeight == 0 {
		return 1
	}
	return (len(c.data) / 16) * (c.charHeight + c.interLine)
}

func (c *HexViewer) readFile() {
	var err error
	c.data, err = os.ReadFile("d:\\data.png")
	if err != nil {
		return
	}
	c.updateInnerSize()
}
