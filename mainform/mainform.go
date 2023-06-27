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
	//panel.AddWidget(NewToolbar(panel))
	tabs := panel.AddTabControl()

	tabPage0 := tabs.AddPage()
	tabPage0.SetText("File System")
	filePanels := NewFilePanels(panel)
	tabPage0.AddWidget(filePanels)

	tabPage1 := tabs.AddPage()
	tabPage1.SetText("File Viewer")
	fileViewer := NewFileViewer(panel)
	tabPage1.AddWidget(fileViewer)

	tabs.SetCurrentPage(1)

	panel.AddWidget(NewCommandLine(panel))
	form.OnKeyDown = func(event *ui.KeyDownEvent) bool {
		if event.Key == glfw.KeyTab {
			filePanels.Tab()
			return true
		}
		if event.Key == glfw.KeyF3 {
			file := filePanels.SelectedFile()
			fileViewer.SetFile(file)
			tabs.SetCurrentPage(1)
			return true
		}
		if event.Key == glfw.KeyEscape {
			tabs.SetCurrentPage(0)
			return true
		}
		return false
	}
	return form
}
