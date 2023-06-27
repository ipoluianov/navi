package core

import (
	"io/fs"
	"io/ioutil"
	"os"
	"path/filepath"
	"runtime"
	"strings"
	"unicode/utf8"
)

func IsRoot(p string) bool {
	if runtime.GOOS == "windows" {
		parentDir, _ := SplitPath(p)
		return parentDir == ""
	}
	return p == "" || p == "/"
}

func GetDirectoryContent(path1 string) (items []FileInfo, err error) {
	var entries []fs.FileInfo
	entries, err = ioutil.ReadDir(path1)

	if err != nil {
		return
	}

	for _, entry := range entries {
		var fi FileInfo
		fi.FullName = path1 + pathSep() + entry.Name()
		fi.FullName = removeDuplicates(fi.FullName, "\\")
		fi.FullName = removeDuplicates(fi.FullName, "/")
		st, errStat := os.Stat(fi.FullName)
		if err != nil {
			fi.Error = err.Error()
		}
		lst, errLstat := os.Lstat(fi.FullName)
		if errLstat == nil {
			fi.Path = lst.Name()
			fi.ShortName = lst.Name()

			isDir := lst.IsDir()
			name := lst.Name()
			size := lst.Size()
			dt := lst.ModTime()
			if errStat == nil {
				name = st.Name()
				isDir = st.IsDir()
				dt = st.ModTime()
			}

			fi.CreatedDT = dt
			fi.ModifiedDT = dt

			if lst.Mode()&os.ModeSymlink == os.ModeSymlink {
				fi.IsSymlink = true
			}

			if isDir || (len(name) > 0 && name[0] == '.') {
				// Empty Extension for:
				// - dirs
				// - 'hidden' files (.filename)
				fi.ShortName = name
				fi.Extension = ""
			} else {
				fi.Extension = filepath.Ext(name)
				fi.ShortName = fileNameWithoutExt(name)
				if len(fi.Extension) > 0 && fi.Extension[0] == '.' {
					// Remote first dot
					fi.Extension = fi.Extension[1:]
				}
			}
			fi.IsDir = isDir
			fi.Size = size

			items = append(items, fi)
		}
	}
	return
}

func fileNameWithoutExt(fileName string) string {
	return fileName[:len(fileName)-len(filepath.Ext(fileName))]
}

func removeDuplicates(input string, ch string) string {
	var result strings.Builder

	lastChar := ""

	for i := 0; i < len(input); {
		r, _ := utf8.DecodeRuneInString(input[i:])
		runeString := string(r)
		count := utf8.RuneLen(r)
		if lastChar != runeString || runeString != ch {
			result.WriteString(runeString)
		}
		lastChar = runeString
		i += count
	}

	return result.String()
}

func pathSep() string {
	if runtime.GOOS == "windows" {
		return "\\"
	}
	return "/"
}

func pathSepRune() rune {
	if runtime.GOOS == "windows" {
		return '\\'
	}
	return '/'
}

func SplitPath(p string) (directory string, fileName string) {
	rs := []rune(p)

	// find last slash
	for i := len(rs) - 1; i > 0; i-- {
		if rs[i] == pathSepRune() {
			directory = string(rs[:i])
			fileName = string(rs[i+1:])
			return
		}
	}

	return "", p
}
