# cppyy-bbhash: cppyy-generated bindings for bbhash

This repository is both a working set of cppyy bindings for
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

# Example Usage

For this repository:

    git clone https://github.com/camillescott/cppyy-bbhash
    cd cppyy-bbhash
    git submodule update --init --recursive

    mkdir build; cd build
    cmake ..
    make

    python setup.py bdist_wheel
    pip install dist/cppyy_bbhash-*.whl

# TODOS

- The CMake code for finding libclang is a bit fragile in conda environments.
- Have CMake produce install commands to invoke setup.py and the pip install.
