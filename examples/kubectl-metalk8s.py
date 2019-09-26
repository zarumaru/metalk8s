"""Some draft of a kubectl plugin for MetalK8s."""

import argparse


class BaseCmd(object):
    def __init__(self):
        pass

    @classmethod
    def register_parser(cls, subparsers):
        parser = subparsers.add_parser(cls.CMD_NAME)

        for method in cls.SUBCOMMANDS:
            


def main(args):
    """Dispatch commands to different classes."""


def build_parser():
    """Create a command-line parser with argparse."""
    parser = argparse.ArgumentParser(
        prog="kubectl metalk8s",
        version="2.4.0-dev",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )

    subparsers = parser.add_subparsers()
    SolutionsCmd.register_parser(subparsers)

    return parser


if __name__ == '__main__':
    parser = build_parser()
    args = parser.parse_args()
    main(args)
