# SPDX-FileCopyrightText: 2026 Alberto P
#
# SPDX-License-Identifier: MPL-2.0

import os
from pathlib import Path
import shutil
import subprocess
from setuptools import setup
from setuptools.command.build_py import build_py as _build_py


here = Path(__file__).resolve().parent


class CMakeBuild(_build_py):
    def run(self):
        self.build_cmake()
        super().run()

    def build_cmake(self):
        build_command = self.get_finalized_command("build")
        build_temp = Path(build_command.build_temp)
        build_temp.mkdir(parents=True, exist_ok=True)

        cmake_args = ["cmake", str(here)]

        # On Windows, enforce MinGW Makefiles generator
        if os.name == "nt":
            cmake_args.append('-G')
            cmake_args.append('MinGW Makefiles')

        subprocess.check_call(cmake_args, cwd=build_temp)

        build_args = ["cmake", "--build", ".", "--config", "Release"]
        subprocess.check_call(build_args, cwd=build_temp)

        exe_name = "miescat.exe" if os.name == "nt" else "miescat"
        built_exe = build_temp / "miev" / exe_name
        if not built_exe.exists():
            raise FileNotFoundError(f"Could not find built executable: {built_exe}")

        target_dir = Path(self.build_lib) / "miescat"
        target_dir.mkdir(parents=True, exist_ok=True)
        shutil.copy2(built_exe, target_dir / exe_name)

setup(cmdclass={"build_py": CMakeBuild})
