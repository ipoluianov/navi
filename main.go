package main

import (
	"github.com/ipoluianov/goforms/ui"
	"github.com/ipoluianov/navi/mainform"
)

func main() {
	ui.InitUI()
	mainForm := mainform.NewMainForm()
	ui.StartMainForm(mainForm)
}
