package mainform

import (
	"os"

	"github.com/ipoluianov/goforms/ui"
)

type FileViewer struct {
	ui.Panel
	txtViewer *ui.TextBox
}

func NewFileViewer(parent ui.Widget) *FileViewer {
	var c FileViewer
	c.InitControl(parent, &c)
	c.txtViewer = c.AddTextBox()
	c.txtViewer.SetMultiline(true)
	c.txtViewer.SetReadOnly(true)
	return &c
}

func (c *FileViewer) SetFile(fileName string) {
	c.txtViewer.SetText("")
	bs, err := os.ReadFile(fileName)
	if err != nil {
		return
	}
	if len(bs) > 100000 {
		bs = bs[:100000]
	}
	c.txtViewer.SetText(string(bs))
}
