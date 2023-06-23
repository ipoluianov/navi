package mainform

import (
	"sort"

	"github.com/ipoluianov/goforms/ui"
	"github.com/ipoluianov/navi/core"
)

type FilePanel struct {
	ui.ListView
	currentPath       string
	isActive          bool
	lastSelectedIndex int
}

func NewFilePanel(parent ui.Widget) *FilePanel {
	var c FilePanel
	c.InitControl(parent, &c)
	return &c
}

func (c *FilePanel) OnInit() {
	c.Construct()
	c.SetPanelPadding(0)
	c.AddColumn("Name", 300)
	c.AddColumn("Type", 100)
	c.AddColumn("Size", 50)
	c.AddColumn("Attr", 50)
	c.AddColumn("DT", 50)
	c.OnSelectionChanged = func() {
		if c.SelectedItemIndex() >= 0 {
			c.lastSelectedIndex = c.SelectedItemIndex()
		}
	}
	c.currentPath = "c:\\"
	c.load()
}

func (c *FilePanel) Activate() {
	c.isActive = true
	c.Focus()
	if c.lastSelectedIndex < 0 {
		c.lastSelectedIndex = 0
	}
	c.SelectItem(c.lastSelectedIndex)
}

func (c *FilePanel) Deactivate() {
	c.isActive = false
	c.lastSelectedIndex = c.SelectedItemIndex()
	c.ClearSelection()
}

func (c *FilePanel) load() {

	items, err := core.GetDirectoryContent(c.currentPath)
	if err != nil {
		return
	}

	dirs := make([]core.FileInfo, 0)
	files := make([]core.FileInfo, 0)
	for _, item := range items {
		if item.IsDir {
			dirs = append(dirs, item)
		} else {
			files = append(files, item)
		}
	}

	sort.Slice(dirs, func(i, j int) bool {
		return dirs[i].ShortName < dirs[j].ShortName
	})

	sort.Slice(files, func(i, j int) bool {
		return files[i].ShortName < files[j].ShortName
	})

	for _, item := range dirs {
		lvItem := c.AddItem(item.DisplayName())
		lvItem.SetValue(1, item.DisplayType())
		lvItem.SetValue(2, item.DisplaySize())
		lvItem.SetUserData("item", item)
	}

	for _, item := range files {
		lvItem := c.AddItem(item.DisplayName())
		lvItem.SetValue(1, item.DisplayType())
		lvItem.SetValue(2, item.DisplaySize())
		lvItem.SetUserData("item", item)
	}
}
