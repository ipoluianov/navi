package mainform

import (
	"sort"

	"github.com/ipoluianov/goforms/ui"
	"github.com/ipoluianov/navi/core"
)

type FilePanel struct {
	ui.Panel
	currentPath       string
	lvItems           *ui.ListView
	isActive          bool
	lastSelectedIndex int
}

func NewFilePanel(parent ui.Widget) *FilePanel {
	var c FilePanel
	c.InitControl(parent, &c)
	return &c
}

func (c *FilePanel) OnInit() {
	c.Panel.Init()
	c.SetPanelPadding(0)
	c.lvItems = c.AddListView()
	c.lvItems.AddColumn("Name", 300)
	c.lvItems.AddColumn("Type", 100)
	c.lvItems.AddColumn("Size", 50)
	c.lvItems.AddColumn("Attr", 50)
	c.lvItems.AddColumn("DT", 50)
	c.lvItems.OnSelectionChanged = func() {
		if c.lvItems.SelectedItemIndex() >= 0 {
			c.lastSelectedIndex = c.lvItems.SelectedItemIndex()
		}
	}
	c.currentPath = "c:\\"
	c.load()
}

func (c *FilePanel) Activate() {
	c.isActive = true
	c.lvItems.Focus()
	if c.lastSelectedIndex < 0 {
		c.lastSelectedIndex = 0
	}
	c.lvItems.SelectItem(c.lastSelectedIndex)
}

func (c *FilePanel) Deactivate() {
	c.isActive = false
	c.lastSelectedIndex = c.lvItems.SelectedItemIndex()
	c.lvItems.ClearSelection()
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
		lvItem := c.lvItems.AddItem(item.DisplayName())
		lvItem.SetValue(1, item.DisplayType())
		lvItem.SetValue(2, item.DisplaySize())
		lvItem.SetUserData("item", item)
	}

	for _, item := range files {
		lvItem := c.lvItems.AddItem(item.DisplayName())
		lvItem.SetValue(1, item.DisplayType())
		lvItem.SetValue(2, item.DisplaySize())
		lvItem.SetUserData("item", item)
	}
}
