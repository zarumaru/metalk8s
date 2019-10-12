"""Base class for generating a CLI with git-style commands."""

import abc
import sys

import six


class Command(six.with_metaclass(abc.ABCMeta, object)):
    """A CLI command (or subcommand).

    Such an object has two major methods:
      - the `prepare_parser` class method, to recurse through `SUBCOMMANDS` and
        register all needed arguments and subparsers
      - the `run` instance method, which actually executes the selected command

    Instantiating a `Command` is done from a `Namespace` (the `args` argument
    to `__init__`) generated by `ArgumentParser.parse_args()`, given this
    parser was prepared properly.
    """

    # Name of this subcommand as a string (None if not a subcommand)
    NAME = None

    # List of `Command` subclasses (may stay empty)
    SUBCOMMANDS = []

    # Dictionary of command arguments, using tuples of argument names as keys
    ARGUMENTS = {}

    # List of factory functions to create additional parent parsers for this
    # command and optional subcommands
    EXTRA_PARENTS = []

    def __init__(self, args):
        """Extract necessary arguments for execution in `run`."""
        self.command_name = args.cmd_name

    @classmethod
    def prepare_parser(cls, parser, parents, prog):
        if cls.SUBCOMMANDS:
            subparsers = parser.add_subparsers(
                title='subcommands',
                description='Allowed subcommands for "{}"'.format(prog),
                dest='subcommand',  # Need to use a `dest` to make it required
            )
            subparsers.required = True

            for subcommand in cls.SUBCOMMANDS:
                subcmd_doc = subcommand.__doc__
                subcmd_help = ''
                if subcmd_doc:
                    subcmd_help = subcmd_doc.splitlines()[0]

                new_parents = parents + [
                    build_parser()
                    for build_parser in subcommand.PARENT_PARSERS
                ]
                subparser = subparsers.add_parser(
                    subcommand.NAME,
                    parents=new_parents,
                    help=subcmd_help,
                    description=subcmd_doc,
                )

                new_prog = '{} {}'.format(prog, subcommand.NAME)
                subcommand.prepare_parser(
                    subparser, parents=new_parents, prog=new_prog
                )

        for arg_names, kwargs in cls.ARGUMENTS.items():
            parser.add_argument(*arg_names, **kwargs)

        parser.set_defaults(cmd_name=prog)
        parser.set_defaults(cmd=cls)

    @abc.abstractmethod
    def run(self):
        """Execute an instance of this Command."""
        raise NotImplementedError(
            "Each `Command` subclass must implement a `run` classmethod."
        )

    @property
    def command_invocation(self):
        """The command line invocation of this command instance.

        Used for display in logfile(s).
        """
        # NOTE: ugly clean-up of command-line args to remove subcommands
        args = sys.argv[1:]
        for part in self.command_name.split():
            if args and args[0] == part:
                args = args[1:]
        return '{} {}'.format(self.command_name, ' '.join(args))