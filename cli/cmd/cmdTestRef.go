package cmd

import (
	"fmt"
	"log"

	"github.com/spf13/cobra"
)

// testRefCmd represents the test command
var testRefCmd = &cobra.Command{
	Use:     "ref",
	Version: rootCmd.Version,
	Short:   "",
	Long:    ``,
	Args:    cobra.MinimumNArgs(1),
	Run: func(cmd *cobra.Command, args []string) {
		for _, v := range args {
			fmt.Println("")
			r, err := parseRef(v)
			if err != nil {
				log.Fatal(err)
			}
			r.Print()
		}
	},
}

func init() {
	testCmd.AddCommand(testRefCmd)
}
