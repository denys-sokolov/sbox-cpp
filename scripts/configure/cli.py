import argparse
import pathlib
import questionary
import sys
import os
import typing as tp

from .configure import (
    CMakeCacheEntry,
    configure_user_cache,
    configure_user_presets,
    get_build_specs_path
)


def parse_cache_entry(value: str) -> CMakeCacheEntry:
  """Parse a CMake cache entry from a string."""
  entry_name, entry_type, entry_value = value, "INTERNAL", "TRUE"
  if "=" in value:
    entry_name, entry_value = value.split("=", 1)
  if ":" in entry_name:
    entry_name, entry_type = entry_name.split(":", 1)
  return CMakeCacheEntry(
      name=entry_name,
      type=entry_type,
      value=entry_value
  )


def parse_cwd_path(value: str) -> pathlib.Path:
  """Convert a path string to a Path object relative to the current working directory."""
  rv = pathlib.Path(value)
  if not rv.is_absolute():
    rv = (pathlib.Path.cwd() / rv).resolve()
  if not rv.is_dir():
    raise argparse.ArgumentTypeError(
        f"Path '{value}' is not a valid directory.")
  return rv


def parse_presets_file_path(value: str) -> pathlib.Path:
  """Convert a preset file path string to a Path object."""
  rv = pathlib.Path(value)
  if not rv.is_absolute():
    rv = (get_build_specs_path() / rv).resolve()
  if not rv.is_file():
    raise argparse.ArgumentTypeError(
        f"Presets file '{value}' does not exist."
    )
  return rv


def get_cache_entries() -> list[CMakeCacheEntry]:
  """Prompt the user to input CMake cache entries."""
  if not questionary.confirm(
      "Would you like to define CMake cache entries now?"
  ).ask():
    return []

  questionary.print(
      "Enter cache entries as NAME[:TYPE][=VALUE] or leave blank to finish."
  )

  rv: list[CMakeCacheEntry] = []
  while True:
    try:
      entry = questionary.text("Cache entry:").ask()
      if not entry:
        break
      rv.append(parse_cache_entry(entry))
    except Exception as e:
      print(f"Error parsing entry: {e}")
  return rv


def get_presets() -> list[pathlib.Path]:
  """Prompt the user to select preset files from available build specs."""
  choices = [
      questionary.Choice(f"{entry.parent.name}/CMakePresets.json", value=entry)
      for entry in get_build_specs_path().glob("*/CMakePresets.json")
      if entry.is_file()
  ]

  if not choices:
    return []

  return questionary.checkbox(
      "Select one or more presets files",
      choices=choices
  ).ask()


def main(argv: tp.Sequence[str] | None = None) -> int:
  parser = argparse.ArgumentParser(
      "configure",
      usage="%(prog)s [options] [PATH]",
      description="Configure CMake presets and cache entries for the project."
  )
  parser.add_argument(
      "path",
      default=pathlib.Path.cwd(),
      help="path to the project root (default: current working directory)",
      metavar="PATH",
      nargs="?",
      type=parse_cwd_path
  )
  parser.add_argument(
      "-D",
      action="append",
      default=[],
      dest="cache_entries",
      help="define CMake cache entry (e.g., -D BUILD_TESTING=OFF)",
      metavar="NAME[:TYPE][=VALUE]",
      type=parse_cache_entry,
  )
  parser.add_argument(
      "-p", "--presets",
      action="append",
      default=[],
      help=(
          "path to a JSON preset file to include (relative paths are resolved "
          "from config/build_specs/)"
      ),
      metavar="FILE",
      type=parse_presets_file_path,
  )

  args = parser.parse_args(argv)

  # Change to the specified project root directory
  os.chdir(args.path)

  if not args.presets and is_interactive():
    args.presets = get_presets()

  if not args.cache_entries and is_interactive():
    args.cache_entries = get_cache_entries()

  if args.presets:
    configure_user_presets(
        output=pathlib.Path.cwd(),
        presets=args.presets
    )
    print(f"Configured {len(args.presets)} CMake user presets.")

  if args.cache_entries:
    configure_user_cache(
        output=pathlib.Path.cwd(),
        cache_entries=args.cache_entries
    )
    print(f"Configured {len(args.cache_entries)} CMake cache entries.")

  return 0


def is_interactive() -> bool:
  """Check if the current environment is interactive."""
  return hasattr(sys.stdin, "isatty") and sys.stdin.isatty()
