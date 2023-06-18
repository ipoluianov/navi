package mainform

import "github.com/ipoluianov/goforms/ui"

func NewMainForm() *ui.Form {
	form := ui.NewForm()
	form.SetTitle("Navi")
	form.Panel().SetPanelPadding(0)
	panel := form.Panel().AddVPanel()
	panel.SetPanelPadding(0)
	panel.AddWidget(NewToolbar(panel))
	panel.AddWidget(NewFilePanels(panel))
	panel.AddWidget(NewCommandLine(panel))
	return form
}
