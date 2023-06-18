package core

import "time"

type FileInfo struct {
	Path       string
	ShortName  string
	Extension  string
	FullName   string
	Owner      string
	IsDir      bool
	CreatedDT  time.Time
	ModifiedDT time.Time
}

func (c *FileInfo) DisplayType() string {
	if c.IsDir {
		return "[DIR]"
	}
	return c.Extension
}
