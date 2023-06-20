package mainform

import (
	"github.com/ipoluianov/goforms/ui"
)

type FilePanels struct {
	ui.Panel
	filePanels        []*FilePanel
	currentPanelIndex int
}

func NewFilePanels(parent ui.Widget) *FilePanels {
	var c FilePanels
	c.InitControl(parent, &c)
	c.SetPanelPadding(0)
	return &c
}

func (c *FilePanels) OnInit() {
	c.Panel.OnInit()
	panel := c.AddHPanel()
	panel.SetPanelPadding(0)
	c.filePanels = append(c.filePanels, NewFilePanel(panel))
	c.filePanels = append(c.filePanels, NewFilePanel(panel))
	NewFilePanel(panel)
	panel.AddWidget(c.filePanels[0])
	panel.AddWidget(c.filePanels[1])
}

func (c *FilePanels) Tab() {
	index := c.currentPanelIndex
	if index == 0 {
		index = 1
	} else {
		index = 0
	}
	c.SetCurrentPanel(index)
}

func (c *FilePanels) SetCurrentPanel(index int) {
	if index != 0 && index != 1 {
		return
	}
	c.filePanels[c.currentPanelIndex].Deactivate()
	c.currentPanelIndex = index
	c.filePanels[c.currentPanelIndex].Activate()
}
