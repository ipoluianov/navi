package mainform

import (
	"github.com/go-gl/glfw/v3.3/glfw"
	"github.com/ipoluianov/goforms/ui"
)

func NewMainForm() *ui.Form {
	form := ui.NewForm()
	form.SetTitle("Navi")
	form.Panel().SetPanelPadding(0)
	panel := form.Panel().AddVPanel()
	panel.SetPanelPadding(0)
	panel.AddWidget(NewToolbar(panel))
	filePanels := NewFilePanels(panel)
	panel.AddWidget(filePanels)
	panel.AddWidget(NewCommandLine(panel))
	form.OnKeyDown = func(event *ui.KeyDownEvent) bool {
		if event.Key == glfw.KeyTab {
			filePanels.Tab()
			return true
		}
		return false
	}
	return form
}
