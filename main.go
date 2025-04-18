package main

import (
	"github.com/ipoluianov/goforms/ui"
	"github.com/ipoluianov/navi/mainform"
)

func main() {
	mainForm := mainform.NewMainForm()
	ui.StartMainForm(mainForm)
}
