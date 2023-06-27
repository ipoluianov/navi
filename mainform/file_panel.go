package mainform

import (
	"fmt"
	"os"
	"runtime"
	"sort"
	"time"

	"github.com/go-gl/glfw/v3.3/glfw"
	"github.com/ipoluianov/goforms/ui"
	"github.com/ipoluianov/goforms/utils/canvas"
	"github.com/ipoluianov/navi/core"
)

type FilePanel struct {
	ui.Panel
	lvItems           *ui.ListView
	currentPath       string
	isActive          bool
	lastSelectedIndex int

	lblCurrentPath    *ui.TextBlock
	currentItemsNames map[string]string

	OnMouseClick func()
}

func NewFilePanel(parent ui.Widget) *FilePanel {
	var c FilePanel
	c.currentItemsNames = make(map[string]string)
	c.InitControl(parent, &c)

	return &c
}

func (c *FilePanel) OnInit() {
	c.SetPanelPadding(0)

	column := c.AddVPanel()
	c.lblCurrentPath = column.AddTextBlock("---")
	c.lvItems = column.AddListView()
	c.lvItems.AllowDeselectItems = false
	c.lvItems.SetOnKeyDown(func(event *ui.KeyDownEvent) bool {
		if event.Key == glfw.KeyEnter {
			c.gotoFolder()
			return true
		}
		if event.Key == glfw.KeyBackspace {
			c.gotoUp()
			return true
		}
		return false
	})
	c.lvItems.OnMouseDown = func() {
		if c.OnMouseClick != nil {
			c.OnMouseClick()
		}
	}
	c.lvItems.AddColumn("Name", 300)
	c.lvItems.AddColumn("Type", 100)
	c.lvItems.AddColumn("Size", 150)
	c.lvItems.AddColumn("Attr", 50)
	c.lvItems.AddColumn("DT", 130)
	c.lvItems.SetColumnTextAlign(2, canvas.HAlignRight)
	c.lvItems.OnSelectionChanged = func() {
		if c.lvItems.SelectedItemIndex() >= 0 {
			c.lastSelectedIndex = c.lvItems.SelectedItemIndex()
		}
	}
	if runtime.GOOS == "windows" {
		c.setCurrentPath("c:")
	} else {
		c.setCurrentPath("/")
	}
}

func (c *FilePanel) Activate() {
	c.isActive = true
	c.lvItems.Focus()
	if c.lastSelectedIndex < 0 {
		c.lastSelectedIndex = 0
	}
	if c.lvItems.ItemsCount() > 0 {
		c.lvItems.SelectItem(c.lastSelectedIndex)
	}
}

func (c *FilePanel) Deactivate() {
	c.isActive = false
	c.lastSelectedIndex = c.lvItems.SelectedItemIndex()
	c.lvItems.ClearSelection()
}

func (c *FilePanel) loadCurrentDirectory() error {
	items, err := core.GetDirectoryContent(c.currentPath)
	if err != nil {
		return err
	}

	dirs := make([]core.FileInfo, 0)
	files := make([]core.FileInfo, 0)

	if !core.IsRoot(c.currentPath) {
		var dt time.Time
		st, err := os.Lstat(c.currentPath)
		if err == nil {
			dt = st.ModTime()
		}
		var fi core.FileInfo
		fi.IsUpDir = true
		fi.CreatedDT = dt
		fi.ModifiedDT = dt
		dirs = append(dirs, fi)
	}

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

	c.lvItems.RemoveItems()

	for _, item := range dirs {
		lvItem := c.lvItems.AddItem(item.DisplayName())
		lvItem.SetValue(1, item.DisplayType())
		lvItem.SetValue(2, item.DisplaySize())
		lvItem.SetValue(3, item.DisplayAttr())
		lvItem.SetValue(4, item.DisplayDateTime())
		lvItem.SetUserData("item", item)
	}

	for _, item := range files {
		lvItem := c.lvItems.AddItem(item.DisplayName())
		lvItem.SetValue(1, item.DisplayType())
		lvItem.SetValue(2, item.DisplaySize())
		lvItem.SetValue(3, item.DisplayAttr())
		lvItem.SetValue(4, item.DisplayDateTime())
		lvItem.SetUserData("item", item)
	}

	if c.lvItems.ItemsCount() > 0 {
		c.lvItems.SetCurrentRow(0, false)
	}
	return nil
}

func (c *FilePanel) setCurrentPath(p string) {
	originalPath := c.currentPath
	c.currentPath = p
	err := c.loadCurrentDirectory()
	if err != nil {
		c.currentPath = originalPath
		return
	}
	c.lblCurrentPath.SetText(p)
}

func (c *FilePanel) gotoFolder() {
	selectedItem := c.lvItems.SelectedItem()
	if selectedItem == nil {
		return
	}
	item := selectedItem.UserData("item").(core.FileInfo)
	c.currentItemsNames[c.currentPath] = item.FullName
	fmt.Println("go to " + item.FullName)
	if item.IsUpDir {
		c.gotoUp()
	} else {
		c.setCurrentPath(item.FullName)
	}
}

func (c *FilePanel) gotoUp() {
	parentDirectory, _ := core.SplitPath(c.currentPath)
	if parentDirectory == "" && runtime.GOOS != "windows" {
		parentDirectory = "/"
	}
	if len(parentDirectory) > 0 {
		lastCurrentItem := c.currentItemsNames[parentDirectory]
		delete(c.currentItemsNames, parentDirectory)
		c.setCurrentPath(parentDirectory)
		c.tryToSetCurrentItem(lastCurrentItem)
	}
}

func (c *FilePanel) tryToSetCurrentItem(fullPath string) {
	for i := 0; i < c.lvItems.ItemsCount(); i++ {
		item := c.lvItems.Item(i).UserData("item").(core.FileInfo)
		if item.FullName == fullPath {
			c.lvItems.SelectItem(i)
			break
		}
	}
}
