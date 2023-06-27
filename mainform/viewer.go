package mainform

import (
	"github.com/ipoluianov/goforms/ui"
)

type Viewer struct {
	ui.Panel
	txtViewer *HexViewer
}

func NewFileViewer(parent ui.Widget) *Viewer {
	var c Viewer
	c.InitControl(parent, &c)
	c.SetPanelPadding(0)
	c.txtViewer = NewHexViewer(&c)
	c.AddWidget(c.txtViewer)
	return &c
}

func (c *Viewer) SetFile(fileName string) {
}
