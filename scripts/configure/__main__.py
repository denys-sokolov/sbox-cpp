import pathlib
import sys

if not __package__:
  # Adjust sys.path to allow relative imports when executed as a script
  sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1]))

if __name__ == "__main__":
  import configure.cli as cli
  sys.exit(cli.main(sys.argv[1:]))
