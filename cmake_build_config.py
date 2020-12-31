#!/usr/bin/env python3
"""
@brief  CMake configuration helper
@details
This script was written to have a portable way to perform the CMake configuration with various parameters on
different OSes. It was first written for the Flight Software Framework project.

Run cmake_build_config.py --help to get more information.
"""
import os
import sys
import argparse
import shutil


def main():
    print("-- Python CMake build configurator utility --")

    print("Parsing command line arguments..")
    parser = argparse.ArgumentParser(description="Processing arguments for CMake build configuration.")
    parser.add_argument("-b", "--buildtype", type=str, choices=["debug", "release", "size", "reldeb"],
                        help="CMake build type. Valid arguments: debug, release, size, reldeb "
                             "(Release with Debug Information)", default="debug")
    parser.add_argument("-l", "--builddir", type=str, help="Specify build directory.")
    parser.add_argument("-g", "--generator", type=str, help="CMake Generator")
    parser.add_argument("-p", "--prefix", type=str, help="RTEMS prefix")
    parser.add_argument("-t", "--rtems_bsp", type=str, help="RTEMS BSP")
    parser.add_argument("-d", "--defines",
                        help="Additional custom defines passed to CMake (suply without -D prefix!)",
                        nargs="*", type=str)
    parser.add_argument("-s", "--sources", type=str, help="Filepath of project sources")
    parser.add_argument("-v", "--verbose", help="Verbose CMake build configuration",
                        action="store_true")

    args = parser.parse_args()

    # TODO: make this smarter
    print("Determining source location..")
    if args.sources is None:
        source_location = input("No source location specified. Please supply one: ")
    else:
        source_location = args.sources

    print(f"Source location: {source_location}")

    print("Building cmake configuration command..")

    if args.generator is None:
        generator_cmake_arg = ""
    else:
        generator_cmake_arg = f"-G \"{args.generator}\""

    if args.buildtype == "debug":
        cmake_build_type = "Debug"
    elif args.buildtype == "release":
        cmake_build_type = "Release"
    elif args.buildtype == "size":
        cmake_build_type = "MinSizeRel"
    else:
        cmake_build_type = "RelWithDebInfo"

    if args.rtems_bsp is not None:
        cmake_rtems_bsp = f"-DRTEMS_BSP=\"{args.rtems_bsp}\""
    else:
        print("Error: RTEMS BSP has to be specified!")
        sys.exit(1)

    if args.prefix is not None:
        rtems_prefix_arg = f"-DRTEMS_PREFIX=\"{args.prefix}\""
    else:
        print("Error: RTEMS prefix has to be specified!")
        sys.exit(1)

    rtems_verbose_args = ""
    if args.verbose:
        rtems_verbose_args = f"-DRTEMS_VERBOSE=TRUE"

    define_string = ""
    if args.defines is not None:
        for define in args.defines:
            define_string += f"-D{define} "

    build_folder = cmake_build_type
    if args.builddir is not None:
        build_folder = args.builddir

    build_path = source_location + os.path.sep + build_folder
    if os.path.isdir(build_path):
        remove_old_dir = input(f"{build_folder} folder already exists. Remove old directory? [y/n]: ")
        if str(remove_old_dir).lower() in ["yes", "y", 1]:
            remove_old_dir = True
        else:
            build_folder = determine_new_folder()
            build_path = source_location + os.path.sep + build_folder
            remove_old_dir = False
        if remove_old_dir:
            shutil.rmtree(build_path)
    os.chdir(source_location)
    os.mkdir(build_folder)
    print(f"Navigating into build directory: {build_path}")
    os.chdir(build_folder)

    cmake_command = f"cmake {generator_cmake_arg} -DCMAKE_BUILD_TYPE=\"{cmake_build_type}\" " \
                    f"{cmake_rtems_bsp} {rtems_prefix_arg} {define_string} {rtems_verbose_args} "\
                    f"{source_location}"
    # Remove redundant spaces
    cmake_command = ' '.join(cmake_command.split())
    print("Running CMake command: ")
    print(f"+ {cmake_command}")
    os.system(cmake_command)
    print("-- CMake configuration done. --")


if __name__ == "__main__":
    main()
