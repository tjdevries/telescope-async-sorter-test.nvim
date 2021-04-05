package main

import (
	"github.com/neovim/go-client/nvim/plugin"
	"strings"
)

func hello(args []string) (string, error) {
	return "Hello " + strings.Join(args, " "), nil
}

func asyncHello(args []string) {
}

func main() {
	plugin.Main(func(p *plugin.Plugin) error {
		p.HandleFunction(&plugin.FunctionOptions{Name: "Hello"}, hello)
		p.HandleFunction(&plugin.FunctionOptions{Name: "AsyncHello"}, asyncHello)
		return nil
	})
}
