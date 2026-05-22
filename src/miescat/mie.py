# SPDX-FileCopyrightText: 2026 Alberto P
#
# SPDX-License-Identifier: MPL-2.0

import os
import subprocess
import json
from pathlib import Path
from typing import Tuple, Union


exec_name = "miescat.exe" if os.name == "nt" else "miescat"
DEFAULT_EXECUTABLE = Path(__file__).parent / exec_name


def run_console(program: Path, *args: str) -> Tuple[str, str, int]:
    result = subprocess.run(
        [str(program)] + list(args),
        capture_output=True,
        text=True,
        check=True
    )
    return result.stdout, result.stderr, result.returncode


def compute_mie_scattering(m_real: float,
                           m_img: float,
                           radius: float,
                           wavelength: float,
                           executable: Union[Path, str]=DEFAULT_EXECUTABLE
                           ) -> dict:
    executable_path = Path(executable)
    output, _, _ = run_console(
        executable_path,
        str(m_real),
        str(m_img),
        str(radius),
        str(wavelength),
    )
    return json.loads(output)
