# SPDX-FileCopyrightText: 2026 Alberto P
#
# SPDX-License-Identifier: MPL-2.0

cmake_minimum_required(VERSION 3.10)
project(mie_code
    LANGUAGES Fortran
)

find_package(Python REQUIRED COMPONENTS Interpreter)
include(GNUInstallDirs)
enable_testing()

add_executable(miescat
    mieleg.F90
    MIEV0.f
    RDI1MACHmodule.F90
    ErrPack.f
)

set_target_properties(miescat PROPERTIES
  Fortran_MODULE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/modules"
)
target_compile_definitions(miescat PRIVATE
    $<$<CONFIG:Release>:NDEBUG>
)

install(TARGETS miescat
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
install(PROGRAMS ${CMAKE_CURRENT_SOURCE_DIR}/mieleg.py
    DESTINATION ${CMAKE_INSTALL_BINDIR}
    RENAME mieleg
)

add_test(NAME test_mie
    COMMAND miescat 1.3484 0.001 1.0 0.41
)
add_test(NAME test_mie_py
    COMMAND Python::Interpreter ${CMAKE_CURRENT_SOURCE_DIR}/mieleg.py
       --executable ${CMAKE_CURRENT_BINARY_DIR}/miescat
       --m_real 1.3484 --m_img 0.001 --radius 1.0 --wavelength 0.41
)
