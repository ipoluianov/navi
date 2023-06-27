package mainform

import (
	"github.com/ipoluianov/goforms/ui"
)

type Viewer struct {
	ui.Panel
	txtViewer *PlainViewer
}

func NewFileViewer(parent ui.Widget) *Viewer {
	var c Viewer
	c.InitControl(parent, &c)
	c.txtViewer = NewPlainViewer(&c)
	c.AddWidget(c.txtViewer)
	return &c
}

func (c *Viewer) SetFile(fileName string) {
}
