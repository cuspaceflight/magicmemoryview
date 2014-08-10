import sys
from setuptools import setup, Extension

try:
    from Cython.Build import cythonize

    PY2 = sys.version_info[0] == 2
    ext_modules = cythonize("magicmemoryview.pyx",
                            compile_time_env={'PY2': PY2},
                            force=True)

except ImportError:
    ext_modules = [Extension('magicmemoryview', ['magicmemoryview.c'])]

with open('README.rst') as f:
    long_description = f.read()

setup(
    name="magicmemoryview",
    version="0.1.5",
    author='Cambridge University Spaceflight',
    author_email='contact@cusf.co.uk',
    url='http://github.com/cuspaceflight/magicmemoryview',
    license='GPLv3+',
    description='Magic memoryview() style casting for Cython',
    long_description=long_description,
    ext_modules=ext_modules,
    classifiers=[
        'Development Status :: 4 - Beta',
        'License :: OSI Approved :: GNU General Public License v3 or later (GPLv3+)',
        'Programming Language :: Python :: 3.3',
    ],
)
