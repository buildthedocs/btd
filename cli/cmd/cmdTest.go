package cmd

import (
	"log"
	//	"strings"

	"github.com/spf13/cobra"
	//	v "github.com/spf13/viper"
)

// testCmd represents the test command
var testCmd = &cobra.Command{
	Use:     "test",
	Version: rootCmd.Version,
	Short:   "",
	Long:    ``,
	Run: func(cmd *cobra.Command, args []string) {
		log.Println("testCmd")
	},
}

func init() {
	rootCmd.AddCommand(testCmd)
}

/*
btd_test() {
  printf "$ANSI_DARKCYAN[BTD] Test $ANSI_NOCOLOR\n"

  VERSIONS_btd="master,featured"
  VERSIONS_ghdl="master,v0.35,v0.34"
  VERSIONS_PoC="master,relese"

  for prj in "buildthedocs/btd" "ghdl/ghdl" "1138-4EB/PoC"; do
    p="`echo $prj | cut -d'/' -f2`"

    git clone "https://github.com/$prj" "${p}-test"
    cd "${p}-test"

    VERSIONS="VERSIONS_${p}"
    if [ "$p" = "PoC" ]; then INPUT="-i docs"; fi
    "$BTD_SH" build -o "../${p}_test_builds" -v "${!VERSIONS}" $INPUT

    cd ..
    rm -rf "$p"
    rm -rf "${p}_test_builds"
  done

  exit 0

  #git clone https://github.com/buildthedocs/btd btd-full
  #cd btd-full

  #BTD_DEPLOY_KEY="travis/deploy_key.enc" "$BTD_SH" build -o '../btd_full_builds' -v "master,featured"

  #cd ..
  #rm -rf btd-full
  #rm -rf btd_full_builds

  #git clone https://github.com/VLSI-EDA/PoC
  #cd PoC
  #curl -L https://raw.githubusercontent.com/buildthedocs/btd/master/btd.sh | sh -s build -v "release,stable" -i docs
}
*/
