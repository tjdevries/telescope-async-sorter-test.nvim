package main

import (
	"strings"

	"github.com/neovim/go-client/nvim"
	"github.com/neovim/go-client/nvim/plugin"
	"github.com/sahilm/fuzzy"
)

func hello(args []string) (string, error) {
	return "Hello " + strings.Join(args, " "), nil
}

func asyncHello(v *nvim.Nvim, args []string) {
	v.SetVar("echoed", true)
}

func luaPrint(v *nvim.Nvim, args ...interface{}) {
	v.ExecLua("print(...)", nil, args...)
}

func handleOneSort(v *nvim.Nvim, id int, prompt, entry string) {
	go func() {
		if prompt == "" {
			v.ExecLua("require('async_sorter_test').resolve(...)", nil, id, 1)
			return
		}

		match := fuzzy.Find(prompt, []string{entry})
		if len(match) == 0 {
			v.ExecLua("require('async_sorter_test').resolve(...)", nil, id, -1)
			return
		}

		score := match[0].Score

		v.ExecLua("require('async_sorter_test').resolve(...)", nil, id, 1.0/float64(score))
	}()
}

func levenshtein(str1, str2 []rune) int {
	s1len := len(str1)
	s2len := len(str2)
	column := make([]int, len(str1)+1)

	for y := 1; y <= s1len; y++ {
		column[y] = y
	}
	for x := 1; x <= s2len; x++ {
		column[0] = x
		lastkey := x - 1
		for y := 1; y <= s1len; y++ {
			oldkey := column[y]
			var incr int
			if str1[y-1] != str2[x-1] {
				incr = 1
			}

			column[y] = minimum(column[y]+1, column[y-1]+1, lastkey+incr)
			lastkey = oldkey
		}
	}
	return column[s1len]
}

func minimum(a, b, c int) int {
	if a < b {
		if a < c {
			return a
		}
	} else {
		if b < c {
			return b
		}
	}
	return c
}

func testThing(v *nvim.Nvim, a, b, c int) {
	luaPrint(v, "stuff:", a, b, c)
}

func main() {
	plugin.Main(func(p *plugin.Plugin) error {
		p.HandleFunction(&plugin.FunctionOptions{Name: "Hello"}, hello)
		p.HandleFunction(&plugin.FunctionOptions{Name: "AsyncHello"}, asyncHello)
		p.HandleFunction(&plugin.FunctionOptions{Name: "AsyncTelescopeSort"}, handleOneSort)
		p.HandleFunction(&plugin.FunctionOptions{Name: "TestThing"}, testThing)
		return nil
	})
}
