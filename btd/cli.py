#!/usr/bin/env python3

from pathlib import Path
from os import listdir

from pyAttributes.ArgParseAttributes import (
    ArgParseMixin,
    ArgumentAttribute,
    Attribute,
    CommandAttribute,
    CommonSwitchArgumentAttribute,
    DefaultAttribute,
    SwitchArgumentAttribute,
)

from __init__ import BTDConfigFile, BTDRun


class Tool:
    HeadLine = "Build The Docs CLI"

    def __init__(self):
        pass

    def PrintHeadline(self):
        print("{line}".format(line="=" * 80))
        print("{headline: ^80s}".format(headline=self.HeadLine))
        print("{line}".format(line="=" * 80))

    @staticmethod
    def run():
        BTDRun()


class WithBuildAttributes(Attribute):
    def __call__(self, func):
        self._AppendAttribute(
            func,
            SwitchArgumentAttribute("--dry-run", dest="dry_run", help="Print build commands but do not execute them."),
        )
        # ... add more if needed
        return func


class CLI(Tool, ArgParseMixin):
    def __init__(self):
        import argparse
        import textwrap

        # Call constructor of the main interitance tree
        super().__init__()
        # Call constructor of the ArgParseMixin
        ArgParseMixin.__init__(
            self,
            description=textwrap.dedent("Helper tool to build and publish Sphinx docs."),
            epilog=textwrap.fill("Happy hacking!"),
            formatter_class=argparse.RawDescriptionHelpFormatter,
            add_help=False,
        )

    @CommonSwitchArgumentAttribute("-q", "--quiet", dest="quiet", help="Reduce messages to a minimum.")
    @CommonSwitchArgumentAttribute("-v", "--verbose", dest="verbose", help="Print out detailed messages.")
    @CommonSwitchArgumentAttribute("-d", "--debug", dest="debug", help="Enable debug mode.")
    def Run(self):
        ArgParseMixin.Run(self)

    @DefaultAttribute()
    def HandleDefault(self, args):
        self.PrintHeadline()
        self.MainParser.print_help()

    @CommandAttribute("help", help="Display help page(s) for the given command name.")
    @ArgumentAttribute(
        metavar="<Command>", dest="Command", type=str, nargs="?", help="Print help page(s) for a command."
    )
    def HandleHelp(self, args):
        if args.Command == "help":
            print("This is a recursion ...")
            return
        if args.Command is None:
            self.PrintHeadline()
            self.MainParser.print_help()
        else:
            try:
                self.PrintHeadline()
                self.SubParsers[args.Command].print_help()
            except KeyError:
                print("Command {0} is unknown.".format(args.Command))

    @CommandAttribute("run", help="Run.")
    def HandleRun(self, _):
        self.run()


if __name__ == "__main__":
    CLI().Run()
