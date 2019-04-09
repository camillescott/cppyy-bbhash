# cppyy-bbhash: cppyy-generated bindings for bbhash

[![Build Status](https://travis-ci.org/camillescott/cppyy-bbhash.svg?branch=master)](https://travis-ci.org/camillescott/cppyy-bbhash)

This repository is both a working set of [cppyy](https://bitbucket.org/wlav/cppyy/src/master/) bindings for
[bbhash](https://github.com/rizkg/BBHash) and an example of a CMake
workflow for automatically generating bindings and a python package
with cppyy. Although it is based on the bundled cppyy cmake modules,
it makes a number of improvements and changes:

- `genreflex` and a selection XML are use instead of a direct `rootcling` invocation. This makes
    name selection much easier.
- Python package files are generated using template files. This allows them to be customized for the
    particular library being wrapped.
- The python package is more complete: it includes a MANIFEST, LICENSE, and README; it properly
    recognizes submodules; it includes a tests submodule for bindings tests; it directly copies a
    python module file and directory structure for its pure python code.
- The cppyy initializor routine has basic support for packaging cppyy pythonizors. These are stored
    in the pythonizors/ submodule, in files of the form `pythonize_*.py`. The pythonizor routines
    themselves should be named `pythonize_<NAMESPACE>_*.py`, where `<NAMESPACE>` refers to the
    namespace the pythonizor will be added to in the `cppyy.py.add_pythonization` call. These will
    be automatically found and added by the initializor.

And example of cppyy's bundled cmake support can be found
[here](https://github.com/jclay/cppyy-knearestneighbors-example); there is also a listing of cppyy
example projects in the [cppyy documentation](https://cppyy.readthedocs.io/en/latest/examples.html).

## Repo Structure

- `CMakeLists.txt`: The CMake file for bindings generation.
- `selection.xml`:  The genreflex selection file.
- `interface.hh`:   The interface header used by genreflex. Should include the headers and template
    declarations desired in the bindings.
- `cmake/`: CMake files for the build. Should not need to be modified.
- `pkg_templates/`: Templates for the generated python package. Users can modify the templates to
    their liking; they will be configured and copied into the build and package directory.
- `py/`: Python package structure that will be copied into the generated package. Add any pure
    python code you'd like include in your bindings package here.
- `py/initializor.py`: The cppyy bindings initializor that will be copied in the package. Do not
    delete!

## Example Usage

For this repository with anaconda:

    conda create -n cppyy-example python=3 cmake cxx-compiler c-compiler clangdev libcxx libstdcxx-ng libgcc-ng pytest
    conda activate cppyy-example 
    pip install cppyy clang

    git clone https://github.com/camillescott/cppyy-bbhash
    cd cppyy-bbhash
    git submodule update --init --recursive

    mkdir build; cd build
    cmake ..
    make

    python setup.py bdist_wheel
    pip install dist/cppyy_bbhash-*.whl

And then to test:

    py.test -v cppyy_bbhash/tests/test_bbhash_basic.py

To use this repo as a template for you own bindings, you'll want to modify the selection.xml,
interface.hh, and CMakeLists.txt, as well as swap out the submodule.

## TODOS

- The CMake code for finding libclang is a bit fragile in conda environments.
- Have CMake produce install commands to invoke setup.py and the pip install.
- Create a PyPA package with a script to generate a repo using this this one as a template.
- Use git hash in CMake for versioning.
