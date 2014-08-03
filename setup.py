import sys
from setuptools import setup
from Cython.Build import cythonize

PY2 = sys.version_info[0] == 2

with open('README.rst') as f:
    long_description = f.read()

setup(
    name="Magicmemoryview",
    version="0.1.3",
    author='Cambridge University Spaceflight',
    author_email='contact@cusf.co.uk',
    ext_modules = cythonize("magicmemoryview.pyx", compile_time_env={'PY2': PY2}),
    url='http://github.com/cuspaceflight/magicmemoryview',
    license='GPLv3+',
    description='Magic memoryview() style casting for Cython',
    long_description=long_description,
    install_requires=[
        "Cython",
    ],
    classifiers=[
        'Development Status :: 4 - Beta',
        'License :: OSI Approved :: GNU General Public License v3 or later (GPLv3+)',
        'Programming Language :: Python :: 3.3',
    ],
)
