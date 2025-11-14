import jinja2
import jinja2.sandbox
import pathlib
import typing as tp

_TEMPLATES_SEARCH_PATH = pathlib.Path(__file__).resolve().parent / "templates"


class CMakeCacheEntry(tp.NamedTuple):
  """Represents a CMake cache entry."""
  name: str
  type: str
  value: str


def configure_user_cache(
    output: pathlib.Path,
    cache_entries: tp.Sequence[CMakeCacheEntry]
) -> None:
  """Configure user CMake cache entries."""
  if not output.is_dir():
    output.mkdir(parents=True, exist_ok=True)

  generate_from_template_file(
      output / "CMakeUserConfig.cmake",
      "CMakeUserConfig.cmake.jinja",
      cache_entries=cache_entries
  )


def configure_user_presets(
    output: pathlib.Path,
    presets: tp.Sequence[pathlib.Path]
) -> None:
  """Configure user CMake presets."""
  if not output.is_dir():
    output.mkdir(parents=True, exist_ok=True)

  generate_from_template_file(
      output / "CMakeUserPresets.json",
      "CMakeUserPresets.json.jinja",
      includes=[x.resolve().as_posix() for x in presets]
  )


def generate_from_template_file(
    output_file: pathlib.Path,
    template: str,
    **kwargs: tp.Any
) -> None:
  """Generate a file from a Jinja2 template file."""
  name = template.replace("\\", "/")
  loader = jinja2.FileSystemLoader(_TEMPLATES_SEARCH_PATH)
  env = jinja2.sandbox.SandboxedEnvironment(loader=loader)
  env.get_template(name).stream(**kwargs).dump(str(output_file))


def get_build_specs_path() -> pathlib.Path:
  """Get the path to the build specs directory."""
  return pathlib.Path.cwd() / "config" / "build_specs"
