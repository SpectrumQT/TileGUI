# Assembles source files into release build, just run it and grab freshly built .zip from \!RELEASE\X.X.X

import shutil
import re
import time

from pathlib import Path
from dataclasses import dataclass, field
from datetime import datetime


class Version:
    def __init__(self, ini_path):
        self.ini_path = ini_path
        self.version = None
        self.parse_version()

    def parse_version(self):
        with open(self.ini_path, 'r', encoding='utf-8') as f:

            version_pattern = re.compile(r'^\$return_version = (\d+)\.*(\d)(\d*)')

            for line in f.readlines():

                result = version_pattern.findall(line)

                if len(result) != 1:
                    continue

                result = list(result[0])

                if len(result) == 2:
                    result.append(0)

                if len(result) != 3:
                    raise ValueError(f'Malformed WWMI version!')

                self.version = result

                return

        raise ValueError(f'Failed to locate WWMI version!')

    def __str__(self) -> str:
        return f'{self.version[0]}.{self.version[1]}.{self.version[2]}'

    def as_float(self):
        return float(f'{self.version[0]}.{self.version[1]}{self.version[2]}')

    def as_ints(self):
        return [map(int, self.version)]
    

class Project:
    def __init__(self):
        self.release_name = 'TileGUI'
        self.root_dir = Path(__file__).resolve().parent
        self.trash_path = self.root_dir / '!TRASH'
        self.source_dir = self.root_dir / 'TileGUI'
        self.release_dir = self.root_dir / '!RELEASES'
        self.version = Version(self.source_dir / 'TileGUI.ini')
        self.version_dir = self.release_dir / str(self.version)

    def trash(self, target_path: Path):
        trashed_path = self.trash_path / target_path.name
        if trashed_path.is_dir():
            timestamp = datetime.now().strftime('%Y-%m-%d %H-%M-%S')
            trashed_path = trashed_path.with_name(f'{trashed_path.name} {timestamp}')
        shutil.move(target_path, trashed_path)

    def build(self):
        if self.version_dir.is_dir():
            remove_ok = input(f'Directory {self.version_dir} already exists! Overwrite? (y/n)')
            if remove_ok != 'y':
                print('Version building aborted!')
                return
            else:
                self.trash(self.version_dir)
                print(f'Existing directory sent to {self.trash_path}!')

        release_path = self.version_dir / self.release_name
        shutil.copytree(self.source_dir, release_path, ignore=shutil.ignore_patterns('*.bin'))
        print(f'Copied loose release files to {release_path}')

        zip_release_path = self.version_dir / f'{self.release_name}-v{self.version}.zip'
        shutil.make_archive(str(zip_release_path.parent / f'{zip_release_path.stem}'), 'zip', self.version_dir, self.release_name)
        print(f'Created .zip release {zip_release_path.name} in {zip_release_path.parent}')
        


if __name__ == '__main__':
    try:
        project = Project()
        project.build()
    except Exception as e:
        print(f'Error:', e)
    print(f'Press eny key to exit')
    input()
